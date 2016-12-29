#!/bin/sh
dropdb db_json_sample --if-exists
createdb db_json_sample

psql db_json_sample <<EOF
  create table contacts (name varchar(25), age int, data bytea);

  insert into contacts (name, age, data) values ('John Doe', 30, decode('53514C697465', 'hex'));
  insert into contacts (name, age, data) values ('Jane Roe', 32, decode('6574694C5153', 'hex'));
EOF
