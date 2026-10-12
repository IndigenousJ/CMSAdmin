component extends="Model" {

	function config() {
		table("form_submission_values");

		// Associations
		belongsTo(name="formSubmission", foreignKey="submission_id");
		belongsTo(name="formField", foreignKey="field_id");

		// Validations
		validatesPresenceOf(properties="submission_id,field_key");

		// Timestamp
		setDateTimeProperties(createdAt="createdat");
	}

}
