#!/usr/bin/env bash

set -eux

if [ "$DB" = 'postgresql' ]; then
  psql -d template1 -c 'CREATE EXTENSION citext;' -U postgres
fi
