#!/bin/bash

# Carregar variáveis do arquivo .env
if [ -f .env ]; then
    export $(cat .env | sed 's/#.*//g' | xargs)
fi

if test -z "$TOKEN"; then
    echo "Erro: Token não informado..."
    exit 1
fi

DOCKER_USER=dopanel

echo "$TOKEN" | docker --config ./.docker-config login --username $DOCKER_USER --password-stdin

docker pull php:8.1-fpm-alpine
docker pull php:8.2-fpm-alpine
docker pull php:8.3-fpm-alpine

export DOCKER_CONFIG=./.docker-config

# Criar e usar o builder com suporte multiplataforma
docker buildx create --name $DOCKER_USER --use
docker buildx inspect --bootstrap

docker buildx build -f ./Dockerfile-8.1 --push --platform linux/amd64,linux/amd64/v2,linux/amd64/v3,linux/386 -t $DOCKER_USER/php-postgres-cron-logrotate-laravel-optimized:8.1-fpm-alpine .
docker buildx build -f ./Dockerfile-8.2 --push --platform linux/amd64,linux/amd64/v2,linux/amd64/v3,linux/386 -t $DOCKER_USER/php-postgres-cron-logrotate-laravel-optimized:8.2-fpm-alpine .
docker buildx build -f ./Dockerfile-8.3 --push --platform linux/amd64,linux/amd64/v2,linux/amd64/v3,linux/386 -t $DOCKER_USER/php-postgres-cron-logrotate-laravel-optimized:8.3-fpm-alpine .
docker buildx build -f ./Dockerfile-8.3 --push --platform linux/amd64,linux/amd64/v2,linux/amd64/v3,linux/386 -t $DOCKER_USER/php-postgres-cron-logrotate-laravel-optimized .

# Remover o builder após o build
docker buildx rm $DOCKER_USER