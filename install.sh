#!/bin/bash

# SETTINGS
DOCKER_COMPOSE_FILE="docker-compose.yml"
DB_IMPORT="/var/www/db/wordpress-export.xml"
MYSQL_ROOT_PASSWORD="50UP3RH4X!"

# IMAGES
WORDPRESS_IMAGE="wordpress:4.9.1"
MYSQL_IMAGE="mysql:5.7"
WPCLI_IMAGE="tatemz/wp-cli"

# ############################
# DO NOT EDIT BEYOND THIS LINE

# Argument -i for install overwrites defined location
# of imported backup/database
if [ -z $i ]; then
    DB_IMPORT=$i
fi

touch "${DOCKER_COMPOSE_FILE}"
cat > "${DOCKER_COMPOSE_FILE}" <<EOL
version: '2'
services:
  wordpress:
    depends_on:
      - db
    image: $WORDPRESS_IMAGE
    restart: always
    volumes:
      - ./wp-content:/var/www/html/wp-content
      - ./db:/var/www/db
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_PASSWORD: password
    ports:
      - 80:80 # Expose http and https
      - 443:443
    networks:
      - back
  db:
    image: $MYSQL_IMAGE
    restart: always
    volumes:
       - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
    networks:
      - back
  phpmyadmin:
    depends_on:
      - db
    image: phpmyadmin/phpmyadmin
    restart: always
    ports:
      - 8080:80
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
    networks:
      - back
  wpcli:
    image: $WPCLI_IMAGE
    volumes_from:
      - wordpress
    links:
      - db:mysql
    entrypoint: wp
    command: "import $DB_IMPORT --authors=create --debug"
networks:
  back:
volumes:
  db_data:

EOL

docker-compose up -d
