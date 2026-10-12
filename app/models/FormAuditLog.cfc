component extends="Model" {

	function config() {
		table("form_audit_logs");

		// Associations
		belongsTo(name="form", foreignKey="form_id");

		// Validations
		validatesPresenceOf(properties="action,performed_by");

		// Timestamp
		setDateTimeProperties(createdAt="createdat");
	}

}
