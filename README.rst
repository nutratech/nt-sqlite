***********
 nt-sqlite
***********

.. image:: https://api.travis-ci.com/nutratech/nt-sqlite.svg?branch=master
    :target: https://travis-ci.com/github/nutratech/nt-sqlite

Python, SQL and CSV files for setting up portable nt-sqlite database.

See CLI:    https://github.com/nutratech/cli

Pypi page:  https://pypi.org/project/nutra


Building the database
#########################

1. If you are committing database changes, add a line to :code:`data/version.csv` (e.g. :code:`id=4` is the latest in this case),

+-----+----------+-------------+------------------+
| id  | version  | created     | notes            |
+=====+==========+=============+==================+
| 1   | 0.0.0    | 2020-09-22  | initial release  |
+-----+----------+-------------+------------------+
| 2   | 0.0.1    | 2021-05-21  | bump version     |
+-----+----------+-------------+------------------+
| 3   | 0.0.2    | 2021-05-24  | remove guids     |
+-----+----------+-------------+------------------+
| 4   | 0.0.3    | 2021-05-24  | general cleanup  |
+-----+----------+-------------+------------------+

2. Create the database with,

.. code-block:: bash

    python sql/__init__.py

3. Verify the tables (again inside the SQL shell :code:`sqlite3 nutra.sqlite`),

.. code-block:: sql

    .tables
    SELECT * FROM versions;
    .exit

4. If everything looks good, commit and update submodules in the ``cli`` (python) and ``nt-android`` (java) repos.


Tables (Relational Design)
##########################

See :code:`sql/tables.sql` for details.

This is frequently updated, see :code:`docs/` for more info.

.. image:: docs/nt.svg
