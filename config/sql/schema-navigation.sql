-- =============================================================================
-- Chelan County CMS Admin 2.0 - Navigation Module Database Schema
-- Dialect: Microsoft SQL Server (2016+ / 2019 / 2022 / Azure SQL)
-- Features: Site-scoped menus, ordered nested items, and destination validation
-- Safe to rerun: creates missing Navigation tables and indexes only.
-- Existing objects and data are not altered or dropped. Run in the intended database.
-- =============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- -----------------------------------------------------------------------------
-- 1. Table: navigation_menus
-- Defines named navigation menus for a site or workspace.
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[navigation_menus]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[navigation_menus] (
        [id] INT IDENTITY(1,1) NOT NULL,
        [siteid] NVARCHAR(100) NOT NULL,
        [menu_key] NVARCHAR(100) NOT NULL,
        [name] NVARCHAR(150) NOT NULL,
        [is_active] BIT NOT NULL CONSTRAINT [DF_navigation_menus_is_active] DEFAULT (1),
        [createdat] DATETIME2(7) NOT NULL CONSTRAINT [DF_navigation_menus_createdat] DEFAULT (SYSUTCDATETIME()),
        [updatedat] DATETIME2(7) NOT NULL CONSTRAINT [DF_navigation_menus_updatedat] DEFAULT (SYSUTCDATETIME()),
        [deletedat] DATETIME2(7) NULL,
        CONSTRAINT [PK_navigation_menus] PRIMARY KEY CLUSTERED ([id] ASC),
        CONSTRAINT [UQ_navigation_menus_site_key] UNIQUE NONCLUSTERED ([siteid] ASC, [menu_key] ASC)
    );
END;
GO

-- -----------------------------------------------------------------------------
-- 2. Table: navigation_menu_items
-- Stores ordered menu links with optional nested parent items.
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[navigation_menu_items]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[navigation_menu_items] (
        [id] INT IDENTITY(1,1) NOT NULL,
        [navigation_menu_id] INT NOT NULL,
        [parent_item_id] INT NULL,
        [label] NVARCHAR(150) NOT NULL,
        [destination_type] NVARCHAR(20) NOT NULL CONSTRAINT [DF_navigation_menu_items_destination_type] DEFAULT ('page'),
        [destination] NVARCHAR(1000) NOT NULL,
        [sort_order] INT NOT NULL CONSTRAINT [DF_navigation_menu_items_sort_order] DEFAULT (0),
        [is_active] BIT NOT NULL CONSTRAINT [DF_navigation_menu_items_is_active] DEFAULT (1),
        [open_in_new_tab] BIT NOT NULL CONSTRAINT [DF_navigation_menu_items_open_in_new_tab] DEFAULT (0),
        [createdat] DATETIME2(7) NOT NULL CONSTRAINT [DF_navigation_menu_items_createdat] DEFAULT (SYSUTCDATETIME()),
        [updatedat] DATETIME2(7) NOT NULL CONSTRAINT [DF_navigation_menu_items_updatedat] DEFAULT (SYSUTCDATETIME()),
        [deletedat] DATETIME2(7) NULL,
        CONSTRAINT [PK_navigation_menu_items] PRIMARY KEY CLUSTERED ([id] ASC),
        CONSTRAINT [UQ_navigation_menu_items_menu_id] UNIQUE NONCLUSTERED ([navigation_menu_id] ASC, [id] ASC),
        CONSTRAINT [FK_navigation_menu_items_menu] FOREIGN KEY ([navigation_menu_id])
            REFERENCES [dbo].[navigation_menus] ([id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_navigation_menu_items_parent_menu] FOREIGN KEY ([navigation_menu_id], [parent_item_id])
            REFERENCES [dbo].[navigation_menu_items] ([navigation_menu_id], [id]) ON DELETE NO ACTION,
        CONSTRAINT [CK_navigation_menu_items_destination_type]
            CHECK ([destination_type] IN ('page', 'url')),
        CONSTRAINT [CK_navigation_menu_items_not_self_parent]
            CHECK ([parent_item_id] IS NULL OR [parent_item_id] <> [id])
    );
END;
GO

-- -----------------------------------------------------------------------------
-- Performance Indexes
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_navigation_menus_siteid' AND object_id = OBJECT_ID(N'[dbo].[navigation_menus]'))
    CREATE NONCLUSTERED INDEX [IX_navigation_menus_siteid] ON [dbo].[navigation_menus] ([siteid] ASC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_navigation_menu_items_menu_sort' AND object_id = OBJECT_ID(N'[dbo].[navigation_menu_items]'))
    CREATE NONCLUSTERED INDEX [IX_navigation_menu_items_menu_sort] ON [dbo].[navigation_menu_items] ([navigation_menu_id] ASC, [sort_order] ASC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_navigation_menu_items_parent_sort' AND object_id = OBJECT_ID(N'[dbo].[navigation_menu_items]'))
    CREATE NONCLUSTERED INDEX [IX_navigation_menu_items_parent_sort] ON [dbo].[navigation_menu_items] ([parent_item_id] ASC, [sort_order] ASC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_navigation_menu_items_menu_parent' AND object_id = OBJECT_ID(N'[dbo].[navigation_menu_items]'))
    CREATE NONCLUSTERED INDEX [IX_navigation_menu_items_menu_parent] ON [dbo].[navigation_menu_items] ([navigation_menu_id] ASC, [parent_item_id] ASC);
GO

-- -----------------------------------------------------------------------------
-- Verification: expected Navigation tables in the current database
-- -----------------------------------------------------------------------------
SELECT [name]
FROM sys.tables
WHERE [schema_id] = SCHEMA_ID(N'dbo')
  AND [name] IN (
      N'navigation_menus',
      N'navigation_menu_items'
  )
ORDER BY [name];
GO
