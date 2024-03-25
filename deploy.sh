#!/usr/bin/env sh

[ -f .env ] && source .env
[ -z "$REMOTE_PORT" ] && REMOTE_PORT="22"
REMOTE="$REMOTE_HOST:$REMOTE_PATH"
PROJECT="SDJ.PW"

deployment_alert() {
    curl --location "https://discord.com/api/webhooks/$DISCORD_WEBHOOK_ID/$DISCORD_WEBHOOK_TOKEN" \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--data "{
    \"username\": \"Doge\",
    \"avatar_url\": \"https://pngimg.com/d/doge_meme_PNG12.png\",
    \"footer\": {
        \"text\": \"Github Action: $GITHUB_WORKFLOW @ $GITHUB_REPOSITORY\",
        \"icon_url\": \"https://avatars.githubusercontent.com/u/68156353?s=48&v=4\"
    },
    \"embeds\": [{
      \"title\": \"$1\",
      \"color\": $2,
      \"fields\": [
        {
            \"name\": \"Hostname\",
            \"value\": \"$REMOTE_HOST\",
            \"inline\": true
        },
        {
            \"name\": \"Environment\",
            \"value\": \"$GITHUB_REF_NAME\",
            \"inline\": true
        },
        {
            \"name\": \"Triggered BY\",
            \"value\": \"$GITHUB_ACTOR\",
            \"inline\": true
        },
        {
            \"name\": \"Commit\",
            \"value\": \"$GITHUB_SHA\"
        },
        {
            \"name\": \"Links\",
            \"value\": \"Workflow Link - Commit Link - Deployment Link\"
        }
      ]
    }]
}"
}

trap "deployment_alert \"❌ [$PROJECT] Failed Deployment\" \"16711680\" && exit 255" ERR

echo "[i] Configured remote is: $REMOTE"

deployment_alert "ℹ️ [$PROJECT] Starting Deployment" "43775"

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

echo "[+] Flushing Cloudflare Cache"
curl --request POST \
    --url https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_CACHE_ZONE/purge_cache \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $CLOUDFLARE_CACHE_TOKEN" \
    --data '{"purge_everything": true}'

deployment_alert "✅ [$PROJECT] Completed Deployment" "2876424"