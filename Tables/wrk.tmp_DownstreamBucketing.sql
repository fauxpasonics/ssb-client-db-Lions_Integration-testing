CREATE TABLE [wrk].[tmp_DownstreamBucketing]
(
[new] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[old] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[actiontype] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mdm_run_dt] [datetime] NOT NULL,
[dimcustomerid] [int] NULL,
[primaryflag] [int] NULL,
[SSB_CRMSYSTEM_CONTACT_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSystem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
