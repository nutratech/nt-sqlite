#!/bin/bash -ex

cd "$(dirname "$0")"

for t in $(sqlite3 nt.sqlite '.tables'); do
    sqlite3 -csv nt.sqlite "SELECT * FROM $t" > "data/$t.csv"
done
