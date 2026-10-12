component extends="wheels.migrator.Migration" hint="Creates job_postings and job_applications tables for Chelan County HRM" {

	function up() {
		// 1. Table: job_postings
		t = createTable(name="job_postings");
		t.string(columnNames="job_code", limit=50, allowNull=false);
		t.string(columnNames="title", limit=255, allowNull=false);
		t.string(columnNames="department_code", limit=100, default="hrm", allowNull=false);
		t.string(columnNames="department_name", limit=150, allowNull=true);
		t.string(columnNames="job_type", limit=50, default="Full-Time", allowNull=false);
		t.string(columnNames="salary_range", limit=100, allowNull=true);
		t.string(columnNames="salary_type", limit=50, default="Hourly", allowNull=false);
		t.string(columnNames="flsa_status", limit=50, default="Non-Exempt", allowNull=false);
		t.string(columnNames="bargaining_unit", limit=100, default="Non-Represented", allowNull=true);
		t.string(columnNames="location", limit=255, default="Wenatchee, WA", allowNull=false);
		t.text(columnNames="summary", allowNull=true);
		t.text(columnNames="description", allowNull=true);
		t.text(columnNames="qualifications", allowNull=true);
		t.text(columnNames="benefits", allowNull=true);
		t.datetime(columnNames="open_date", allowNull=true);
		t.datetime(columnNames="close_date", allowNull=true);
		t.boolean(columnNames="is_open_until_filled", default=true, allowNull=false);
		t.string(columnNames="status", limit=50, default="Active", allowNull=false);
		t.string(columnNames="file_attachment", limit=500, allowNull=true);
		t.string(columnNames="file_attachment_name", limit=255, allowNull=true);
		t.integer(columnNames="applications_count", default=0, allowNull=false);
		t.integer(columnNames="views_count", default=0, allowNull=false);
		t.string(columnNames="created_by", limit=100, allowNull=true);
		t.string(columnNames="updated_by", limit=100, allowNull=true);
		t.timestamps();
		t.datetime(columnNames="deletedat", allowNull=true);
		t.create();

		addIndex(table="job_postings", columnNames="job_code", unique=true);
		addIndex(table="job_postings", columnNames="department_code");
		addIndex(table="job_postings", columnNames="status");
		addIndex(table="job_postings", columnNames="close_date");

		// 2. Table: job_applications (Adjusted and mapped to legacy Application schema)
		t = createTable(name="job_applications", id=false);
		t.primaryKey(columnNames="ApplicationID", autoIncrement=true);
		t.integer(columnNames="JobID", allowNull=true);
		t.string(columnNames="Position", limit=255, allowNull=false);
		t.string(columnNames="FirstName", limit=100, allowNull=false);
		t.string(columnNames="MiddleName", limit=100, allowNull=true);
		t.string(columnNames="LastName", limit=100, allowNull=false);
		t.string(columnNames="Email", limit=255, allowNull=false);
		t.string(columnNames="Phone", limit=50, allowNull=false);
		t.string(columnNames="Address1", limit=255, allowNull=false);
		t.string(columnNames="Address2", limit=150, allowNull=true);
		t.string(columnNames="City", limit=100, allowNull=false);
		t.string(columnNames="State", limit=50, default="WA", allowNull=false);
		t.string(columnNames="Zip", limit=20, allowNull=false);

		// Driver's License
		t.boolean(columnNames="hasLicense", default=false, allowNull=false);
		t.string(columnNames="LicenseNo", limit=50, allowNull=true);
		t.string(columnNames="LicenseState", limit=50, allowNull=true);
		t.datetime(columnNames="LicenseExpireDate", allowNull=true);

		// CDL
		t.boolean(columnNames="hasCDL", default=false, allowNull=false);
		t.string(columnNames="CDLNo", limit=50, allowNull=true);
		t.string(columnNames="CDLState", limit=50, allowNull=true);
		t.datetime(columnNames="CDLExpireDate", allowNull=true);
		t.string(columnNames="CDLType", limit=50, allowNull=true);
		t.string(columnNames="CDLRestriction", limit=150, allowNull=true);

		// County Employment
		t.boolean(columnNames="wasEmployed", default=false, allowNull=false);
		t.datetime(columnNames="EmploymentStart", allowNull=true);
		t.datetime(columnNames="EmploymentEnd", allowNull=true);
		t.string(columnNames="EmploymentDepartment", limit=150, allowNull=true);

		// Relatives
		t.boolean(columnNames="hasRelative", default=false, allowNull=false);
		t.string(columnNames="RelativeNames", limit=255, allowNull=true);

		// Legal / Eligibility
		t.boolean(columnNames="under18", default=false, allowNull=false);
		t.boolean(columnNames="hasImmigration", default=true, allowNull=false);

		// Foreign Languages
		t.string(columnNames="ForeignLanguage1", limit=100, allowNull=true);
		t.string(columnNames="Proficiency1", limit=50, allowNull=true);
		t.string(columnNames="ForeignLanguage2", limit=100, allowNull=true);
		t.string(columnNames="Proficiency2", limit=50, allowNull=true);
		t.string(columnNames="ForeignLanguage3", limit=100, allowNull=true);
		t.string(columnNames="Proficiency3", limit=50, allowNull=true);

		// Education
		t.boolean(columnNames="hasGED", default=false, allowNull=false);
		t.string(columnNames="HighestGrade", limit=50, allowNull=true);
		t.string(columnNames="Education1", limit=255, allowNull=true);
		t.string(columnNames="Degree1", limit=150, allowNull=true);
		t.string(columnNames="DateEarned1", limit=50, allowNull=true);
		t.string(columnNames="Education2", limit=255, allowNull=true);
		t.string(columnNames="Degree2", limit=150, allowNull=true);
		t.string(columnNames="DateEarned2", limit=50, allowNull=true);
		t.string(columnNames="Education3", limit=255, allowNull=true);
		t.string(columnNames="Degree3", limit=150, allowNull=true);
		t.string(columnNames="DateEarned3", limit=50, allowNull=true);
		t.string(columnNames="Education4", limit=255, allowNull=true);
		t.string(columnNames="Degree4", limit=150, allowNull=true);
		t.string(columnNames="DateEarned4", limit=50, allowNull=true);

		// Work Experience 1-3
		t.string(columnNames="WorkExperienceEmployer1", limit=255, allowNull=true);
		t.string(columnNames="WorkExperienceEmployerPhone1", limit=50, allowNull=true);
		t.string(columnNames="WorkExperienceStart1", limit=50, allowNull=true);
		t.string(columnNames="WorkExperienceEnd1", limit=50, allowNull=true);
		t.string(columnNames="WorkExperienceReason1", limit=500, allowNull=true);

		t.string(columnNames="WorkExperienceEmployer2", limit=255, allowNull=true);
		t.string(columnNames="WorkExperienceEmployerPhone2", limit=50, allowNull=true);
		t.string(columnNames="WorkExperienceStart2", limit=50, allowNull=true);
		t.string(columnNames="WorkExperienceEnd2", limit=50, allowNull=true);
		t.string(columnNames="WorkExperienceReason2", limit=500, allowNull=true);

		t.string(columnNames="WorkExperienceEmployer3", limit=255, allowNull=true);
		t.string(columnNames="WorkExperienceEmployerPhone3", limit=50, allowNull=true);
		t.string(columnNames="WorkExperienceStart3", limit=50, allowNull=true);
		t.string(columnNames="WorkExperienceEnd3", limit=50, allowNull=true);
		t.string(columnNames="WorkExperienceReason3", limit=500, allowNull=true);

		// References 1-3
		t.string(columnNames="ReferenceName1", limit=150, allowNull=true);
		t.string(columnNames="ReferenceEmail1", limit=255, allowNull=true);
		t.string(columnNames="ReferencePhone1", limit=50, allowNull=true);

		t.string(columnNames="ReferenceName2", limit=150, allowNull=true);
		t.string(columnNames="ReferenceEmail2", limit=255, allowNull=true);
		t.string(columnNames="ReferencePhone2", limit=50, allowNull=true);

		t.string(columnNames="ReferenceName3", limit=150, allowNull=true);
		t.string(columnNames="ReferenceEmail3", limit=255, allowNull=true);
		t.string(columnNames="ReferencePhone3", limit=50, allowNull=true);

		// Legal / Certification
		t.boolean(columnNames="Certification", default=true, allowNull=false);
		t.string(columnNames="Signature", limit=255, allowNull=true);
		t.datetime(columnNames="EntryDate", allowNull=false);

		// Modern Municipal Enhancements & Candidate Management
		t.string(columnNames="ResumePath", limit=500, allowNull=true);
		t.string(columnNames="ResumeFileName", limit=255, allowNull=true);
		t.string(columnNames="CoverLetterPath", limit=500, allowNull=true);
		t.string(columnNames="CoverLetterFileName", limit=255, allowNull=true);
		t.string(columnNames="Status", limit=50, default="New", allowNull=false);
		t.integer(columnNames="Rating", default=0, allowNull=false);
		t.text(columnNames="AdminNotes", allowNull=true);
		t.string(columnNames="ReviewedBy", limit=100, allowNull=true);
		t.datetime(columnNames="ReviewedAt", allowNull=true);
		t.datetime(columnNames="DeletedAt", allowNull=true);

		t.create();

		addIndex(table="job_applications", columnNames="JobID");
		addIndex(table="job_applications", columnNames="Status");
		addIndex(table="job_applications", columnNames="Email");
		addIndex(table="job_applications", columnNames="EntryDate");
	}

	function down() {
		dropTable("job_applications");
		dropTable("job_postings");
	}

}
