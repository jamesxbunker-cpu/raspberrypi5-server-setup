# Pi Website Updater

This repository provides an automated solution for keeping your Raspberry Pi's website synchronized with a GitHub repository.

## What This Does

- Automatically checks for updates to your website every 5 minutes
- Pulls the latest changes when detected
- Reloads Nginx to serve the updated files
- Logs all activity for troubleshooting

## Installation

### 1. Clone This Repository

```bash
git clone https://github.com/jamesxbunker-cpu/raspberrypi5-server-setup.git
cd raspberrypi5-server-setup