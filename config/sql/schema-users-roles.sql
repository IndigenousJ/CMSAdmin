-- =============================================================================
-- Chelan County CMS Admin 2.0 - Users & Roles Relational Schema
-- Dialect: Microsoft SQL Server (2016+ / 2019 / 2022 / Azure SQL)
-- Modules: 4 Primary User Groups (Admin, PIO, HR, Author)
-- Workspace Scoping: Multi-Workspace & Portal Assignment Support
-- =============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- -----------------------------------------------------------------------------
-- 1. Table: cms_roles
-- Stores the 4 standard user groups and their operational descriptions
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cms_roles]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[cms_roles] (
        [id] INT IDENTITY(1,1) NOT NULL,
        [code] NVARCHAR(50) NOT NULL, -- 'admin', 'pio', 'hr', 'author'
        [name] NVARCHAR(100) NOT NULL,
        [description] NVARCHAR(MAX) NULL,
        [badge_class] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cms_roles_badge] DEFAULT ('badge-neutral'),
        [color_hex] NVARCHAR(20) NOT NULL CONSTRAINT [DF_cms_roles_color] DEFAULT ('#0073aa'),
        [icon_name] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cms_roles_icon] DEFAULT ('shield'),
        [can_access_content] BIT NOT NULL CONSTRAINT [DF_cms_roles_content] DEFAULT (1),
        [can_access_hrm] BIT NOT NULL CONSTRAINT [DF_cms_roles_hrm] DEFAULT (0),
        [can_access_pio] BIT NOT NULL CONSTRAINT [DF_cms_roles_pio] DEFAULT (0),
        [can_access_admin] BIT NOT NULL CONSTRAINT [DF_cms_roles_admin] DEFAULT (0),
        [is_system] BIT NOT NULL CONSTRAINT [DF_cms_roles_system] DEFAULT (1),
        [createdat] DATETIME2(7) NOT NULL CONSTRAINT [DF_cms_roles_createdat] DEFAULT (SYSUTCDATETIME()),
        [updatedat] DATETIME2(7) NOT NULL CONSTRAINT [DF_cms_roles_updatedat] DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT [PK_cms_roles] PRIMARY KEY CLUSTERED ([id] ASC),
        CONSTRAINT [UQ_cms_roles_code] UNIQUE NONCLUSTERED ([code] ASC)
    );
END;
GO

-- -----------------------------------------------------------------------------
-- 2. Table: cms_users
-- Staff and administrator user accounts with role binding and departmental scoping
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cms_users]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[cms_users] (
        [id] INT IDENTITY(1,1) NOT NULL,
        [role_id] INT NOT NULL,
        [role_code] NVARCHAR(50) NOT NULL,
        [username] NVARCHAR(100) NOT NULL,
        [email] NVARCHAR(255) NOT NULL,
        [first_name] NVARCHAR(100) NOT NULL,
        [last_name] NVARCHAR(100) NOT NULL,
        [job_title] NVARCHAR(150) NULL,
        [phone] NVARCHAR(50) NULL,
        [department_code] NVARCHAR(100) NULL CONSTRAINT [DF_cms_users_dept] DEFAULT ('global'),
        [department_name] NVARCHAR(150) NULL,
        [assigned_workspaces] NVARCHAR(MAX) NULL CONSTRAINT [DF_cms_users_workspaces] DEFAULT ('["global"]'),
        [password_hash] NVARCHAR(255) NOT NULL,
        [password_salt] NVARCHAR(100) NULL,
        [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cms_users_status] DEFAULT ('active'), -- 'active', 'inactive', 'suspended'
        [two_factor_enabled] BIT NOT NULL CONSTRAINT [DF_cms_users_2fa] DEFAULT (0),
        [force_password_change] BIT NOT NULL CONSTRAINT [DF_cms_users_pw_change] DEFAULT (0),
        [last_login_at] DATETIME2(7) NULL,
        [last_login_ip] NVARCHAR(45) NULL,
        [createdat] DATETIME2(7) NOT NULL CONSTRAINT [DF_cms_users_createdat] DEFAULT (SYSUTCDATETIME()),
        [updatedat] DATETIME2(7) NOT NULL CONSTRAINT [DF_cms_users_updatedat] DEFAULT (SYSUTCDATETIME()),
        [deletedat] DATETIME2(7) NULL,
        CONSTRAINT [PK_cms_users] PRIMARY KEY CLUSTERED ([id] ASC),
        CONSTRAINT [UQ_cms_users_username] UNIQUE NONCLUSTERED ([username] ASC),
        CONSTRAINT [UQ_cms_users_email] UNIQUE NONCLUSTERED ([email] ASC),
        CONSTRAINT [FK_cms_users_roles] FOREIGN KEY ([role_id]) REFERENCES [dbo].[cms_roles] ([id])
    );

    CREATE NONCLUSTERED INDEX [IX_cms_users_role_code] ON [dbo].[cms_users] ([role_code] ASC);
    CREATE NONCLUSTERED INDEX [IX_cms_users_dept_code] ON [dbo].[cms_users] ([department_code] ASC);
    CREATE NONCLUSTERED INDEX [IX_cms_users_status] ON [dbo].[cms_users] ([status] ASC);
