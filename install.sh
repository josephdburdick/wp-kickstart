#!/bin/bash

# SETTINGS
DOCKER_COMPOSE_FILE="docker-compose.yml"

mkdir -p wp-site && cd wp-site
touch "${DOCKER_COMPOSE_FILE}"

cat > "${DOCKER_COMPOSE_FILE}" <<EOL
version: '2'
services:
  my-wpdb:
    image: mariadb
    ports:
      - "8081:3306"
    environment:
      MYSQL_ROOT_PASSWORD: root

  my-wp:
    image: wordpress
    volumes:
      - ./:/var/www/html
    ports:
      - "8080:80"
    links:
      - my-wpdb:mysql
    environment:
      WORDPRESS_DB_PASSWORD: root

  my-wpcli:
    image: tatemz/wp-cli
    volumes_from:
      - my-wp
    links:
      - my-wpdb:mysql
    entrypoint: wp
    command: "--info"
EOL

docker-compose up -d
