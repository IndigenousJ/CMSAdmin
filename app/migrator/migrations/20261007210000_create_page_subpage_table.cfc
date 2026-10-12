component extends="wheels.migrator.Migration" hint="Creates page_SubPage table for subpages attached to pages" {

	function up() {
		t = createTable(name="page_SubPage", id=false);
		t.primaryKey(columnNames="ID", autoIncrement=true);
		// ContentID is the ID of the page that hosts this subpage
		t.integer(columnNames="ContentID", allowNull=false);
		t.string(columnNames="SiteID", limit=100, default="global", allowNull=false);
		t.string(columnNames="Title", limit=255, allowNull=false);
		t.text(columnNames="Body", allowNull=true);
		t.integer(columnNames="Position", default=0, allowNull=false);
		t.datetime(columnNames="CreatedAt", allowNull=false);
		t.string(columnNames="CreatedBy", limit=255, allowNull=true);
		t.datetime(columnNames="ModifiedAt", allowNull=true);
		t.string(columnNames="ModifiedBy", limit=255, allowNull=true);
		t.create();

		addIndex(table="page_SubPage", columnNames="SiteID,ContentID,Position");
	}

	function down() {
		dropTable("page_SubPage");
	}

}
