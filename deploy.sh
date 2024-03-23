#!/usr/bin/env sh

[ -f .env ] && source .env
[ -z "$REMOTE_PORT" ] && REMOTE_PORT="22"
REMOTE="$REMOTE_HOST:$REMOTE_PATH"

echo "[i] Configured remote is: $REMOTE"

echo "[+] Checking connection to remote"
SSH_OUTPUT=$(ssh -p$REMOTE_PORT $REMOTE_HOST "ls -la $REMOTE_PATH"  2>&1 >/dev/null)
if [ "$?" != "0" ]; then
    echo "[!] Connection error"
    echo "[!]   $SSH_OUTPUT"
    exit 1
fi

echo "[+] Deploying to remote"
rsync -e "ssh -p $REMOTE_PORT" -azv --delete public/ "$REMOTE_HOST:$REMOTE_PATH"

echo "[+] Flush varnish cache for domain"
ssh -p$REMOTE_PORT $REMOTE_HOST "sudo /opt/flush_varnish.sh sdj.pw"
