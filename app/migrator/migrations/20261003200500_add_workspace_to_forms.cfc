component extends="wheels.migrator.Migration" hint="Adds workspace ownership to forms" {

	function up() {
		addColumn(
			table="forms",
			columnType="string",
			columnName="siteid",
			limit=100,
			allowNull=true
		);
		addIndex(
			table="forms",
			columnNames="siteid",
			indexName="ix_forms_siteid"
		);
	}

	function down() {
		removeIndex(table="forms", indexName="ix_forms_siteid");
		removeColumn(table="forms", columnName="siteid");
	}

}
