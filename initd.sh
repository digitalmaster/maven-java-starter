#!/bin/bash

###
# chkconfig: 2345 20 80
# description: Java app init.d service script
# processname: TODO
#
# Installation (CentOS):
#   copy file to /etc/init.d
#   chmod +x /etc/init.d/TODO
#   chkconfig --add /etc/init.d/TODO
#   chkconfig TODO on
# 
# Installation (Ubuntu):
#   copy file to /etc/init.d
#   chmod +x /etc/init.d/TODO
#   update-rc.d TODO defaults
#
#
# Usage: (as root)
#   service TODO start
#   service TODO stop
#   service TODO status
#
###

# Desired name of the application on the filesystem
APP_NAME="TODO"

# The directory in which your application is installed
APPLICATION_DIR="/opt/${APP_NAME}/"

# The fat jar containing your application
APPLICATION_JAR="${APP_NAME}.jar"

# Convenience var to get at the full JAR path
FULL_APP_PATH="${APPLICATION_DIR}/${APPLICATION_JAR}"

# The application argument such as -cluster -cluster-host ...
APPLICATION_ARGS=""

# System options and system properties (-Dfoo=bar).
SYS_PROPS=""

# The Java command to use to launch the application (must be java 8+)
JAVA=/usr/bin/java

# ***********************************************
OUT_FILE="${APPLICATION_DIR}"/out.log
RUNNING_PID="${APPLICATION_DIR}"/RUNNING_PID
# ***********************************************

# colors
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
reset='\e[0m'

echoRed() { echo -e "${red}$1${reset}"; }
echoGreen() { echo -e "${green}$1${reset}"; }
echoYellow() { echo -e "${yellow}$1${reset}"; }

# Check whether the application is running.
# The check is pretty simple: open a running pid file and check that the process
# is alive.
isRunning() {
  # Check for running app
  if [ -f "${RUNNING_PID}" ]; then
    proc=$(cat ${RUNNING_PID});
    if /bin/ps --pid ${proc} 1>&2 >/dev/null; then
      return 0
    fi
  fi
  return 1
}

start() {
  echo "Attempting to start service with JAR ${FULL_APP_PATH}"

  # Validate the JAR actually exists
  if [ ! -f "${FULL_APP_PATH}" ]; then
    echoRed "JAR not found ${FULL_APP_PATH}"
    exit 3
  fi

  if isRunning; then
    echoYellow "${FULL_APP_PATH} is already running"
    return 0
  fi

  pushd ${APPLICATION_DIR} > /dev/null
  nohup ${JAVA} ${SYS_PROPS} -jar ${APPLICATION_JAR} ${APPLICATION_ARGS} > ${OUT_FILE} 2>&1 &
  echo $! > ${RUNNING_PID}
  popd > /dev/null

  if isRunning; then
    echoGreen "${FULL_APP_PATH} started"
    exit 0
  else
    echoRed "${FULL_APP_PATH} has not started - check log"
    exit 3
  fi
}

restart() {
  echo "Restarting ${FULL_APP_PATH}"
  stop
  start
}

stop() {
  echoYellow "Stopping ${FULL_APP_PATH}"
  if isRunning; then
    kill `cat ${RUNNING_PID}`
    rm ${RUNNING_PID}
  fi
}

status() {
  if isRunning; then
    echoGreen "${FULL_APP_PATH} is running"
  else
    echoRed "${FULL_APP_PATH} is either stopped or inaccessible"
  fi
}

case "$1" in
start)
    start
;;

status)
   status
   exit 0
;;

stop)
    if isRunning; then
  stop
  exit 0
    else
  echoRed "Application not running"
  exit 3
    fi
;;

restart)
    stop
    start
;;

*)
    echo "Usage: $0 {status|start|stop|restart}"
    exit 1
esac