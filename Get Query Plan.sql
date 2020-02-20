SELECT cp.objType AS ObjectType,
OBJECT_NAME(st.objectid,st.dbid) AS ObjectName,
cp.useCounts AS ExecutionCount,
st.TEXT as queryText,
qp.Query_plan AS QueryPlan,
ps.cached_time,
ps.last_execution_time
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) as qp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
INNER JOIN sys.dm_exec_procedure_stats AS ps ON cp.plan_handle = ps.plan_handle
WHERE OBJECT_NAME(st.objectID, st.dbid) = 'uspGetFirmPlan'