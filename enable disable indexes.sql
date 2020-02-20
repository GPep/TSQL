select
    sys.objects.name,
    sys.indexes.name,
	'ALTER INDEX ' + QUOTENAME(sys.indexes.name) + ' ON ' +  QUOTENAME(SCHEMA_NAME(sys.tables.schema_id))+'.'+ QUOTENAME(sys.tables.name) + ' REBUILD'  AS 'Enable Command',
    'ALTER INDEX ' + QUOTENAME(sys.indexes.name) + ' ON ' +  QUOTENAME(SCHEMA_NAME(sys.tables.schema_id))+'.'+ QUOTENAME(sys.tables.name) + ' DISABLE' AS 'Disable Command'
from sys.indexes
    inner join sys.objects on sys.objects.object_id = sys.indexes.object_id
	INNER JOIN sys.tables  ON sys.objects.object_id = sys.tables.object_id
where sys.indexes.is_disabled = 1
order by
    sys.objects.name,
    sys.indexes.name