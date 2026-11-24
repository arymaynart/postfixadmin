#!/opt/policyd-msgsize/venv/bin/python3
# /usr/local/bin/policyd_msgsize.py
# Policy daemon for Postfix: enforces per-user and per-domain max message size stored in PostfixAdmin DB.
# Supports RCPT (early reject via ESMTP SIZE + per-instance limit tracking) and END-OF-MESSAGE (actual size).
# Credentials order: Environment variables (EnvironmentFile=/etc/policyd-msgsize.env) -> DBCONFIG_PATH fallback.
# Requires: python3, PyMySQL

import os
import re
import socketserver
import sys
import threading
import time
import pymysql

DB_HOST = 'localhost'
DB_NAME = 'postfixadmin'
DB_USER = 'postfixadmin'
DB_PASS = 'CHANGE_ME'
DBCONFIG_PATH = os.environ.get('DBCONFIG_PATH', '/etc/postfixadmin/dbconfig.inc.php').strip()
LISTEN_HOST = os.environ.get('LISTEN_HOST', '127.0.0.1').strip() or '127.0.0.1'
LISTEN_PORT = int(os.environ.get('LISTEN_PORT', '10031'))
DB_TIMEOUT = int(os.environ.get('DB_TIMEOUT', '5'))
SOCKET_TIMEOUT = int(os.environ.get('SOCKET_TIMEOUT', '10'))
QUOTA_MULTIPLIER = int(os.environ.get('QUOTA_MULTIPLIER', '1024000'))
INSTANCE_TTL = 600
INSTANCE_MAX_ENTRIES = 5000
MAX_CONCURRENT_REQUESTS = int(os.environ.get('MAX_CONCURRENT_REQUESTS', '64'))
MAX_ATTRS_PER_REQUEST = 128

_INSTANCE_LOCK = threading.Lock()
_INSTANCE_LIMITS = {}   # instance_id -> (min_limit_bytes, monotonic_ts)
_REQUEST_SEMAPHORE = threading.BoundedSemaphore(max(1, MAX_CONCURRENT_REQUESTS))


def _load_dbconfig():
    global DB_HOST, DB_NAME, DB_USER, DB_PASS

    # 1. Highest priority: environment variables (e.g. EnvironmentFile=/etc/policyd-msgsize.env)
    env_host = os.environ.get('DB_HOST', '').strip()
    env_name = os.environ.get('DB_NAME', '').strip()
    env_user = os.environ.get('DB_USER', '').strip()
    env_pass = os.environ.get('DB_PASS', '').strip()
    if env_host:
        DB_HOST = env_host
    if env_name:
        DB_NAME = env_name
    if env_user:
        DB_USER = env_user
    if env_pass:
        DB_PASS = env_pass
        return

    # 2. Fallback: parse Debian/Ubuntu dbconfig.inc.php if readable by the daemon user
    if DB_PASS != 'CHANGE_ME' or not DBCONFIG_PATH or not os.path.isfile(DBCONFIG_PATH):
        return
    try:
        with open(DBCONFIG_PATH, 'r', encoding='utf-8', errors='ignore') as f:
            txt = f.read()
        m_user = re.search(r"\$dbuser\s*=\s*'([^']+)'", txt)
        m_pass = re.search(r"\$dbpass\s*=\s*'([^']+)'", txt)
        m_name = re.search(r"\$dbname\s*=\s*'([^']+)'", txt)
        m_host = re.search(r"\$dbserver\s*=\s*'([^']+)'", txt)
        if m_user:
            DB_USER = m_user.group(1)
        if m_pass:
            DB_PASS = m_pass.group(1)
        if m_name:
            DB_NAME = m_name.group(1)
        if m_host and m_host.group(1):
            DB_HOST = m_host.group(1)
    except Exception as e:
        sys.stderr.write("policy: warning loading dbconfig.inc.php: %s\n" % (str(e),))


_load_dbconfig()


def _prune_instances_locked(now):
    expired = [k for k, (_, ts) in _INSTANCE_LIMITS.items() if (now - ts) > INSTANCE_TTL]
    for k in expired:
        del _INSTANCE_LIMITS[k]
    if len(_INSTANCE_LIMITS) > INSTANCE_MAX_ENTRIES:
        oldest = sorted(_INSTANCE_LIMITS.items(), key=lambda kv: kv[1][1])
        for k, _ in oldest[:len(_INSTANCE_LIMITS) - INSTANCE_MAX_ENTRIES]:
            del _INSTANCE_LIMITS[k]


def _record_instance_limit(instance, limit):
    if not instance or limit <= 0:
        return
    now = time.monotonic()
    with _INSTANCE_LOCK:
        _prune_instances_locked(now)
        prev = _INSTANCE_LIMITS.get(instance)
        if prev is None or limit < prev[0]:
            _INSTANCE_LIMITS[instance] = (limit, now)
        else:
            _INSTANCE_LIMITS[instance] = (prev[0], now)


def _pop_instance_limit(instance):
    if not instance:
        return 0
    now = time.monotonic()
    with _INSTANCE_LOCK:
        entry = _INSTANCE_LIMITS.pop(instance, None)
    if entry is None or (now - entry[1]) > INSTANCE_TTL:
        return 0
    return entry[0]


