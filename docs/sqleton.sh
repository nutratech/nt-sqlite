#!/bin/bash -e

cd "$(dirname "$0")"
cd ..

sqleton -o docs/nt.svg sql/nt.sqlite3
