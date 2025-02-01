# Module 2 Homework: Workflow Orchestration

* Run `docker compose up` to deploy containers.
* Run http://localhost:8082 in your browser if you wish to use pgAdmin database, alternatively you could create a GCP service account and generate a key to ingest the data into cloud storage.
* Run http://localhost:8080 in your browser to view the Kestra UI. The workflows and namespace key-value pairs should be imported.
* Execute backill trigger on the gcp_taxi_scheduled flow to ingest the resources into GCP.

<br>

## Q1. Within the execution for Yellow Taxi data for the year 2020 and month 12: what is the uncompressed file size (i.e. the output file yellow_tripdata_2020-12.csv of the extract task)?

* 128.3 MB
* 134.5 MB
* 364.7 MB
* 692.6 MB


Answer: 128.3 MB

Explanation: Look up file size in GCP bucket details. 

<br>

## Q2. What is the value of the variable file when the inputs taxi is set to green, year is set to 2020, and month is set to 04 during execution?


* {{inputs.taxi}}_tripdata_{{inputs.year}}-{{inputs.month}}.csv
* green_tripdata_2020-04.csv
* green_tripdata_04_2020.csv
* green_tripdata_2020.csv


Answer: green_tripdata_2020-04.csv

Explanation: As per Kestra documentation, to reference an input value in your flow, use the {{ inputs.input_name }} syntax.

<br>

## Q3. How many rows are there for the Yellow Taxi data for all CSV files in the year 2020?


* 13,537.299
* 24,648,499
* 18,324,219
* 29,430,127

Answer: 24,648,499

Code: select count(*) from `de_zoomcamp.yellow_tripdata` where filename like '%2020%';


<br>

## Q4. How many rows are there for the Green Taxi data for all CSV files in the year 2020?


* 5,327,301
* 936,199
* 1,734,051
* 1,342,034


Answer: 1,734,051

Code: select count(*) from `de_zoomcamp.green_tripdata` where filename like '%2020%';

<br>

## Q5. How many rows are there for the Yellow Taxi data for the March 2021 CSV file?

* 1,428,092
* 706,911
* 1,925,152
* 2,561,031


Answer: 1,925,152

Code: select count(*) from `de_zoomcamp.yellow_tripdata` where filename like '%2021-03%';


<br>

## Q6. How would you configure the timezone to New York in a Schedule trigger?


* Add a timezone property set to EST in the Schedule trigger configuration
* Add a timezone property set to America/New_York in the Schedule trigger configuration
* Add a timezone property set to UTC-5 in the Schedule trigger configuration
* Add a location property set to New_York in the Schedule trigger configuration


Answer: Add a timezone property set to America/New_York in the Schedule trigger configuration

Explanation: As per Kestra documentation, use the time zone identifier (i.e. the second column in the Wikipedia table) to use for evaluating the cron expression. This gives the value of America/New_York. There is no "location" property in the Schedule trigger configuration.
