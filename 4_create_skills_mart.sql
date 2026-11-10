

SELECT '==CREATING SCHEMA AND TABLES FOR SKILLS MART==' AS info;

DROP SCHEMA IF EXISTS skills_mart CASCADE;

CREATE SCHEMA IF NOT EXISTS skills_mart;



--DIM table for skills
CREATE TABLE skills_mart.dim_skills (
    skill_id    INTEGER    PRIMARY KEY,
    skills      VARCHAR,
    type        VARCHAR
);
SELECT '==LOADING SKILLS DIMENSION TABLE==' AS info;
INSERT INTO  skills_mart.dim_skills(
    skill_id,
    skills,
    type
)

SELECT 
    skill_id,
    skills,
    type
FROM skills_dim;

--DIM table for dates
CREATE TABLE skills_mart.dim_date_month(
    
    month_start_date DATE PRIMARY KEY,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    quarter_name VARCHAR,
    year_quarter VARCHAR
);

SELECT '==LOADING DATE DIMENSION TABLE==' AS info;
INSERT INTO skills_mart.dim_date_month(
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date)::VARCHAR || '-Q' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS year_quarter
FROM job_postings_fact
ORDER BY month_start_date;



--


CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id INTEGER,
    month_start_date DATE,
    job_title_short VARCHAR,
    postings_count INTEGER,
    total_wfh_count INTEGER,
    total_health_insurance_count INTEGER,
    total_no_degree_requirement_count INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skills(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)
);

SELECT '==LOADING SKILL DEMAND FACT TABLE==' AS info;
INSERT INTO skills_mart.fact_skill_demand_monthly(
    skill_id,
    month_start_date,
    job_title_short,
    postings_count,
    total_wfh_count,
    total_health_insurance_count,
    total_no_degree_requirement_count
)
WITH job_postings_prep AS(

SELECT 
    sjd.skill_id,
    DATE_TRUNC('month', jp.job_posted_date) AS month_start_date,
    jp.job_posted_date,
    jp.job_title_short,
    CASE WHEN jp.job_work_from_home = TRUE THEN 1 ELSE 0 END AS Has_WFH,
    CASE WHEN jp.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
    CASE WHEN jp.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_requirement
FROM 
    job_postings_fact AS jp
INNER JOIN
    skills_job_dim AS sjd
ON
    jp.job_id = sjd.job_id
)

SELECT
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS postings_count,
    SUM(Has_WFH) AS total_wfh_count,
    SUM(has_health_insurance) AS total_health_insurance_count,
    SUM(no_degree_requirement) AS total_no_degree_requirement_count

FROM job_postings_prep
GROUP BY ALL
ORDER BY skill_id, month_start_date, job_title_short;

--VALIDATIONS

SELECT 'Skill Dimension' AS table_name, COUNT(*) AS total_count FROM skills_mart.dim_skills
UNION ALL
SELECT 'Date Dimension' AS table_name, COUNT(*) AS total_count FROM skills_mart.dim_date_month
UNION ALL
SELECT 'Skill Demand Fact' AS table_name, COUNT(*) AS total_count FROM skills_mart.fact_skill_demand_monthly;

SELECT '==SKILLS MART SAMPLE DATA==' AS info;
SELECT '==DIM SKILLS TABLE SAMPLE DATA==' AS info;
SELECT * from skills_mart.dim_skills LIMIT 10;

SELECT '==DIM DATE MONTH TABLE SAMPLE DATA==' AS info;
SELECT * from skills_mart.dim_date_month LIMIT 10;

SELECT '==FACT SKILL DEMAND MONTHLY TABLE SAMPLE DATA==' AS info;
SELECT * from skills_mart.fact_skill_demand_monthly LIMIT 10;
