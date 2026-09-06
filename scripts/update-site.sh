#!/bin/bash

# Define the path to your website repository
SITE_PATH="/var/www/geosmin"

echo "$(date): Checking for updates..." >> /var/log/update-site.log

# Navigate to the site directory
cd $SITE_PATH || exit 1

# Fetch the latest changes from the remote repository
git fetch origin

# Check if the local branch is behind the remote branch
if [ $(git rev-list HEAD...origin/main --count) -gt 0 ]; then
    echo "$(date): Changes detected! Pulling latest code..." >> /var/log/update-site.log

    # Pull the latest changes
    git pull origin main

    # Reload Nginx to ensure the latest files are being served
    sudo systemctl reload nginx

    echo "$(date): Site updated and Nginx reloaded." >> /var/log/update-site.log
else
    echo "$(date): No changes detected." >> /var/log/update-site.log
fi