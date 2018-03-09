Select "Creating all tables"  as 'CURRENT ACTION:'; -- Print messages in Terminal
source 150101021.sql;
Select "Importing table: ett"  as 'CURRENT ACTION:';
source 150101021_ett.sql;
Select "Importing table: cc"  as 'CURRENT ACTION:';
source 150101021_cc.sql;
Select "Importing table: cwls"  as 'CURRENT ACTION:';
source 150101021_cwls.sql;
select count(*) from ett;
select count(*) from cc;
select count(*) from cwls;
