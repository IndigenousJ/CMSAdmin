component extends="wheels.migrator.Migration" hint="Enforces same-menu navigation parents and prevents self-parenting" {

	function up() {
		addIndex(
			table="navigation_menu_items",
			columnNames="navigation_menu_id,id",
			unique=true,
			indexName="uq_navigation_menu_items_menu_id"
		);
		addIndex(
			table="navigation_menu_items",
			columnNames="navigation_menu_id,parent_item_id",
			indexName="ix_navigation_menu_items_menu_parent"
		);

		dropForeignKey(
			table="navigation_menu_items",
			keyName="fk_navigation_menu_items_parent"
		);
		execute("
			ALTER TABLE navigation_menu_items
			ADD CONSTRAINT fk_navigation_menu_items_parent_menu
			FOREIGN KEY (navigation_menu_id, parent_item_id)
			REFERENCES navigation_menu_items (navigation_menu_id, id)
			ON DELETE NO ACTION
		");
		execute("
			ALTER TABLE navigation_menu_items
			ADD CONSTRAINT chk_navigation_menu_items_not_self_parent
			CHECK (parent_item_id IS NULL OR parent_item_id <> id)
		");
	}

	function down() {
		execute("
			ALTER TABLE navigation_menu_items
			DROP CONSTRAINT chk_navigation_menu_items_not_self_parent
		");
		dropForeignKey(
			table="navigation_menu_items",
			keyName="fk_navigation_menu_items_parent_menu"
		);
		execute("
			ALTER TABLE navigation_menu_items
			ADD CONSTRAINT fk_navigation_menu_items_parent
			FOREIGN KEY (parent_item_id)
			REFERENCES navigation_menu_items (id)
			ON DELETE NO ACTION
		");

		removeIndex(
			table="navigation_menu_items",
			indexName="ix_navigation_menu_items_menu_parent"
		);
		removeIndex(
			table="navigation_menu_items",
			indexName="uq_navigation_menu_items_menu_id"
		);
	}

}
