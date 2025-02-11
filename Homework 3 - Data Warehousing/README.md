# Module 3 Homework: Data Warehousing

<br>

## Q1. What is count of records for the 2024 Yellow Taxi Data?

* 65,623
* 840,402
* 20,332,093
* 85,431,289


Answer: 20,332,093

Code:
   
    -- Create external table
    CREATE OR REPLACE EXTERNAL TABLE `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata`
    OPTIONS (format = 'PARQUET', uris = ['gs://zoomcamp_module3/yellow_2024-*.parquet']);

    -- Create a materialized, non-partitioned table from external table
    CREATE OR REPLACE TABLE `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata_nonpartitioned` AS
    SELECT * FROM `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata`;

    --Record count
    SELECT COUNT(*)
    FROM taxi-rides-ny-448101.de_zoomcamp.external_yellow_tripdata


<br>

## Q2. Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables. What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?


* 18.82 MB for the External Table and 47.60 MB for the Materialized Table
* 0 MB for the External Table and 155.12 MB for the Materialized Table
* 2.14 GB for the External Table and 0 MB for the Materialized Table
* 0 MB for the External Table and 0 MB for the Materialized Table



Answer: 0 MB for the External Table and 155.12 MB for the Materialized Table

Explanation: 

    -- Check estimated amount of data read on the top-right corner, do not run query.

    SELECT COUNT(DISTINCT PULocationID) FROM `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata`;
    -- This query will process 0 B when run.

    SELECT COUNT(DISTINCT PULocationID) FROM `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata_nonpartitioned`;
    -- This query will process 155.12 MB when run.

<br>

## Q3. Write a query to retrieve the PULocationID from the table (not the external table) in BigQuery. Now write a query to retrieve the PULocationID and DOLocationID on the same table. Why are the estimated number of Bytes different?


* BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.
* BigQuery duplicates data across multiple storage partitions, so selecting two columns instead of one requires scanning the table twice, doubling the estimated bytes processed.
* BigQuery automatically caches the first queried column, so adding a second column increases processing time but does not affect the estimated bytes scanned.
* When selecting multiple columns, BigQuery performs an implicit join operation between them, increasing the estimated bytes processed


Answer: BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.

Code: 
    
    -- This query will process 155.12 MB when run.
    SELECT PULocationID FROM `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata_nonpartitioned`;

    -- This query will process 310.24 MB when run.
    SELECT PULocationID, DOLocationID FROM `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata_nonpartitioned`;

<br>

## Q4. How many records have a fare_amount of 0?


* 128,210
* 546,578
* 20,188,016
* 8,333

Answer: 8,333

Code: 

    SELECT Count(1) FROM `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata_nonpartitioned`
    WHERE fare_amount = 0;

<br>

## Q5. What is the best strategy to make an optimized table in Big Query if your query will always filter based on tpep_dropoff_datetime and order the results by VendorID? (Create a new table with this strategy)

* Partition by tpep_dropoff_datetime and Cluster on VendorID
* Cluster on by tpep_dropoff_datetime and Cluster on VendorID
* Cluster on tpep_dropoff_datetime Partition by VendorID
* Partition by tpep_dropoff_datetime and Partition by VendorID

Answer: Partition by tpep_dropoff_datetime and Cluster on VendorID

Code: 

    CREATE OR REPLACE TABLE `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata_pc`
    PARTITION BY DATE(tpep_dropoff_datetime)
    CLUSTER BY VendorID AS
    SELECT * FROM `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata_nonpartitioned`;


<br>

## Q6. Estimated processed bytes difference on regular vs. partitioned tables


* 12.47 MB for non-partitioned table and 326.42 MB for the partitioned table
* 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table
* 5.87 MB for non-partitioned table and 0 MB for the partitioned table
* 310.31 MB for non-partitioned table and 285.64 MB for the partitioned table


Answer: 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table

Code: 

    -- Regular query will process 310.24 MB when run.
    SELECT DISTINCT VendorID FROM `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata_nonpartitioned` 
    WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';

    -- Partitioned query will process 26.84 MB when run.
    SELECT DISTINCT VendorID FROM `ny-taxi-449405.yellow_nytaxi.external_yellow_tripdata_pc` 
    WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';


<br>

## Q7. Where is the data stored in the External Table you created?

* Big Query
* Container Registry
* GCP Bucket
* Big Table

Answer: GCP Bucket

<br>

## Q8. It is best practice in Big Query to always cluster your data?

* True
* False

Answer: False