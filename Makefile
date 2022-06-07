SHELL=/bin/bash

.DEFAULT_GOAL := _help

# NOTE: must put a <TAB> character and two pound "\t##" to show up in this list.  Keep it brief! IGNORE_ME
.PHONY: _help
_help:
	@grep -h "##" $(MAKEFILE_LIST) | grep -v IGNORE_ME | sed -e 's/##//' | column -t -s $$'\t'

.PHONY: clean
clean:	## Clean up build intermediates
	rm -f  sql/nt.sqlite
	rm -rf .mypy_cache/ .pytest_cache/
	find sql/ -name __pycache__ -o -name .pytest_cache | xargs rm -rf

.PHONY: build
build:	## Build sqlite image
	python -m sql

.PHONY: test
test:	## Cursory sanity check
	sqlite3 -csv -header \
		sql/nt.sqlite \
		'SELECT * FROM bf_eqs;' \
		'SELECT * FROM biometrics;' \
		'SELECT * FROM bmr_eqs;' \
		'SELECT * FROM meal_name;' \
		'SELECT * FROM version;' \

.PHONY: install
install:	## Copy sqlite file into ~/.nutra
	mkdir -p ~/.nutra
	cp sql/nt.sqlite ~/.nutra
