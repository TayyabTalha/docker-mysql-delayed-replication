#!/bin/bash
BASE_PATH=$(dirname $0)
#sleep 60
echo "Creating Replication For Master"

until mysqladmin --host mysql-master -uroot -p$MYSQL_MASTER_PASSWORD ping --silent; do
  >&2 echo "Master is unavailable - sleeping"
  sleep 10
done

until mysqladmin --host mysql-slave -uroot -p$MYSQL_SLAVE_PASSWORD ping --silent; do
  >&2 echo "Slave is unavailable - sleeping"
  sleep 10
done


MASTER_IP=$(eval "getent hosts mysql-master|awk '{print \$1}'")
SLAVE_IP=$(eval "getent hosts mysql-slave|awk '{print \$1}'")
echo "MASTER IP : $MASTER_IP"
echo "SLAVE IP  : $SLAVE_IP"

mysqldump --host mysql-master -uroot -p$MYSQL_MASTER_PASSWORD --all-databases > "/tmp/backup.sql"
mysql --host mysql-slave -uroot -p$MYSQL_SLAVE_PASSWORD  <  "/tmp/backup.sql"

mysql --host mysql-slave -uroot -p$MYSQL_SLAVE_PASSWORD -AN -e 'STOP SLAVE;';
mysql --host mysql-slave -uroot -p$MYSQL_MASTER_PASSWORD -AN -e 'RESET SLAVE ALL;';

mysql --host mysql-master -uroot -p$MYSQL_MASTER_PASSWORD -AN -e "CREATE USER $MYSQL_REPLICATION_USER@'%';"
mysql --host mysql-master -uroot -p$MYSQL_MASTER_PASSWORD -AN -e "GRANT REPLICATION SLAVE ON *.* TO '$MYSQL_REPLICATION_USER'@'%' IDENTIFIED BY '$MYSQL_REPLICATION_PASSWORD';"
mysql --host mysql-master -uroot -p$MYSQL_MASTER_PASSWORD -AN -e 'flush privileges;'


MYSQL01_Position=$(eval "mysql --host mysql-master -uroot -p$MYSQL_MASTER_PASSWORD -e 'show master status \G' | grep Position | sed -n -e 's/^.*: //p'")
MYSQL01_File=$(eval "mysql --host mysql-master -uroot -p$MYSQL_MASTER_PASSWORD -e 'show master status \G'     | grep File     | sed -n -e 's/^.*: //p'")

mysql --host mysql-slave -uroot -p$MYSQL_SLAVE_PASSWORD -AN -e "CHANGE MASTER TO master_host='mysql-master', master_port=3306, \
        master_user='$MYSQL_REPLICATION_USER', master_password='$MYSQL_REPLICATION_PASSWORD', master_log_file='$MYSQL01_File', \
        master_log_pos=$MYSQL01_Position;"


MYSQL02_Position=$(eval "mysql --host mysql-slave -uroot -p$MYSQL_SLAVE_PASSWORD -e 'show master status \G' | grep Position | sed -n -e 's/^.*: //p'")
MYSQL02_File=$(eval "mysql --host mysql-slave -uroot -p$MYSQL_SLAVE_PASSWORD -e 'show master status \G'     | grep File     | sed -n -e 's/^.*: //p'")

mysql --host mysql-master -uroot -p$MYSQL_MASTER_PASSWORD -AN -e "CHANGE MASTER TO master_host='mysql-master', master_port=3306, \
        master_user='$MYSQL_REPLICATION_USER', master_password='$MYSQL_REPLICATION_PASSWORD', master_log_file='$MYSQL02_File', \
        master_log_pos=$MYSQL02_Position;"


#mysql --host mysql-master -uroot -p$MYSQL_MASTER_PASSWORD -AN -e "CHANGE MASTER TO MASTER_DELAY = $MASTER_DELAY"


echo "* Start Slave on both Servers"
mysql --host mysql-slave -uroot -p$MYSQL_SLAVE_PASSWORD -AN -e "start slave;"

#sleep 10
mysql --host mysql-slave -uroot -p$MYSQL_SLAVE_PASSWORD -AN -e "stop slave;"
mysql --host mysql-slave -uroot -p$MYSQL_MASTER_PASSWORD -AN -e "CHANGE MASTER TO MASTER_DELAY = $MASTER_DELAY"
mysql --host mysql-slave -uroot -p$MYSQL_SLAVE_PASSWORD -AN -e "start slave;"


#echo "Increase the max_connections to 2000"
#mysql --host mysql-master -uroot -p$MYSQL_MASTER_PASSWORD -AN -e 'set GLOBAL max_connections=2000';
#mysql --host mysql-slave -uroot -p$MYSQL_SLAVE_PASSWORD -AN -e 'set GLOBAL max_connections=2000';

mysql --host mysql-slave -uroot -p$MYSQL_MASTER_PASSWORD -e "show slave status \G"

echo "MySQL servers created!"
