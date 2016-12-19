#!/usr/bin/env bash

start_daemon () {
	/etc/redhat-lsb/lsb_start_daemon "$@"
}

killproc () {
	/etc/redhat-lsb/lsb_killproc "$@"
}

pidofproc () {
	/etc/redhat-lsb/lsb_pidofproc "$@"
}

log_success_msg () {
	/etc/redhat-lsb/lsb_log_message success "$@"
}

log_failure_msg () {
	/etc/redhat-lsb/lsb_log_message failure "$@"
}

log_warning_msg () {
	/etc/redhat-lsb/lsb_log_message warning "$@"
}
