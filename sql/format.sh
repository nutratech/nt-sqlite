#!/bin/bash -ex

cd "$(dirname "$0")"

# Format
pg_format -L -s 2 -w 80 tables.sql >tables.fmt.sql
mv tables.fmt.sql tables.sql

pg_format -L -s 2 -w 80 functions.sql >functions.fmt.sql
mv functions.fmt.sql functions.sql

