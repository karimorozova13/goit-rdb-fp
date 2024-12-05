DROP SCHEMA IF EXISTS pandemic;

CREATE SCHEMA IF NOT EXISTS pandemic;

USE pandemic;

SELECT * FROM infectious_cases LIMIT 10;

CREATE TABLE countries(id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(255), code VARCHAR(255));

INSERT INTO countries (name, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

select * from countries;

ALTER TABLE infectious_cases
ADD COLUMN country_id INT,
ADD CONSTRAINT fk_country
FOREIGN KEY (country_id) REFERENCES countries(id);

UPDATE infectious_cases ic
JOIN countries c
ON ic.Entity = c.name AND ic.Code = c.code
SET ic.country_id = c.id;

ALTER TABLE infectious_cases
DROP COLUMN Entity,
DROP COLUMN Code;

UPDATE infectious_cases
SET Number_rabies = NULL
WHERE Number_rabies = '';

SELECT 
    c.name AS Entity,
    c.code AS Code,
    AVG(ic.Number_rabies) AS avg_rabies,
    MIN(ic.Number_rabies) AS min_rabies,
    MAX(ic.Number_rabies) AS max_rabies,
    SUM(ic.Number_rabies) AS sum_rabies
FROM infectious_cases ic
JOIN countries c
ON ic.country_id = c.id
WHERE ic.Number_rabies IS NOT NULL
GROUP BY c.name, c.code
ORDER BY avg_rabies DESC
LIMIT 10;

SELECT 
    Year,
    STR_TO_DATE(CONCAT(Year, '-01-01'), '%Y-%m-%d') AS first_january_date,
    CURDATE() AS cur_date,
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(CONCAT(Year, '-01-01'), '%Y-%m-%d'), CURDATE()) AS year_difference
FROM infectious_cases
WHERE Year IS NOT NULL;

DELIMITER //

CREATE FUNCTION year_difference(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE first_january_date DATE;
    DECLARE diff INT;
    
    SET first_january_date = STR_TO_DATE(CONCAT(input_year, '-01-01'), '%Y-%m-%d');
    
    SET diff = TIMESTAMPDIFF(YEAR, first_january_date, CURDATE());
    
    RETURN diff;
END //

DELIMITER ;

SELECT 
    Year,
    year_difference(Year) AS year_difference
FROM infectious_cases
WHERE Year IS NOT NULL;







