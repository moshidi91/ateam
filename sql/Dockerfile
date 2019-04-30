
FROM mysql:5.7


WORKDIR /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 

COPY . /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 
ENV GOSU_VERSION = 1.7
ENV MYSQL_MAJOR = 5.7 
ENV MYSQL_VERSION = 5.7.25-1debian9 
ENV MYSQL_ALLOW_EMPTY_PASSWORD = true
ENV MYSQL_ROOT_PASSWORD=12345
USER root
# Add the content of the sql-scripts/ directory to your image
# All scripts in docker-entrypoint-initdb.d/ are automatically
# executed during container startup

COPY init_db.sh /docker-entrypoint-initdb.d/init_db.sh

EXPOSE 3306 




