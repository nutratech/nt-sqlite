--------------------------------
-- Weight
--------------------------------

SELECT
  users.name,
  date,
  ROUND(bio_log_entry.value * 2.204, 1) AS weight,
  tags,
  notes
FROM
  biometric_log
  INNER JOIN users ON user_id = users.id
  INNER JOIN bio_log_entry ON biometric_id = 2
    AND log_id = biometric_log.id
WHERE
  users.name = 'Mark';

--------------------------------
-- Pulse and blood pressure
--------------------------------

SELECT DISTINCT
  date,
  users.name,
  tags,
  notes,
  CAST(sys.value AS int) || '/' || CAST(dia.value AS int) AS pressure,
  CAST(pulse.value AS int) AS pulse
FROM
  biometric_log
  INNER JOIN users ON user_id = users.id
  INNER JOIN bio_log_entry pulse ON pulse.biometric_id = 22
    AND pulse.log_id = biometric_log.id
  INNER JOIN bio_log_entry sys ON sys.biometric_id = 23
    AND sys.log_id = biometric_log.id
  INNER JOIN bio_log_entry dia ON dia.biometric_id = 24
    AND dia.log_id = biometric_log.id
WHERE
  users.name = 'Mark';

--------------------------------
-- Meas, skinfolds, statics
--------------------------------

SELECT
  date,
  users.name,
  height.value AS height,
  wrist.value AS wrist,
  ankle.value AS ankle
FROM
  biometric_log
  INNER JOIN users ON user_id = users.id
  LEFT JOIN bio_log_entry height ON height.biometric_id = 1
    AND height.log_id = biometric_log.id
  LEFT JOIN bio_log_entry wrist ON wrist.biometric_id = 3
    AND wrist.log_id = biometric_log.id
  LEFT JOIN bio_log_entry ankle ON ankle.biometric_id = 4
    AND ankle.log_id = biometric_log.id
WHERE
  height.value
  OR wrist.value
  OR ankle.value;

--------------------------------
-- OLD: pulse/bp
--------------------------------

SELECT
  date,
  users.name,
  (
    SELECT
      value
    FROM
      bio_log_entry
    WHERE
      biometric_id = 23
      AND log_id = biometric_log.id) AS sys,
  (
    SELECT
      value
    FROM
      bio_log_entry
    WHERE
      biometric_id = 24
      AND log_id = biometric_log.id) AS dia,
  (
    SELECT
      value
    FROM
      bio_log_entry
    WHERE
      biometric_id = 22
      AND log_id = biometric_log.id) AS pulse,
  notes
FROM
  biometric_log
  INNER JOIN users ON user_id = users.id;

-- LEFT JOIN bio_log_entry ON biometric_id IN (22,23,24);
SELECT
  date,
  users.name,
  notes,
  (
    SELECT
      (
        SELECT
          value
        FROM
          bio_log_entry
        WHERE
          biometric_id = 23
          AND log_id = biometric_log.id) || '/' || (
          SELECT
            value
          FROM
            bio_log_entry
          WHERE
            biometric_id = 24
            AND log_id = biometric_log.id) || ' (' || (
            SELECT
              value
            FROM
              bio_log_entry
            WHERE
              biometric_id = 22
              AND log_id = biometric_log.id) || ' bpm)') AS summary
      FROM
        biometric_log
        INNER JOIN users ON user_id = users.id;

SELECT
  users.name,
  date,
  notes,
  biometrics.name,
  bio_log_entry.value
FROM
  biometric_log
  INNER JOIN users ON user_id = users.id
  INNER JOIN bio_log_entry ON log_id = biometric_log.id
  INNER JOIN biometrics ON biometric_id = biometrics.id;

