-- =============================================================================
-- Chelan County CMS Admin 2.0 - County Calendar of Events Relational Schema
-- Dialect: Microsoft SQL Server (2016+ / 2019 / 2022 / Azure SQL)
-- Modules: Event Categories (calendar_event_categories) & Events (calendar_events)
-- Workspace Scoping: Multi-Tenant Site/Department Scoping (siteid) with County Rollup
-- Safe to rerun: creates missing tables, indexes, constraints, and seeds standard data.
-- =============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- -----------------------------------------------------------------------------
-- 1. Table: dbo.calendar_event_categories
-- Standard Chelan County calendar categories (Commissioners Meeting, Public Hearing,
-- Advisory Board, Community Event, Holiday/Closure, Training & Elections)
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calendar_event_categories]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[calendar_event_categories] (
        [id]          INT IDENTITY(1,1) NOT NULL,
        [name]        NVARCHAR(120) NOT NULL,
        [slug]        NVARCHAR(120) NOT NULL,
        [color]       NVARCHAR(30)  NOT NULL CONSTRAINT [DF_cal_event_cat_color] DEFAULT (N'#0284c7'),
        [badge_class] NVARCHAR(50)  NOT NULL CONSTRAINT [DF_cal_event_cat_badge] DEFAULT (N'badge-info'),
        [icon]        NVARCHAR(50)  NOT NULL CONSTRAINT [DF_cal_event_cat_icon]  DEFAULT (N'calendar'),
        [description] NVARCHAR(255) NULL,
        [sort_order]  INT NOT NULL CONSTRAINT [DF_cal_event_cat_sort]   DEFAULT (0),
        [is_active]   BIT NOT NULL CONSTRAINT [DF_cal_event_cat_active] DEFAULT (1),
        [is_system]   BIT NOT NULL CONSTRAINT [DF_cal_event_cat_system] DEFAULT (0),
        [createdat]   DATETIME2(7) NOT NULL CONSTRAINT [DF_cal_event_cat_createdat] DEFAULT (SYSUTCDATETIME()),
        [updatedat]   DATETIME2(7) NOT NULL CONSTRAINT [DF_cal_event_cat_updatedat] DEFAULT (SYSUTCDATETIME()),
        [deletedat]   DATETIME2(7) NULL,
        CONSTRAINT [PK_calendar_event_categories] PRIMARY KEY CLUSTERED ([id] ASC)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UQ_calendar_event_categories_slug' AND object_id = OBJECT_ID(N'[dbo].[calendar_event_categories]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UQ_calendar_event_categories_slug]
        ON [dbo].[calendar_event_categories] ([slug] ASC)
        WHERE [deletedat] IS NULL;
END;
GO

-- Seed the 6 Standard Chelan County Event Categories
MERGE INTO [dbo].[calendar_event_categories] AS Target
USING (VALUES
    (N'Commissioners Meeting',       N'commissioners-meeting', N'#0284c7', N'badge-info',    N'building',     N'Board of County Commissioners regular sessions, workshops, and legislative briefings.', 10, 1, 1),
    (N'Public Hearing',              N'public-hearing',        N'#b45309', N'badge-warning', N'megaphone',    N'Official public hearings, land use dockets, budget hearings, and ordinance reviews.', 20, 1, 1),
    (N'Advisory Board & Committee',  N'advisory-board',        N'#7e22ce', N'badge-purple',  N'users',        N'Planning Commission, Noxious Weed Board, Lodging Tax, and citizen advisory committees.', 30, 1, 1),
    (N'Community Event & Outreach',  N'community-event',       N'#15803d', N'badge-success', N'calendar',     N'County Expo Center events, town halls, parks activities, and public workshops.', 40, 1, 1),
    (N'Holiday & Office Closure',    N'holiday-closure',       N'#b91c1c', N'badge-danger',  N'clock',        N'Official county holidays, courthouse closures, and modified department hours.', 50, 1, 1),
    (N'Elections & Civic Deadlines', N'elections-deadlines',   N'#0f172a', N'badge-neutral', N'check-square', N'Voter registration deadlines, ballot drop dates, tax due dates, and public trainings.', 60, 1, 1)
) AS Source ([name], [slug], [color], [badge_class], [icon], [description], [sort_order], [is_active], [is_system])
ON Target.[slug] = Source.[slug] AND Target.[deletedat] IS NULL
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([name], [slug], [color], [badge_class], [icon], [description], [sort_order], [is_active], [is_system], [createdat], [updatedat])
    VALUES (Source.[name], Source.[slug], Source.[color], Source.[badge_class], Source.[icon], Source.[description], Source.[sort_order], Source.[is_active], Source.[is_system], SYSUTCDATETIME(), SYSUTCDATETIME());
