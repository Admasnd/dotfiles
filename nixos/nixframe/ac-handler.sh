# -e exits on error
# -u exits on undefined variable
# -o pipefail exits on error on a piped command
# help set provides more documentation for set options
# set -eu -o pipefail

LOCK_FILE="/tmp/sleep-inhibitor.lock"

acquire_lock() {
    # If there isn't a lock file or the PID referenced within doesn't exist
    if [ ! -f "$LOCK_FILE" ] || ! kill -0 "$(cat $LOCK_FILE)" 2>/dev/null; then
        # Acquire sleep inhibitor lock via D-Bus
        systemd-inhibit --what=sleep --who="ac-event" \
                        --why="AC power connected" --mode=block \
                                                  sleep infinity &
        echo $! > "$LOCK_FILE"
        echo "Sleep inhibitor lock acquired"
        logger "Power inhibitor: Sleep lock acquired (AC connected)"
    fi
}

release_lock() {
    # If there is a lock file and the PID referenced within is an existing process
    if [ -f "$LOCK_FILE" ] && kill -0 "$(cat $LOCK_FILE)" 2>/dev/null; then
        # Close the file descriptor to release the lock
        if kill "$(cat $LOCK_FILE)" 2>/dev/null; then 
            echo "Sleep inhibitor lock released"
        fi
        rm -f "$LOCK_FILE"
        logger "Power inhibitor: Sleep lock released (AC disconnected)"
    fi
}

if [ "$1" = "1" ]; then               # AC present
    echo "Set performance mode to 'performance'"
    powerprofilesctl set performance
    echo "Inhibit sleep"
    acquire_lock
else                                   # on battery
    echo "Set performance mode to 'power-saver'"
    powerprofilesctl set power-saver
    echo "Remove sleep inhibition"
    release_lock
fi
