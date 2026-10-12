component extends="Model" {

	function config() {
		table("forms");
		
		// Associations
		belongsTo(name="formDepartment", foreignKey="department_id");
		hasMany(name="formFields", foreignKey="form_id");
		hasMany(name="formSubmissions", foreignKey="form_id");
		hasMany(name="formAuditLogs", foreignKey="form_id");

		// Validations
		validatesPresenceOf(properties="title,form_key,slug,siteid");
		validatesUniquenessOf(properties="form_key");
		validatesUniquenessOf(properties="slug");
		validatesNumericalityOf(properties="min_delay_seconds,cooldown_seconds", onlyInteger=true);

		// Automatic Timestamping & Soft Deletes
		setDateTimeProperties(createdAt="createdat", updatedAt="updatedat");
		setSoftDeleteProperty("deletedat");
	}

	/**
	 * Returns human-readable status badge class
	 */
	public string function getStatusBadge() {
		switch (LCase(this.status)) {
			case "published": return "badge-success";
			case "draft": return "badge-neutral";
			case "archived": return "badge-danger";
			default: return "badge-primary";
		}
	}

}
