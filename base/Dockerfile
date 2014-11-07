# Base Ubuntu Precise 12.04 LTS image
#
FROM ubuntu:precise
MAINTAINER bobpaulin bob@bobpaulin.com
# Setup a volume for data
VOLUME ["/data"]
# Set correct source list
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu precise-updates main universe" >> /etc/apt/sources.list
# install a few other useful packages plus Open Jdk 7
RUN apt-get update && apt-get upgrade -y && apt-get install -y less openjdk-7-jre-headless net-tools vim-tiny sudo openssh-server iputils-ping python2.7

# Docker messes up /etc/hosts and adds two entries for 127.0.0.1
# we try to recover from that by giving /etc/resolv.conf and therefore
# the nameserver priority
RUN sed -i s/"files dns"/"dns files"/ /etc/nsswitch.conf

# Set JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

ENV SCALA_VERSION 2.10.3
ENV SPARK_VERSION 1.1.0
ENV SCALA_HOME /opt/scala-$SCALA_VERSION
ENV SPARK_HOME /opt/spark-$SPARK_VERSION
ENV PATH $SPARK_HOME:$SCALA_HOME/bin:$PATH

# Install Scala
ADD http://www.scala-lang.org/files/archive/scala-$SCALA_VERSION.tgz /
RUN (cd / && gunzip < scala-$SCALA_VERSION.tgz)|(cd /opt && tar -xvf -)
RUN rm /scala-$SCALA_VERSION.tgz
# Install Spark
ADD http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION-bin-hadoop1.tgz /
RUN (cd / && gunzip < spark-$SPARK_VERSION-bin-hadoop1.tgz)|(cd /opt && tar -xvf -)
RUN (ln -s /opt/spark-$SPARK_VERSION-bin-hadoop1 /opt/spark-$SPARK_VERSION && rm /spark-$SPARK_VERSION-bin-hadoop1.tgz)
# Add Shark config files and configure script
ADD files /root/spark_files

RUN groupadd -r spark -g 433 && \
useradd -u 431 -r -g spark -d /opt/spark-$SPARK_VERSION -s /sbin/nologin -c "Docker Spark image user" spark && \
chown -R spark:spark /opt/spark-$SPARK_VERSION
