.DEFAULT_GOAL := build

clean:
	find sql/ -name __pycache__ | xargs rm -rf
	rm -f  sql/nt.sqlite

build:
	python sql/__init__.py

test:
	sqlite3 sql/nt.sqlite \
		'SELECT * FROM bf_eqs;' \
		'SELECT * FROM biometrics;' \
		'SELECT * FROM bmr_eqs;' \
		'SELECT * FROM meal_name;' \
		'SELECT * FROM version;' \
