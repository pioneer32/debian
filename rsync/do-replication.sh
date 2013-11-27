#!/bin/bash

SCRIPTNAME=`basename ${0}`
PIDFILE=/var/run/${SCRIPTNAME}.pid
LOGFILE=/var/log/${SCRIPTNAME}.log

# HOST & USER on remote mirror
REMOTE_USER=mirror_user
REMOTE_HOST=mirror_host

# local source path & remote destination path (!!!without trailing /)
SOURCE_PATH=/var/wwws
DESTINATION_PATH=/var/wwws
SOURCE_EXCLUDE_PATH='--exclude=**/*.log --exclude=**/app_root/images-cache/* --exclude=**/app_root/cache/*'

# check for dublicate run
if [ -f "${PIDFILE}" ]; then
        pid=`cat "${PIDFILE}"`
        if [ ! `ps -eo pid | grep -v grep | grep -c -P "^\\s*${pid}$"` -eq 0 ]; then
                echo "`date +'%Y-%m-%d %H:%M:%S'` Dublicate run" >> "${LOGFILE}";
                exit 0;
        fi
fi

# write current pid
echo $$ > "${PIDFILE}";
echo "`date +'%Y-%m-%d %H:%M:%S'` Runned" >> "${LOGFILE}";
rsync -avz --delete ${SOURCE_EXCLUDE_PATH} -e "ssh -i /root/rsync/mirror-rsync-key" ${REMOTE_USER}@${REMOTE_HOST}:${SOURCE_PATH}/ ${DESTINATION_PATH}/ 2>> "${LOGFILE}"
echo "`date +'%Y-%m-%d %H:%M:%S'` Finished" >> "${LOGFILE}"
exit 0;
