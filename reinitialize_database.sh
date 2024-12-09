#!/usr/bin/env bash

mysql -u root -ppassword -e "DROP DATABASE IF EXISTS business_supply;"
mysql -u root -ppassword < 4database.sql
mysql -u root -ppassword business_supply < phase4_team6.sql