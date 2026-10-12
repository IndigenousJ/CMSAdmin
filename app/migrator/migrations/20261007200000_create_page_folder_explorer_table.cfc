component extends="wheels.migrator.Migration" hint="Creates page_FolderExplorer table for Folder Explorer modules attached to pages" {

	function up() {
		t = createTable(name="page_FolderExplorer", id=false);
		t.primaryKey(columnNames="ID", autoIncrement=true);
		// ContentID is the ID of the page that hosts this folder explorer
		t.integer(columnNames="ContentID", allowNull=false);
		t.string(columnNames="SiteID", limit=100, default="global", allowNull=false);
		t.string(columnNames="Title", limit=255, allowNull=false);
		t.string(columnNames="RelativePath", limit=500, allowNull=true);
		t.string(columnNames="AbsolutePath", limit=500, allowNull=true);
		t.boolean(columnNames="Absolute", default=false, allowNull=false);
		t.integer(columnNames="Weight", default=0, allowNull=false);
		t.string(columnNames="Layout", limit=50, default="Full", allowNull=false);
		// Position among multiple folder explorers on the same page
		t.string(columnNames="Placement", limit=20, default="After", allowNull=false);
		t.create();

		addIndex(table="page_FolderExplorer", columnNames="SiteID,ContentID");
	}

	function down() {
		dropTable("page_FolderExplorer");
	}

}
