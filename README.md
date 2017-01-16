# db_json sample application

Use `./db/seed-*.sh` scripts to initialize a sample database for each driver.
Build and start the app with the `database_url` as command line argument.

```
$ git clone https://github.com/bcardiff/sample-crystal-db_json.git
$ cd sample-crystal-db_json
$ ./db/seed-chinook.sh
$ crystal src/db_json.cr -- sqlite3://./db/chinook.db
```

## Other connection strings

```
$ ./db/seed-sqlite3.sh
$ crystal src/db_json.cr -- sqlite3://./db/sqlite3.db
```

```
$ ./db/seed-mysql.sh
$ crystal src/db_json.cr -- mysql://root@localhost/db_json_sample
```

```
$ ./db/seed-pg.sh
$ crystal src/db_json.cr -- postgres://localhost/db_json_sample
```

## Contributors

- [bcardiff](https://github.com/bcardiff) Brian J. Cardiff - creator, maintainer
