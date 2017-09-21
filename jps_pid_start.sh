#!/usr/bin/env bash

# set bin path
APP_HOME_BIN=$(cd $(dirname $0) && pwd)

# set daemon out file
APP_DAEMON_OUT=${APP_HOME_BIN}/log.out

# set app home
APP_HOME=$(dirname ${APP_HOME_BIN})

# set pid file
APP_PID_FILE=${APP_HOME_BIN}/running.pid

# set main class
APP_MAIN_CLASS=com.xx.oo.MainClassName

# set mock class
APP_MOCK_CLASS=com.xx.oo.MockClassName

# set lib path
APP_HOME_LIB=${APP_HOME}/lib

# set config path
APP_HOME_CONFIG=${APP_HOME}/config

# set log path
APP_HOME_LOG=${APP_HOME}/log

# set java home
JAVA_HOME=${JAVA_HOME}

# check java
JAVA=${JAVA_HOME}/bin/java
if [ ! -e ${JAVA} ]; then
  JAVA=java
fi

# set CLASSPATH
CLASSPATH=${CLASSPATH}
for i in "$APP_HOME_LIB"/*.jar; do
   CLASSPATH="${CLASSPATH}":"$i"
done

# set JVM options
JAVA_OPTS=""
JAVA_OPTS=${JAVA_OPTS}"-DAPP_HOME=${APP_HOME} "
JAVA_OPTS=${JAVA_OPTS}"-Dconfig.properties=${APP_HOME_CONFIG}/config.properties "

# get process pid
JPS_ID=0

# check and set pid to ${JPS_ID}
check_pid() {
    EXPECTED_PID=`cat ${APP_PID_FILE} 2> /dev/null`
    JPS_ID=`ps aux | grep ${APP_MAIN_CLASS} | grep -v grep | awk '{print $2}'`
    if [[ "empty${JPS_ID}" = "empty" || "${EXPECTED_PID}" != "${JPS_ID}" ]]; then
        JPS_ID=0
    fi
}

# start process foreground
debug() {
    check_pid

    if [ ${JPS_ID} -ne 0 ]; then
        echo "======================================================================="
        echo "warn: ${APP_MAIN_CLASS} already started! (pid=${JPS_ID})"
        echo "======================================================================="
        exit -1
    else
        echo "Starting $APP_MAIN_CLASS foreground..."
        ${JAVA} ${JAVA_OPTS} -classpath ${CLASSPATH} ${APP_MAIN_CLASS}
    fi
}

# mock data
mock() {
    echo "Starting $APP_MOCK_CLASS foreground..."
    ${JAVA} ${JAVA_OPTS} -classpath ${CLASSPATH} ${APP_MOCK_CLASS}
}


# start process
start() {
    check_pid

    if [ ${JPS_ID} -ne 0 ]; then
        echo "======================================================================="
        echo "warn: ${APP_MAIN_CLASS} already started! (pid=${JPS_ID})"
        echo "======================================================================="
    else
        echo "Starting $APP_MAIN_CLASS ..."
        nohup ${JAVA} ${JAVA_OPTS} -classpath ${CLASSPATH} ${APP_MAIN_CLASS} 1>${APP_DAEMON_OUT} 2>&1 < /dev/null &
        echo $! > ${APP_PID_FILE}

        # wait at most 5 seconds for starting
        for ((second=1; second<=5; second++))
        do
            sleep 1
            check_pid
            if [ ${JPS_ID} -ne 0 ]; then
                echo "Running $APP_MAIN_CLASS for ${second} seconds...(pid=${JPS_ID})"
            else
                echo "Waiting ${second} seconds for starting..."
            fi
        done

        if [ ${JPS_ID} -ne 0 ]; then
            echo "Starting $APP_MAIN_CLASS (pid=${JPS_ID}) [OK]"
        else
            echo "Starting $APP_MAIN_CLASS [Failed]"
            exit -1
        fi
    fi
}

# stop process
stop() {
    check_pid

   if [ ${JPS_ID} -ne 0 ]; then
        echo -n "Send signal to ${APP_MAIN_CLASS} ...(pid=${JPS_ID}) "
        kill -TERM ${JPS_ID}
        if [ $? -eq 0 ]; then
             echo "[OK]"
        else
            echo "[Failed]"
        fi

        while true
        do
            check_pid
            if [ ${JPS_ID} -ne 0 ]; then
                echo "waiting ${APP_MAIN_CLASS} to stop ...(pid=${JPS_ID}) "
                sleep 1
            else
                break
            fi
        done
        rm ${APP_PID_FILE} 2>/dev/null
        echo "${APP_MAIN_CLASS} is stopped...(pid=${JPS_ID}) "
   else
        echo "======================================================================="
        echo "warn: ${APP_MAIN_CLASS} is not running"
        echo "======================================================================="
   fi
}

# get process status
status() {
    check_pid

    if [ ${JPS_ID} -ne 0 ];  then
        echo "${APP_MAIN_CLASS} is running! (pid=${JPS_ID})"
    else
        echo "${APP_MAIN_CLASS} is not running"
    fi
}

# get system info
info() {
    JAVA=${JAVA_HOME}/bin/java
    if [ ! -e ${JAVA} ]; then
      JAVA=java
    fi

    echo "system information:"
    echo "**************************************************************************"
    echo `head -n 1 /etc/issue`
    echo `uname -a`
    echo
    echo "JAVA_HOME=${JAVA_HOME}"
    echo `${JAVA} -version`
    echo
    echo "APP_HOME=${APP_HOME}"
    echo "APP_MAIN_CLASS=${APP_MAIN_CLASS}"
    echo "***************************************************************************"
}

case "$1" in
    'debug')
        debug
        ;;
    'start')
        start
        ;;
   'stop')
        stop
        ;;
   'restart')
        stop
        start
        ;;
   'status')
        status
        ;;
   'info')
        info
        ;;
   'mock_do_not_use_in_pro_dev')
        mock
        ;;
   *)
        echo "Usage: $0 {debug|start|stop|restart|status|info|mock_do_not_use_in_pro_dev}"
        exit 1
esac