GO

-- -----------------------------------------------------------------------------
-- 2. Table: dbo.calendar_events
-- Individual county calendar events scoped by workspace (siteid) and category
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calendar_events]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[calendar_events] (
        [id]                  INT IDENTITY(1,1) NOT NULL,
        [siteid]              NVARCHAR(100) NOT NULL CONSTRAINT [DF_calendar_events_siteid] DEFAULT (N'global'),
        [category_id]         INT NOT NULL,
        [title]               NVARCHAR(255) NOT NULL,
        [slug]                NVARCHAR(255) NOT NULL,
        [summary]             NVARCHAR(500) NULL,
        [description]         NVARCHAR(MAX) NULL,
        [start_date]          DATE NOT NULL,
        [end_date]            DATE NOT NULL,
        [start_time]          NVARCHAR(20) NULL,
        [end_time]            NVARCHAR(20) NULL,
        [is_all_day]          BIT NOT NULL CONSTRAINT [DF_calendar_events_allday] DEFAULT (0),
        [location_name]       NVARCHAR(255) NULL,
        [location_address]    NVARCHAR(255) NULL,
        [room_number]         NVARCHAR(120) NULL,
        [virtual_meeting_url] NVARCHAR(1000) NULL,
        [virtual_meeting_id]  NVARCHAR(120) NULL,
        [agenda_url]          NVARCHAR(1000) NULL,
        [minutes_url]         NVARCHAR(1000) NULL,
        [contact_name]        NVARCHAR(150) NULL,
        [contact_email]       NVARCHAR(150) NULL,
        [contact_phone]       NVARCHAR(60) NULL,
        [is_featured]         BIT NOT NULL CONSTRAINT [DF_calendar_events_featured] DEFAULT (0),
        [is_public_notice]    BIT NOT NULL CONSTRAINT [DF_calendar_events_notice] DEFAULT (0),
        [status]              NVARCHAR(30) NOT NULL CONSTRAINT [DF_calendar_events_status] DEFAULT (N'Published'),
        [created_by]          NVARCHAR(255) NULL,
        [modified_by]         NVARCHAR(255) NULL,
        [createdat]           DATETIME2(7) NOT NULL CONSTRAINT [DF_calendar_events_createdat] DEFAULT (SYSUTCDATETIME()),
        [updatedat]           DATETIME2(7) NOT NULL CONSTRAINT [DF_calendar_events_updatedat] DEFAULT (SYSUTCDATETIME()),
        [deletedat]           DATETIME2(7) NULL,
        CONSTRAINT [PK_calendar_events] PRIMARY KEY CLUSTERED ([id] ASC),
        CONSTRAINT [FK_calendar_events_categories] FOREIGN KEY ([category_id]) REFERENCES [dbo].[calendar_event_categories] ([id])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_calendar_events_dates_site' AND object_id = OBJECT_ID(N'[dbo].[calendar_events]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_calendar_events_dates_site]
        ON [dbo].[calendar_events] ([start_date] ASC, [end_date] ASC, [siteid] ASC, [category_id] ASC)
        WHERE [deletedat] IS NULL;
END;
GO

