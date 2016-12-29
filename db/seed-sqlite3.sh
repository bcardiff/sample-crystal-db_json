#!/bin/sh
rm -rf "${0%/*}/sqlite3.db"
sqlite3 "${0%/*}/sqlite3.db" <<EOF
  create table contacts (name text, age integer, data blob);

  insert into contacts (name, age, data) values ('John Doe', 30, X'53514C697465');
  insert into contacts (name, age, data) values ('Jane Roe', 32, X'6574694C5153');
EOF
