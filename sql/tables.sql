-- nt-sqlite, an sqlite3 database for embedded clients
-- Copyright (C) 2018-2022  Shane Jaroch <chown_tee@proton.me>
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
CREATE TABLE `version` (
  id integer PRIMARY KEY AUTOINCREMENT,
  `version` text NOT NULL UNIQUE,
  created date NOT NULL,
  notes text
);

-- NOTE: INSERT INTO statements for version, bmr_eq, bf_eq? Don't maintain as CSV?
-- TODO: enforce FK constraint across two DBs?
--
---------------------------------
-- Equations
---------------------------------
CREATE TABLE bmr_eq (
  id integer PRIMARY KEY AUTOINCREMENT,
  name text NOT NULL UNIQUE
);

CREATE TABLE bf_eq (
  id integer PRIMARY KEY AUTOINCREMENT,
  name text NOT NULL UNIQUE
);

--
--------------------------------
-- Profile table
--------------------------------
-- TODO: active profile? Decide what belongs here, vs. in prefs.json (if at all)
CREATE TABLE profile (
  id integer PRIMARY KEY AUTOINCREMENT,
  name text NOT NULL UNIQUE,
  gender text,
  dob date,
  act_lvl int DEFAULT 2, -- [1, 2, 3, 4, 5]
  goal_wt real,
  goal_bf real,
  bmr_eq_id int DEFAULT 1,
  bf_eq_id int DEFAULT 1,
  created int DEFAULT (strftime ('%s', 'now')),
  FOREIGN KEY (bmr_eq_id) REFERENCES bmr_eq (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (bf_eq_id) REFERENCES bf_eq (id) ON UPDATE CASCADE ON DELETE CASCADE
);

--
--------------------------------
-- Recipe
--------------------------------
CREATE TABLE recipe (
  id integer PRIMARY KEY AUTOINCREMENT,
  tagname text NOT NULL UNIQUE,
  name text NOT NULL UNIQUE,
  created int DEFAULT (strftime ('%s', 'now'))
);

CREATE TABLE recipe_dat (
  recipe_id int NOT NULL,
  food_id int NOT NULL,
  grams real NOT NULL,
  notes text,
  created int DEFAULT (strftime ('%s', 'now')),
  PRIMARY KEY (recipe_id, food_id),
  FOREIGN KEY (recipe_id) REFERENCES recipe (id) ON UPDATE CASCADE ON DELETE CASCADE
);

--
--------------------------------
-- Custom foods
--------------------------------
CREATE TABLE custom_food (
  id integer PRIMARY KEY AUTOINCREMENT,
  tagname text NOT NULL UNIQUE,
  name text NOT NULL UNIQUE,
  created int DEFAULT (strftime ('%s', 'now'))
);

CREATE TABLE cf_dat (
  cf_id int NOT NULL,
  nutr_id int NOT NULL, -- no FK constraining on usda :[
  nutr_val real NOT NULL,
  notes text,
  created int DEFAULT (strftime ('%s', 'now')),
  PRIMARY KEY (cf_id, nutr_id),
  FOREIGN KEY (cf_id) REFERENCES custom_food (id) ON UPDATE CASCADE ON DELETE CASCADE
);

--
--------------------------------
-- Food (and recipe) logs
--------------------------------
CREATE TABLE meal_name (
  -- predefined, includes standard three, snacks, brunch, and 3 optional/extra meals
  id integer PRIMARY KEY AUTOINCREMENT,
  name text NOT NULL
);

CREATE TABLE food_log (
  id integer PRIMARY KEY AUTOINCREMENT,
  profile_id int NOT NULL,
  date int DEFAULT (strftime ('%s', 'now')),
  meal_id int NOT NULL,
  -- NOTE: do we want separate tables for logging `food_id` vs. `custom_food_id`?
  food_id int,
  custom_food_id int,
  msre_id int NOT NULL,
  amt real NOT NULL,
  created int DEFAULT (strftime ('%s', 'now')),
  FOREIGN KEY (profile_id) REFERENCES profile (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (meal_id) REFERENCES meal_name (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (custom_food_id) REFERENCES custom_food (id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- TODO: support msre_id for recipe
CREATE TABLE recipe_log (
  id integer PRIMARY KEY AUTOINCREMENT,
  profile_id int NOT NULL,
  date int DEFAULT (strftime ('%s', 'now')),
  meal_id int NOT NULL,
  recipe_id int NOT NULL,
  grams real NOT NULL,
  created int DEFAULT (strftime ('%s', 'now')),
  FOREIGN KEY (profile_id) REFERENCES profile (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (meal_id) REFERENCES meal_name (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (recipe_id) REFERENCES recipe (id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- TODO: CREATE TABLE custom_food_log ( ... );
--
--------------------------------
-- Custom RDAs
--------------------------------
CREATE TABLE rda (
  profile_id int NOT NULL,
  nutr_id int NOT NULL,
  rda real NOT NULL,
  PRIMARY KEY (profile_id, nutr_id),
  FOREIGN KEY (profile_id) REFERENCES profile (id) ON UPDATE CASCADE ON DELETE CASCADE
);

--
--------------------------------
-- Food costs
--------------------------------
-- Case for no FK?  e.g. points to food OR custom_food?
-- Leave edge cases potentially dangling (should never happen)
-- Does this simplify imports with a potential `guid` column?
CREATE TABLE food_cost (
  food_id int,
  custom_food_id int,
  profile_id int NOT NULL,
  cost real NOT NULL,
  PRIMARY KEY (food_id, custom_food_id, profile_id),
  FOREIGN KEY (custom_food_id) REFERENCES custom_food (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (profile_id) REFERENCES profile (id) ON UPDATE CASCADE ON DELETE CASCADE
);

--
--------------------------------
-- Bug report, message queues
--------------------------------
-- NOTE: be sure to SELECT version (latest) to include on bug report too
CREATE TABLE bug (
  id integer PRIMARY KEY AUTOINCREMENT,
  profile_id int,
  created int DEFAULT (strftime ('%s', 'now')),
  arguments text,
  activity text,
  stack text,
  -- e.g. OS, Python / Android version
  client_info json,
  -- e.g. app version
  app_info json,
  user_details json,
  submitted tinyint DEFAULT 0,
  UNIQUE (arguments, stack),
  FOREIGN KEY (profile_id) REFERENCES profile (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE msg (
  id integer PRIMARY KEY AUTOINCREMENT,
  profile_id int,
  msg_id int NOT NULL,
  created int,
  received int DEFAULT (strftime ('%s', 'now')),
  header text,
  body text,
  UNIQUE (profile_id, msg_id),
  FOREIGN KEY (profile_id) REFERENCES profile (id) ON UPDATE CASCADE ON DELETE CASCADE
);
