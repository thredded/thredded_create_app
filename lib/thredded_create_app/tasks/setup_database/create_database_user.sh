#!/usr/bin/env bash
DB="$1"
APP_NAME="$2"
USER="$3"
PASS="$4"
TRAVIS="$5"

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

create_mysql_user() {
  if mysql -s -u"$USER" -p"$PASS" -e '' 2>/dev/null ; then return; fi
  log "Creating MySQL '$USER' user. MySQL root password required."
  local mysql_flags='-p'
  if [ -z "$TRAVIS" ]; then
    mysql_flags=''
  fi
  mysql --verbose -uroot $mysql_flags <<SQL
GRANT ALL PRIVILEGES ON \`${APP_NAME}_dev\`.* TO '$USER'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON \`${APP_NAME}_test\`.* TO '$USER'@'localhost';
SQL
}

if [ "$DB" = 'mysql2' ]; then
 create_mysql_user || echo 'Error'
elif [ "$DB" = 'postgresql' ]; then
  create_postgresql_user || echo 'Error'
fi
