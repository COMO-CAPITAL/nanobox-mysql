# nanobox-mysql

Этот проект наследует стандартный [nanobox-docker-mysql](https://github.com/nanobox-io/nanobox-docker-mysql). Основным отличием является наличие [Percona XtraBackup](https://www.percona.com/doc/percona-xtrabackup/LATEST/index.html).

```yml
data.mysql:
  image: comocapital/nanobox-mysql:5.6
```

##  Backup and Restore

* Full backup (compressed, streaming) into single file:
```sh
xtrabackup --defaults-file=/data/etc/my.cnf --backup --compress -compress-threads=4 --stream=xbstream --parallel=4 --databases="mydatabase1 mydatabase2" --socket=/tmp/mysqld.sock --user=root --host=127.0.0.1 > /data/var/backup-mysql-$(date -u +%Y-%m-%d.%H-%M-%S).xbstream
```

* Restore backup (compressed, streaming):
```sh
mkdir -p /data/var/restore
xbstream -x --parallel=4 --directory=/data/var/restore < backup-mysql.xbstream
xtrabackup --decompress --parallel=4 --target-dir=/data/var/restore --remove-original
xtrabackup --defaults-file=/data/etc/my.cnf --prepare --target-dir=/data/var/restore --socket=/tmp/mysqld.sock --user=root --host=127.0.0.1
sv stop db
xtrabackup --defaults-file=/data/etc/my.cnf --copy-back --target-dir=/data/var/restore --socket=/tmp/mysqld.sock --user=root --host=127.0.0.1
chown -R gonano:gonano /data/var/db/mysql
sv start db
rm -rf /data/var/restore/*
```

* Upload to internal backup store (from pipe):
```sh
curl -k -H "X-AUTH-TOKEN: ${WAREHOUSE_DATA_HOARDER_TOKEN}" https://${WAREHOUSE_DATA_HOARDER_HOST}:7410/blobs/backup-mysql-$(date -u +%Y-%m-%d.%H-%M-%S).xbstream --data-binary @- >&2
```

* Download file from internal backup store:
```sh
curl -k -H "X-AUTH-TOKEN: ${WAREHOUSE_DATA_HOARDER_TOKEN}" https://${WAREHOUSE_DATA_HOARDER_HOST}:7410/blobs/backup-mysql-{date}.xbstream > backup-mysql.xbstream
```
