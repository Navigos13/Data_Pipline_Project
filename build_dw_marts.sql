-- duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"


-- Step 1: Create the data warehouse marts
.read 1_create_tables_dw.sql


-- Step 2: Load data into the data warehouse marts
.read 2_load_schema_dw.sql

-- Step 3: Build the flat mart for analytics
.read 3_create_flat_mart.sql