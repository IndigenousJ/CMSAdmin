component extends="Model" {

	function config() {
		table("navigation_menu_items");

		belongsTo(name="navigationMenu", foreignKey="navigation_menu_id");
		belongsTo(name="parentItem", foreignKey="parent_item_id");
		hasMany(name="childItems", foreignKey="parent_item_id");

		validatesPresenceOf(properties="navigation_menu_id,label,destination_type,destination");
		validatesNumericalityOf(properties="sort_order", onlyInteger=true);

		setDateTimeProperties(createdAt="createdat", updatedAt="updatedat");
	}

}
