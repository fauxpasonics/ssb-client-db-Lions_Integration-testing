IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'SSBINFO\BI Administrators')
CREATE LOGIN [SSBINFO\BI Administrators] FROM WINDOWS
GO
CREATE USER [SSBCLOUD\Bi Administrators] FOR LOGIN [SSBINFO\BI Administrators] WITH DEFAULT_SCHEMA=[SSBCLOUD\Bi Administrators]
GO
REVOKE CONNECT TO [SSBCLOUD\Bi Administrators]
