ALTER LOGIN sa WITH NAME = C4rb0n;  

USE [master]
GO
ALTER DATABASE [model] SET RECOVERY SIMPLE WITH NO_WAIT
GO
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modeldev', FILEGROWTH = 204800KB )
GO
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modellog', FILEGROWTH = 204800KB )
GO


DBCC TRACEON( 1118, -1)
DBCC TRACEON( 1204, -1)
DBCC TRACEON( 3226, -1)


EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'cost threshold for parallelism', N'50'
GO
EXEC sys.sp_configure N'max degree of parallelism', N'8'
GO
EXEC sys.sp_configure N'optimize for ad hoc workloads', N'1'
GO
EXEC sys.sp_configure N'backup compression default', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO


--Change number of error log files to 35

USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', REG_DWORD, 35
GO

-- amend agent history to 10000 rows
USE [msdb]
GO

EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=10000, 
		@email_save_in_sent_folder=1, 
		@use_databasemail=1
GO

--Enable Database mail

USE master
GO
sp_configure 'show advanced options',1
GO
RECONFIGURE WITH OVERRIDE
GO
sp_configure 'Database Mail XPs',1
GO
RECONFIGURE 
GO

--create profile
USE msdb
GO
DECLARE @SN varchar(20)

SET @SN = (SELECT @@SERVERNAME)

EXECUTE msdb.dbo.sysmail_add_profile_sp
@profile_name = @SN,
@description = 'Profile for sending Automated DBA Notifications'
GO

EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name            = 'SQLAlerts',
    @email_address           = 'glenn.pepper@gmail.com', -- <-- change this
    @display_name            = 'SQL Alerts',
    @replyto_address         = 'glenn.pepper@gmail.com', -- <-- change this
    @description             = '',
    @mailserver_name         = 'smtp.gmail.com',
    @mailserver_type         = 'SMTP',
    @port                    = '25',
    @username                = 'glenn.pepper@gmail.com', -- <-- change this
    @password                = 'M@n0fwar', -- <-- change this
    @use_default_credentials =  0 ,
    @enable_ssl              =  1 ;
GO

--Associate profile with mail account
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
@profile_name = @@SERVERNAME,
@account_name = 'SQLAlerts',
@sequence_number = 1
GO

--Enable xp_cmdshell

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  


--Create Server Trigger for Create database statement

CREATE TRIGGER [DDL_CREATE_DATABASE_EVENT]
ON ALL SERVER
FOR CREATE_DATABASE
AS
DECLARE @bd varchar(max)
Declare @tsql varchar(max)
Set @tsql = EVENTDATA().value
        ('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','varchar(max)')
SET @bd = 'UserName: ' + UPPER(SUSER_NAME()) + '

         ServerName: ' + @@SERVERNAME + '

         Time: '   + CONVERT(varchar(25),Getdate()) + '

         HostName: ' + HOST_NAME() + '

         Database: ' + db_name() + '

         T-SQL: ' +  @tsql
         

BEGIN
PRINT 'Make sure you have informed all DBAs before creating databases. This event has been logged'

EXEC msdb.dbo.sp_send_dbmail @profile_name = @@SERVERNAME,
                      @recipients = 'Database Administrators',
                      @subject = 'A new database has been created!',
                      @body_format = 'HTML',
                      @importance = 'High',
                      @body = @bd
END

GO

ENABLE TRIGGER [DDL_CREATE_DATABASE_EVENT] ON ALL SERVER
GO

--create operator

USE [msdb]
GO
EXEC msdb.dbo.sp_add_operator @name=N'Database Administrators', 
		@enabled=1, 
		@pager_days=0, 
		@email_address=N'glenn.pepper@microsoft.com'
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1, 
		@databasemail_profile=N'MININT-9F84K7A'
GO

--create failsafe operator

USE [msdb]
GO
EXEC master.dbo.sp_MSsetalertinfo @failsafeoperator=N'Database Administrators', 
		@notificationmethod=1
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1
GO


