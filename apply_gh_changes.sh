#!/bin/bash
read -p "Enter the BACKEND directory: " BACKEND
read -p "Enter the FRONTEND directory: " FRONTEND
read -p "Enter the SSH key name: " SSH_KEY_NAME
HOME_DIR="/home/$USER/"
BACKEND_DIR="$HOME_DIR$BACKEND"
FRONTEND_DIR="$HOME_DIR$FRONTEND"
KEY_NAME="${HOME_DIR}.ssh/${SSH_KEY_NAME}"
if [ -d "$BACKEND_DIR" ] && [ -d "$FRONTEND_DIR" ] && [ -s "$KEY_NAME" ]
then
    echo "Project directories look fine."
    echo "Refleshing SSH keys..."
    eval $(ssh-agent);
    ssh-add;
    ssh-add $KEY_NAME;
    cd $BACKEND_DIR;
    git pull origin develop;
    cd $FRONTEND_DIR;
    git pull origin develop;
    npm install
    npm run build
    echo "Restarting process manager..."
    pm2 restart 0;
    echo "You did a great job, Now go back to work";
else
    echo "Error: dir: $BACKEND_DIR or $FRONTEND_DIR does not exits"
fi