component extends="wheels.migrator.Migration" hint="Creates relational database schema for Form Builder, Department Groups (HRM, PIO), ADA WCAG, and Anti-Spam Telemetry" {

	function up() {
		// 1. Table: form_departments
		t = createTable(name="form_departments");
		t.string(columnNames="code", limit=50, allowNull=false);
		t.string(columnNames="name", limit=150, allowNull=false);
		t.text(columnNames="description", allowNull=true);
		t.string(columnNames="alert_email", limit=255, allowNull=false);
		t.string(columnNames="color_hex", limit=20, default="#0073aa");
		t.string(columnNames="badge_class", limit=50, default="badge-primary");
		t.boolean(columnNames="is_active", default=true);
		t.timestamps();
		t.create();
		addIndex(table="form_departments", columnNames="code", unique=true);

		// 2. Table: forms
		t = createTable(name="forms");
		t.references(columnNames="department", allowNull=true);
		t.string(columnNames="form_key", limit=100, allowNull=false);
		t.string(columnNames="slug", limit=200, allowNull=false);
		t.string(columnNames="title", limit=255, allowNull=false);
		t.text(columnNames="description", allowNull=true);
		t.string(columnNames="status", limit=50, default="published");
		t.string(columnNames="theme_color", limit=20, default="#0073aa");
		t.string(columnNames="submit_text", limit=100, default="Submit Form");
		t.text(columnNames="success_message", allowNull=true);
		t.string(columnNames="redirect_url", limit=500, allowNull=true);
		t.string(columnNames="notification_email", limit=255, allowNull=true);
		t.string(columnNames="notification_email_cc", limit=500, allowNull=true);
		t.boolean(columnNames="email_notifications_enabled", default=true);
		t.boolean(columnNames="anti_spam_enabled", default=true);
		t.string(columnNames="honeypot_field_name", limit=100, default="_chelan_gov_verify");
		t.integer(columnNames="min_delay_seconds", default=3);
		t.integer(columnNames="cooldown_seconds", default=3);
		t.boolean(columnNames="wcag_compliant", default=true);
		t.boolean(columnNames="allow_iframe_embed", default=true);
		t.boolean(columnNames="is_standalone_public", default=true);
		t.integer(columnNames="submissions_count", default=0);
		t.integer(columnNames="views_count", default=0);
		t.text(columnNames="schema_json", allowNull=true);
		t.datetime(columnNames="publishedat", allowNull=true);
		t.timestamps();
		t.create();
		addIndex(table="forms", columnNames="form_key", unique=true);
		addIndex(table="forms", columnNames="slug", unique=true);

		// 3. Table: form_fields
		t = createTable(name="form_fields");
		t.references(columnNames="form", allowNull=false);
		t.string(columnNames="field_key", limit=100, allowNull=false);
		t.string(columnNames="field_type", limit=50, allowNull=false);
		t.string(columnNames="label", limit=255, allowNull=false);
		t.string(columnNames="placeholder", limit=255, allowNull=true);
		t.text(columnNames="default_value", allowNull=true);
		t.string(columnNames="subtext", limit=500, allowNull=true);
		t.text(columnNames="paragraph_content", allowNull=true);
		t.string(columnNames="paragraph_style", limit=50, default="normal");
		t.text(columnNames="options_json", allowNull=true);
		t.boolean(columnNames="is_required", default=false);
		t.string(columnNames="column_width", limit=10, default="100");
		t.integer(columnNames="textarea_rows", default=4);
		t.integer(columnNames="sort_order", default=0);
		t.text(columnNames="validation_rules_json", allowNull=true);
		t.boolean(columnNames="is_active", default=true);
		t.timestamps();
		t.create();

		// 4. Table: form_submissions
		t = createTable(name="form_submissions");
		t.references(columnNames="form", allowNull=false);
		t.string(columnNames="reference_id", limit=50, allowNull=false);
		t.string(columnNames="status", limit=50, default="received");
		t.datetime(columnNames="submitted_at", allowNull=false);
		t.biginteger(columnNames="load_time_epoch_ms", allowNull=true);
		t.integer(columnNames="elapsed_seconds", allowNull=true);
		t.boolean(columnNames="honeypot_passed", default=true);
		t.boolean(columnNames="speed_trap_passed", default=true);
		t.boolean(columnNames="is_flagged_as_spam", default=false);
		t.string(columnNames="ip_address", limit=45, allowNull=true);
		t.string(columnNames="user_agent", limit=500, allowNull=true);
		t.integer(columnNames="assigned_to_user_id", allowNull=true);
		t.string(columnNames="reviewed_by", limit=100, allowNull=true);
		t.datetime(columnNames="reviewed_at", allowNull=true);
		t.text(columnNames="admin_notes", allowNull=true);
		t.text(columnNames="submission_json", allowNull=false);
		t.timestamps();
		t.create();
		addIndex(table="form_submissions", columnNames="reference_id", unique=true);

		// 5. Table: form_submission_values
		t = createTable(name="form_submission_values");
		t.references(columnNames="submission", allowNull=false);
		t.references(columnNames="field", allowNull=true);
		t.string(columnNames="field_key", limit=100, allowNull=false);
		t.string(columnNames="field_label", limit=255, allowNull=true);
		t.string(columnNames="field_type", limit=50, allowNull=true);
		t.text(columnNames="field_value", allowNull=true);
		t.string(columnNames="file_path", limit=500, allowNull=true);
		t.string(columnNames="file_name", limit=255, allowNull=true);
		t.biginteger(columnNames="file_size_bytes", allowNull=true);
		t.string(columnNames="file_mime_type", limit=100, allowNull=true);
		t.timestamps();
		t.create();

		// 6. Table: form_audit_logs
		t = createTable(name="form_audit_logs");
		t.references(columnNames="form", allowNull=true);
		t.integer(columnNames="submission_id", allowNull=true);
		t.string(columnNames="action", limit=100, allowNull=false);
		t.string(columnNames="performed_by", limit=100, default="System");
		t.string(columnNames="ip_address", limit=45, allowNull=true);
		t.text(columnNames="details_json", allowNull=true);
		t.timestamps();
		t.create();
	}

	function down() {
		dropTable("form_audit_logs");
		dropTable("form_submission_values");
		dropTable("form_submissions");
		dropTable("form_fields");
		dropTable("forms");
		dropTable("form_departments");
	}

}
