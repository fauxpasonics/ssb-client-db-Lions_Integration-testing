CREATE TABLE [dbo].[Account_Custom_CRMResults]
(
[accountid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CrmRecordId] [uniqueidentifier] NULL,
[IsNew] [bit] NULL,
[ErrorCode] [int] NULL,
[ErrorColumn] [int] NULL,
[CrmErrorMessage] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResultDateTime] [datetime] NULL CONSTRAINT [DF__Account_C__Resul__6383C8BA] DEFAULT (getdate()),
[new_ssbcrmsystemssidwinner] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_ssbcrmsystemSSIDWinnerSourceSystem] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_ssbcrmsystemdimcustomerids] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_ssbcrmsystemarchticsids] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
