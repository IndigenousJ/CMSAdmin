component extends="Model" {

	function config() {
		table("how_do_i_categories");
		hasMany(name="items", modelName="HowDoIItem", foreignKey="category_id");
		validatesPresenceOf(properties="name,slug");
	}

}

