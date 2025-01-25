# Module 1 Homework: Docker & SQL

Refer to codealong.txt to complete the following tasks:

* Create docker network to connect pgAdmin and Postgres database.
* Create and start containers to run in pg-network.
* Access http://localhost:8080 with your browser to access the pgAdmin interface. Use below credentials to log in.

        Email: pgadmin@pgadmin.com<br>
        Password: pgadmin<br>

* Setup a server with the postgres container specs as shown below.

        Host: postgres<br>
        Port: 5432<br>
        DB name: ny_taxi<br>
        DB user: postgres<br>
        DB password: postgres<br>


* Download data from provided links and specify database key parameters to ingest data.

        URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz"
    
        python ingest_data.py \
            --user=postgres \
            --password=postgres \
            --host=localhost \
            --port=5433 \
            --db=ny_taxi \
            --table_name=green_taxi_trips \
            --url=${URL}

        URL2="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv"
        
        python ingest_data.py \
            --user=postgres \
            --password=postgres \
            --host=localhost \
            --port=5433 \
            --db=ny_taxi \
            --table_name=zones \
            --url=${URL2}

<br>

## Q1. Understanding docker first run

Run docker with the python:3.12.8 image in an interactive mode, use the entrypoint bash.

What's the version of pip in the image?

    24.3.1
    24.2.1
    23.3.1
    23.2.1

Answer: 24.3.1

Code:

    docker run -it --entrypoint=bash python:3.12.8
    pip list

<br>

## Q2. Understanding Docker networking and docker-compose

Given the following docker-compose.yaml, what is the hostname and port that pgadmin should use to connect to the postgres database? <br>

<details>
<summary>Docker compose YAML file</summary>

    services:
        db:
            container_name: postgres
            image: postgres:17-alpine
            environment:
            POSTGRES_USER: 'postgres'
            POSTGRES_PASSWORD: 'postgres'
            POSTGRES_DB: 'ny_taxi'
            ports:
            - '5433:5432'
            volumes:
            - vol-pgdata:/var/lib/postgresql/data

        pgadmin:
            container_name: pgadmin
            image: dpage/pgadmin4:latest
            environment:
            PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
            PGADMIN_DEFAULT_PASSWORD: "pgadmin"
            ports:
            - "8080:80"
            volumes:
            - vol-pgadmin_data:/var/lib/pgadmin  

        volumes:
        vol-pgdata:
            name: vol-pgdata
        vol-pgadmin_data:
            name: vol-pgadmin_data
</details>
<br>
        
    postgres:5433
    localhost:5432
    db:5433
    postgres:5432
    db:5432

Answer: postgres:5432

pgAdmin web server is run within a Docker container, it will have to communicate with the postgres database (another container) within the same virtual network using its container name and container port. As seen from the docker yaml file, the values are postgres and 5432 respectively.

<br>

## Q3. Trip segmentation count

During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, respectively, happened:

    Up to 1 mile
    In between 1 (exclusive) and 3 miles (inclusive),
    In between 3 (exclusive) and 7 miles (inclusive),
    In between 7 (exclusive) and 10 miles (inclusive),
    Over 10 miles


    104,802; 197,670; 110,612; 27,831; 35,281
    104,802; 198,924; 109,603; 27,678; 35,189
    104,793; 201,407; 110,612; 27,831; 35,281
    104,793; 202,661; 109,603; 27,678; 35,189
    104,838; 199,013; 109,645; 27,688; 35,202

Answer: 104,802; 198,924; 109,603; 27,678; 35,189

Code:
    
    select sum(case when trip_distance<=1 then 1 else 0 end) as "Up to 1 mile",
    sum(case when trip_distance>1 and trip_distance<=3 then 1 else 0 end) as "Between 1 to 3 miles",
    sum(case when trip_distance>3 and trip_distance<=7 then 1 else 0 end) as "Between 3 to 7 miles",
    sum(case when trip_distance>7 and trip_distance<=10 then 1 else 0 end) as "Between 7 to 10 miles",
    sum(case when trip_distance>10 then 1 else 0 end) as "Over 10 miles"
    from green_taxi_trips
    where lpep_pickup_datetime >= '2019-10-01' and lpep_dropoff_datetime < '2019-11-01';

