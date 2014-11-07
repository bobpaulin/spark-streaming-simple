# Spark
FROM bobpaulin/spark-streaming-simple-base:1.1.0
MAINTAINER bobpaulin bob@bobpaulin.com
# Expose TCP ports 7077 8080
EXPOSE 7077 8080
ADD files /root/spark_master_files
CMD ["/root/spark_master_files/default_cmd"]