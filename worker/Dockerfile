#!/bin/bash

# Spark
FROM spark-streaming-simple-base:1.1.0
MAINTAINER bobpaulin bob@bobpaulin.com
# Instead of using a random port, bind the worker to a specific port
ENV SPARK_WORKER_PORT 8888
EXPOSE 8888
ADD files /root/spark_worker_files
# Add the entrypoint script for the master
CMD ["-h"]
ENTRYPOINT ["/root/spark_worker_files/default_cmd"]