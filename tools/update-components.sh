#/bin/bash

source ./tools/config.sh

#
# CLONE/UPDATE TINYUSB
#
echo "Updating TinyUSB..."
TINYUSB_REPO_URL="https://github.com/hathach/tinyusb.git"
TINYUSB_REPO_DIR="$AR_COMPS/arduino_tinyusb/tinyusb"
if [ ! -d "$TINYUSB_REPO_DIR" ]; then
    git clone "$TINYUSB_REPO_URL" "$TINYUSB_REPO_DIR"
else
    git -C "$TINYUSB_REPO_DIR" fetch && \
    git -C "$TINYUSB_REPO_DIR" pull --ff-only
fi
if [ $? -ne 0 ]; then exit 1; fi

# SlicklinePro fork: pin TinyUSB.
#
# Upstream tracks master with no pin at all, so what you get depends on the day
# you build. Today's master has moved src/device/usbd_control.c, and the build
# dies with "No SOURCES given to target: __idf_arduino_tinyusb" - nothing to do
# with this project's changes.
#
# This is the commit recorded in versions.txt of the esp32s3-libs 3.3.7 package
# the unit is actually running, so the output matches what is installed.
if [ -n "$TINYUSB_COMMIT" ]; then
    echo "Pinning TinyUSB to $TINYUSB_COMMIT"
    git -C "$TINYUSB_REPO_DIR" fetch origin "$TINYUSB_COMMIT" || true
    git -C "$TINYUSB_REPO_DIR" checkout --detach "$TINYUSB_COMMIT" || {
        echo "::error::could not check out TinyUSB $TINYUSB_COMMIT"
        exit 1
    }
    git -C "$TINYUSB_REPO_DIR" --no-pager log --oneline -1
fi
