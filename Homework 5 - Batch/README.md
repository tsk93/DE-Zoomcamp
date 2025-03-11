# Module 5 Homework: Batch

<br>

## Q1: Install Spark and PySpark

* Install Spark
* Run PySpark
* Create a local spark session
* Execute spark.version.

What's the output?


Answer: '3.0.3'

Code:
   
    import pandas as pd
    import pyspark
    from pyspark.sql import SparkSession
    from pyspark.sql.types import *
    from pyspark.sql import functions as F

    spark = SparkSession.builder \
        .master("local[*]") \
        .appName('test') \
        .getOrCreate()

    spark.version


<br>

## Q2. Yellow October 2024

Read the October 2024 Yellow into a Spark Dataframe.

Repartition the Dataframe to 4 partitions and save it to parquet.

What is the average size of the Parquet (ending with .parquet extension) Files that were created (in MB)? Select the answer which most closely matches.

* 6MB
* 25MB
* 75MB
* 100MB


Answer: 25MB

Code: 

    df = spark.read.parquet('./yellow_tripdata.parquet')
    
    df.coalesce(4).write.parquet('data/homework/', mode='overwrite')
    
    !ls -lh data/homework/

The average file size is approximately 20MB.    

<br>

## Q3. Count records

How many taxi trips were there on the 15th of October?

Consider only trips that started on the 15th of October.

* 85,567
* 105,567
* 125,567
* 145,567


Answer: 128893

Code: 
    
    df.filter(F.to_date(df.tpep_pickup_datetime) == '2024-10-15').count()

<br>

## Q4. Longest trip

What is the length of the longest trip in the dataset in hours?


* 122
* 142
* 162
* 182


Answer: 162

Code: 

    df.withColumn('Duration', (df.tpep_dropoff_datetime.cast('long') - df.tpep_pickup_datetime.cast('long'))/3600).\
    orderBy('Duration', ascending=False).limit(1).select('Duration').show(truncate=False)

<br>

## Q5: User Interface

Spark’s User Interface which shows the application's dashboard runs on which local port?

* 80
* 443
* 4040
* 8080


Answer: 4040

<br>

## Q6. Least frequent pickup location zone

Load the zone lookup data into a temp view in Spark:

    wget https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv

Using the zone lookup data and the Yellow October 2024 data, what is the name of the LEAST frequent pickup location Zone?

* Governor's Island/Ellis Island/Liberty Island
* Arden Heights
* Rikers Island
* Jamaica Bay

Answer: Governor's Island/Ellis Island/Liberty Island

Code: 

    df.createOrReplaceTempView('trips')

    df2 = spark.read.option('header','true').csv('./taxi_zone_lookup.csv')

    df2 = df2.withColumn("LocationID", F.col("LocationID").cast("int"))

    df2.createOrReplaceTempView('zones')

    spark.sql("""select t2.Zone, count(*) as num_trips from trips t1 inner join zones t2 on t1.PULocationID = t2.LocationID
    group by t2.Zone
    order by count(*)
    LIMIT 1""").show(truncate=False)
