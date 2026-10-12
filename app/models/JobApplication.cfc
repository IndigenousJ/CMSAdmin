component extends="Model" {

	function config() {
		table("job_applications");
		setPrimaryKey("ApplicationID");

		// Associations
		belongsTo(name="jobPosting", modelName="JobPosting", foreignKey="JobID");

		// Validations
		validatesPresenceOf(properties="Position,FirstName,LastName,Email,Phone");

		// Timestamps & Soft Deletes
		setSoftDeleteProperty("DeletedAt");
	}

	/**
	 * Returns full applicant name
	 */
	public string function getFullName() {
		var name = Trim(this.FirstName ?: "");
		if (Len(Trim(this.MiddleName ?: ""))) {
			name &= " " & Trim(this.MiddleName);
		}
		name &= " " & Trim(this.LastName ?: "");
		return Trim(name);
	}

	/**
	 * Returns badge class for candidate status
	 */
	public string function getStatusBadge() {
		switch (LCase(this.Status ?: "")) {
			case "new": return "badge-primary";
			case "under review":
			case "reviewing": return "badge-info";
			case "interview": return "badge-purple";
			case "offer": return "badge-warning";
			case "hired": return "badge-success";
			case "not selected":
			case "rejected": return "badge-danger";
			case "archived": return "badge-neutral";
			default: return "badge-neutral";
		}
	}

}
