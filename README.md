## MARIADB DELAYED REPLICATION DOCKER
This repo contains `docker-compose` file which will set mariadb delayed replica

# Setup Guid:
copy .env.example to .env

```
cp .env.example .env
```

Now edit .env it has following variables
| Variable Name | Description
| --- | --- |
|MYSQL\_MASTER\_PASSWORD|Password of mariadb root for master node|
|MYSQL\_SLAVE\_PASSWORD|Password of mariadb root for replica node|
|MYSQL\_REPLICATION\_USER|Username which will be used to connect to master node by replica node|
|MYSQL\_REPLICATION\_PASSWORD|Password which will be used to connect to master node by replica node|
|MASTER\_DELAY|Dealy for query to run in seconds|
