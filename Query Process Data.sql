-- 1. Prepare
-- Membuat Database --
CREATE DATABASE project;

-- Membuat Tabel --
CREATE TABLE data(
	patientid VARCHAR,
	appointmentid VARCHAR,
	gender VARCHAR,
	scheduledday DATE,
	appointmentday DATE,
	age INT, 
	neighbourhood VARCHAR,
	scholarship BOOLEAN, 
	hipertension BOOLEAN,
	diabetes BOOLEAN,
	alcoholism BOOLEAN,
	handcap BOOLEAN,
	sms_received BOOLEAN,
	showed_up BOOLEAN,
	date_diff INT
)

-- Mengecek Data --
SELECT * FROM data
	
--------------------------------------------------
-- 2. Process
-- Mengecek kelengkapan data patientid dan appointmentid
SELECT 
	COUNT(*) AS NULL_data
FROM 
	data
WHERE 
	patientid IS NULL OR appointmentid IS NULL

-- Mengecek duplikasi data patientid dan appointmentid
SELECT 
	COUNT(*) AS duplicate_combination
FROM (
    SELECT patientid, appointmentid
    FROM data
    GROUP BY patientid, appointmentid
    HAVING COUNT(*) > 1
) 
	
-- Menangani duplikasi data --
-- yang unik adalah appointment id
SELECT appointmentid
FROM data
GROUP BY appointmentid
HAVING COUNT(*) > 1;

SELECT patientid
FROM data
GROUP BY patientid
HAVING COUNT(*) > 1;

-- Melakukan penggelompokkan usia
-- Menambahkan tabel age_group
ALTER TABLE data
ALTER COLUMN age_group TYPE VARCHAR(50);

UPDATE data
SET age_group = CASE
    WHEN age BETWEEN 0 AND 12 THEN 'Children'
    WHEN age BETWEEN 13 AND 17 THEN 'Teenagers'
    WHEN age BETWEEN 18 AND 24 THEN 'Young Adults'
    WHEN age BETWEEN 25 AND 64 THEN 'Adults'
    ELSE 'Elderly '
END;

SELECT * FROM DATA

-- Mengubah tulisan menjadi proper case
UPDATE data
SET neighbourhood = INITCAP(neighbourhood);

-- Mengekstrak bulan dari date
-- Menambahkan tabel month
ALTER TABLE data
ADD month_scheduledday INTEGER;

UPDATE data
SET month_scheduledday = EXTRACT(MONTH FROM scheduledday);

ALTER TABLE data
ADD month_appointmentday INTEGER;

UPDATE data
SET month_appointmentday = EXTRACT(MONTH FROM appointmentday);

ALTER TABLE data
DROP COLUMN year;

ALTER TABLE data
DROP COLUMN month;

-- Mendefinisikan kalau scheduled day = appointment day berarti same day, tetapi kalau appointmentday tidak sama berarti different days
ALTER TABLE data
ADD appointment_status VARCHAR(15);

UPDATE data
SET appointment_status = CASE
    WHEN scheduledday = appointmentday THEN 'Same Day'
    ELSE 'Different Day'
END;

--------------------------------------------------

ALTER TABLE data
ADD status VARCHAR(15);

UPDATE data
SET status = CASE
    WHEN showed_up = true THEN 'Hadir'
    ELSE 'Tidak Hadir'
END;

select * from data
---
ALTER TABLE data
ADD meeting_number INTEGER;

WITH ranked_meetings AS (
    SELECT
        patientid,
        appointmentday,
        ROW_NUMBER() OVER (PARTITION BY patientid ORDER BY appointmentday) AS meeting_number
    FROM data
)
UPDATE data
SET meeting_number = ranked_meetings.meeting_number
FROM ranked_meetings
WHERE data.patientid = ranked_meetings.patientid
AND data.appointmentday = ranked_meetings.appointmentday;





