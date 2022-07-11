#!/bin/bash -e

set -x

cd "$(dirname "$0")"
cd ..

SQLITE3_FILE=sql/nt.sqlite3

test -f $SQLITE3_FILE

sqleton -o docs/nt.svg $SQLITE3_FILE
