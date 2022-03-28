DO_RAMDISK=0
if grep -q 'ramDisk:.*yes' server-setup-config.yaml; then
    SAVE_DIR=$(cat server.properties | grep 'level-name' | awk 'BEGIN {FS="="}{print $2}')
    mv $SAVE_DIR "${SAVE_DIR}_backup"
    mkdir $SAVE_DIR
    sudo mount -t tmpfs -o size=2G tmpfs $SAVE_DIR
    DO_RAMDISK=1
fi

STARTER_JAR="serverstarter-2.1.1.jar"
URL="https://github.com/TeamAOF/ServerStarter/releases/download/v2.1.1/$STARTER_JAR"
if [ -f $STARTER_JAR ]; then
    echo "Skipping download. Using existing $STARTER_JAR"
else
    echo $URL
    which wget >> /dev/null
    if [ $? -eq 0 ]; then
        echo "DEBUG: (wget) Downloading ${URL}"
        wget -O $STARTER_JAR "${URL}"
    else
        which curl >> /dev/null
        if [ $? -eq 0 ]; then
            echo "DEBUG: (curl) Downloading ${URL}"
            curl -L -o $STARTER_JAR "${URL}"
        else
            echo "Neither wget or curl were found on your system. Please install one and try again"
        fi
    fi
fi

java -jar $STARTER_JAR
if [ $DO_RAMDISK -eq 1 ]; then
    sudo umount $SAVE_DIR
    rm -rf $SAVE_DIR
    mv "${SAVE_DIR}_backup" $SAVE_DIR
fi
