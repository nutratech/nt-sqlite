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

CREATE TABLE table_versions (
  tablename text PRIMARY KEY,
  version int NOT NULL
);

INSERT INTO table_versions
  VALUES ('table_versions', 1);

--
---------------------------------
-- Goals, equations, & statics
---------------------------------

INSERT INTO table_versions
  VALUES ('goals', 1), ('bmr_eqs', 1), ('bf_eqs', 1), ('lbm_eqs', 1);

CREATE TABLE goals (
  id integer PRIMARY KEY AUTOINCREMENT,
  goal_desc text
);

CREATE TABLE bmr_eqs (
  id integer PRIMARY KEY AUTOINCREMENT,
  bmr_eq text
);

CREATE TABLE bf_eqs (
  id integer PRIMARY KEY AUTOINCREMENT,
  bf_eq text DEFAULT 'NAVY' -- ['NAVY', '3SITE', '7SITE']
);

CREATE TABLE lbm_eqs (
  id integer PRIMARY KEY AUTOINCREMENT,
  lbm_eq text
);

INSERT INTO goals (goal_desc)
  VALUES ('LOSE'), ('GAIN'), ('MAINTAIN'), ('TRANSFORM');

INSERT INTO bmr_eqs (bmr_eq)
  VALUES ('HARRIS_BENEDICT'), ('KATCH_MACARDLE'), ('MIFFLIN_ST_JEOR'), ('CUNNINGHAM');

INSERT INTO bf_eqs (bf_eq)
  VALUES ('NAVY'), ('3SITE'), ('7SITE');

INSERT INTO lbm_eqs (lbm_eq)
  VALUES ('MARTIN_BERKHAN'), ('ERIC_HELMS'), ('CASEY_BUTT');

--
--------------------------------
-- Users and biometrics
--------------------------------

INSERT INTO table_versions
  VALUES ('users', 1), ('measurements', 1);

CREATE TABLE users (
  id integer PRIMARY KEY AUTOINCREMENT,
  name text NOT NULL,
  eula int DEFAULT 0,
  email text,
  gender text,
  dob date,
  act_lvl int DEFAULT 2, -- [1, 2, 3, 4, 5]
  goal_id int DEFAULT 3,
  goal_wt real,
  goal_bf real,
  bmr_id int DEFAULT 1,
  bf_id int DEFAULT 1,
  lbm_id int DEFAULT 1,
  created int DEFAULT (strftime ('%s', 'now')),
  UNIQUE (name),
  UNIQUE (email),
  FOREIGN KEY (goal_id) REFERENCES goals (id) ON UPDATE CASCADE,
  FOREIGN KEY (bmr_id) REFERENCES bmr_eqs (id) ON UPDATE CASCADE,
  FOREIGN KEY (bf_id) REFERENCES bf_eqs (id) ON UPDATE CASCADE,
  FOREIGN KEY (lbm_id) REFERENCES lbm_eqs (id) ON UPDATE CASCADE
);

CREATE TABLE measurements (
  id integer PRIMARY KEY AUTOINCREMENT,
  user_id int NOT NULL,
  -- Mass (kg)
  weight real,
  -- Kinostatics (cm)
  height int,
  wrist real,
  ankle real,
  -- Tape Measurements (cm)
  chest real,
  arm real,
  thigh real,
  calf real,
  shoulders real,
  waist real,
  hips real,
  neck real,
  forearm real,
  -- Skin Manifolds (mm)
  pectoral int,
  abdominal int,
  quadricep int,
  midaxillary int,
  subscapular int,
  tricep int,
  suprailiac int,
  -- Times
  date date DEFAULT CURRENT_DATE,
  created int DEFAULT (strftime ('%s', 'now')),
  updated int,
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE
);

--
--------------------------------
-- Biometrics
--------------------------------

INSERT INTO table_versions
  VALUES ('biometrics', 1), ('biometric_log', 1);

CREATE TABLE biometrics (
  id integer PRIMARY KEY AUTOINCREMENT,
  user_id int,
  name text NOT NULL,
  units text NOT NULL,
  created int DEFAULT (strftime ('%s', 'now')),
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE
);

CREATE TABLE biometric_log (
  id integer PRIMARY KEY AUTOINCREMENT,
  user_id int NOT NULL,
  biometric_id int NOT NULL,
  value real NOT NULL,
  created int DEFAULT (strftime ('%s', 'now')),
  updated int,
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE,
  FOREIGN KEY (biometric_id) REFERENCES biometrics (id) ON UPDATE CASCADE
);

--
--------------------------------
-- Recipes
--------------------------------

INSERT INTO table_versions
  VALUES ('recipes', 1), ('recipe_dat', 1), ('recipe_serv', 1);

CREATE TABLE recipes (
  id integer PRIMARY KEY AUTOINCREMENT,
  name text NOT NULL,
  user_id int NOT NULL,
  shared int DEFAULT 1,
  created int DEFAULT (strftime ('%s', 'now')),
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE
);

CREATE TABLE recipe_dat (
  id integer PRIMARY KEY AUTOINCREMENT,
  recipe_id int NOT NULL,
  -- TODO: enforce FK constraint across two DBs?
  food_id int NOT NULL,
  msre_id int NOT NULL,
  amount real NOT NULL,
  created int DEFAULT (strftime ('%s', 'now')),
  FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON UPDATE CASCADE
);

CREATE TABLE recipe_serv (
  id integer PRIMARY KEY AUTOINCREMENT,
  recipe_id int NOT NULL,
  msre_desc text NOT NULL,
  grams real NOT NULL,
  created int DEFAULT (strftime ('%s', 'now')),
  FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON UPDATE CASCADE
);

--
--------------------------------
-- Food logs
--------------------------------

INSERT INTO table_versions
  VALUES ('food_log', 1);

CREATE TABLE food_log (
  id integer PRIMARY KEY AUTOINCREMENT,
  user_id int,
  date date DEFAULT CURRENT_DATE,
  meal_name text,
  amount real NOT NULL,
  recipe_id int,
  -- TODO: enforce FK constraint across two DBs?
  msre_id int,
  food_id int,
  created int DEFAULT (strftime ('%s', 'now')),
  updated int,
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE,
  FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON UPDATE CASCADE
);

