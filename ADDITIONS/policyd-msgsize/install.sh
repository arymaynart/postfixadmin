#!/usr/bin/env bash
set -euo pipefail

# Installer for policyd-msgsize (Postfix per-mailbox / per-domain message size policy daemon)
# Usage: sudo bash install.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_USER="policyd-msgsize"
VENV_DIR="/opt/policyd-msgsize/venv"
BIN_DEST="/usr/local/bin/policyd_msgsize.py"
UNIT_DEST="/etc/systemd/system/policyd-msgsize.service"
ENV_DEST="/etc/policyd-msgsize.env"

if [[ "$(id -u)" -ne 0 ]]; then
    echo "ERROR: Please run as root (e.g. sudo bash install.sh)." >&2
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: python3 is required. Install python3 and python3-venv first." >&2
    exit 1
fi

echo "[1/6] Ensuring dedicated system user '${SERVICE_USER}' exists..."
if ! id -u "${SERVICE_USER}" >/dev/null 2>&1; then
    useradd --system --no-create-home --shell /usr/sbin/nologin "${SERVICE_USER}"
fi

echo "[2/6] Creating isolated Python virtual environment at ${VENV_DIR}..."
if ! python3 -m venv --help >/dev/null 2>&1; then
    echo "ERROR: python3-venv module is missing. Install python3-venv first." >&2
    exit 1
fi
install -d -m 0750 -o root -g "${SERVICE_USER}" /opt/policyd-msgsize
if [[ ! -x "${VENV_DIR}/bin/python3" ]]; then
    python3 -m venv "${VENV_DIR}"
fi
"${VENV_DIR}/bin/pip" install --upgrade pip >/dev/null
"${VENV_DIR}/bin/pip" install -r "${SCRIPT_DIR}/requirements.txt"
chown -R root:"${SERVICE_USER}" /opt/policyd-msgsize
chmod -R g+rX,o-rwx /opt/policyd-msgsize

echo "[3/6] Installing ${BIN_DEST}..."
install -m 0755 -o root -g root "${SCRIPT_DIR}/policyd_msgsize.py" "${BIN_DEST}"

echo "[4/6] Preparing ${ENV_DEST}..."
if [[ ! -f "${ENV_DEST}" ]]; then
    install -m 0640 -o root -g "${SERVICE_USER}" "${SCRIPT_DIR}/policyd-msgsize.env.example" "${ENV_DEST}"
    echo "NOTE: Created ${ENV_DEST} from template. Edit DB_HOST/DB_NAME/DB_USER/DB_PASS before starting!"
else
    chown root:"${SERVICE_USER}" "${ENV_DEST}"
    chmod 0640 "${ENV_DEST}"
    echo "Keeping existing ${ENV_DEST} (permissions verified: 0640 root:${SERVICE_USER})."
fi

echo "[5/6] Installing systemd service ${UNIT_DEST}..."
install -m 0644 -o root -g root "${SCRIPT_DIR}/policyd-msgsize.service" "${UNIT_DEST}"
systemctl daemon-reload
systemctl enable policyd-msgsize.service

echo "[6/6] Checking credentials before starting service..."
if grep -q '^DB_PASS=CHANGE_ME$' "${ENV_DEST}"; then
    echo ""
    echo "Installation complete, service NOT started yet because DB_PASS is still CHANGE_ME."
    echo "Next steps:"
    echo "  1. Edit ${ENV_DEST} with your read-only PostfixAdmin DB credentials."
    echo "  2. Run: systemctl restart policyd-msgsize && systemctl status policyd-msgsize"
    echo "  3. Configure /etc/postfix/main.cf as documented in ${SCRIPT_DIR}/README.md."
else
    systemctl restart policyd-msgsize.service
    systemctl --no-pager --full status policyd-msgsize.service | head -n 15
    echo ""
    echo "Installation complete and policyd-msgsize is running."
fi
