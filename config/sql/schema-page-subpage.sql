IF OBJECT_ID(N'dbo.page_SubPage', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.page_SubPage (
        ID           INT IDENTITY(1,1) NOT NULL,
        ContentID    INT            NOT NULL,   -- ID of the page
        SiteID       NVARCHAR(100)  NOT NULL CONSTRAINT DF_page_SubPage_SiteID DEFAULT (N'global'),   -- workspace
        Title        NVARCHAR(255)  NOT NULL,
        Body         NVARCHAR(MAX)  NULL,
        Position     INT            NOT NULL CONSTRAINT DF_page_SubPage_Position DEFAULT (0),
        CreatedAt    DATETIME2(0)   NOT NULL CONSTRAINT DF_page_SubPage_CreatedAt DEFAULT (SYSDATETIME()),
        CreatedBy    NVARCHAR(255)  NULL,
        ModifiedAt   DATETIME2(0)   NULL,
        ModifiedBy   NVARCHAR(255)  NULL,
        CONSTRAINT PK_page_SubPage PRIMARY KEY CLUSTERED (ID)
    );

    CREATE NONCLUSTERED INDEX IX_page_SubPage_ContentID
        ON dbo.page_SubPage (SiteID, ContentID, Position);
END
GO

-- Upgrade path for a table created before workspace scoping
IF COL_LENGTH(N'dbo.page_SubPage', N'SiteID') IS NULL
BEGIN
    ALTER TABLE dbo.page_SubPage ADD SiteID NVARCHAR(100) NOT NULL
        CONSTRAINT DF_page_SubPage_SiteID DEFAULT (N'global');
    CREATE NONCLUSTERED INDEX IX_page_SubPage_SiteID
        ON dbo.page_SubPage (SiteID, ContentID, Position);
END
GO
