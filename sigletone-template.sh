#!/bin/bash

SCRIPTNAME=`basename ${0}`
PIDFILE=/var/run/${SCRIPTNAME}.pid
LOGFILE=/var/log/${SCRIPTNAME}.log

# check for dublicate run
if [ -f "${PIDFILE}" ]; then
        pid=`cat "${PIDFILE}"`
        if [ ! `ps -eo pid | grep -v grep | grep -c "${pid}"` -eq 0 ]; then
                echo "`date +'%Y-%m-%d %H:%M:%S'` Dublicate run" >> "${LOGFILE}";
                exit 0;
        fi
fi

# write current pid
echo $$ > "${PIDFILE}";
# write start time to log
echo "`date +'%Y-%m-%d %H:%M:%S'` Runned" >> "${LOGFILE}";

# do something

# write finish time to log
echo "`date +'%Y-%m-%d %H:%M:%S'` Finished" >> "${LOGFILE}"
exit 0;
