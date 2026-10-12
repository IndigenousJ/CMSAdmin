-- =============================================================================
-- Chelan County CMS Admin 2.0 - Online Form Builder Database Schema
-- Dialect: PostgreSQL (12+ / 14 / 15 / 16)
-- Features: JSONB fields, TIMESTAMPTZ, Generated UUIDs, Normalized Relations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Table: form_departments
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS form_departments (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    alert_email VARCHAR(255) NOT NULL,
    color_hex VARCHAR(20) NOT NULL DEFAULT '#0073aa',
    badge_class VARCHAR(50) NOT NULL DEFAULT 'badge-primary',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    createdat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deletedat TIMESTAMPTZ NULL
);

-- -----------------------------------------------------------------------------
-- 2. Table: forms
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS forms (
    id SERIAL PRIMARY KEY,
    department_id INT NULL REFERENCES form_departments(id) ON DELETE SET NULL,
    siteid VARCHAR(100) NULL,
    form_key VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(200) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'published',
    theme_color VARCHAR(20) NOT NULL DEFAULT '#0073aa',
    submit_text VARCHAR(100) NOT NULL DEFAULT 'Submit Form',
    success_message TEXT NULL,
    redirect_url VARCHAR(500) NULL,
    notification_email VARCHAR(255) NULL,
    notification_email_cc VARCHAR(500) NULL,
    email_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Anti-Spam & Submission Delay Controls
    anti_spam_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    honeypot_field_name VARCHAR(100) NOT NULL DEFAULT '_chelan_gov_verify',
    min_delay_seconds INT NOT NULL DEFAULT 3,
    cooldown_seconds INT NOT NULL DEFAULT 3,
    
    -- ADA WCAG Accessibility & Embed Settings
    wcag_compliant BOOLEAN NOT NULL DEFAULT TRUE,
    allow_iframe_embed BOOLEAN NOT NULL DEFAULT TRUE,
    is_standalone_public BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Aggregate Counters & JSON Blueprint Cache
    submissions_count INT NOT NULL DEFAULT 0,
    views_count INT NOT NULL DEFAULT 0,
    schema_json JSONB NULL,
    
    createdat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    publishedat TIMESTAMPTZ NULL,
    deletedat TIMESTAMPTZ NULL
);

CREATE INDEX IF NOT EXISTS ix_forms_department_status ON forms (department_id, status);
CREATE INDEX IF NOT EXISTS ix_forms_siteid ON forms (siteid);

-- -----------------------------------------------------------------------------
-- 3. Table: form_fields
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS form_fields (
    id SERIAL PRIMARY KEY,
    form_id INT NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
    field_key VARCHAR(100) NOT NULL,
    field_type VARCHAR(50) NOT NULL,
    label VARCHAR(255) NOT NULL,
    placeholder VARCHAR(255) NULL,
    default_value TEXT NULL,
    subtext VARCHAR(500) NULL,
    paragraph_content TEXT NULL,
    paragraph_style VARCHAR(50) NOT NULL DEFAULT 'normal',
    options_json JSONB NULL,
    is_required BOOLEAN NOT NULL DEFAULT FALSE,
    column_width VARCHAR(10) NOT NULL DEFAULT '100',
    textarea_rows INT NOT NULL DEFAULT 4,
    sort_order INT NOT NULL DEFAULT 0,
    validation_rules_json JSONB NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    createdat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deletedat TIMESTAMPTZ NULL,
    CONSTRAINT uq_form_fields_key UNIQUE (form_id, field_key)
);

CREATE INDEX IF NOT EXISTS ix_form_fields_sort ON form_fields (form_id, sort_order);

-- -----------------------------------------------------------------------------
-- 4. Table: form_submissions
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS form_submissions (
    id SERIAL PRIMARY KEY,
    form_id INT NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
    reference_id VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(50) NOT NULL DEFAULT 'received',
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Anti-Spam Telemetry
    load_time_epoch_ms BIGINT NULL,
    elapsed_seconds INT NULL,
    honeypot_passed BOOLEAN NOT NULL DEFAULT TRUE,
    speed_trap_passed BOOLEAN NOT NULL DEFAULT TRUE,
    is_flagged_as_spam BOOLEAN NOT NULL DEFAULT FALSE,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    
    -- Review & Routing
    assigned_to_user_id INT NULL,
    reviewed_by VARCHAR(100) NULL,
    reviewed_at TIMESTAMPTZ NULL,
    admin_notes TEXT NULL,
    submission_json JSONB NOT NULL,
    
    createdat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deletedat TIMESTAMPTZ NULL
);

