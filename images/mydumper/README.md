# mydumper

The goal of this container is to simplify the use of mydumper with velero for automating backups of MySQL databases

## variables

You can override the following variables to fit your needs

| variable               | default                                     | usage                                                |
| ---------------------- | ------------------------------------------- | ---------------------------------------------------- |
| MYSQL_HOST             | MySQL                                       | MySQL server                                         |
| MYSQL_PORT             | 3306                                        | MySQL port to connect                                |
| MYSQL_USER             | root                                        | MySQL user used to connect                           |
| MYSQL_PASSWORD         | root                                        | MySQL password used to connect                       |
| MYSQL_DATABASE         | "app"                                       | MySQL database to dump                               |
| MYDUMPER_THREADS       | 4                                           | number of CPU threads used to dump data              |
| MYDUMPER_COMPRESS      | 1                                           | compress dump files (evaluated as true if not empty) |
| MYDUMPER_EXTRA_OPTIONS | "-e -F 100 --use-savepoints --less-locking" | extra options passed to the mydumper command         |
| KEEP_BACKUPS           | 7                                           | number of backups to keep                            |

## usage

- `/entrypoint.sh` is run at the container startup and creates dumps in `/backups` with a timestamped directory
- `KEEP_BACKUPS` backuos are kept at the same time to avoid filling up `/backups`
