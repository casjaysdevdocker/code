#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202303102006-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.pro
# @@License          :  WTFPL
# @@ReadME           :  entrypoint.sh --help
# @@Copyright        :  Copyright: (c) 2023 Jason Hempstead, Casjays Developments
# @@Created          :  Friday, Mar 10, 2023 20:06 EST
# @@File             :  entrypoint.sh
# @@Description      :  entrypoint point for code
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  other/docker-entrypoint
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
SCRIPT_NAME="$(basename "$0" 2>/dev/null)"
[ "$DEBUGGER" = "on" ] && echo "Enabling debugging" && set -o pipefail -x$DEBUGGER_OPTIONS || set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# remove whitespaces from beginning argument
while :; do [ "$1" = " " ] && shift 1 || break; done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ "$1" = "$0" ] && shift 1
[ "$1" = "$SCRIPT_NAME" ] && shift 1
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import the functions file
if [ -f "/usr/local/etc/docker/functions/entrypoint.sh" ]; then
  . "/usr/local/etc/docker/functions/entrypoint.sh"
else
  echo "Can not load functions from /usr/local/etc/docker/functions/entrypoint.sh"
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create the default env files
__create_env "/config/env/default.sh" "/root/env.sh" &>/dev/null
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import variables from files
for set_env in "/root/env.sh" "/usr/local/etc/docker/env"/*.sh "/config/env"/*.sh; do
  [ -f "$set_env" ] && . "$set_env"
done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Custom functions

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define script variables
SERVICE_USER="root" # execute command as another user
SERVICE_GROUP=""    # Set user group for permission fix
SERVICE_UID="0"     # set the user id for creation of user
SERVICE_PORT=""     # specifiy port which service is listening on
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Healthcheck variables
HEALTH_ENABLED="yes" # enable healthcheck [yes/no]
SERVICES_LIST="tini" # comma seperated list of processes for the healthcheck
SERVER_PORTS=""      # ports : 80,443
HEALTH_ENDPOINTS=""  # url endpoints: [http://localhost/health,http://localhost/test]
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional
PHP_INI_DIR="${PHP_INI_DIR:-$(__find_php_ini)}"
PHP_BIN_DIR="${PHP_BIN_DIR:-$(__find_php_bin)}"
HTTPD_CONFIG_FILE="${HTTPD_CONFIG_FILE:-$(__find_httpd_conf)}"
NGINX_CONFIG_FILE="${NGINX_CONFIG_FILE:-$(__find_nginx_conf)}"
MYSQL_CONFIG_FILE="${MYSQL_CONFIG_FILE:-$(__find_mysql_conf)}"
PGSQL_CONFIG_FILE="${PGSQL_CONFIG_FILE:-$(__find_pgsql_conf)}"
MONGODB_CONFIG_FILE="${MONGODB_CONFIG_FILE:-$(__find_mongodb_conf)}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Overwrite variables

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Last thing to run before options
__run_pre() {
  if [ "$ENTRYPOINT_FIRST_RUN" = "false" ]; then # Run on initial creation
    true
  fi
  if [ "$CONFIG_DIR_INITIALIZED" = "false" ]; then # Initial config
    true
  fi
  if [ "$DATA_DIR_INITIALIZED" = "false" ]; then
    true
  fi
  # End Initial config
  if [ "$START_SERVICES" = "yes" ]; then # only run on start
    true
  fi # end run on start
  # Run everytime container starts
  # __certbot
  # __create_ssl_cert
  # __update_ssl_certs
  # end
  return 0
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__run_message() {

  return
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# rewrite variables
ENV_PORTS="${ENV_PORTS//,/ }"
ENV_PORTS="${ENV_PORTS//\/*/}"
SERVER_PORTS="${SERVER_PORTS//,/ }"
WEB_SERVER_PORTS="${SERVICE_PORT//\/*/}"
HEALTH_ENDPOINTS="${HEALTH_ENDPOINTS//,/ }"
WEB_SERVER_PORTS="${WEB_SERVER_PORTS//\/*/}"
WEB_SERVER_PORTS="${SERVICE_PORT//,/ } ${WEB_SERVER_PORTS//,/ }"
ENV_PORTS="$(echo "$ENV_PORTS" | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' ' | grep '^' || false)"
WEB_SERVER_PORTS="$(echo "$WEB_SERVER_PORTS" | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' ' | grep '^' || false)"
ENV_PORTS="$(echo "$SERVER_PORTS" "$WEB_SERVER_PORTS" "$ENV_PORTS" "$SERVER_PORTS" | tr ' ' '\n' | sort -u | grep -v '^$' | tr '\n' ' ' | grep '^' || false)"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# variables based on env/files
[ "$SERVICE_PORT" = "443" ] && SSL_ENABLED="true"
[ -f "/config/.enable_ssh" ] && SSL_ENABLED="true"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# export variables

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Default directories
BACKUP_DIR="${BACKUP_DIR:-/data/backups}"
WWW_ROOT_DIR="${WWW_ROOT_DIR:-/data/htdocs}"
LOCAL_BIN_DIR="${LOCAL_BIN_DIR:-/usr/local/bin}"
DEFAULT_DATA_DIR="${DEFAULT_DATA_DIR:-/usr/local/share/template-files/data}"
DEFAULT_CONF_DIR="${DEFAULT_CONF_DIR:-/usr/local/share/template-files/config}"
DEFAULT_TEMPLATE_DIR="${DEFAULT_TEMPLATE_DIR:-/usr/local/share/template-files/defaults}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create required directories
mkdir -p "/run"
mkdir -p "/tmp"
mkdir -p "/root"
mkdir -p "/data/logs"
mkdir -p "/run/init.d"
mkdir -p "/config/secure"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create required files
touch "/data/logs/entrypoint.log"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# fix permissions
chmod -f 777 "/run"
chmod -f 777 "/tmp"
chmod -f 700 "/root"
chmod -f 777 "/data/logs"
chmod -f 777 "/run/init.d"
chmod -f 777 "/config/secure"
chmod -f 777 "/data/logs/entrypoint.log"
chmod -f 777 "/dev/stderr" "/dev/stdout"
################## END OF CONFIGURATION #####################
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create the backup dir
[ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ] || mkdir -p "$BACKUP_DIR"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Show start message
if [ "$CONFIG_DIR_INITIALIZED" = "false" ] || [ "$DATA_DIR_INITIALIZED" = "false" ]; then
  [ "$ENTRYPOINT_MESSAGE" = "yes" ] && echo "Executing entrypoint script for code"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set timezone
