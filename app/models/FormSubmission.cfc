component extends="Model" {

	function config() {
		table("form_submissions");

		// Associations
		belongsTo(name="form", foreignKey="form_id");
		hasMany(name="formSubmissionValues", foreignKey="submission_id");

		// Validations
		validatesPresenceOf(properties="form_id,reference_id,submission_json");
		validatesUniquenessOf(properties="reference_id");

		// Timestamps
		setDateTimeProperties(createdAt="createdat", updatedAt="updatedat");
		setSoftDeleteProperty("deletedat");
	}

}
