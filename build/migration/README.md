# Migrations
Migration files in this directory will be run every automatically on service startup (`build/run.sh`).  There are two types of migrations supported.  `alwaysup` which will run every time
migrations are run and `up` which will only run once on a given DB.  Files should follow this naming convention:

`0000n_<description>.up.sql` and 

`1000n_<description>.alwaysup.sql`

E.G. `00001_user_tables.up.sql` would contain the table create statements for the user tables and `10001_users.alwaysup.sql` would contain any types or procs that interact with the user tables.

Up files must have a lower number than always up files.
