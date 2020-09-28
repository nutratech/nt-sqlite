-- nt-sqlite, an sqlite3 database for nutratracker clients
-- Copyright (C) 2020  Shane Jaroch <nutratracker@gmail.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

PRAGMA foreign_keys = 1;

CREATE TABLE version( id integer PRIMARY KEY AUTOINCREMENT, version text NOT NULL, created date NOT NULL, notes text
);

INSERT INTO version(version, created, notes)
  VALUES ('0.0.0', '2020-09-22', 'initial release');

--
---------------------------------
-- Equations
---------------------------------

CREATE TABLE bmr_eqs (
  id integer PRIMARY KEY AUTOINCREMENT,
  bmr_eq text
);

CREATE TABLE bf_eqs (
  id integer PRIMARY KEY AUTOINCREMENT,
  bf_eq text
);

--
--------------------------------
-- Users table
--------------------------------

CREATE TABLE users (
  id integer PRIMARY KEY AUTOINCREMENT,
  name text NOT NULL UNIQUE,
  guid text NOT NULL DEFAULT (lower(hex (randomblob (16)))) UNIQUE,
  created int DEFAULT (strftime ('%s', 'now')),
  eula int DEFAULT 0,
  gender text,
  dob date,
  act_lvl int DEFAULT 2, -- [1, 2, 3, 4, 5]
  goal_wt real,
  goal_bf real,
  bmr_id int DEFAULT 1,
  bf_id int DEFAULT 1,
  FOREIGN KEY (bmr_id) REFERENCES bmr_eqs (id) ON UPDATE CASCADE,
  FOREIGN KEY (bf_id) REFERENCES bf_eqs (id) ON UPDATE CASCADE
);

--
--------------------------------
-- Biometrics
--------------------------------

CREATE TABLE biometrics (
  -- TODO: support custom biometrics and sync?
  id integer PRIMARY KEY AUTOINCREMENT,
  name text NOT NULL UNIQUE,
  unit text,
  created int DEFAULT (strftime ('%s', 'now'))
);

CREATE TABLE biometric_log (
  id integer PRIMARY KEY AUTOINCREMENT,
  guid text NOT NULL DEFAULT (lower(hex (randomblob (16)))) UNIQUE,
  user_id int NOT NULL,
  date date DEFAULT CURRENT_DATE,
  biometric_id int NOT NULL,
  value real NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE,
  FOREIGN KEY (biometric_id) REFERENCES biometrics (id) ON UPDATE CASCADE
);

--
--------------------------------
-- Recipes
--------------------------------

CREATE TABLE recipes (
  id integer PRIMARY KEY AUTOINCREMENT,
  guid text NOT NULL DEFAULT (lower(hex (randomblob (16)))) UNIQUE,
  created int DEFAULT (strftime ('%s', 'now')),
  name text NOT NULL
);

CREATE TABLE recipe_dat (
  recipe_id int NOT NULL,
  -- TODO: enforce FK constraint across two DBs?
  food_id int NOT NULL,
  grams real NOT NULL,
  notes text,
  UNIQUE (recipe_id, food_id),
  FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON UPDATE CASCADE
);

--
--------------------------------
-- Food (and recipe) logs
--------------------------------

CREATE TABLE meal_names (
  id integer PRIMARY KEY AUTOINCREMENT,
  name text NOT NULL
);

CREATE TABLE food_log (
  id integer PRIMARY KEY AUTOINCREMENT,
  guid text NOT NULL DEFAULT (lower(hex (randomblob (16)))) UNIQUE,
  user_id int,
  date date DEFAULT CURRENT_DATE,
  meal_id int,
  grams real NOT NULL,
  -- TODO: enforce FK constraint across two DBs?
  food_id int,
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE,
  FOREIGN KEY (meal_id) REFERENCES meal_names (id) ON UPDATE CASCADE
);

CREATE TABLE recipe_log (
  id integer PRIMARY KEY AUTOINCREMENT,
  guid text NOT NULL DEFAULT (lower(hex (randomblob (16)))) UNIQUE,
  user_id int,
  date date DEFAULT CURRENT_DATE,
  meal_id int,
  grams real NOT NULL,
  recipe_id int,
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE,
  FOREIGN KEY (meal_id) REFERENCES meal_names (id) ON UPDATE CASCADE,
  FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON UPDATE CASCADE
);

--
--------------------------------
-- Custom RDAs
--------------------------------

CREATE TABLE rda (
  user_id int NOT NULL,
  -- TODO: enforce FK constraint across two DBs?
  nutr_id int NOT NULL,
  rda real NOT NULL,
  synced int DEFAULT 0,
  UNIQUE (user_id, nutr_id),
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE
);

CREATE TRIGGER rda_sync
  AFTER UPDATE OF rda ON rda
BEGIN
  UPDATE rda SET synced = 0
WHERE
  NEW.user_id = user_id AND NEW.nutr_id = nutr_id;

END;

--
--------------------------------
-- Custom RDAs
--------------------------------

CREATE TABLE sync_data (
  id integer PRIMARY KEY AUTOINCREMENT,
  tablename text NOT NULL,
  guid text,
  `constraint` text, -- e.g. "(a, b)" in "UNIQUE (a, b)" or "ON CONFLICT (a, b) DO ..."
  action text NOT NULL -- insert, delete, update
);

