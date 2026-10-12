IF OBJECT_ID(N'dbo.page_FolderExplorer', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.page_FolderExplorer (
        ID           INT IDENTITY(1,1) NOT NULL,
        ContentID    INT           NOT NULL,   -- ID of the page
        SiteID       NVARCHAR(100) NOT NULL CONSTRAINT DF_page_FolderExplorer_SiteID DEFAULT (N'global'),   -- workspace
        Title        NVARCHAR(255) NOT NULL,
        RelativePath NVARCHAR(500) NULL,
        AbsolutePath NVARCHAR(500) NULL,
        Absolute     BIT           NOT NULL CONSTRAINT DF_page_FolderExplorer_Absolute  DEFAULT (0),
        Weight       INT           NOT NULL CONSTRAINT DF_page_FolderExplorer_Weight    DEFAULT (0),
        Layout       NVARCHAR(50)  NOT NULL CONSTRAINT DF_page_FolderExplorer_Layout    DEFAULT (N'Full'),
        Placement    NVARCHAR(20)  NOT NULL CONSTRAINT DF_page_FolderExplorer_Placement DEFAULT (N'After'),
        CONSTRAINT PK_page_FolderExplorer PRIMARY KEY CLUSTERED (ID)
    );

    CREATE NONCLUSTERED INDEX IX_page_FolderExplorer_ContentID
        ON dbo.page_FolderExplorer (SiteID, ContentID);
END
GO

-- Upgrade path for a table created before workspace scoping
IF COL_LENGTH(N'dbo.page_FolderExplorer', N'SiteID') IS NULL
BEGIN
    ALTER TABLE dbo.page_FolderExplorer ADD SiteID NVARCHAR(100) NOT NULL
        CONSTRAINT DF_page_FolderExplorer_SiteID DEFAULT (N'global');
    CREATE NONCLUSTERED INDEX IX_page_FolderExplorer_SiteID
        ON dbo.page_FolderExplorer (SiteID, ContentID);
END
GO
