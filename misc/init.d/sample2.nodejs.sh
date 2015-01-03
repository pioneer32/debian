#!/bin/bash
#
# Using forever-cli https://github.com/foreverjs/forever
#
### BEGIN INIT INFO
# Provides: ${NODE_APP_NAME}
# Required-Start: $local_fs $network $remote_fs redis-server
# Required-Stop: $local_fs $network $remote_fs redis-server
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description:
# Description: ${NODE_APP_DESCRIPTION}
### END INIT INFO

APPLICATION_PATH="${NODE_APP_ROOTDIR}/${NODE_APP_NAME}.js"
PIDFILE="${NODE_APP_ROOTDIR}/${NODE_APP_NAME}.pid"

# NODE_BIN_DIR="/usr/local/bin/node"
# NODE_PATH="/usr/local/lib/node_modules"
. /etc/profile.d/node.sh


export PATH=$PATH:/usr/local/bin
export NODE_PATH=$NODE_PATH
export HOME=/root

case $1 in
	start)
		echo "Starting up ${NODE_APP_NAME}"
		forever \
			--no-colors \
			--pidFile $PIDFILE \
			--append \
			-l ${NODE_APP_LOGFILE} \
			--debug \
			start $APPLICATION_PATH 2>&1 >> ${NODE_APP_LOGFILE} &
		RETVAL=$?
		;;
	stop)
		if [ -f $PIDFILE ]; then
			echo "Shutting down ${NODE_APP_NAME}"
			forever --no-colors --debug stop $APPLICATION_PATH 2>&1 >> ${NODE_APP_LOGFILE}
			rm -f $PIDFILE
			RETVAL=$?
		else
			echo "${NODE_APP_NAME} is not running."
			RETVAL=0
		fi
		;;
	restart|reload)
		$0 stop
		sleep 1
		$0 start
		;;
	status)
		forever list | grep -q "$APPLICATION_PATH"
		if [ "$?" -eq "0" ]; then
			echo "${NODE_APP_NAME} is running."
			RETVAL=0
		else
			echo "${NODE_APP_NAME} is not running."
			RETVAL=3
		fi
		;;
	*)
		echo "Usage: $0 {start|stop|restart|reload|status}"
		exit 1
		;;
	esac
exit $RETVAL
