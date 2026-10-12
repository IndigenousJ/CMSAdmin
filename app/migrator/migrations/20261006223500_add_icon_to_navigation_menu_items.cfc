component extends="wheels.migrator.Migration" hint="Adds an optional icon name to navigation menu items" {

	function up() {
		addColumn(table="navigation_menu_items", columnType="string", columnName="icon", limit=50, allowNull=true);
	}

	function down() {
		removeColumn(table="navigation_menu_items", columnName="icon");
	}

}
