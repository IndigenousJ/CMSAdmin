component extends="Model" {

	function config() {
		table("navigation_menus");

		hasMany(name="navigationMenuItems", foreignKey="navigation_menu_id");

		validatesPresenceOf(properties="siteid,menu_key,name");
		validatesUniquenessOf(properties="siteid,menu_key");

		setDateTimeProperties(createdAt="createdat", updatedAt="updatedat");
	}

}
