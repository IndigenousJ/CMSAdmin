# Chelan County CMS Admin 2.0 - Comprehensive Project Status

**Current Stage:** Form Builder Database Wiring (SQL Server persistence ~70% complete)  
**Last Updated:** 2026-10-05  
**Platform Host:** `http://cmsadmin.chelancounty.gov/`  
**Framework:** CFWheels 4.1.2 (App-side flat structure)  
**Server Environment:** Microsoft-IIS/10.0 + Lucee CFML Engine (Java/JVM)  
**WCAG Compliance:** ADA Title II, Section 508 & WCAG 2.1 / 2.2 Level AA  

---

## 📊 1. Executive Summary

CMSAdmin 2.0 is an enterprise-grade, high-performance Content Management System administration suite architected for Chelan County public services. The system replaces bloated legacy dependencies with zero-dependency modern native web standards, full ADA WCAG 2.1/2.2 AA accessibility, multi-tier automated anti-spam protections, departmental organization (featuring dedicated HRM and PIO divisions), an interactive visual online form builder, and a comprehensive pages and content management system.

---

## 🗺️ 2. Core Modules & Implementation Status

| Module | Route / Endpoint | Status | Description |
|---|---|---|---|
| **Admin Shell & Layout** | `/` (Dashboard) | ✅ Complete | Chelan County official logo (`logo.png`), responsive sidebar, workspace selector, breadcrumbs, notifications. "New Content" quick create button removed from header. "Public Records Requests" link removed from PIO sidebar menu. |
| **Workspace Selector** | Global Header | ✅ Complete | Department/site switcher (`Global`, `HRM`, `PIO`, `Admin`, `Community Development`) with localStorage persistence and event broadcasting. |
| **Form Builder Studio** | `/form-builder`, `/forms/builder` | ✅ Complete | 17+ field palette, drag/click-to-add, live property inspector, sticky scroll panels, mobile column auto-stacking, device viewport simulator. Starts with a fresh, clean canvas centered to occupy the full container workspace on new form creation or studio entry, with explicit template loading (`?template=...`) and draft resumption (`?resume=1`). |
| **Form Starter Templates** | `/forms/builder?template=...`, `/forms/preview?template=...` | ✅ Complete | Official municipal templates: "Report a Problem" (Public Works / road hazards, potholes, drainage, park maintenance), "Report Infestations & Pests" (Natural Resources / noxious weeds, agricultural pests, tree borers), HRM Candidate Intake, PIO Press Inquiry, Building Permit, and Satisfaction Survey. |
| **Form Builder DB Save / Load** | `POST /forms/save`, `/forms/builder?id=N` | 🟢 Wired (needs runtime test) | `Forms.cfc:save()` upserts `forms` + `form_fields` (by `field_key`, soft-deletes removed fields), caches `schema_json`, writes `form_audit_logs`. Builder loads DB forms via `window.CMSAdminFormBuilderConfig.form` and saves via `fetch` with `X-CSRF-Token`. |
| **Public Form Intake** | `/forms/preview?slug=…` | 🟡 Partial | Server side loads published forms by `slug`/`key`/`id` into `variables.fbPublicFormJson`, but `preview.cfm` **does not consume it yet** (still reads templates / localStorage) and does not send `_form_key` / `_payload` on submit. |
| **Form Management Directory** | `/forms`, `/forms/index` | 🟡 Partial | Rows, KPI cards, status pills and department tabs now render from SQL Server (`formsList`, `formMetrics`, `deptTabs`); soft delete wired (`POST /forms/delete`). Submissions modal + CSV button still show mock data; dead mock rows remain inside `<cfif false>`. |
| **Form Submission Endpoint** | `/forms/submit` (POST/GET) | 🟢 Wired (needs runtime test) | With `_form_key`: per-form honeypot + speed trap, required-field validation, file uploads to `files/_form-uploads/` (web.config deny), inserts `form_submissions` + `form_submission_values`, increments counter, audits, optional email. Without key: legacy validate-only response (`persisted:false`). |
| **Submissions JSON / CSV Export** | `/forms/submissions?id=N`, `/forms/exportCsv?id=N` | 🟡 Backend only | Actions exist in `Forms.cfc` (reachable via wildcard route); no explicit named routes and no UI consumer yet. |
| **Embed & Export Engine** | Form Builder Modal | ✅ Complete | Responsive iFrame embed generator, syntax-highlighted code card, standalone WCAG AA HTML download, JSON schema export. |
| **All Pages Directory & Modal** | `/pages`, `/pages/index` | ✅ Complete | Filterable listing, system-page protection, and accessible "Add Page" modal with real-time slugify and 2 iconized layout wireframe cards (`Full Width` and `Right Sidebar`). |
| **Add / Edit Page Editor** | `/pages/edit`, `/pages/edit?id=N` | ✅ Complete | Dynamic parameter intake (`title`, `slug`, `layout`), initialization notification banner, rich formatting toolbar, SEO meta fields, Page Assignment listbox (`Top Level - Called from URL` / `Assign to Main Menu Item`), conditional menu item picker, template selector, main menu toggle. |
| **Folder Explorer in Page Attributes** | `/pages/edit` (Page Attributes) | ✅ Complete | Integrated into Page Attributes on Add/Edit Page. "Add Folder Explorer Item" modal prompts for Title, Server Absolute Path, Web URL Relative Path, and Layout selection (`Full Width` vs `3/9 Grid Layout`) with iconized wireframe cards. Main menu entry removed. |
| **Workspace Root Files & Media Library** | `/files/` (Root Filesystem) | ✅ Complete | Dedicated root `files/` folders provisioned for each workspace/site (`assessors`, `auditor`, `hrm`, `pio`, `community-development`, `public-works`, `admin`, `commissioners`, `sheriff`, `treasurer`, `clerk`, `chelancounty.gov`, `parks.chelancounty.gov`, `gis.chelancounty.gov`, `shared`). `files/assessors` structured with `media` and `documents` subdirectories to serve as the shared folder for media library assets and documents. Assessor and Auditor integrated into the Workspace dropdown in `layout.cfm`. |
| **Media Library & Asset Browser** | `/media`, `/media/upload`, `/media/picker` | ✅ Complete | Full government-grade media asset management studio: dual Grid & List views, real-time filesystem scanning (`files/`), strict workspace folder isolation (active workspace exclusively scans its assigned on-disk directory `files/[workspace]`), seamless integration with top header Workspace selector (redundant in-filter dropdown eliminated), direct sidebar navigation link with automatic workspace query param synchronization, cookie and event auto-sync, workspace-isolated KPI stat cards, multi-facet filtering (subfolder, type, ADA compliance, sorting), live search, asset inspector drawer with metadata editor, drag-and-drop upload studio, and modal Media Picker integration for the Page Editor. |
| **PIO Articles & Posts** | `/app/views/layout.cfm` | ✅ Complete | Articles & Posts menu moved exclusively under PIO (Public Information Office) in the sidebar and Quick Create menu. |
| **Users & Roles Directory** | `/users`, `/users/index` | ✅ Complete | Government staff directory with 4 user groups (`Admin`, `PIO`, `HR`, `Author`), live multi-facet filtering, search, 2FA status, and accessible Role Permissions Inspector modal. |
| **Roles & Permissions Studio** | `/users/roles` | ✅ Complete | Dedicated RBAC permissions studio with 4 usergroup overview cards, full functional capability matrix, and dynamic persona switcher. |
| **Workspaces Management Studio** | `/workspaces`, `/workspaces/index` | ✅ Complete | Dedicated Administrator workspace management center: 16 municipal workspaces, 4 KPI cards, filter tabs (Departments vs Sites), filesystem verification, staff counts, and direct context switching. |
| **Add / Edit User Management** | `/users/new`, `/users/edit` | ✅ Complete | Fast-action add/edit staff forms with interactive 4-role selection radio cards, department workspace scoping, and live permission summaries. 6x6 col (50%/50%) responsive grid layout: Row 1 features Profile Info + User Group & Role; Row 2 features Scoped Department Workspaces (12-col); Row 3 features Primary Home Department + Credentials & Security in one row. |
| **Dynamic Role Simulator** | `/users/simulate?role=[role]` | ✅ Complete | Real-time interface simulator allowing administrators to test and preview the exact CMS interface for Admin, PIO, HR, and Author roles. |
| **Delete Prevention Policy** | Pages & Core Records | ✅ Complete | Permanent record protection: delete actions removed from Pages screens. Inactive/Hidden status used for decommissioning. |
| **Database Schema Specs** | `Form-Builder.md`, SQL scripts | ✅ Complete | MSSQL, MySQL, and PostgreSQL DDL definitions for forms, departments, fields, submissions, values, and audit logs. |