[ -n "$TZ" ] && [ -w "/etc/timezone" ] && echo "$TZ" >"/etc/timezone"
[ -f "/usr/share/zoneinfo/$TZ" ] && [ -w "/etc/localtime" ] && ln -sf "/usr/share/zoneinfo/$TZ" "/etc/localtime"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Make sure localhost exists
if [ -w "/etc/hosts" ] && ! grep -q '127.0.0.1' /etc/hosts; then
  echo "127.0.0.1       localhost" >"/etc/hosts"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set containers hostname
[ -n "$HOSTNAME" ] && [ -w "/etc/timezone" ] && echo "$HOSTNAME" >"/etc/hostname"
if [ -w "/etc/hosts" ] && [ -n "$HOSTNAME" ]; then
  echo "${CONTAINER_IP4_ADDRESS:-127.0.0.1}    $HOSTNAME $HOSTNAME.local" >>"/etc/hosts"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Add domain to hosts file
[ -n "$DOMAINNAME" ] && [ -w "/etc/timezone" ] && echo "$HOSTNAME.${DOMAINNAME:-local}" >"/etc/hostname"
if [ -w "/etc/hosts" ] && [ -n "$DOMAINNAME" ]; then
  echo "${CONTAINER_IP4_ADDRESS:-127.0.0.1}    $HOSTNAME.${DOMAINNAME:-local}" >"/etc/hosts"
  echo "${CONTAINER_IP4_ADDRESS:-127.0.0.1}    $HOSTNAME.$DOMAINNAME" >>"/etc/hosts"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Delete any gitkeep files
