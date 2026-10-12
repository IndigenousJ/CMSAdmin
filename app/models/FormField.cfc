component extends="Model" {

	function config() {
		table("form_fields");

		// Associations
		belongsTo(name="form", foreignKey="form_id");
		hasMany(name="formSubmissionValues", foreignKey="field_id");

		// Validations
		validatesPresenceOf(properties="form_id,field_key,field_type,label");
		validatesNumericalityOf(properties="sort_order,textarea_rows", onlyInteger=true);

		// Timestamps
		setDateTimeProperties(createdAt="createdat", updatedAt="updatedat");
		setSoftDeleteProperty("deletedat");
	}

}