---

## ♿ 3. ADA Title II & WCAG 2.1 / 2.2 Level AA Compliance Hardening

Every user-facing screen, public intake form, exported HTML document, and admin studio view adheres to strict WCAG 2.1/2.2 AA standards:

1. **Bypass Blocks (SC 2.4.1 - Level A)**:
   - Permanent, high-contrast "Skip to main content" links (`.skip-link`) placed as the first interactive element inside `<body>` across `layout.cfm`, `preview.cfm`, and standalone form exports. Target: `<main id="mainContent" tabindex="-1">`.
2. **Color Contrast (SC 1.4.3 & 1.4.11 - Level AA)**:
   - Normal text contrast $\ge 4.5:1$ on all backgrounds (`--admin-text-main: #0f172a` = 16.5:1, `--admin-text-muted: #475569` = 7.48:1 on white and 6.6:1 on `#f4f6fa`).
   - Accent colors calibrated: Success (`#15803d` = 4.72:1), Warning (`#b45309` = 4.82:1), Danger (`#b91c1c` = 5.92:1), Info (`#0284c7` = 4.58:1), Purple (`#7e22ce` = 7.21:1).
   - Non-text UI control borders: `--admin-border-input: #64748b` ensuring $\ge 3:1$ contrast against adjacent white backgrounds.
