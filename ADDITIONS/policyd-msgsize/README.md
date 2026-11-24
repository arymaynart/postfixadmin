# policyd-msgsize — Per-Mailbox & Per-Domain Message Size Policy Daemon

`policyd-msgsize` is a lightweight, multithreaded Postfix SMTP access policy delegation daemon written in Python 3 (`PyMySQL`). It enforces per-mailbox (`mailbox.max_msg_mailsize`) and per-domain (`domain.max_domain_msg_mailsize`) message size limits configured directly inside PostfixAdmin.

## Limit Resolution Rules (3-State Logic)

Values are stored in bytes in the database (`BIGINT NOT NULL DEFAULT 0`), and edited in **MB** in the PostfixAdmin UI (multiplied by `$CONF['quota_multiplier']`, default `1024000`):

| `mailbox.max_msg_mailsize` | `domain.max_domain_msg_mailsize` | Effective Limit |
|---|---|---|
| `> 0` (e.g. `50` MB) | any | **Mailbox limit (`50 MB`)** |
| `-1` (unlimited) | any | **Bypass domain limit** (Postfix global `message_size_limit` still applies) |
| `0` (inherit) | `> 0` (e.g. `30` MB) | **Domain limit (`30 MB`)** |
| `0` (inherit) | `0` or `-1` | **No policy limit (`DUNNO`)** — Postfix global `message_size_limit` applies |

### Additional Features
- **Early + Final Enforcement:** Checks declared ESMTP `SIZE=` during `RCPT TO` **and** actual message size during `END-OF-MESSAGE` (tracking the strictest recipient limit per Postfix `instance=` across multi-recipient messages).
- **Subaddressing (`+tag`) Support:** Strips `+tag` (Postfix `recipient_delimiter`) when looking up `mailbox.username`.
- **Fail-Open on DB Error:** Returns `action=DUNNO` and logs to `stderr`/`journald` so mail delivery is never blocked by transient DB hiccups.
- **Hardened systemd Unit:** Runs unprivileged as `policyd-msgsize`, isolated in `/opt/policyd-msgsize/venv` (PEP 668 compatible on Debian 12+ / Ubuntu 24.04+), reading DB credentials from `/etc/policyd-msgsize.env` (`0640 root:policyd-msgsize`).

---

## 1. Database Schema

Run PostfixAdmin's web upgrader (`/setup.php` or `/upgrade.php`) which executes `upgrade_1853()`, **or** apply manually on MySQL/MariaDB:

```sql
ALTER TABLE mailbox
    ADD COLUMN max_msg_mailsize BIGINT NOT NULL DEFAULT 0 AFTER quota;

ALTER TABLE domain
    ADD COLUMN max_domain_msg_mailsize BIGINT NOT NULL DEFAULT 0 AFTER maxquota;
```

### Recommended Read-Only MySQL User

```sql
CREATE USER 'policyd_ro'@'127.0.0.1' IDENTIFIED BY 'STRONG_RANDOM_PASSWORD';
GRANT SELECT (username, max_msg_mailsize) ON postfixadmin.mailbox TO 'policyd_ro'@'127.0.0.1';
GRANT SELECT (domain, max_domain_msg_mailsize) ON postfixadmin.domain TO 'policyd_ro'@'127.0.0.1';
FLUSH PRIVILEGES;
```

---

## 2. Daemon Installation

Ensure `python3-venv` is installed (`apt install python3-venv`), then run:

```bash
cd /var/www/postfixadmin/ADDITIONS/policyd-msgsize
sudo bash install.sh
```

Edit `/etc/policyd-msgsize.env` with your database credentials:

```ini
DB_HOST=127.0.0.1
DB_NAME=postfixadmin
DB_USER=policyd_ro
DB_PASS=STRONG_RANDOM_PASSWORD
LISTEN_HOST=127.0.0.1
LISTEN_PORT=10031
QUOTA_MULTIPLIER=1024000
```

Start and verify the service:

```bash
sudo systemctl restart policyd-msgsize
sudo systemctl status policyd-msgsize
ss -tlnp | grep 10031
```

---

## 3. Postfix Configuration (`/etc/postfix/main.cf`)

1. Set the global hard ceiling (`message_size_limit`) high enough to accommodate your largest mailbox override (e.g., `100 MB` = `104857600` bytes):

```ini
message_size_limit = 104857600
```

2. Add `check_policy_service inet:127.0.0.1:10031` to **both** `smtpd_recipient_restrictions` (early reject on ESMTP `SIZE=`) and `smtpd_end_of_data_restrictions` (authoritative reject when client omits `SIZE=` or sends more bytes than declared):

```ini
smtpd_recipient_restrictions =
    permit_mynetworks,
    permit_sasl_authenticated,
    reject_unauth_destination,
    check_policy_service inet:127.0.0.1:10031

smtpd_end_of_data_restrictions =
    check_policy_service inet:127.0.0.1:10031
```

> **Note:** If you also want authenticated submission users (`587`/`465`) to be checked against recipient limits, either place `check_policy_service inet:127.0.0.1:10031` *before* `permit_sasl_authenticated` in `smtpd_recipient_restrictions` or rely on `smtpd_end_of_data_restrictions` (which runs after `DATA` for all sessions unless overridden in `master.cf`).

3. Validate and reload Postfix:

```bash
sudo postfix check
sudo systemctl reload postfix
```

---

## 4. Smoke Test

Test directly against the policy socket (adjust recipient and byte size to match a real mailbox/domain):

```bash
# 1) Simulate RCPT with 60 MB message (should REJECT if recipient limit < 60 MB)
printf 'request=smtpd_access_policy\nprotocol_state=RCPT\ninstance=test-001\nrecipient=user@example.com\nsize=62914560\n\n' \
  | nc -w 3 127.0.0.1 10031

# 2) Simulate RCPT without SIZE followed by END-OF-MESSAGE with 60 MB
printf 'request=smtpd_access_policy\nprotocol_state=RCPT\ninstance=test-002\nrecipient=user@example.com\nsize=0\n\nrequest=smtpd_access_policy\nprotocol_state=END-OF-MESSAGE\ninstance=test-002\nsize=62914560\n\n' \
  | nc -w 3 127.0.0.1 10031
```

Expected responses:
- Under limit or `-1` (unlimited): `action=DUNNO`
- Over limit: `action=REJECT 5.3.4 Message too large; recipient limit is <N> MB`
