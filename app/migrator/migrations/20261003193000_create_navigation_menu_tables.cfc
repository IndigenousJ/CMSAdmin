component extends="wheels.migrator.Migration" hint="Creates navigation menus and their ordered, nested menu items" {

	function up() {
		t = createTable(name="navigation_menus");
		t.string(columnNames="siteid", limit=100, allowNull=false);
		t.string(columnNames="menu_key", limit=100, allowNull=false);
		t.string(columnNames="name", limit=150, allowNull=false);
		t.boolean(columnNames="is_active", default=true);
		t.timestamps();
		t.create();
		addIndex(table="navigation_menus", columnNames="siteid,menu_key", unique=true);
		addIndex(table="navigation_menus", columnNames="siteid");

		t = createTable(name="navigation_menu_items");
		t.integer(columnNames="navigation_menu_id", allowNull=false);
		t.integer(columnNames="parent_item_id", allowNull=true);
		t.string(columnNames="label", limit=150, allowNull=false);
		t.string(columnNames="destination_type", limit=20, default="page");
		t.string(columnNames="destination", limit=1000, allowNull=false);
		t.integer(columnNames="sort_order", default=0);
		t.boolean(columnNames="is_active", default=true);
		t.boolean(columnNames="open_in_new_tab", default=false);
		t.timestamps();
		t.create();
		addIndex(table="navigation_menu_items", columnNames="navigation_menu_id,sort_order");
		addIndex(table="navigation_menu_items", columnNames="parent_item_id,sort_order");

		execute("
			ALTER TABLE navigation_menu_items
			ADD CONSTRAINT fk_navigation_menu_items_menu
			FOREIGN KEY (navigation_menu_id)
			REFERENCES navigation_menus (id)
			ON DELETE NO ACTION
		");
		execute("
			ALTER TABLE navigation_menu_items
			ADD CONSTRAINT fk_navigation_menu_items_parent
			FOREIGN KEY (parent_item_id)
			REFERENCES navigation_menu_items (id)
			ON DELETE NO ACTION
		");
		execute("
			ALTER TABLE navigation_menu_items
			ADD CONSTRAINT chk_navigation_menu_items_destination_type
			CHECK (destination_type IN ('page', 'url'))
		");
	}

	function down() {
		dropTable("navigation_menu_items");
		dropTable("navigation_menus");
	}

}
