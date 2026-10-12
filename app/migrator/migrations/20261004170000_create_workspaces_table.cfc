component extends="wheels.migrator.Migration" hint="Creates cms_workspaces directory table with classification, virtual folder mapping, and contact metadata" {

	function up() {
		t = createTable(name="cms_workspaces");
		
		// Core Identification
		t.string(columnNames="code", limit=50, allowNull=false);
		t.string(columnNames="name", limit=150, allowNull=false);
		t.string(columnNames="alias", limit=100, allowNull=true);
		
		// Classification & Visual Markers
		t.string(columnNames="type", limit=20, default="dept", allowNull=false);
		t.string(columnNames="badge", limit=50, default="Dept", allowNull=false);
		t.string(columnNames="badge_class", limit=50, default="badge-neutral", allowNull=false);
		t.string(columnNames="icon", limit=50, default="building", allowNull=false);
		t.text(columnNames="description", allowNull=true);
		
		// Storage & Routing
		t.string(columnNames="folder_path", limit=255, allowNull=false);
		t.string(columnNames="virtual_directory", limit=100, allowNull=false);
		t.string(columnNames="redirect_url", limit=500, allowNull=true);
		
		// Department Categorization
		t.string(columnNames="department", limit=150, allowNull=true);
		t.string(columnNames="department_category", limit=100, allowNull=true);
		
		// Contact Information
		t.string(columnNames="contact_first_name", limit=100, allowNull=true);
		t.string(columnNames="contact_last_name", limit=100, allowNull=true);
		t.string(columnNames="contact_email", limit=255, allowNull=true);
		t.string(columnNames="contact_phone", limit=50, allowNull=true);
		t.string(columnNames="contact_fax", limit=50, allowNull=true);
		
		// Physical Location & Facility
		t.string(columnNames="address", limit=255, allowNull=true);
		t.string(columnNames="address2", limit=150, allowNull=true);
		t.string(columnNames="city", limit=100, default="Wenatchee", allowNull=false);
		t.string(columnNames="state", limit=50, default="WA", allowNull=false);
		t.string(columnNames="zip", limit=20, default="98801", allowNull=false);
		
		// Schedule & Hours
		t.text(columnNames="office_hours", allowNull=true);
		
		// Status & System Controls
		t.boolean(columnNames="is_active", default=true, allowNull=false);
		t.boolean(columnNames="is_system", default=false, allowNull=false);
		t.integer(columnNames="sort_order", default=0, allowNull=false);
		
		t.timestamps();
		t.datetime(columnNames="deletedat", allowNull=true);
		
		t.create();
		
		addIndex(table="cms_workspaces", columnNames="code", unique=true);
		addIndex(table="cms_workspaces", columnNames="virtual_directory", unique=true);
		addIndex(table="cms_workspaces", columnNames="type");
		addIndex(table="cms_workspaces", columnNames="department_category");
		addIndex(table="cms_workspaces", columnNames="is_active");
		addIndex(table="cms_workspaces", columnNames="sort_order");
	}

	function down() {
		dropTable("cms_workspaces");
	}

}
