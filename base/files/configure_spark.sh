#!/bin/bash
function create_spark_directories() {
  rm -rf /opt/spark-$SPARK_VERSION/work
  mkdir -p /opt/spark-$SPARK_VERSION/work
  chown spark:spark /opt/spark-$SPARK_VERSION/work
  mkdir /tmp/spark
  chown spark:spark /tmp/spark
  rm -rf /opt/spark-$SPARK_VERSION/logs
  mkdir -p /opt/spark-$SPARK_VERSION/logs
  chown spark:spark /opt/spark-$SPARK_VERSION/logs
}
function deploy_spark_files() {
  cp /root/spark_files/spark-env.sh /opt/spark-$SPARK_VERSION/conf/
  cp /root/spark_files/log4j.properties /opt/spark-$SPARK_VERSION/conf/
}
function configure_spark() {
  export SPARK_LOCAL_IP=$IP
  sed -i s/__MASTER__/$1/ /opt/spark-$SPARK_VERSION/conf/spark-env.sh
  #sed -i s/__MASTER__/master/ /opt/spark-$SPARK_VERSION/conf/spark-env.sh
  sed -i s/__SPARK_HOME__/"\/opt\/spark-${SPARK_VERSION}"/ /opt/spark-$SPARK_VERSION/conf/spark-env.sh
  sed -i s/__JAVA_HOME__/"\/usr\/lib\/jvm\/java-7-openjdk-amd64"/ /opt/spark-$SPARK_VERSION/conf/spark-env.sh
}
function create_ssh_directories() {
  rm -rf /root/.ssh
  mkdir /root/.ssh
  chmod go-rx /root/.ssh
  mkdir /var/run/sshd
}

function prepare_spark() {
  create_ssh_directories
  create_spark_directories
  deploy_spark_files
  configure_spark $1
}
