#!/bin/bash

echo "Giving ES time to start..."
until curl -sS "http://$ES_HOST:$ES_PORT/_cluster/health?wait_for_status=yellow"
do
    echo "Waiting for ES to start"
    sleep 1
done
echo

if [ ! -f $MOLOCHDIR/etc/.initialized ]; then
    echo $MOLOCH_VERSION > $MOLOCHDIR/etc/.initialized
    $MOLOCHDIR/bin/Configure
    echo INIT | $MOLOCHDIR/db/db.pl http://$ES_HOST:$ES_PORT init
    $MOLOCHDIR/bin/moloch_add_user.sh admin "Admin User" $MOLOCH_ADMIN_PASSWORD --admin
else
    # possible update
    read old_ver < $MOLOCHDIR/etc/.initialized
    # detect the newer version
    newer_ver=`echo -e "$old_ver\n$MOLOCH_VERSION" | sort -rV | head -n 1`
    # the old version should not be the same as the newer version
    # otherwise -> upgrade
    if [ "$old_ver" != "$newer_ver" ]; then
        echo "Upgrading ES database..."
        $MOLOCHDIR/bin/Configure
        echo UPGRADE | $MOLOCHDIR/db/db.pl http://$ES_HOST:$ES_PORT upgrade
        echo $MOLOCH_VERSION > $MOLOCHDIR/etc/.initialized
    fi
fi

# start cron daemon for logrotate
service cron start

if [ "$CAPTURE" = "on" ]
then
    echo "Launch capture..."
    if [ "$VIEWER" = "on" ]
    then
        # Background execution
        exec $MOLOCHDIR/bin/moloch-capture --config $MOLOCHDIR/etc/config.ini --host $MOLOCH_HOSTNAME >> $MOLOCHDIR/logs/capture.log 2>&1 &
    else
        # If only capture, foreground execution
        exec $MOLOCHDIR/bin/moloch-capture --config $MOLOCHDIR/etc/config.ini --host $MOLOCH_HOSTNAME >> $MOLOCHDIR/logs/capture.log 2>&1
    fi
fi

echo "Look at log files for errors"
echo "  /data/moloch/logs/viewer.log"
echo "  /data/moloch/logs/capture.log"
echo "Visit http://127.0.0.1:8005 with your favorite browser."
echo "  user: admin"
echo "  password: $MOLOCH_ADMIN_PASSWORD"

if [ "$VIEWER" = "on" ]
then
    echo "Launch viewer..."
    pushd $MOLOCHDIR/viewer
    exec $MOLOCHDIR/bin/node $MOLOCHDIR/viewer/viewer.js -c $MOLOCHDIR/etc/config.ini --host $MOLOCH_HOSTNAME >> $MOLOCHDIR/logs/viewer.log 2>&1
    popd
fi
