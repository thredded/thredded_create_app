#!/usr/bin/env bash
USER="$1"
PASS="$2"

BLUE='\033[1;34m'
RESET_COLOR='\033[0m'
log() { if [ -t 1 ]; then echo -e >&2 "${BLUE} $@${RESET_COLOR}"; else echo >&2 "$@"; fi }

set -e

create_postgresql_user() {
  if PGPASSWORD="$PASS" psql -h 127.0.0.1 postgres -U $USER -c '' 2>/dev/null; then return; fi
  log "Creating Postgres '$USER' user."
  local cmd='psql postgres'
  if ! $cmd -c '' 2>/dev/null; then
    log 'Using sudo'
    cmd="sudo -u ${PG_DAEMON_USER:-postgres} psql postgres"
  fi
  $cmd --quiet <<SQL
CREATE ROLE $USER LOGIN PASSWORD '$PASS';
ALTER ROLE $USER CREATEDB;
SQL
}

create_postgresql_user
