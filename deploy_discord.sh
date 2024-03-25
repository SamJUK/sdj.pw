#!/usr/bin/env sh

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