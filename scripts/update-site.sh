#!/bin/bash

SITE_PATH="/var/www/geosmin/Geosmin"
REPO_URL="https://github.com/jamesxbunker-cpu/Geosmin"
BRANCH="main"
LOG_FILE="/var/log/update-site.log"
GIT="/usr/bin/git"
SUDO="/usr/bin/sudo"
CHOWN="/usr/bin/chown"
CHMOD="/usr/bin/chmod"
SYSTEMCTL="/usr/bin/systemctl"

# Add repository as safe directory for Git
$GIT config --global --add safe.directory $SITE_PATH 2>/dev/null
$SUDO $GIT config --global --add safe.directory $SITE_PATH 2>/dev/null

# Ensure log file is writable
if [ ! -w "$LOG_FILE" ]; then
    $SUDO $CHOWN $USER:$USER $LOG_FILE 2>/dev/null
    $SUDO $CHMOD 644 $LOG_FILE 2>/dev/null
fi

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> $LOG_FILE
}

log_message "========================================="
log_message "Checking for updates..."

if [ ! -d "$SITE_PATH" ]; then
    log_message "ERROR: Site directory $SITE_PATH does not exist."
    exit 1
fi

cd $SITE_PATH || exit 1

# Force permissions before any git operations
$SUDO $CHOWN -R $USER:$USER .git 2>/dev/null
$SUDO $CHMOD -R 755 .git 2>/dev/null

if ! $GIT fetch origin 2>&1 | tee -a $LOG_FILE; then
    log_message "ERROR: Git fetch failed."
    exit 1
fi

LOCAL_COMMIT=$($GIT rev-parse HEAD 2>/dev/null)
REMOTE_COMMIT=$($GIT rev-parse origin/$BRANCH 2>/dev/null)

if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
    log_message "Changes detected! Pulling latest code..."
    
    $GIT stash --include-untracked 2>&1 | tee -a $LOG_FILE
    log_message "Stashed local changes."
    
    if $GIT pull origin $BRANCH 2>&1 | tee -a $LOG_FILE; then
        log_message "Pull successful."
        $SUDO $CHOWN -R $USER:$USER $SITE_PATH
        $SUDO $CHMOD -R 755 $SITE_PATH
        $SUDO $SYSTEMCTL reload nginx
        log_message "Nginx reloaded."
    else
        log_message "ERROR: Git pull failed."
        $GIT stash pop 2>/dev/null
        exit 1
    fi
else
    log_message "No changes detected."
fi

log_message "Update check complete."
log_message "========================================="