END;
GO

-- -----------------------------------------------------------------------------
-- 3. Table: cms_user_workspaces (Many-to-Many Multi-Workspace Assignment)
-- Supports multiple departmental workspaces and site portals per staff member
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cms_user_workspaces]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[cms_user_workspaces] (
        [id] INT IDENTITY(1,1) NOT NULL,
        [user_id] INT NOT NULL,
        [workspace_code] NVARCHAR(50) NOT NULL, -- e.g. 'global', 'pio', 'commdev', 'site-main', 'site-parks'
        [is_primary] BIT NOT NULL CONSTRAINT [DF_cms_user_ws_primary] DEFAULT (0),
        [createdat] DATETIME2(7) NOT NULL CONSTRAINT [DF_cms_user_ws_createdat] DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT [PK_cms_user_workspaces] PRIMARY KEY CLUSTERED ([id] ASC),
        CONSTRAINT [FK_cms_user_workspaces_user] FOREIGN KEY ([user_id]) REFERENCES [dbo].[cms_users] ([id]) ON DELETE CASCADE,
        CONSTRAINT [UQ_cms_user_workspaces_user_ws] UNIQUE NONCLUSTERED ([user_id] ASC, [workspace_code] ASC)
    );

    CREATE NONCLUSTERED INDEX [IX_cms_user_workspaces_ws] ON [dbo].[cms_user_workspaces] ([workspace_code] ASC);
END;
GO

-- -----------------------------------------------------------------------------
-- 4. Seed Data: 4 Core User Groups
-- Admin (Everything), PIO (Content + PIO), HR (Content + HRM), Author (Content)
-- -----------------------------------------------------------------------------
MERGE INTO [dbo].[cms_roles] AS Target
USING (VALUES
    ('admin', 'Administrator', 'Full unrestricted county-wide administrative access to all workspaces, settings, user security, and modules.', 'badge-danger', '#b91c1c', 'shield', 1, 1, 1, 1, 1),
    ('pio', 'PIO (Public Information Officer)', 'Dedicated public communications, emergency alerts, press releases, media kits, articles and general web publishing.', 'badge-info', '#0284c7', 'megaphone', 1, 0, 1, 0, 1),
    ('hr', 'HR (Human Resources)', 'Human resources personnel management, recruitment job postings, employee onboarding, policies, and web publishing.', 'badge-purple', '#7e22ce', 'briefcase', 1, 1, 0, 0, 1),
    ('author', 'Author (Web Content Editor)', 'General web content update permissions for drafting and editing pages, media library assets, and online forms.', 'badge-primary', '#0073aa', 'edit', 1, 0, 0, 0, 1)
) AS Source ([code], [name], [description], [badge_class], [color_hex], [icon_name], [can_access_content], [can_access_hrm], [can_access_pio], [can_access_admin], [is_system])
ON Target.[code] = Source.[code]
WHEN MATCHED THEN
    UPDATE SET 
        Target.[name] = Source.[name],
        Target.[description] = Source.[description],
        Target.[badge_class] = Source.[badge_class],
        Target.[color_hex] = Source.[color_hex],
        Target.[icon_name] = Source.[icon_name],
        Target.[can_access_content] = Source.[can_access_content],
        Target.[can_access_hrm] = Source.[can_access_hrm],
        Target.[can_access_pio] = Source.[can_access_pio],
        Target.[can_access_admin] = Source.[can_access_admin]
WHEN NOT MATCHED THEN
    INSERT ([code], [name], [description], [badge_class], [color_hex], [icon_name], [can_access_content], [can_access_hrm], [can_access_pio], [can_access_admin], [is_system])
    VALUES (Source.[code], Source.[name], Source.[description], Source.[badge_class], Source.[color_hex], Source.[icon_name], Source.[can_access_content], Source.[can_access_hrm], Source.[can_access_pio], Source.[can_access_admin], Source.[is_system]);
GO
