#!/bin/sh

mysql -uroot -p$MYSQL_ROOT_PASSWORD -e $MYSQL_PASSWORD "CREATE DATABASE ateam_db;"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e $MYSQL_PASSWORD "USE mysql ; SELECT host,user FROM user;"



mysql -uroot -p$MYSQL_ROOT_PASSWORD -e $MYSQL_PASSWORD "CREATE USER 'ateam'@'%' IDENTIFIED BY '12345';"
mysql -uroot -p$MYSQL_ROOT_PASSWORD -e $MYSQL_PASSWORD  "GRANT ALL PRIVILEGES ON * . * TO 'ateam'@'%';"
mysql -uateam  -p$MYSQL_ROOT_PASSWORD ateam_db < ateam_db.sql

