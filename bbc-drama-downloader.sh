#!/sbin/openrc-run

# This init script can be used in alpine linux
# copy to /etc/init.d/bbc-drama-downloader
# and then issue: rc-update add bbc_downloader default

name="$SVCNAME"
save_dir="/root"
command="/usr/bin/ruby"
command_args="/root/bbc-drama-downloader/bbc-drama-downloader.rb"
command_background="yes"
pidfile="/var/run/$SVCNAME.pid"
logfile="/var/log/messages"
start_stop_daemon_args="--exec $command $command_args -d $save_dir  -1 $logfile -2 $logfile"

depend() {
  need net
  use logger
  after firewall
}
