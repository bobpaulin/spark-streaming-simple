Spark Streaming Simple Docker
=====================================

A simple docker Spark container without Hadoop.

== Master

docker run -d --name spark-master -p 8080 -p 7077 bobpaulin/spark-streaming-simple-master:1.1.0


The master web interface will be exposed on port 8080 and the spark url on 7077

== Slave

docker run -d --link spark:spark --name spark-worker -p 8888 bobpaulin/spark-streaming-simple-worker:1.1.0 <master-ip>

The worker web interface will be exposed on port 8888