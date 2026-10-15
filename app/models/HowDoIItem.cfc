component extends="Model" {

	function config() {
		table("how_do_i_items");
		belongsTo(name="category", modelName="HowDoICategory", foreignKey="category_id");
		validatesPresenceOf(properties="category_id,siteid,question,destination_url");
	}

}

