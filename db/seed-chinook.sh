#!/bin/sh
curl http://www.sqlitetutorial.net/download/sqlite-sample-database/?wpdmdl=94 -o "${0%/*}/chinook.zip"
unzip -o  "${0%/*}/chinook.zip" -d "${0%/*}"
