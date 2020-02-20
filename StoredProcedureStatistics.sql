SELECT CASE WHEN database_id = 32767 then 'Resource' ELSE DB_NAME(database_id)END AS DBName
      ,OBJECT_SCHEMA_NAME(object_id,database_id) AS [SCHEMA_NAME]  
      ,OBJECT_NAME(object_id,database_id)AS [OBJECT_NAME]  
      ,
cached_time, last_execution_time, execution_count, 
 total_worker_time / execution_count AS AVG_CPU
 ,total_elapsed_time / execution_count AS AVG_ELAPSED
 ,total_logical_reads / execution_count AS AVG_LOGICAL_READS
 ,total_logical_writes / execution_count AS AVG_LOGICAL_WRITES
 ,total_physical_reads  / execution_count AS AVG_PHYSICAL_READS
 , CONVERT(varchar, DATEADD(ms, last_elapsed_time / 1000, 0),114) AS last_elapsed_time
 , qp.Query_plan AS QueryPlan
FROM sys.dm_exec_procedure_stats as ps 
CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) as qp
WHERE DB_NAME(database_id) = 'Agency'
ORDER BY AVG_LOGICAL_READS DESC