3. **Focus Visible (SC 2.4.7 - Level AA)**:
   - Universal 2px high-contrast solid focus ring (`outline: 2px solid var(--admin-primary) !important; outline-offset: 2px !important;`) applied globally to buttons, inputs, links, tabs, switches, and radio/checkbox controls.
4. **Information & Relationships (SC 1.3.1 - Level A)**:
   - Every input, select, textarea, and file upload has an explicit `<label for="...">`.
   - Multi-field Address blocks enclosed in `<fieldset class="fb-fieldset fb-address-group" role="group">` with `<legend>` and individual visually hidden `<label class="sr-only">` tags for Street, Line 2, City, State, and ZIP.
   - Choice groups (Radio, Checkbox) enclosed in semantic `<fieldset>` with accessible `<legend>`.
   - Subtexts linked via `aria-describedby`.
   - Asterisks accompanied by `<span class="sr-only"> (required)</span>` and `aria-required="true"`.
5. **Input Purpose Identification (SC 1.3.5 - Level AA)**:
   - Proper HTML5 `autocomplete` attributes populated (`name`, `email`, `tel`, `street-address`, `address-line2`, `address-level2`, `address-level1`, `postal-code`).
6. **Keyboard Navigation & Operability (SC 2.1.1 & 2.1.2 - Level A)**:
   - Palette items and template cards implemented as `<button type="button">` for native keyboard navigation and `Enter`/`Space` activation.
   - Interactive star ratings feature roving `tabindex` and full arrow key (`ArrowLeft`, `ArrowRight`, `ArrowUp`, `ArrowDown`), `Home`, and `End` support.
   - Modal dialogs support `Escape` key dismissal and trapping protection.
7. **Screen Reader Utility & Live Regions (SC 4.1.2 & 4.1.3 - Level AA)**:
   - Global `.sr-only` class defined in `admin-theme.css` ensuring hidden helper text is never visually leaked on any screen.
   - Live regions (`role="alert"` and `role="status"` with `aria-live="polite"`) for real-time validation and autosave status announcements.

---

## 🛡️ 4. Anti-Spam & Submission Security Architecture

1. **Invisible Honeypot Bot Trap**:
   - Inaudible and invisible field (`_chelan_gov_verify`, `aria-hidden="true"`, `tabindex="-1"`, styled off-screen). Bots populate all encountered inputs; human submissions leave it blank. Populated values trigger immediate denial (`SPAM_HONEYPOT_TRIGGERED`).
