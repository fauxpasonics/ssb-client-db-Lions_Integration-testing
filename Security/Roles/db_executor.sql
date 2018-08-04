CREATE ROLE [db_executor]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_executor', N'SSBCLOUD\Bi Administrators'
GO
EXEC sp_addrolemember N'db_executor', N'SSBCLOUD\BI Developers'
GO
EXEC sp_addrolemember N'db_executor', N'SSBCLOUD\saag'
GO
EXEC sp_addrolemember N'db_executor', N'svcLogi'
GO
GRANT EXECUTE TO [db_executor]
