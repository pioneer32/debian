#!/bin/bash
#
# Using http://www.libslack.org/daemon/
# On a Linux distro daemon can be easily installed from a repository. Debian has it inside its repository, as probably do most other distributions.
#
### BEGIN INIT INFO
# Provides: example-app
# Required-Start: $local_fs $network $remote_fs redis-server
# Required-Stop: $local_fs $network $remote_fs redis-server
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description:
# Description: Description of example-app
### END INIT INFO

## Guarantee a single named instance
NAME="example-app"
## Run the client in directory path
WORK_DIR=/var/lib/example-app/app
## Override standard pidfile location
PID_DIR=/var/lib/example-app
## Send daemon's error output to file
ERR_LOG=/var/lib/example-app/log/daemon_err.log
## Send daemon's debug output to syslog or file
OUTPUT_LOG=/var/lib/example-app/log/example_app.log

## If it necessary, respawn the client when it terminates
RESPAWN='--respawn'
## Respawn # times on error before delay
ATTEMPTS=3
## Delay between spawn attempt bursts (seconds)
DELAY=10
## Maximum number of spawn attempt bursts
LIMIT=5

## Daemonizing application
APP="node example_app.js"

do_start() {
  echo "Starting Example App..."
  daemon $RESPAWN \
    --attempts=$ATTEMPTS \
    --delay=$DELAY \
    --limit=$LIMIT \
    --name=$NAME \
    --chdir=$WORK_DIR \
    --pidfiles=$PID_DIR \
    --errlog=$ERR_LOG \
    --output=$OUTPUT_LOG \
    -- $APP

  sleep 1
  do_status
}

do_stop() {
  echo "Stopping Example App..."
  daemon --name $NAME --pidfiles=$PID_DIR --stop
}

do_restart() {
  echo "Restarting Example App..."
  do_stop
  sleep 3
  do_start
}

do_status() {
  daemon -v --name $NAME --pidfiles=$PID_DIR --running
}

case "$1" in
  start)
    do_start
    ;;

  stop)
    do_stop
    ;;

  status)
    do_status
    ;;

  restart)
    do_restart
    ;;

  *)
    echo "Usage: $0 {start|stop|status|restart}" >&2
    exit 3
    ;;
esac
