-- Creating a flat mart table for sales data

CREATE SCHEMA IF NOT EXISTS flat_mart;


SELECT '==LOADING FLAT MART==' AS info;
CREATE TABLE IF NOT EXISTS flat_mart.job_postings_flat AS
SELECT 

    jp.job_id, 
    jp.company_id, 
    jp.job_title_short, 
    jp.job_title, 
    jp.job_location, 
    jp.job_via, 
    jp.job_schedule_type, 
    jp.job_work_from_home, 
    jp.search_location, 
    jp.job_posted_date, 
    jp.job_no_degree_mention, 
    jp.job_health_insurance, 
    jp.job_country, 
    jp.salary_rate, 
    jp.salary_year_avg, 
    jp.salary_hour_avg,
    cd.company_id,
    cd.name AS company_name,
    ARRAY_AGG(
        STRUCT_PACK(
            type := sd.type,
            skills := sd.skills
        )
    ) AS skills_and_types

FROM job_postings_fact AS jp

LEFT JOIN company_dim AS cd 
ON jp.company_id = cd.company_id

LEFT JOIN skills_job_dim AS sjd
ON jp.job_id = sjd.job_id

LEFT JOIN skills_dim AS sd
ON sjd.skill_id = sd.skill_id

GROUP BY ALL;


--Validation section to make sure the flat mart runs properly

SELECT 'Flat Mart Job Postings' AS table_name, COUNT(*) AS total_count FROM flat_mart.job_postings_flat;

SELECT '==FLAT MART SAMPLE DATA==' AS info;

SELECT * 
FROM flat_mart.job_postings_flat
LIMIT 10;