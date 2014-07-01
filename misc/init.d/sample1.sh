#!/bin/bash
### BEGIN INIT INFO
# Provides:          Sample
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description:
# Description:       Данный файл должен быть в /etc/init.d/sample.sh
#                    Далее update-rc.d sample.sh defaults S 3 4 5
### END INIT INFO

SOMEVAR="somevalue";

case $1 in
	start)
		# do something for start
		;;
	stop)
		# do something for stop
		;;
	restart|reload)
		$0 stop
		sleep 3
		$0 start
		;;
	status)
		# do something for status report
		;;
	*)
		echo "Usage: $0 {start|stop|restart|reload|status}"
		exit 1
		;;
	esac
exit 0