2. **Form Load Speed-Trap Token**:
   - Millisecond timestamp token (`_cf_form_load_time`) generated at render. Submissions received under 3 seconds (configurable) are held with an accessible warning alert (`SUBMISSION_TOO_FAST`).
3. **Double-Click & Cooldown Prevention**:
   - Submit buttons trigger `.btn-submitting` with spinner, disabling pointer events during inflight requests.
4. **Server Validation**:
   - `Forms.cfc:submit()` verifies honeypots and request validity, returning structured JSON response envelopes.

---

## 👥 5. Role-Based Access Control (RBAC) & User Management Architecture

The platform enforces a robust 4-tier security model designed specifically for Chelan County municipal administration:

### 1. Defined User Groups & Scopes
1. **Administrator (`admin`)**:
   - **Scope:** Full, unrestricted county-wide administrative access.
   - **Modules:** Content Management Group, HRM Group, PIO Group, Administration, Navigation Menus, Global Settings, User Provisioning, and Audit Logs.
2. **PIO (`pio` - Public Information Officer)**:
   - **Scope:** Public communications, press relations, urgent notifications, and county news.
   - **Modules:** **Content Management Group + PIO Group** (Articles & Posts, Press Releases, Media Alerts, Public Records Requests, Emergency Alerts).
   - **Restrictions:** Restricted from HRM confidential records and system administration.
3. **HR (`hr` - Human Resources)**:
   - **Scope:** Personnel recruitment, employee onboarding, benefits, and policy archives.
   - **Modules:** **Content Management Group + HRM Group** (Job Postings & Careers, Employee Onboarding, Personnel Policies, HRM Applications & Inquiries).
   - **Restrictions:** Restricted from PIO communications and system administration.
4. **Author (`author`)**:
   - **Scope:** General web content authoring and website updates.
   - **Modules:** **Content Management Group only** (Pages Directory & Editor, Media Library & Asset Browser, Form Builder Studio & Forms, Citizen Feedback & Inquiries).
   - **Restrictions:** Restricted from HRM, PIO, and Administration.

### 2. Functional Capability Matrix
| Operational Module / Feature | Author | HR | PIO | Administrator |
|---|:---:|:---:|:---:|:---:|
| **All Pages Directory & Page Editor** | ✅ Full Access | ✅ Full Access | ✅ Full Access | ✅ Full Access |
| **Media Library & Asset Browser** | ✅ Full Access | ✅ Full Access | ✅ Full Access | ✅ Full Access |
| **Form Builder Studio & Online Forms** | ✅ Full Access | ✅ Full Access | ✅ Full Access | ✅ Full Access |
| **Citizen Feedback & Inquiries** | 🔶 Assigned Dept | ✅ Full Access | ✅ Full Access | ✅ Full Access |
| **HRM Forms & Job Applications** | ⛔ No Access | ✅ Full Access | ⛔ No Access | ✅ Full Access |
| **Job Postings & Careers Studio** | ⛔ No Access | ✅ Full Access | ⛔ No Access | ✅ Full Access |
| **Employee Onboarding Workflows** | ⛔ No Access | ✅ Full Access | ⛔ No Access | ✅ Full Access |
| **Personnel Policy Library** | ⛔ No Access | ✅ Full Access | ⛔ No Access | ✅ Full Access |
| **Articles & Posts (PIO News)** | ⛔ No Access | ⛔ No Access | ✅ Full Access | ✅ Full Access |
| **Press Releases & Media Alerts** | ⛔ No Access | ⛔ No Access | ✅ Full Access | ✅ Full Access |
| **Public Records Requests (PRR)** | ⛔ No Access | ⛔ No Access | ✅ Full Access | ✅ Full Access |
| **Emergency Alerts & Notifications** | ⛔ No Access | ⛔ No Access | ✅ Full Access | ✅ Full Access |
| **Users & Roles Management** | ⛔ No Access | ⛔ No Access | ⛔ No Access | ✅ Full Access |
| **Navigation Menu Manager** | ⛔ No Access | ⛔ No Access | ⛔ No Access | ✅ Full Access |
| **System & Global Settings** | ⛔ No Access | ⛔ No Access | ⛔ No Access | ✅ Full Access |

