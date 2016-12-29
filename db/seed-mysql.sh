#!/bin/sh
mysql -u root <<EOF
  drop database if exists db_json_sample;
  create database db_json_sample;
  use db_json_sample;
  create table contacts (name varchar(25), age int, data blob);

  insert into contacts (name, age, data) values ('John Doe', 30, X'53514C697465');
  insert into contacts (name, age, data) values ('Jane Roe', 32, X'6574694C5153');
EOF
