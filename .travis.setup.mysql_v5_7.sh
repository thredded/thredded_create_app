#!/usr/bin/env bash
# Install MySQL v5.7. Must be run as root.
# Based on https://github.com/brianmario/mysql2/blob/220c3ff70c5aa831754cb045ec153182b0ea0f41/.travis_mysql57.sh
set -eux
apt-get purge -qq '^mysql*' '^libmysql*'
rm -rf /etc/mysql
rm -rf /var/lib/mysql
apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5
add-apt-repository 'deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7'
apt-get update -qq
apt-get install -qq mysql-server libmysqlclient-dev
# https://www.percona.com/blog/2016/03/16/change-user-password-in-mysql-5-7-with-plugin-auth_socket/
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''"