CREATE INDEX IF NOT EXISTS ix_form_submissions_form_date ON form_submissions (form_id, submitted_at DESC);
CREATE INDEX IF NOT EXISTS ix_form_submissions_status ON form_submissions (status);

-- -----------------------------------------------------------------------------
-- 5. Table: form_submission_values
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS form_submission_values (
    id SERIAL PRIMARY KEY,
    submission_id INT NOT NULL REFERENCES form_submissions(id) ON DELETE CASCADE,
    field_id INT NULL REFERENCES form_fields(id) ON DELETE SET NULL,
    field_key VARCHAR(100) NOT NULL,
    field_label VARCHAR(255) NULL,
    field_type VARCHAR(50) NULL,
    field_value TEXT NULL,
    
    -- File attachments metadata
    file_path VARCHAR(500) NULL,
    file_name VARCHAR(255) NULL,
    file_size_bytes BIGINT NULL,
    file_mime_type VARCHAR(100) NULL,
    
    createdat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_form_subval_lookup ON form_submission_values (submission_id, field_key);

-- -----------------------------------------------------------------------------
-- 6. Table: form_audit_logs
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS form_audit_logs (
    id SERIAL PRIMARY KEY,
    form_id INT NULL REFERENCES forms(id) ON DELETE SET NULL,
    submission_id INT NULL,
    action VARCHAR(100) NOT NULL,
    performed_by VARCHAR(100) NOT NULL DEFAULT 'System',
    ip_address VARCHAR(45) NULL,
    details_json JSONB NULL,
    createdat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_form_audit_form ON form_audit_logs (form_id, createdat DESC);

-- -----------------------------------------------------------------------------
-- Navigation Menus
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS navigation_menus (
    id SERIAL PRIMARY KEY,
    siteid VARCHAR(100) NOT NULL,
    menu_key VARCHAR(100) NOT NULL,
    name VARCHAR(150) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    createdat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deletedat TIMESTAMPTZ NULL,
    CONSTRAINT uq_navigation_menus_site_key UNIQUE (siteid, menu_key)
);

CREATE INDEX IF NOT EXISTS ix_navigation_menus_siteid ON navigation_menus (siteid);

CREATE TABLE IF NOT EXISTS navigation_menu_items (
    id SERIAL PRIMARY KEY,
    navigation_menu_id INT NOT NULL REFERENCES navigation_menus(id) ON DELETE NO ACTION,
    parent_item_id INT NULL,
    label VARCHAR(150) NOT NULL,
    destination_type VARCHAR(20) NOT NULL DEFAULT 'page'
        CHECK (destination_type IN ('page', 'url')),
    destination VARCHAR(1000) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    open_in_new_tab BOOLEAN NOT NULL DEFAULT FALSE,
    createdat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedat TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deletedat TIMESTAMPTZ NULL,
    CONSTRAINT fk_navigation_menu_items_parent_menu
        FOREIGN KEY (navigation_menu_id, parent_item_id)
        REFERENCES navigation_menu_items (navigation_menu_id, id) ON DELETE NO ACTION,
    CONSTRAINT chk_navigation_menu_items_not_self_parent
        CHECK (parent_item_id IS NULL OR parent_item_id <> id),
    CONSTRAINT uq_navigation_menu_items_menu_id UNIQUE (navigation_menu_id, id)
);

CREATE INDEX IF NOT EXISTS ix_navigation_menu_items_menu_sort
    ON navigation_menu_items (navigation_menu_id, sort_order);
CREATE INDEX IF NOT EXISTS ix_navigation_menu_items_parent_sort
    ON navigation_menu_items (parent_item_id, sort_order);
CREATE INDEX IF NOT EXISTS ix_navigation_menu_items_menu_parent
    ON navigation_menu_items (navigation_menu_id, parent_item_id);
