component extends="wheels.migrator.Migration" hint="Creates pages table for Chelan County CMSAdmin 2.0" {

	function up() {
		t = createTable(name="pages", id=false);
		t.primaryKey(columnNames="ContentID", autoIncrement=true);
		t.string(columnNames="SiteID", limit=100, default="global", allowNull=false);
		t.integer(columnNames="PageType", default=0, allowNull=false);
		t.string(columnNames="MenuSelected", limit=255, allowNull=true);
		t.string(columnNames="LayoutType", limit=50, default="Full", allowNull=false);
		t.integer(columnNames="ParentID", default=0, allowNull=false);
		t.string(columnNames="StatusCode", limit=50, default="Active", allowNull=false);
		t.string(columnNames="Permalink", limit=255, allowNull=false);
		t.string(columnNames="Title", limit=255, allowNull=false);

		t.string(columnNames="MetaTitle", limit=255, allowNull=true);
		t.text(columnNames="MetaDesc", allowNull=true);
		t.string(columnNames="MetaKeyWords", limit=500, allowNull=true);
		t.text(columnNames="Summary", allowNull=true);
		t.text(columnNames="Body", allowNull=true);

		t.string(columnNames="imageAttachment", limit=500, allowNull=true);
		t.string(columnNames="imageAttribution", limit=255, allowNull=true);
		t.string(columnNames="imageAlt", limit=255, allowNull=true);
		t.string(columnNames="imageTitle", limit=255, allowNull=true);
		t.text(columnNames="imageDescription", allowNull=true);

		t.boolean(columnNames="isService", default=false, allowNull=false);
		t.boolean(columnNames="hasArchive", default=false, allowNull=false);
		t.boolean(columnNames="ShowInMenu", default=false, allowNull=false);
		t.boolean(columnNames="isLocked", default=false, allowNull=false);
		t.text(columnNames="SidebarIDs", allowNull=true);
		t.integer(columnNames="SortOrder", default=0, allowNull=false);

		t.boolean(columnNames="isPublished", default=true, allowNull=false);
		t.string(columnNames="Visibility", limit=50, default="Published", allowNull=false);
		t.dateTime(columnNames="PublishAt", allowNull=true);

		t.integer(columnNames="ViewCount", default=0, allowNull=false);

		t.dateTime(columnNames="Created", allowNull=false);
		t.string(columnNames="CreatedBy", limit=255, allowNull=true);
		t.dateTime(columnNames="Modified", allowNull=true);
		t.string(columnNames="ModifiedBy", limit=255, allowNull=true);
		t.dateTime(columnNames="DeletedAt", allowNull=true);
		t.string(columnNames="DeletedBy", limit=255, allowNull=true);
		t.create();

		addIndex(table="pages", columnNames="SiteID,Permalink", unique=true);
		addIndex(table="pages", columnNames="SiteID,StatusCode");
		addIndex(table="pages", columnNames="SiteID,ParentID");
	}

	function down() {
		dropTable("pages");
	}

}

