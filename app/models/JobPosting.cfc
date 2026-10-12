component extends="Model" {

	function config() {
		table("job_listings");
		setPrimaryKey("JobID");

		// Associations
		hasMany(name="applications", modelName="JobApplication", foreignKey="JobID");

		// Validations
		validatesPresenceOf(properties="Title,SiteID,Permalink");

		// Timestamps and soft delete
		setDateTimeProperties(createdAt="Created", updatedAt="Modified");
		setSoftDeleteProperty("DeletedAt");
	}

	/**
	 * Returns human-readable FLSA text
	 */
	public string function getFLSAText() {
		return (this.FLSAClassificationID == 2) ? "Exempt" : "Non-Exempt";
	}

	/**
	 * Returns human-readable job classification text
	 */
	public string function getClassificationText() {
		switch (Val(this.JobClasificationID ?: 1)) {
			case 1: return "Full-Time";
			case 2: return "Part-Time";
			case 3: return "Seasonal";
			case 4: return "Temporary";
			case 5: return "On-Call";
			default: return "Full-Time";
		}
	}

	/**
	 * Returns formatted salary / compensation string
	 */
	public string function getFormattedSalary() {
		var minS = Val(this.MinSalary ?: 0);
		var maxS = Val(this.MaxSalary ?: 0);
		var sched = Len(Trim(this.SalarySchedule ?: "")) ? Trim(this.SalarySchedule) : "Hourly";
		
		if (minS > 0 && maxS > 0) {
			if (minS == maxS) {
				return "$" & NumberFormat(minS, ",.__") & " / " & sched;
			}
			return "$" & NumberFormat(minS, ",.__") & " - $" & NumberFormat(maxS, ",.__") & " / " & sched;
		} else if (minS > 0) {
			return "From $" & NumberFormat(minS, ",.__") & " / " & sched;
		}
		return "DOE";
	}

	/**
	 * Returns badge class based on status
	 */
	public string function getStatusBadge() {
		switch (LCase(this.StatusCode ?: "")) {
			case "active": return "badge-success";
			case "draft": return "badge-neutral";
			case "reviewing": return "badge-warning";
			case "closed": return "badge-danger";
			case "archived": return "badge-neutral";
			default: return "badge-primary";
		}
	}

	/**
	 * Returns true if position is currently open
	 */
	public boolean function isOpen() {
		if (LCase(this.StatusCode ?: "") != "active") return false;
		if (!IsDate(this.ApplicationDeadline)) return true; // Open until filled
		if (this.ApplicationDeadline < Now()) return false;
		return true;
	}

}
