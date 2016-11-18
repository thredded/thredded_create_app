#!/usr/bin/env bash

set -eux

if [ "$DB" = 'postgresql' ]; then
  psql -d template1 -c 'CREATE EXTENSION citext;' -U postgres
fi

if [ "$DB" = 'mysql2' ]; then
  # Install MySQL v5.7.
  # Copied from https://github.com/brianmario/mysql2/blob/40cae130b6d183dd4a1911dbc41791b04f1930aa/.travis_mysql57.sh
  sudo apt-get purge -qq '^mysql*' '^libmysql*'
  sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5
  sudo add-apt-repository 'deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7'
  sudo apt-get update -qq
  sudo apt-get install -qq mysql-server libmysqlclient-dev
  # https://www.percona.com/blog/2016/03/16/change-user-password-in-mysql-5-7-with-plugin-auth_socket/
  mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''"
fi
