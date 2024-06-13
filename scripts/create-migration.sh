#!/bin/bash

msg=$1

python3 -m venv .venv
source .venv/bin/activate
pip3 install alembic psycopg2-binary


if grep -qi microsoft /proc/version && grep -q WSL2 /proc/version; then
    PWRHOST=$(hostname -I | awk '{print $1}')
    export PWR_KAFKA_BROKER=${PWRHOST}:9092
    export POSTGRES_DATABASE_HOST=${PWRHOST}
    echo "Setting Kakfa & Postgres host by WSL2 IP: ${PWRHOST}"
else
    export PWR_KAFKA_BROKER=kafka:9092
    export POSTGRES_DATABASE_HOST=postgres
    echo "Setting Kakfa & Postgres host by docker-compose service name: kafka, postgres"
fi


set -a
source .env-dev
set +a

alembic revision --autogenerate -m "$msg"