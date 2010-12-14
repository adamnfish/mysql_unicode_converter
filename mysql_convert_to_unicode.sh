#! /bin/bash

if [ $# = 3 ]; then
	# dump
	mysqldump -h$1 -u$2 -p $3 > $3"_dump.sql"
	# copy dump
	cp $3"_dump.sql" $3"_dump.sql.bak"
	# DEFAULT CHARSET=latin1 => DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
	sed "s/DEFAULT CHARSET=latin1/DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci/g" $3"_dump.sql" > $3"_dump_fixed.sql"
	# DROP DATABASE `<name>`;
	# CREATE DATABASE `<name>` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
	echo "DROP DATABASE $3;" > recreate_database.sql
	echo "CREATE DATABASE $3 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" >> recreate_database.sql
	mysql -h$1 -u$2 -p $3 < recreate_database.sql
	# load converted sql dump
	mysql -h$1 -u$2 -p $3 < $3"_dump_fixed.sql"
	# remove dump (keep backup)
	rm $3"_dump.sql" 
	# remove fixed dump 
	# no - good to check it
else
	echo "Fixes the database encoding by converting from latin to utf8"
	echo "Usage: `basename $0` <host> <user> <database>"
	echo "eg. `basename $0` 192.168.103.11 fcc_uat fcc_uat"
fi

