--------------------------------
-- Weight
--------------------------------

SELECT
  date,
  users.name,
  notes,
  (
    SELECT
      value
    FROM
      bio_log_entry
    WHERE
      biometric_id = 2
      AND log_id = biometric_log.id) AS weight
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

