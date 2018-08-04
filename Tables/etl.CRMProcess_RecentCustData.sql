CREATE TABLE [etl].[CRMProcess_RecentCustData]
(
[SSID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxTransDate] [datetime] NULL,
[Team] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__CRMProces__LoadD__0F975522] DEFAULT (getdate())
)
GO
