#!/bin/bash

SITE_PATH="/var/www/geosmin/Geosmin"
REPO_URL="https://github.com/jamesxbunker-cpu/Geosmin"
BRANCH="main"
LOG_FILE="/var/log/update-site.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> $LOG_FILE
}

log_message "========================================="
log_message "Checking for updates..."

# Check if site directory exists
if [ ! -d "$SITE_PATH" ]; then
    log_message "ERROR: Site directory $SITE_PATH does not exist."
    log_message "Attempting to clone repository..."
    
    sudo git clone $REPO_URL $SITE_PATH
    
    if [ $? -eq 0 ]; then
        log_message "Repository cloned successfully."
        sudo chown -R $USER:$USER $SITE_PATH
        sudo chmod -R 755 $SITE_PATH
        sudo systemctl reload nginx
        log_message "Nginx reloaded after initial clone."
    else
        log_message "ERROR: Failed to clone repository."
        exit 1
    fi
fi

# Navigate to the site directory
cd $SITE_PATH || exit 1

# Ensure .git directory has correct permissions
sudo chown -R $USER:$USER .git 2>/dev/null

# Fetch the latest changes
if ! git fetch origin; then
    log_message "ERROR: Git fetch failed."
    exit 1
fi

# Check if local branch is behind remote
LOCAL_COMMIT=$(git rev-parse HEAD 2>/dev/null)
REMOTE_COMMIT=$(git rev-parse origin/$BRANCH 2>/dev/null)

if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
    log_message "Changes detected! Pulling latest code..."
    
    # Stash any local changes
    git stash --include-untracked 2>/dev/null
    log_message "Stashed local changes."
    
    # Pull the latest changes
    if git pull origin $BRANCH; then
        log_message "Pull successful."
        
        # Set permissions
        sudo chown -R $USER:$USER $SITE_PATH
        sudo chmod -R 755 $SITE_PATH
        
        # Reload Nginx
        sudo systemctl reload nginx
        log_message "Nginx reloaded."
    else
        log_message "ERROR: Git pull failed."
        # Try to recover from stash
        git stash pop 2>/dev/null
        exit 1
    fi
else
    log_message "No changes detected."
fi

log_message "Update check complete."
log_message "========================================="
