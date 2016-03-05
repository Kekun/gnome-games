#!/bin/sh
# Extract the list of games supported by MAME
# $1: path to the MAME repository
# $2: file name of the produced game database

cat `find $1/src/mame/drivers -name "*.cpp" | sort` | egrep "^GAMEL?\(.*\)$" > $2
