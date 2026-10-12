component extends="Model" {

	function config() {
		table("form_departments");

		// Associations
		hasMany(name="forms", foreignKey="department_id");

		// Validations
		validatesPresenceOf(properties="code,name,alert_email");
		validatesUniquenessOf(properties="code");
		validatesFormatOf(properties="alert_email", type="email");

		// Timestamps
		setDateTimeProperties(createdAt="createdat", updatedAt="updatedat");
		setSoftDeleteProperty("deletedat");
	}

}
