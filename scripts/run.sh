#!/bin/bash

env_file=".env-dev"
JB_ENGINE_VERSION=0.0.1

while getopts ":e:v:" opt; do
  case $opt in
    e) env_file="$OPTARG" ;;
    v) JB_ENGINE_VERSION="$OPTARG" ;;
    *) echo "Usage: $0 [-e env_file] [service1 service2 ...]"
       exit 1 ;;
  esac
done

# Remove processed options from the arguments list
shift $((OPTIND -1))

mkdir -p ./server/dist

cd ../Jugalbandi-Studio-Engine/ && ./build.sh ${JB_ENGINE_VERSION}
cd -

cd ../PwR-NL2DSL/ && poetry install && poetry build
cd -
cp ../PwR-NL2DSL/dist/*.whl ./server/dist  

cd ../PwR-Studio/lib && poetry install && poetry build
cd -
cp ../PwR-Studio/lib/dist/*.whl ./server/dist  



if grep -qi microsoft /proc/version && grep WSL2 /proc/version; then
    PWRHOST=$(hostname -I | awk '{print $1}')
    export PWRHOST
    export PWR_SERVER_HOST=http://${PWRHOST}:3000
    export PWR_KAFKA_BROKER=${PWRHOST}:9092
    export POSTGRES_DATABASE_HOST=${PWRHOST}
else
    export PWRHOST="localhost"
    export PWR_SERVER_HOST=http://api:3000
    export PWR_KAFKA_BROKER=kafka:9092
    export POSTGRES_DATABASE_HOST="localhost"
fi

export JB_ENGINE_VERSION=$JB_ENGINE_VERSION

docker compose build $@
docker compose --env-file "$env_file" up $@
