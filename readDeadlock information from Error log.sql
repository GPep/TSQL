declare @RawLogs table (id int IDENTITY (1, 1), logdate datetime, processinfo nvarchar(50), logtext nvarchar(max))

insert into @RawLogs
exec sp_readerrorlog

declare @results table (id int IDENTITY (1,1), logdate datetime, processinfo nvarchar(50), logtext nvarchar(max))
declare @ids table (id int, processinfo nvarchar(50))

insert into @ids
select id, processinfo
from @RawLogs
where logteXt = 'deadlock-list'
order by id

declare @Startid int, @endid int, @processinfo nvarchar(50)
select top 1 @Startid = id from @ids order by id
while(@@rowcount<>0)
begin
	select @processinfo = processinfo from @ids where id = @Startid
	select top 1 @endid = id from @ids where id > @Startid and processinfo = @processinfo order by id
	insert into @results (logdate, processinfo, logtext)
	select logdate, processinfo, logtext
	from @RawLogs
	where
	   id >=@Startid and
	   processinfo = @processinfo and
	   id < @endid
	order by id
	delete @ids where id = @Startid
	select top 1 @Startid = id from @ids order by id
end

select logdate, processinfo, logtext
from @results
order by id