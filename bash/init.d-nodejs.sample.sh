#!/bin/bash
#
### BEGIN INIT INFO
# Provides: application
# Required-Start: $local_fs $network $remote_fs $rabbitmq-server
# Required-Stop: $local_fs $network $remote_fs $rabbitmq-server
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description:
# Description: Provides replication from v2 to v1
### END INIT INFO

APPLICATION_NAME="application";
APPLICATION_DIR="";
APPLICATION_PATH="$APPLICATION_DIR/application.js"
PIDFILE="$APPLICATION_DIR/application.pid"
LOGFILE="$APPLICATION_DIR/application.log"

# NODE_BIN_DIR="/usr/local/bin/node"
# NODE_PATH="/usr/local/lib/node_modules"
. /etc/profile.d/node.sh

export PATH=$PATH:/usr/local/bin
export NODE_PATH=$NODE_PATH
export HOME=/root

case $1 in
	start)
		echo "Starting up $APPLICATION_NAME"
		forever \
			--no-colors \
			--pidFile $PIDFILE \
			--append \
			-l $LOGFILE \
			--debug \
			start $APPLICATION_PATH 2>&1 >> $LOGFILE &
    		RETVAL=$?
		;;
	stop)
		if [ -f $PIDFILE ]; then
			echo "Shutting down $APPLICATION_NAME"
			forever --no-colors --debug stop $APPLICATION_PATH 2>&1 >> $LOGFILE
			rm -f $PIDFILE
			RETVAL=$?
		else
			echo "$APPLICATION_NAME is not running."
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
			echo "$APPLICATION_NAME is running."
			RETVAL=0
		else
			echo "$APPLICATION_NAME is not running."
			RETVAL=3
		fi
		;;
	*)
		echo "Usage: $0 {start|stop|restart|reload|status}"
		exit 1
		;;
	esac
exit $RETVAL


# сделаем +x и поместим в автозапуск
chmod 755 /etc/init.d/application && update-rc.d application defaults

# для удаления из автолоада
update-rc.d -f application remove