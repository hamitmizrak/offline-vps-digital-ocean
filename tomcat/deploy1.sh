#!/bin/bash
# Docker-compose yml calistir
# docker-compose up -d
docker-compose -f _3_docker-compose.yml up -d

# Container Image Bağlan
winpty docker container  exec -it  my_tomcat2 bash
cat /usr/local/tomcat/conf/server.xml

# Başka bir container üzeriden volume bağlanmak
# winpty docker run -it --rm --name volume_container \
# -v tomcat_tomcat-conf://usr/local/tomcat/conf \
# -v tomcat_tomcat-logs://usr/local/tomcat/logs \
# -v tomcat_tomcat-webapps://usr/local/tomcat/webapps \
# my_tomcat2 bash
