#!/bin/bash

install_packages () {
    read -p "Do you have a new packages:y(Yes) " WILL_INSTALL
    if [ "$WILL_INSTALL" == "y" ] || [ "$WILL_INSTALL" == "Y" ]; then
        npm install
    fi
}

restart_server () {
    echo "Restarting process manager..."
    pm2 restart 0;
}

update_frontend () {
    read -p "Enter the BACKEND directory: " FRONTEND
    FRONTEND_DIR="$HOME$FRONTEND"
    if [ -d "$FRONTEND_DIR" ]; then
        echo "Updating frontend..."
        cd "$FRONTEND_DIR" || exit;
        git pull origin develop;
        install_packages
        npm run build
        echo "Frontend done."
    else
        echo "Error: dir: $FRONTEND_DIR does not exits"
    fi
}

update_backend () {
    read -p "Enter the BACKEND directory: " BACKEND
    BACKEND_DIR="$HOME$BACKEND"
    if [ -d "$BACKEND_DIR" ]; then
        echo "Updating backend..."
        cd "$BACKEND_DIR" || exit;
        git pull origin develop;
        install_packages
        echo "Backend done."
    else
        echo "Error: dir: $BACKEND_DIR does not exits"
    fi
}

read -p "Enter the SSH key name: " SSH_KEY_NAME
KEY_NAME="$HOME/.ssh/${SSH_KEY_NAME}"
if [ -s "$KEY_NAME" ]; then
    is_restart="no"
    
    echo "Project directories look fine."
    echo "Refleshing SSH keys..."
    eval $(ssh-agent);
    ssh-add;
    ssh-add "$KEY_NAME";
    
    read -p "Which update do you want to make?b(Backend), f(frontend), Otherwise all: " APP_TO_CHANGE
    
    if [ "$APP_TO_CHANGE" == "b" ] || [ "$APP_TO_CHANGE" == "B" ]; then
        update_backend
        is_restart="yes"
    elif [ "$APP_TO_CHANGE" == "f" ] || [ "$APP_TO_CHANGE" == "F" ];
    then
        update_frontend
    else
        update_backend
        update_frontend
        is_restart="yes"
    fi
    if [ "$is_restart" == "yes" ]; then
        echo "Restarting process manager..."
        pm2 restart 0;
    fi
else
    echo "Error: key: the provided key does not exits"
fi
