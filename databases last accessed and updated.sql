--Date Tables last updated

SELECT OBJECT_NAME(OBJECT_ID) AS TABLEName, db_name(database_id) AS Database_Name, last_user_lookup, last_user_seek, last_user_scan, last_user_update
FROM sys.dm_db_index_usage_stats
WHERE object_id IN
(SELECT object_id 
FROM sys.objects
WHERE type = 'u')
--AND db_name(database_id) = '[Sync DB]'
ORDER BY last_user_update, Database_Name

--number of connections per database
SELECT @@ServerName AS server
 ,NAME AS dbname
 ,COUNT(STATUS) AS number_of_connections
 ,GETDATE() AS timestamp
FROM sys.databases sd
LEFT JOIN sys.sysprocesses sp ON sd.database_id = sp.dbid
WHERE database_id NOT BETWEEN 1 AND 4
--AND db_name(database_id) = 'BCP-VCENTRE-01-Srv'
GROUP BY NAME


--last accessed per database
SELECT name, last_access =(select X1= max(LA.xx)
from ( select xx =
max(last_user_seek)
where max(last_user_seek)is not null
union all
select xx = max(last_user_scan)
where max(last_user_scan)is not null
union all
select xx = max(last_user_lookup)
where max(last_user_lookup) is not null
union all
select xx =max(last_user_update)
where max(last_user_update) is not null) LA)
FROM master.dbo.sysdatabases sd 
left outer join sys.dm_db_index_usage_stats s 
on sd.dbid= s.database_id 
group by sd.name
