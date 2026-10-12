-- =============================================================================
-- Chelan County CMS Admin 2.0 - Online Form Builder Seed Data
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Seed: form_departments
-- -----------------------------------------------------------------------------
INSERT INTO form_departments (code, name, description, alert_email, color_hex, badge_class, is_active)
VALUES
('HRM', 'Human Resource Management', 'County employment recruitments, job candidate applications, employee onboarding, benefits, and workplace incident tracking.', 'hrm@chelancounty.gov', '#8e44ad', 'badge-purple', 1),
('PIO', 'Public Information Office', 'Media relations, journalist inquiry desk, official county press statements, public records requests (PRR), and community surveys.', 'pio@chelancounty.gov', '#0284c7', 'badge-info', 1),
('ADMIN', 'General Administration', 'County commissioners office, public meeting notices, general feedback, inter-departmental inquiries, and administrative services.', 'contact@chelancounty.gov', '#0073aa', 'badge-primary', 1),
('COMMDEV', 'Community Development', 'Building permits, zoning inquiries, shoreline management, parcel planning reviews, and code compliance intake.', 'permits@chelancounty.gov', '#e67e22', 'badge-warning', 1),
('PW', 'Public Works & Roads', 'County road maintenance, snow removal inquiries, right-of-way permits, flood control, and solid waste services.', 'public.works@chelancounty.gov', '#27ae60', 'badge-success', 1);

-- Forms are intentionally left empty so staff can create them in the builder.