### 3. Dynamic Persona Simulation
- **Route:** `/users/simulate?role=[admin|pio|hr|author]`
- Administrators can instantly test and verify the exact visual and functional experience of any staff role without logging out.
- The simulator dynamically adjusts the sidebar navigation, quick create menus, permission gates, and displays a high-visibility dismissible notification banner indicating the simulated persona.

### 4. Multi-Workspace & Portal Assignment Architecture
- **Capability:** Users can be assigned to multiple departmental workspaces (11 municipal divisions) and public sites/portals (4 web properties), or assigned county-wide `global` scope.
- **Assigned Workspaces Catalog (16 Scopes):**
  - **Global Scope:** `global` (All Workspaces - County-wide Overview across all 11 departments and 4 portals)
  - **11 Municipal Departments:** `assessors`, `auditor`, `hrm`, `pio`, `commdev`, `pw`, `admin`, `commissioners`, `sheriff`, `treasurer`, `clerk`
  - **4 Public Sites & Portals:** `site-main` (`chelancounty.gov`), `site-parks` (`parks.chelancounty.gov`), `site-gis` (`gis.chelancounty.gov`), `site-expo` (`expo.chelancounty.gov`)
- **Multi-Select Matrix UI:**
  - Dedicated "Assigned Workspaces & Sites" card on `users/new.cfm` and `users/edit.cfm` with master global toggle, quick buttons (`All Departments`, `All Sites`, `Clear`), live selection count badge, and categorized 2-column cards.
  - Interactive multi-workspace matrix integrated into the fast-action "Add New User" modal on `users/index.cfm`.
  - Accessible "Role Permissions Inspector" modal displays the staff member's active authorized workspaces and portals alongside their module entitlements.
- **Directory Table & Filtering:**
  - Directory table features an "Assigned Workspaces / Sites" column rendering responsive badge chips for each assigned workspace (`badge-info`, `badge-success`, `badge-purple`, etc.) with automated `+N more` popover tooltips if more than 3 workspaces are assigned.
  - Search filter bar includes a workspace selector (`dept`) with grouped `<optgroup>` options for Departments and Public Sites, matching against both specific workspace codes and global accounts.
- **Relational Database Design (`schema-users-roles.sql`):**
  - Table `cms_users` includes `assigned_workspaces NVARCHAR(MAX) NULL` JSON column for fast retrieval.
  - Relational junction table `cms_user_workspaces (id, user_id, workspace_code, is_primary, createdat)` with foreign key cascading delete, unique constraint on `(user_id, workspace_code)`, and index on `workspace_code` for strict relational integrity.

---

## 📁 6. Directory & File Reference

