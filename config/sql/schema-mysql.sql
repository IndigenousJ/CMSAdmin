-- =============================================================================
-- Chelan County CMS Admin 2.0 - Online Form Builder Database Schema
-- Dialect: MySQL 5.7+ / MySQL 8.0 / MariaDB 10.3+
-- Engine: InnoDB, Charset: utf8mb4, Collation: utf8mb4_unicode_ci
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- 1. Table: form_departments
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `form_departments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `code` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(150) NOT NULL,
    `description` TEXT NULL,
    `alert_email` VARCHAR(255) NOT NULL,
    `color_hex` VARCHAR(20) NOT NULL DEFAULT '#0073aa',
    `badge_class` VARCHAR(50) NOT NULL DEFAULT 'badge-primary',
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `createdat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updatedat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deletedat` DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. Table: forms
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `forms` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `department_id` INT NULL,
    `siteid` VARCHAR(100) NULL,
    `form_key` VARCHAR(100) NOT NULL UNIQUE,
    `slug` VARCHAR(200) NOT NULL UNIQUE,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `status` VARCHAR(50) NOT NULL DEFAULT 'published',
    `theme_color` VARCHAR(20) NOT NULL DEFAULT '#0073aa',
    `submit_text` VARCHAR(100) NOT NULL DEFAULT 'Submit Form',
    `success_message` TEXT NULL,
    `redirect_url` VARCHAR(500) NULL,
    `notification_email` VARCHAR(255) NULL,
    `notification_email_cc` VARCHAR(500) NULL,
    `email_notifications_enabled` TINYINT(1) NOT NULL DEFAULT 1,
    
    -- Anti-Spam & Submission Delay Controls
    `anti_spam_enabled` TINYINT(1) NOT NULL DEFAULT 1,
    `honeypot_field_name` VARCHAR(100) NOT NULL DEFAULT '_chelan_gov_verify',
    `min_delay_seconds` INT NOT NULL DEFAULT 3,
    `cooldown_seconds` INT NOT NULL DEFAULT 3,
    
    -- ADA WCAG Accessibility & Embed Settings
    `wcag_compliant` TINYINT(1) NOT NULL DEFAULT 1,
    `allow_iframe_embed` TINYINT(1) NOT NULL DEFAULT 1,
    `is_standalone_public` TINYINT(1) NOT NULL DEFAULT 1,
    
    -- Aggregate Counters & JSON Blueprint Cache
    `submissions_count` INT NOT NULL DEFAULT 0,
    `views_count` INT NOT NULL DEFAULT 0,
    `schema_json` LONGTEXT NULL,
    
    `createdat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updatedat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `publishedat` DATETIME NULL,
    `deletedat` DATETIME NULL,
    KEY `ix_forms_department_status` (`department_id`, `status`),
    KEY `ix_forms_siteid` (`siteid`),
    CONSTRAINT `fk_forms_departments` FOREIGN KEY (`department_id`) 
        REFERENCES `form_departments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. Table: form_fields
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `form_fields` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `form_id` INT NOT NULL,
    `field_key` VARCHAR(100) NOT NULL,
    `field_type` VARCHAR(50) NOT NULL,
    `label` VARCHAR(255) NOT NULL,
    `placeholder` VARCHAR(255) NULL,
    `default_value` TEXT NULL,
    `subtext` VARCHAR(500) NULL,
    `paragraph_content` TEXT NULL,
    `paragraph_style` VARCHAR(50) NOT NULL DEFAULT 'normal',
    `options_json` LONGTEXT NULL,
    `is_required` TINYINT(1) NOT NULL DEFAULT 0,
    `column_width` VARCHAR(10) NOT NULL DEFAULT '100',
    `textarea_rows` INT NOT NULL DEFAULT 4,
    `sort_order` INT NOT NULL DEFAULT 0,
    `validation_rules_json` TEXT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `createdat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updatedat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deletedat` DATETIME NULL,
    UNIQUE KEY `uq_form_fields_key` (`form_id`, `field_key`),
    KEY `ix_form_fields_sort` (`form_id`, `sort_order`),
    CONSTRAINT `fk_form_fields_forms` FOREIGN KEY (`form_id`) 
        REFERENCES `forms` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. Table: form_submissions
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `form_submissions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `form_id` INT NOT NULL,
    `reference_id` VARCHAR(50) NOT NULL UNIQUE,
    `status` VARCHAR(50) NOT NULL DEFAULT 'received',
    `submitted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Anti-Spam Telemetry
    `load_time_epoch_ms` BIGINT NULL,
    `elapsed_seconds` INT NULL,
    `honeypot_passed` TINYINT(1) NOT NULL DEFAULT 1,
    `speed_trap_passed` TINYINT(1) NOT NULL DEFAULT 1,
    `is_flagged_as_spam` TINYINT(1) NOT NULL DEFAULT 0,
    `ip_address` VARCHAR(45) NULL,
    `user_agent` VARCHAR(500) NULL,
    
    -- Review & Routing
    `assigned_to_user_id` INT NULL,
    `reviewed_by` VARCHAR(100) NULL,
    `reviewed_at` DATETIME NULL,
    `admin_notes` TEXT NULL,
    `submission_json` LONGTEXT NOT NULL,
    
    `createdat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updatedat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deletedat` DATETIME NULL,
    KEY `ix_form_submissions_form_date` (`form_id`, `submitted_at`),
    KEY `ix_form_submissions_status` (`status`),
    CONSTRAINT `fk_form_submissions_forms` FOREIGN KEY (`form_id`) 
        REFERENCES `forms` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 5. Table: form_submission_values
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `form_submission_values` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `submission_id` INT NOT NULL,
    `field_id` INT NULL,
    `field_key` VARCHAR(100) NOT NULL,
    `field_label` VARCHAR(255) NULL,
    `field_type` VARCHAR(50) NULL,
    `field_value` LONGTEXT NULL,
    
    -- File attachments metadata
    `file_path` VARCHAR(500) NULL,
    `file_name` VARCHAR(255) NULL,
    `file_size_bytes` BIGINT NULL,
    `file_mime_type` VARCHAR(100) NULL,
    
    `createdat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY `ix_form_subval_lookup` (`submission_id`, `field_key`),
    CONSTRAINT `fk_form_subval_submission` FOREIGN KEY (`submission_id`) 
        REFERENCES `form_submissions` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_form_subval_field` FOREIGN KEY (`field_id`) 
        REFERENCES `form_fields` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 6. Table: form_audit_logs
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `form_audit_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `form_id` INT NULL,
    `submission_id` INT NULL,
    `action` VARCHAR(100) NOT NULL,
    `performed_by` VARCHAR(100) NOT NULL DEFAULT 'System',
    `ip_address` VARCHAR(45) NULL,
    `details_json` TEXT NULL,
    `createdat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY `ix_form_audit_form` (`form_id`, `createdat`),
    CONSTRAINT `fk_form_audit_forms` FOREIGN KEY (`form_id`) 
        REFERENCES `forms` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Navigation Menus
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `navigation_menus` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `siteid` VARCHAR(100) NOT NULL,
    `menu_key` VARCHAR(100) NOT NULL,
    `name` VARCHAR(150) NOT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `createdat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updatedat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deletedat` DATETIME NULL,
    UNIQUE KEY `uq_navigation_menus_site_key` (`siteid`, `menu_key`),
    KEY `ix_navigation_menus_siteid` (`siteid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `navigation_menu_items` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `navigation_menu_id` INT NOT NULL,
    `parent_item_id` INT NULL,
    `label` VARCHAR(150) NOT NULL,
    `destination_type` VARCHAR(20) NOT NULL DEFAULT 'page',
    `destination` VARCHAR(1000) NOT NULL,
    `sort_order` INT NOT NULL DEFAULT 0,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `open_in_new_tab` TINYINT(1) NOT NULL DEFAULT 0,
    `createdat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updatedat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deletedat` DATETIME NULL,
    CONSTRAINT `fk_navigation_menu_items_menu` FOREIGN KEY (`navigation_menu_id`)
        REFERENCES `navigation_menus` (`id`) ON DELETE NO ACTION,
    CONSTRAINT `fk_navigation_menu_items_parent_menu`
        FOREIGN KEY (`navigation_menu_id`, `parent_item_id`)
        REFERENCES `navigation_menu_items` (`navigation_menu_id`, `id`) ON DELETE NO ACTION,
    CONSTRAINT `chk_navigation_menu_items_destination_type` CHECK (`destination_type` IN ('page', 'url')),
    CONSTRAINT `chk_navigation_menu_items_not_self_parent`
        CHECK (`parent_item_id` IS NULL OR `parent_item_id` <> `id`),
    UNIQUE KEY `uq_navigation_menu_items_menu_id` (`navigation_menu_id`, `id`),
    KEY `ix_navigation_menu_items_menu_sort` (`navigation_menu_id`, `sort_order`),
    KEY `ix_navigation_menu_items_parent_sort` (`parent_item_id`, `sort_order`),
    KEY `ix_navigation_menu_items_menu_parent` (`navigation_menu_id`, `parent_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
