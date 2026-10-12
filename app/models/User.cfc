component extends="Model" {

	function config() {
		// Table mapping (for database persistence layer)
		table("cms_users");

		// Associations
		belongsTo(name="Role", foreignKey="role_id");
		hasMany(name="UserWorkspaces", foreignKey="user_id");

		// Validations
		validatesPresenceOf(property="first_name,last_name,email,username,role_code");
		validatesUniquenessOf(property="email,username");
	}

}
