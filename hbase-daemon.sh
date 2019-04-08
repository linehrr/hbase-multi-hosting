#!/usr/bin/env bash

bin=`dirname "${BASH_SOURCE-$0}"`
bin=`cd "$bin">/dev/null; pwd`

. "$bin"/hbase-config.sh
. "$bin"/hbase-common.sh

BASE_CONFIG_DIR=$HBASE_CONF_DIR

startStop=$1
shift
command=$1

# this is number of extra region servers you want to have
# aka excluding the main original region server
number_of_instance=7

/usr/hdp/current/hbase-regionserver/bin/hbase-daemon-per-instance.sh --config ${HBASE_CONF_DIR} $startStop $command

for i in `seq 1 $number_of_instance`; do
  rm -rf /tmp/hbase-10$i
  mkdir -p /tmp/hbase-10$i
  cp  $BASE_CONFIG_DIR/* /tmp/hbase-10$i/
  sed -i s/16030/2603$i/ /tmp/hbase-10$i/hbase-site.xml
  sed -i s/16020/2602$i/ /tmp/hbase-10$i/hbase-site.xml
  sed -i "s/\/var\/log\/hbase/\/var\/log\/hbase\/hbase$i/" /tmp/hbase-10$i/hbase-env.sh
  sed -i "s/\/var\/run\/hbase/\/var\/run\/hbase\/hbase$i/" /tmp/hbase-10$i/hbase-env.sh

  export HBASE_CONF_DIR=/tmp/hbase-10$i
  export HBASE_LOG_DIR=/var/log/hbase/hbase$i
  export HBASE_PID_DIR=/var/run/hbase/hbase$i

  unset HBASE_ENV_INIT
  unset HBASE_LOGOUT
  unset HBASE_LOGGC
  unset HBASE_LOGLOG

  # this is to work around the env var not propagated to hbase.distro issue
  echo "export HBASE_LOG_DIR=/var/log/hbase/hbase$i" > ${HBASE_HOME}/conf/hbase-env-${command}.sh
  /usr/hdp/current/hbase-regionserver/bin/hbase-daemon-per-instance.sh --config /tmp/hbase-10$i $startStop $command
  
  # clean up in case main hbase region start next time
  rm -f ${HBASE_HOME}/conf/hbase-env-${command}.sh
done
