#!/bin/sh
DO_RAMDISK=0
if grep -q 'ramDisk:.*yes' server-setup-config.yaml; then
    SAVE_DIR=$(awk -F '=' '/level-name/ {print $2}' server.properties)
    mv "$SAVE_DIR" "${SAVE_DIR}_backup"
    mkdir "$SAVE_DIR"
    sudo mount -t tmpfs -o size=2G tmpfs "$SAVE_DIR"
    DO_RAMDISK=1
fi

STARTER_JAR="serverstarter-2.1.1.jar"
URL="https://github.com/TeamAOF/ServerStarter/releases/download/v2.1.1/$STARTER_JAR"
if [ -f $STARTER_JAR ]; then
    echo "Skipping download. Using existing $STARTER_JAR"
else
    echo $URL
    if which wget >/dev/null 2>&1; then
        echo "DEBUG: (wget) Downloading ${URL}"
        wget -O $STARTER_JAR "${URL}"
    elif which curl >/dev/null 2>&1; then
        echo "DEBUG: (curl) Downloading ${URL}"
        curl -L -o $STARTER_JAR "${URL}"
    else
        echo "Neither wget or curl were found on your system. Please install one and try again"
    fi
fi

java -jar $STARTER_JAR
if [ $DO_RAMDISK -eq 1 ]; then
    sudo umount "$SAVE_DIR"
    rm -rf "$SAVE_DIR"
    mv "${SAVE_DIR}_backup" "$SAVE_DIR"
fi
