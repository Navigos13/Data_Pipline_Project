-- INSTAL httpfs;
-- LOAD httpfs;
-- These are auto-loaded when we run the query, it is mentioned in DuckDB documentation
-- that we need to install and load httpfs extension to read files from HTTP/HTTPS sources.


SELECT 'Loading data into the data warehouse marts...' AS STATUS;

SELECT 'Loading company_dim data...' AS INFO;

INSERT INTO company_dim(company_id, name, link, link_google, thumbnail)
SELECT company_id, name, link, link_google, thumbnail 
FROM read_csv('https://storage.googleapis.com/sql_de/company_dim.csv', AUTO_DETECT = TRUE);



SELECT 'Loading skills_dim data...' AS INFO;

INSERT INTO skills_dim(skill_id, skills, type)
SELECT skill_id, skills, type
FROM read_csv('https://storage.googleapis.com/sql_de/skills_dim.csv', AUTO_DETECT = TRUE);


SELECT 'Loading job_postings_fact data...' AS INFO;

INSERT INTO job_postings_fact(job_id, company_id, job_title_short, job_title, 
job_location, job_via, job_schedule_type, job_work_from_home, search_location, 
job_posted_date, job_no_degree_mention, job_health_insurance, job_country, salary_rate, 
salary_year_avg, salary_hour_avg)
SELECT job_id, company_id, job_title_short, job_title, 
job_location, job_via, job_schedule_type, job_work_from_home, search_location, 
job_posted_date, job_no_degree_mention, job_health_insurance, job_country, salary_rate, 
salary_year_avg, salary_hour_avg
FROM read_csv('https://storage.googleapis.com/sql_de/job_postings_fact.csv', AUTO_DETECT = TRUE);


SELECT 'Loading skills_job_dim data...' AS INFO;

INSERT INTO skills_job_dim(skill_id, job_id)
SELECT skill_id, job_id
FROM read_csv('https://storage.googleapis.com/sql_de/skills_job_dim.csv', AUTO_DETECT = TRUE);