```
c:\inetpub\CMSAdmin2.0\
├── app/
│   ├── controllers/
│   │   ├── Controller.cfc          # Base CFWheels controller
│   │   ├── Forms.cfc               # Form builder, listing, preview & submit actions
│   │   ├── Pages.cfc               # All Pages listing and Add/Edit Page actions
│   │   ├── Media.cfc               # Media Library directory, scanner, upload & metadata API
│   │   ├── Users.cfc               # Users & Roles directory, matrix, simulation & CRUD actions
│   │   ├── Main.cfc                # CMS Admin dashboard controller
│   │   └── Up.cfc                  # Proxy health check / warmup probe
│   ├── models/
│   │   ├── Role.cfc                # CFWheels Role model mapping to cms_roles
│   │   └── User.cfc                # CFWheels User model mapping to cms_users
│   └── views/
│       ├── layout.cfm              # Master admin template, sidebar, role simulator banner, header
│       ├── helpers.cfm             # Global view helpers (svgIcon, badges)
│       ├── forms/
│       │   ├── builder.cfm         # Interactive 3-column Form Builder Studio
│       │   ├── index.cfm           # Forms management directory & template gallery
│       │   └── preview.cfm         # Standalone accessible public form intake
│       ├── pages/
│       │   ├── index.cfm           # All Pages listing with multi-facet filters & Add Page modal
│       │   ├── edit.cfm            # Add / Edit Page editor with formatting toolbar
│       │   └── folderExplorer.cfm  # Add Folder Explorer form (Title, Paths, Grid layouts)
│       ├── media/
│       │   ├── index.cfm           # Media Library directory (Grid & List, WCAG audit, Inspector)
│       │   ├── upload.cfm          # Dedicated Drag-and-Drop file upload studio
│       │   └── picker.cfm          # Standalone embeddable Media Picker dialog for editors
│       ├── users/
│       │   ├── index.cfm           # Users Directory, KPI stat cards, fast-action modal, inspector
│       │   ├── roles.cfm           # Roles & Permissions studio, matrix, persona switcher
│       │   ├── new.cfm             # Add New Staff Account with interactive role radio cards
│       │   └── edit.cfm            # Edit Staff Member, role tier assignment & security flags
│       └── main/
│           └── index.cfm           # Dashboard KPI stats, recent content, quick draft
├── config/
│   ├── routes.cfm                  # RESTful route mappings
│   ├── environment.cfm             # Dynamic environment detector (dev vs prod)
│   ├── settings.cfm                # App settings, reload password configuration
│   └── sql/
│       ├── schema-form-builder.sql # Form Builder relational DDL definitions
│       └── schema-users-roles.sql  # Users & Roles schema DDL & seed dataset for SQL Server
├── files/                          # Root filesystem storage for workspaces & sites
│   ├── assessors/                  # Assessor shared folder for media library & documents
│   │   ├── media/                  # Shared photos, parcel maps, logos, badges
│   │   └── documents/              # Public records, assessment schedules, forms
│   ├── auditor/                    # Auditor elections, recording & licensing repository
│   ├── hrm/                        # Human Resources recruitment, policies & benefits
│   ├── pio/                        # Public Information Office press kits & media alerts
│   ├── community-development/      # Community Development permits, planning & zoning
│   ├── public-works/               # Public Works roads, utilities & project documents
│   ├── admin/                      # County Administration & commissioner agendas
│   ├── shared/                     # County-wide global shared media library
│   └── [site-portals]/             # chelancounty.gov, parks.chelancounty.gov, etc.
├── javascripts/
│   ├── admin.js                    # Admin shell, workspace selector, mobile drawer
│   └── form-builder.js             # Canvas engine, property binding, preview, export
├── stylesheets/
│   ├── admin-theme.css             # Core design system tokens, WCAG AA focus, utilities
│   └── form-builder.css            # Studio grid, sticky scrolling panels, device canvas
├── Form-Builder.md                 # Form Builder technical architecture & database specs
├── PROMPT.md                       # Comprehensive prompt history & continuation guidelines
└── STATUS.md                       # Master project status & compliance documentation
```

---

## ⏳ 7. Open Items & Next Milestones

1. **Finish Form Builder DB wiring (highest priority)** — see [NEXT-AI-PROMPT.md](NEXT-AI-PROMPT.md) for the full task list:
   - `preview.cfm`: consume `fbPublicFormJson`, show "Form Unavailable" when a requested form is missing, submit `_form_key` + `_payload` JSON + files, remove the fake-success `catch` fallback for DB forms, honor `redirectUrl`.
   - `form-builder.js`: share/embed link should use `?slug=` (currently `?id=form_N`), department dropdown from `CMSAdminFormBuilderConfig.departments`, add Draft/Published/Archived status select, normalize loaded field types (`width` → string).
   - `forms/index.cfm`: real submissions modal (`/forms/submissions?id=N`) and CSV export (`/forms/exportCsv?id=N`); delete the `<cfif false>` mock block; fix grid view to use row `data-*` URLs.
   - Create `app/lib/formNotificationMail.cfm` (tag-based `<cfmail>` reading `request.fbMail`).
   - Add explicit named routes for `submissions` and `exportCsv`.
   - Runtime-verify end to end after `?reload=true&password=chelancms`.
2. **Policy decision:** `POST /forms/delete` soft-deletes forms, which conflicts with the documented Delete Prevention Policy (Pages). Confirm with stakeholders.
3. **Remaining persistence:** Connect `Pages.cfc` and `Media.cfc` metadata to SQL Server.
4. **PIO Press Release & News Manager**:
   - Scaffold the dedicated Articles & Posts interface stationed under the PIO division.
