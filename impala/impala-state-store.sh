#!/usr/bin/env bash

# 在本 shell 内执行下边这个脚本，添加几个函数
. /lib/lsb/init-functions
# 这个脚本找不到，网上有人说不用关心这个，好吧。
. /etc/default/hadoop

# 判断 /et/default/impala是否存在且是一个常规文件
if [ -f /etc/default/impala ] ; then
  . /etc/default/impala
fi

# Autodetect JAVA_HOME if not defined
# 文件 /usr/libexec/bigtop-detect-javahome 是否存在
if [ -e /usr/libexec/bigtop-detect-javahome ]; then
  . /usr/libexec/bigtop-detect-javahome
elif [ -e /usr/lib/bigtop-utils/bigtop-detect-javahome ]; then
  . /usr/lib/bigtop-utils/bigtop-detect-javahome
fi

RETVAL_SUCCESS=0

STATUS_RUNNING=0
STATUS_DEAD=1
STATUS_DEAD_AND_LOCK=2
STATUS_NOT_RUNNING=3
STATUS_OTHER_ERROR=102


ERROR_PROGRAM_NOT_INSTALLED=5
ERROR_PROGRAM_NOT_CONFIGURED=6


RETVAL=0
SLEEP_TIME=5
PROC_NAME="statestored"

DAEMON="statestored"
DESC="Impala State Store Server"
EXEC_PATH="/usr/bin/statestored"
SVC_USER="impala"
DAEMON_FLAGS="${IMPALA_STATE_STORE_ARGS}"
CONF_DIR="/etc/impala/conf"
PIDFILE="/var/run/impala/statestored-impala.pid"
LOCKDIR="/var/lock/subsys"
LOCKFILE="$LOCKDIR/statestored"

install -d -m 0755 -o impala -g impala /var/run/impala 1>/dev/null 2>&1 || :
[ -d "$LOCKDIR" ] || install -d -m 0755 $LOCKDIR 1>/dev/null 2>&1 || :

if [ -f /etc/default/impala ] ; then
  . /etc/default/impala
fi

export ENABLE_CORE_DUMPS
export IMPALA_HOME
export IMPALA_BIN
export IMPALA_CONF_DIR
export HADOOP_CONF_DIR
export HIVE_CONF_DIR
export HBASE_CONF_DIR
export LIBHDFS_OPTS
export MYSQL_CONNECTOR
export HIVE_HOME
export HBASE_HOME

start() {
  [ -x $EXEC_PATH ] || exit $ERROR_PROGRAM_NOT_INSTALLED
  [ -d $CONF_DIR ] || exit $ERROR_PROGRAM_NOT_CONFIGURED

  checkstatus >/dev/null 2>/dev/null
  status=$?
  if [ "$status" -eq "$STATUS_RUNNING" ]; then
    log_success_msg "${DESC} is running"
    exit 0
  fi

  log_success_msg "Starting ${DESC}: "

  /bin/su -s /bin/bash -c "/bin/bash -c 'cd ${RUNDIR} && echo \$\$ > ${PIDFILE} && exec ${EXEC_PATH} ${DAEMON_FLAGS} >>${IMPALA_LOG_DIR}/impala-state-store.log 2>&1' &" $SVC_USER
  RETVAL=$?
  [ $RETVAL -eq 0 ] && touch $LOCKFILE
  return $RETVAL
}
stop() {
  log_success_msg "Stopping ${DESC}: "

  killproc -p $PIDFILE $EXEC_PATH
  RETVAL=$?

  [ $RETVAL -eq $RETVAL_SUCCESS ] && rm -f $LOCKFILE $PIDFILE
  return $RETVAL
}
restart() {
  stop
  start
}

checkstatusofproc(){
  pidofproc -p $PIDFILE $PROC_NAME > /dev/null
}

checkstatus(){
  checkstatusofproc
  status=$?

  case "$status" in
    $STATUS_RUNNING)
      log_success_msg "${DESC} is running"
      ;;
    $STATUS_DEAD)
      log_failure_msg "${DESC} is dead and pid file exists"
      ;;
    $STATUS_DEAD_AND_LOCK)
      log_failure_msg "${DESC} is dead and lock file exists"
      ;;
    $STATUS_NOT_RUNNING)
      log_failure_msg "${DESC} is not running"
      ;;
    *)
      log_failure_msg "${DESC} status is unknown"
      ;;
  esac
  return $status
}

condrestart(){
  [ -e $LOCKFILE ] && restart || :
}

check_for_root() {
  if [ $(id -ur) -ne 0 ]; then
    echo 'Error: root user required'
    echo
    exit 1
  fi
}

service() {
  case "$1" in
    start)
      check_for_root
      start
      ;;
    stop)
      check_for_root
      stop
      ;;
    status)
      checkstatus
      RETVAL=$?
      ;;
    restart)
      check_for_root
      restart
      ;;
    condrestart|try-restart)
      check_for_root
      condrestart
      ;;
    *)
      echo $"Usage: $0 {start|stop|status|restart|try-restart|condrestart}"
      exit 1
  esac
}

service "$1"

exit $RETVAL