Result:
|Up to 1 mile|Between 1 to 3 miles|Between 3 to 7 miles|Between 7 to 10 miles|Over 10 miles|
|:------:|:------:|:------:|:------:| :----: |
| 104802 | 198924 | 109603 | 27678  | 35189  |

<br>

## Q4. Longest trip for each day

Which was the pick up day with the longest trip distance? Use the pick up time for your calculations.

Tip: For every day, we only care about one single trip with the longest distance.

    2019-10-11
    2019-10-24
    2019-10-26
    2019-10-31

Answer: 2019-10-31

Code:

    select cast(lpep_pickup_datetime as date) as trip_date, max(trip_distance) as max_distance
    from green_taxi_trips group by cast(lpep_pickup_datetime as date) order by max_distance desc limit 1;

Result:
|trip_date|max_distance|
|:------:|:------:|
| 2019-10-31  | 515.89  |

<br>

## Q5. Three biggest pickup zones

Which were the top pickup locations with over 13,000 in total_amount (across all trips) for 2019-10-18?

Consider only lpep_pickup_datetime when filtering by date.

    East Harlem North, East Harlem South, Morningside Heights
    East Harlem North, Morningside Heights
    Morningside Heights, Astoria Park, East Harlem South
    Bedford, East Harlem North, Astoria Park

Answer: East Harlem North, East Harlem South, Morningside Heights


Code:

    select cast(lpep_pickup_datetime as date) as pickup_date, z."Zone" as Zone, count(total_amount) as total_amount
    from green_taxi_trips gt join zones z on gt."PULocationID" = z."LocationID" 
    where cast(lpep_pickup_datetime as date)='2019-10-18'
    group by cast(lpep_pickup_datetime as date),z."Zone" 
    having sum(total_amount)>13000 
    order by total_amount desc;


Result:

|pickup_date|zone|total_amount|
|:------:|:------:|:------:|
| 2019-10-18 | East Harlem North | 18686.68 |
| 2019-10-18 | East Harlem South | 16797.26 | 
| 2019-10-18 | Morningside Heights | 13029.79 | 

<br>

## Q6. Largest tip

For the passengers picked up in October 2019 in the zone name "East Harlem North" which was the drop off zone that had the largest tip?

We need the name of the zone, not the ID.

    Yorkville West
    JFK Airport
    East Harlem North
    East Harlem South

Answer: JFK Airport

Code:

    select z."Zone" as Zone, max(tip_amount) as max_tip 
    from green_taxi_trips gt join zones z on gt."DOLocationID" = z."LocationID" 
    where date_trunc('month',lpep_pickup_datetime)='2019-10-01' 
    and gt."PULocationID" in (select "LocationID" from zones where "Zone"='East Harlem North')
    group by date_trunc('month',lpep_pickup_datetime),z."Zone"
    order by max_tip desc limit 1;

Result:

|zone|max_tip|
|:------:|:------:|
| JFK Airport | 87.3|

<br>

## Q7. Terraform Workflow

Which of the following sequences, respectively, describes the workflow for:

1. Downloading the provider plugins and setting up backend
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform


        terraform import, terraform apply -y, terraform destroy
        terraform init, terraform plan -auto-apply, terraform rm
        terraform init, terraform run -auto-approve, terraform destroy
        terraform init, terraform apply -auto-approve, terraform destroy
        terraform import, terraform apply -y, terraform rm

Answer: terraform init, terraform apply -auto-approve, terraform destroy

We can run the --help command for below functions:

    terraform init --help

    Initialize a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.

    This is the first command that should be run for any new or existing Terraform configuration per machine. This sets up all the local data necessary to run Terraform that is typically not committed to version control.

    terraform apply --help

    Creates or updates infrastructure according to Terraform configuration files in the current directory.
    
    By default, Terraform will generate a new plan and present it for your approval before taking any action. You can optionally provide a plan file created by a previous call to "terraform plan", in which case Terraform will take the actions described in that plan without any confirmation prompt.

    -auto-approve 
    
    Skip interactive approval of plan before applying.

    terraform destroy --help

    Destroy Terraform-managed infrastructure.
