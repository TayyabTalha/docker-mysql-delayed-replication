# MARIADB DELAYED REPLICATION DOCKER
This repo contains `docker-compose` file which will set mariadb delayed replica

## Getting Started:
Follow these steps
### Prerequisites
You need install following
- [Docker](https://www.docker.com/)
- [Docker-Compose](https://docs.docker.com/compose/)

copy .env.example to .env

```
cp .env.example .env
```

Now edit .env it has following variables

| Variable Name | Description |
| --- | --- |
| MYSQL\_MASTER\_PASSWORD | Password of mariadb root for master node |
| MYSQL\_SLAVE\_PASSWORD| Password of mariadb root for replica node |
| MYSQL\_REPLICATION\_USER| Username which will be used to connect to master node by replica node |
| MYSQL\_REPLICATION\_PASSWORD| Password which will be used to connect to master node by replica node |
| MASTER\_DELAY | Dealy for query to run in seconds |

### Running
Run the containers by running following command

```
docker-compose up -d
```

Once every thing is up and running now run following command

```
docker ps
```

it will show you all of your container running there you can find `docker-mysql-delayed-replication_mysql-master_1`

```
 docker exec -ti docker-mysql-delayed-replication_mysql-master_1 bash
```

Connect to your database don't forget to replace `YOUR_MASTER_ROOT_PASSOWRD` 

```
mysql -uroot -p<YOUR_MASTER_ROOT_PASSOWRD>;
```

Now create a database don't forget to replace `DATA_BASE_NAME_HERE` 

```
CREATE DATABASE <DATA_BASE_NAME_HERE>;
```

Now connect to you replica node connect to mysql and check your database by running following command

```
SHOW DATABASES;
```
After time you specifed in `.env` you will see the new database.
Now create a table and insert some recode and test resules.
