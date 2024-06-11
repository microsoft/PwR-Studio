#!/bin/bash

sql="./scripts/base_queries.sql"


docker cp $sql pwr-studio-postgres-1:/home/db.sql

docker exec -i pwr-studio-postgres-1 psql -U postgres -d postgres -f /home/db.sql








