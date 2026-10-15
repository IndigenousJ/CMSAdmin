-- =============================================================================
-- Chelan County CMS Admin 2.0 - How Do I Directory & Mega-Menu Relational Schema
-- Dialect: Microsoft SQL Server (2016+ / 2019 / 2022 / Azure SQL)
-- Modules: How Do I Categories (how_do_i_categories) & Action Links (how_do_i_items)
-- Workspace Scoping: Multi-Tenant Site/Department Scoping (siteid) with County Rollup
-- Safe to rerun: creates missing tables, indexes, constraints, and seeds standard categories.
-- =============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- -----------------------------------------------------------------------------
-- 1. Table: dbo.how_do_i_categories
-- Standard Chelan County action categories (Apply For, Contact, Find, File A,
-- Join, Pay For, Learn About, Register To, Report, Request, Search For, View)
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[how_do_i_categories]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[how_do_i_categories] (
        [id]          INT IDENTITY(1,1) NOT NULL,
        [name]        NVARCHAR(120) NOT NULL,
        [slug]        NVARCHAR(120) NOT NULL,
        [icon]        NVARCHAR(50) NOT NULL CONSTRAINT [DF_how_do_i_cat_icon] DEFAULT (N'help-circle'),
        [description] NVARCHAR(255) NULL,
        [sort_order]  INT NOT NULL CONSTRAINT [DF_how_do_i_cat_sort] DEFAULT (0),
        [is_active]   BIT NOT NULL CONSTRAINT [DF_how_do_i_cat_active] DEFAULT (1),
        [is_system]   BIT NOT NULL CONSTRAINT [DF_how_do_i_cat_system] DEFAULT (0),
        [createdat]   DATETIME2(7) NOT NULL CONSTRAINT [DF_how_do_i_cat_createdat] DEFAULT (SYSUTCDATETIME()),
        [updatedat]   DATETIME2(7) NOT NULL CONSTRAINT [DF_how_do_i_cat_updatedat] DEFAULT (SYSUTCDATETIME()),
        [deletedat]   DATETIME2(7) NULL,
        CONSTRAINT [PK_how_do_i_categories] PRIMARY KEY CLUSTERED ([id] ASC)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UQ_how_do_i_categories_slug' AND object_id = OBJECT_ID(N'[dbo].[how_do_i_categories]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UQ_how_do_i_categories_slug]
        ON [dbo].[how_do_i_categories] ([slug] ASC)
        WHERE [deletedat] IS NULL;
END;
GO

-- Seed the 12 Standard Chelan County "How Do I" Categories
MERGE INTO [dbo].[how_do_i_categories] AS Target
USING (VALUES
    (N'Apply For',   N'apply-for',   N'clipboard-list', N'Permits, licenses, employment, and county program applications.', 10, 1, 1),
    (N'Contact',     N'contact',     N'phone',          N'Department directories, elected officials, and office contact desks.', 20, 1, 1),
    (N'Find',        N'find',        N'search',         N'Locate county resources, election results, court statuses, and districts.', 30, 1, 1),
    (N'File A',      N'file-a',      N'file-text',      N'Submit official claims, petitions, and formal filings.', 40, 1, 1),
    (N'Join',        N'join',        N'users',          N'Volunteer boards, advisory committees, and community programs.', 50, 1, 1),
    (N'Pay For',     N'pay-for',     N'hard-drive',     N'Online payments for property taxes, court costs, probation, and accounts.', 60, 1, 1),
    (N'Learn About', N'learn-about', N'book',           N'Educational guides, court protection orders, and county initiatives.', 70, 1, 1),
    (N'Register To', N'register-to', N'check-square',   N'Voter registration, jury duty check-in, and court classes.', 80, 1, 1),
    (N'Report',      N'report',      N'megaphone',      N'Report road hazards, code violations, pest infestations, or tips.', 90, 1, 1),
    (N'Request',     N'request',     N'mail',           N'Public records requests, court case records, and vital certificates.', 100, 1, 1),
    (N'Search For',  N'search-for',  N'globe',          N'Public document archives, parcel lookups, and jail registries.', 110, 1, 1),
    (N'View',        N'view',        N'eye',            N'Court calendars, dockets, schedules, and public hearings.', 120, 1, 1)
) AS Source ([name], [slug], [icon], [description], [sort_order], [is_active], [is_system])
ON Target.[slug] = Source.[slug] AND Target.[deletedat] IS NULL
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([name], [slug], [icon], [description], [sort_order], [is_active], [is_system], [createdat], [updatedat])
    VALUES (Source.[name], Source.[slug], Source.[icon], Source.[description], Source.[sort_order], Source.[is_active], Source.[is_system], SYSUTCDATETIME(), SYSUTCDATETIME());
GO

-- -----------------------------------------------------------------------------
-- 2. Table: dbo.how_do_i_items
-- Individual action links scoped by workspace (siteid) and grouped by category
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[how_do_i_items]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[how_do_i_items] (
        [id]                    INT IDENTITY(1,1) NOT NULL,
        [category_id]           INT NOT NULL,
        [siteid]                NVARCHAR(100) NOT NULL CONSTRAINT [DF_how_do_i_items_siteid] DEFAULT (N'global'),
        [question]              NVARCHAR(255) NOT NULL,
        [destination_type]      NVARCHAR(30) NOT NULL CONSTRAINT [DF_how_do_i_items_dtype] DEFAULT (N'page'), -- 'page', 'form', 'custom', 'external'
        [page_id]               INT NULL,
        [form_id]               INT NULL,
        [destination_url]       NVARCHAR(1000) NOT NULL,
        [open_in_new_tab]       BIT NOT NULL CONSTRAINT [DF_how_do_i_items_newtab] DEFAULT (0),
        [is_featured_mega_menu] BIT NOT NULL CONSTRAINT [DF_how_do_i_items_mega] DEFAULT (1),
        [sort_order]            INT NOT NULL CONSTRAINT [DF_how_do_i_items_sort] DEFAULT (0),
        [is_published]          BIT NOT NULL CONSTRAINT [DF_how_do_i_items_pub] DEFAULT (1),
        [created_by]            NVARCHAR(255) NULL,
        [modified_by]           NVARCHAR(255) NULL,
        [createdat]             DATETIME2(7) NOT NULL CONSTRAINT [DF_how_do_i_items_createdat] DEFAULT (SYSUTCDATETIME()),
        [updatedat]             DATETIME2(7) NOT NULL CONSTRAINT [DF_how_do_i_items_updatedat] DEFAULT (SYSUTCDATETIME()),
        [deletedat]             DATETIME2(7) NULL,
        CONSTRAINT [PK_how_do_i_items] PRIMARY KEY CLUSTERED ([id] ASC),
        CONSTRAINT [FK_how_do_i_items_categories] FOREIGN KEY ([category_id]) REFERENCES [dbo].[how_do_i_categories] ([id])
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_how_do_i_items_site_cat' AND object_id = OBJECT_ID(N'[dbo].[how_do_i_items]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_how_do_i_items_site_cat]
        ON [dbo].[how_do_i_items] ([siteid] ASC, [category_id] ASC, [sort_order] ASC)
        WHERE [deletedat] IS NULL;
END;
GO

