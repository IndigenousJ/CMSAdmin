component extends="Model" {

	function config() {
		// Table mapping
		table("cms_roles");

		// Associations
		hasMany(name="Users", foreignKey="role_id");

		// Validations
		validatesPresenceOf(property="code,name");
		validatesUniquenessOf(property="code");
	}

}
