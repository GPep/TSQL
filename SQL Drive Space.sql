WITH CTE AS (SELECT DISTINCT
  vs.volume_mount_point AS [Drive],
  vs.logical_volume_name AS [Drive Name],
  vs.total_bytes/1024/1024 AS [Drive Size MB],
  vs.available_bytes/1024/1024 AS [Drive Free Space MB]
FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs)
SELECT a.*, 100 - (CAST((CAST([Drive Size MB] AS DECIMAL(12,2)) - CAST([Drive Free Space MB] AS DECIMAL(12,2))) / [Drive Size MB] AS DECIMAL(12,2)) * 100)  AS [% Free Space]
FROM CTE AS a