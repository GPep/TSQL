SELECT 
cast(DB_Name(a.database_id) as varchar) as Database_name,
b.physical_name, * 
FROM  
sys.dm_io_virtual_file_stats(null, null) a 
INNER JOIN sys.master_files b ON a.database_id = b.database_id and a.file_id = b.file_id
WHERE DB_Name(a.database_id) IN ('FileStagingSit01','FileStagingSit02','FlexSIT','FLEXSIT02')
ORDER BY Database_Name
