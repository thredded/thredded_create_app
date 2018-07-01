#!/usr/bin/env bash

set -eux

if [ "$DB" = 'postgresql' ]; then
  sudo service postgresql start
  psql -d template1 -c 'CREATE EXTENSION citext;' -U postgres
fi