[ -d "/data" ] && rm -Rf "/data/.gitkeep" "/data"/*/*.gitkeep
[ -d "/config" ] && rm -Rf "/config/.gitkeep" "/config"/*/*.gitkeep
[ -f "/usr/local/bin/.gitkeep" ] && rm -Rf "/usr/local/bin/.gitkeep"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import hosts file into container
[ -f "/usr/local/etc/hosts" ] && [ -w "/etc/hosts" ] && cat "/usr/local/etc/hosts" >>"/etc/hosts"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup bin directory
SET_USR_BIN=""
[ -d "/data/bin" ] && SET_USR_BIN+="$(__find /data/bin f) "
[ -d "/config/bin" ] && SET_USR_BIN+="$(__find /config/bin f) "
if [ -n "$SET_USR_BIN" ]; then
  echo "Setting up bin $SET_USR_BIN > $LOCAL_BIN_DIR"
  for create_bin_template in $SET_USR_BIN; do
    if [ -n "$create_bin_template" ]; then
      create_bin_name="$(basename "$create_bin_template")"
      if [ -e "$create_bin_template" ]; then
        ln -sf "$create_bin_template" "$LOCAL_BIN_DIR/$create_bin_name"
      fi
    fi
  done
  unset create_bin_template create_bin_name SET_USR_BIN
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copy default config
if [ -n "$DEFAULT_TEMPLATE_DIR" ]; then
  if [ "$CONFIG_DIR_INITIALIZED" = "false" ] && [ -d "/config" ]; then
    echo "Copying default config files $DEFAULT_TEMPLATE_DIR > /config"
    for create_config_template in "$DEFAULT_TEMPLATE_DIR"/*; do
      if [ -n "$create_config_template" ]; then
        create_template_name="$(basename "$create_config_template")"
        if [ -d "$create_config_template" ]; then
          mkdir -p "/config/$create_template_name/"
          __is_dir_empty "/config/$create_template_name" || cp -Rf "$create_config_template/." "/config/$create_template_name/" 2>/dev/null
        elif [ -e "$create_config_template" ]; then
          [ -e "/config/$create_template_name" ] || cp -Rf "$create_config_template" "/config/$create_template_name" 2>/dev/null
        fi
      fi
    done
    unset create_config_template create_template_name
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copy custom config files
if [ -n "$DEFAULT_CONF_DIR" ]; then
  if [ "$CONFIG_DIR_INITIALIZED" = "false" ] && [ -d "/config" ]; then
    echo "Copying custom config files: $DEFAULT_CONF_DIR > /config"
    for create_config_template in "$DEFAULT_CONF_DIR"/*; do
      create_config_name="$(basename "$create_config_template")"
      if [ -n "$create_config_template" ]; then
        if [ -d "$create_config_template" ]; then
          mkdir -p "/config/$create_config_name"
          __is_dir_empty "/config/$create_config_name" || cp -Rf "$create_config_template/." "/config/$create_config_name/" 2>/dev/null
        elif [ -e "$create_config_template" ]; then
          [ -e "/config/$create_config_name" ] || cp -Rf "$create_config_template" "/config/$create_config_name" 2>/dev/null
        fi
      fi
    done
    unset create_config_template create_config_name
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copy custom data files
if [ -d "/data" ]; then
  if [ "$DATA_DIR_INITIALIZED" = "false" ] && [ -n "$DEFAULT_DATA_DIR" ]; then
    echo "Copying data files $DEFAULT_DATA_DIR > /data"
    for create_data_template in "$DEFAULT_DATA_DIR"/*; do
      create_data_name="$(basename "$create_data_template")"
      if [ -n "$create_data_template" ]; then
        if [ -d "$create_data_template" ]; then
          mkdir -p "/data/$create_data_name"
          __is_dir_empty "/data/$create_data_name" || cp -Rf "$create_data_template/." "/data/$create_data_name/" 2>/dev/null
        elif [ -e "$create_data_template" ]; then
          [ -e "/data/$create_data_name" ] || cp -Rf "$create_data_template" "/data/$create_data_name" 2>/dev/null
        fi
      fi
    done
    unset create_template
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copy /config to /etc
if [ -d "/config" ]; then
  if [ "$CONFIG_DIR_INITIALIZED" = "false" ]; then
    echo "Copy config files to system: /config > /etc"
    for create_config_name in /config/*; do
      if [ -n "$create_config_name" ]; then
        create_conf_name="$(basename "$create_config_name")"
        if [ -d "/etc/$create_conf_name" ] && [ -d "$create_config_name" ]; then
          mkdir -p "/etc/$create_conf_name/"
          cp -Rf "$create_config_name/." "/etc/$create_conf_name/" 2>/dev/null
        elif [ -e "/etc/$create_conf_name" ] && [ -e "$create_config_name" ]; then
          cp -Rf "$create_config_name" "/etc/$create_conf_name" 2>/dev/null
        fi
      fi
    done
    unset create_config_name create_conf_name
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Copy html files
if [ "$DATA_DIR_INITIALIZED" = "false" ] && [ -n "$WWW_ROOT_DIR" ]; then
  if [ -d "$DEFAULT_DATA_DIR/data/htdocs" ]; then
    __is_dir_empty "$WWW_ROOT_DIR/" || cp -Rf "$DEFAULT_DATA_DIR/data/htdocs/." "$WWW_ROOT_DIR/" 2>/dev/null
  fi
fi
if [ -n "$WWW_ROOT_DIR" ]; then
  if [ -d "$DEFAULT_DATA_DIR/htdocs/www" ] && [ ! -d "$WWW_ROOT_DIR" ]; then
    mkdir -p "$WWW_ROOT_DIR"
    cp -Rf "$DEFAULT_DATA_DIR/htdocs/www/" "$WWW_ROOT_DIR"
    [ -f "$WWW_ROOT_DIR/htdocs/www/health/index.txt" ] || echo "OK" >"$WWW_ROOT_DIR/htdocs/www/health/index.txt"
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -d "$SSL_DIR" ] || mkdir -p "$SSL_DIR"
if [ "$SSL_ENABLED" = "true" ] || [ "$SSL_ENABLED" = "yes" ]; then
  if [ -f "$SSL_CERT" ] && [ -f "$SSL_KEY" ]; then
    SSL_ENABLED="true"
    if [ -n "$SSL_CA" ] && [ -f "$SSL_CA" ]; then
      mkdir -p "$SSL_DIR/certs"
      cat "$SSL_CA" >>"/etc/ssl/certs/ca-certificates.crt"
      cp -Rf "/." "$SSL_DIR/"
    fi
  else
    [ -d "$SSL_DIR" ] || mkdir -p "$SSL_DIR"
    __create_ssl_cert
  fi
  type update-ca-certificates &>/dev/null && update-ca-certificates
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# setup the smtp server
__setup_mta
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__run_pre
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$ENTRYPOINT_CONFIG_INIT_FILE" ]; then
  ENTRYPOINT_FIRST_RUN="no"
elif [ -d "/config" ]; then
  echo "Initialized on: $INIT_DATE" >"$ENTRYPOINT_CONFIG_INIT_FILE"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Check if this is a new container
if [ -f "$ENTRYPOINT_DATA_INIT_FILE" ]; then
  DATA_DIR_INITIALIZED="true"
elif [ -d "/data" ]; then
  echo "Initialized on: $INIT_DATE" >"$ENTRYPOINT_DATA_INIT_FILE"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$ENTRYPOINT_CONFIG_INIT_FILE" ]; then
  CONFIG_DIR_INITIALIZED="true"
elif [ -d "/config" ]; then
  echo "Initialized on: $INIT_DATE" >"$ENTRYPOINT_CONFIG_INIT_FILE"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$ENTRYPOINT_PID_FILE" ]; then
  START_SERVICES="no"
  ENTRYPOINT_MESSAGE="no"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ "$ENTRYPOINT_MESSAGE" = "yes" ] && echo "Container ip address is: $CONTAINER_IP4_ADDRESS"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Show configured listing processes
if [ -n "$ENV_PORTS" ]; then
  show_port=""
  for port in $ENV_PORTS; do [ -n "$port" ] && show_port+="$(printf '%s ' "$port") "; done
  printf '%s\n' "The following ports are open: $show_port"
  unset port show_port
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Show message
__run_message
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Just start services
START_SERVICES="${START_SERVICES:-SYSTEM_INIT}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Begin options
case "$1" in
--help) # Help message
  echo 'Docker container for '$APPNAME''
  echo "Usage: $APPNAME [cron exec start init shell certbot ssl procs ports healthcheck backup command]"
  echo ""
  exit 0
  ;;

cron)
  shift 1
  __cron "$@" &
  ;;

backup) # backup data and config dirs
  shift 1
  save="${1:-$BACKUP_DIR}"
  backupExit=0
  date="$(date '+%Y%m%d-%H%M')"
  file="$save/$date.tar.gz"
  echo "Backing up /data /config to $file"
  sleep 1
  tar cfvz "$file" --exclude="$save" "/data" "/config" || backupExit=1
  backupExit=$?
  [ $backupExit -eq 0 ] && echo "Backed up /data /config has finished" || echo "Backup of /data /config has failed"
  exit $backupExit
  ;;

healthcheck) # Docker healthcheck
  healthStatus=0
  services="${SERVICES_LIST:-$@}"
  healthEnabled="${HEALTH_ENABLED:-}"
  healthPorts="${WEB_SERVER_PORTS:-}"
  healthEndPoints="${HEALTH_ENDPOINTS:-}"
  healthMessage="Everything seems to be running"
  services="${services//,/ }"
  [ "$healthEnabled" = "yes" ] || exit 0
  for proc in $services; do
    if [ -n "$proc" ]; then
      if ! __pgrep "$proc"; then
        echo "$proc is not running" >&2
        status=$((status + 1))
      fi
    fi
  done
  for port in $ports; do
    if [ -n "$(type -P netstat)" ] && [ -n "$port" ]; then
      netstat -taupln | grep -q ":$port " || healthStatus=$((healthStatus + 1))
    fi
  done
  for endpoint in $healthEndPoints; do
    if [ -n "$endpoint" ]; then
      __curl "$endpoint" || healthStatus=$((healthStatus + 1))
    fi
  done
  [ "$healthStatus" -eq 0 ] || healthMessage="Errors reported see: docker logs --follow $CONTAINER_NAME"
  [ -n "$healthMessage" ] && echo "$healthMessage"
  exit $healthStatus
  ;;

ports) # show open ports
  shift 1
  ports="$(__netstat -taupln | awk -F ' ' '{print $4}' | awk -F ':' '{print $2}' | sort --unique --version-sort | grep -v '^$' | grep '^' || echo '')"
  [ -n "$ports" ] && printf '%s\n%s\n' "The following are servers:" "$ports" | tr '\n' ' '
  exit $?
  ;;

procs) # show running processes
  shift 1
  ps="$(__ps axco command | grep -vE 'COMMAND|grep|ps' | sort -u || grep '^' || echo '')"
  [ -n "$ps" ] && printf '%s\n%s\n' "Found the following processes" "$ps" | tr '\n' ' '
  exit $?
  ;;

ssl) # setup ssl
  shift 1
  __create_ssl_cert
  exit $?
  ;;

certbot) # manage ssl certificate
  shift 1
  SSL_CERT_BOT="true"
  if [ "$1" = "create" ]; then
    shift 1
    __certbot "create"
  elif [ "$1" = "renew" ]; then
    shift 1
    __certbot "renew certonly --force-renew"
  else
    __exec_command "certbot" "$@"
  fi
  exit $?
  ;;

*/bin/sh | */bin/bash | bash | sh | shell) # Launch shell
  shift 1
  __exec_command "${@:-/bin/bash}"
  exit $?
  ;;

start) # show/start an init script
  shift 1
  PATH="/usr/local/etc/docker/init.d:$PATH"
  if [ $# -eq 0 ]; then
    scripts="$(ls -A "/usr/local/etc/docker/init.d")"
    [ -n "$scripts" ] && echo "$scripts" || echo "No scripts found in: /usr/local/etc/docker/init.d"
  elif [ -f "/usr/local/etc/docker/init.d/$1" ]; then
    eval "/usr/local/etc/docker/init.d/$1"
  elif [ "$1" = "all" ]; then
    shift $#
    echo "$$" >"/run/init.d/entrypoint.pid"
    __start_init_scripts "/usr/local/etc/docker/init.d"
  fi
  __no_exit
  ;;

*) # Execute primary command
  if [ "$START_SERVICES" = "yes" ] || [ ! -f "/run/init.d/entrypoint.pid" ]; then
    echo "$$" >"/run/init.d/entrypoint.pid"
    __start_init_scripts "/usr/local/etc/docker/init.d"
    __no_exit
  else
    __exec_command "$@"
  fi
  ;;
esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end of entrypoint
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ex: ts=2 sw=2 et filetype=sh
