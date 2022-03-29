#!/bin/sh
DO_RAMDISK=0
if grep -q 'ramDisk:.*yes' server-setup-config.yaml; then
    SAVE_DIR=$(awk -F '=' '/level-name/ {print $2}' server.properties)
    echo "Replacing $SAVE_DIR with a ramdisk"
    mv "$SAVE_DIR" "${SAVE_DIR}_backup"
    mkdir "$SAVE_DIR"
    sudo mount -t tmpfs -o size=2G tmpfs "$SAVE_DIR"
    DO_RAMDISK=1
fi

STARTER_VERSION="2.1.1"
STARTER_JAR="serverstarter-$STARTER_VERSION.jar"
URL="https://github.com/TeamAOF/ServerStarter/releases/download/v$STARTER_VERSION/$STARTER_JAR"
if [ -f $STARTER_JAR ]; then
    echo "Skipping download. Using existing $STARTER_JAR"
else
    echo "Downloading $URL..."
    if which wget >/dev/null 2>&1; then
        echo "DEBUG: (wget)"
        wget -O $STARTER_JAR "${URL}"
    elif which curl >/dev/null 2>&1; then
        echo "DEBUG: (curl)"
        curl -L -o $STARTER_JAR "${URL}"
    else
        echo "Neither wget or curl were found on your system. Please install one and try again"
    fi
fi

echo "Running $STARTER_JAR"
java -jar $STARTER_JAR

if [ $DO_RAMDISK -eq 1 ]; then
    echo "Restoring $SAVE_DIR"
    sudo umount "$SAVE_DIR"
    rm -rf "$SAVE_DIR"
    mv "${SAVE_DIR}_backup" "$SAVE_DIR"
fi