def _normalize_recipient(recipient):
    """
    Lowercase recipient and strip Postfix recipient_delimiter (+tag) for mailbox lookup.
    Returns (exact_recipient, base_recipient, domain).
    """
    rcpt = recipient.strip().lower()
    if '@' not in rcpt:
        return rcpt, rcpt, ''
    local_part, domain = rcpt.rsplit('@', 1)
    base_local = local_part.split('+', 1)[0] if '+' in local_part else local_part
    base_rcpt = f"{base_local}@{domain}" if base_local else rcpt
    return rcpt, base_rcpt, domain


def fetch_limit_bytes(recipient, dbconn):
    exact_rcpt, base_rcpt, domain = _normalize_recipient(recipient)
    if not domain:
        return 0
    with dbconn.cursor() as cur:
        # 1. Check mailbox (exact match or base match without +tag)
        #    -1 = unlimited (bypass domain limit; Postfix global message_size_limit still applies)
        #     0 = inherit from domain
        #   > 0 = specific mailbox limit in bytes
        cur.execute("SELECT max_msg_mailsize FROM mailbox WHERE username=%s LIMIT 1", (exact_rcpt,))
        r = cur.fetchone()
        if (not r or r[0] is None or int(r[0]) == 0) and base_rcpt != exact_rcpt:
            cur.execute("SELECT max_msg_mailsize FROM mailbox WHERE username=%s LIMIT 1", (base_rcpt,))
            r = cur.fetchone()
        if r and r[0] is not None:
            mb_limit = int(r[0])
            if mb_limit < 0:
                return -1
            if mb_limit > 0:
                return mb_limit

        # 2. Fallback to domain limit (-1 or 0 = no domain limit -> DUNNO / Postfix global limit)
        cur.execute("SELECT max_domain_msg_mailsize FROM domain WHERE domain=%s LIMIT 1", (domain,))
        r2 = cur.fetchone()
        if r2 and r2[0] is not None:
            dom_limit = int(r2[0])
            if dom_limit > 0:
                return dom_limit
    return 0


class PolicyHandler(socketserver.StreamRequestHandler):
    def handle(self):
        self.request.settimeout(SOCKET_TIMEOUT)
        while True:
            data = {}
            eof = False
            while True:
                try:
                    raw_line = self.rfile.readline(4096)
                except Exception:
                    return
                if not raw_line:
                    eof = True
                    break
                line = raw_line.decode('utf-8', errors='ignore').strip()
                if line == '':
                    break
                if len(data) < MAX_ATTRS_PER_REQUEST and '=' in line:
                    k, v = line.split('=', 1)
                    data[k.strip()] = v.strip()

            if not data:
                if eof:
                    break
                continue

            recipient = data.get('recipient', '').strip()
            instance = data.get('instance', '').strip()
            state = data.get('protocol_state', '').strip().upper()
            try:
                size = int(data.get('size', '0'))
            except Exception:
                size = 0

            limit = 0
            if recipient:
                acquired = _REQUEST_SEMAPHORE.acquire(timeout=DB_TIMEOUT)
                if not acquired:
                    sys.stderr.write("policy: concurrency limit reached (%d); failing open\n" % (MAX_CONCURRENT_REQUESTS,))
                    self.wfile.write(b"action=DUNNO\n\n")
                    self.wfile.flush()
                    if eof:
                        break
                    continue
                try:
                    dbconn = pymysql.connect(
                        host=DB_HOST,
                        user=DB_USER,
                        password=DB_PASS,
                        db=DB_NAME,
                        connect_timeout=DB_TIMEOUT,
                        read_timeout=DB_TIMEOUT,
                        charset='utf8mb4',
                        cursorclass=pymysql.cursors.Cursor,
                        autocommit=True,
                    )
                    try:
                        limit = fetch_limit_bytes(recipient, dbconn)
                    finally:
                        dbconn.close()
                except Exception as e:
                    sys.stderr.write("policy: DB error: %s\n" % (str(e),))
                    self.wfile.write(b"action=DUNNO\n\n")
                    self.wfile.flush()
                    if eof:
                        break
                    continue
                finally:
                    _REQUEST_SEMAPHORE.release()

            if state == 'END-OF-MESSAGE':
                cached_limit = _pop_instance_limit(instance)
                if cached_limit > 0 and (limit <= 0 or cached_limit < limit):
                    limit = cached_limit

            if size > 0 and limit > 0 and size > limit:
                limit_mb = max(1, int(round(float(limit) / float(QUOTA_MULTIPLIER))))
                resp = "action=REJECT 5.3.4 Message too large; recipient limit is %d MB\n\n" % (limit_mb,)
                self.wfile.write(resp.encode('utf-8'))
                self.wfile.flush()
            else:
                if state == 'RCPT' and limit > 0 and instance:
                    _record_instance_limit(instance, limit)
                self.wfile.write(b"action=DUNNO\n\n")
                self.wfile.flush()

            if eof:
                break


class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True
    daemon_threads = True


if __name__ == "__main__":
    server = ThreadedTCPServer((LISTEN_HOST, LISTEN_PORT), PolicyHandler)
    print("policyd_msgsize listening on %s:%d" % (LISTEN_HOST, LISTEN_PORT))
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()
