# Checkpoint: Pages > "How Do I?" Directory Manager — SQL Server CRUD & Custom Dialog Hardening

**Timestamp:** 2026-10-14  
**Status:** ✅ Complete & Verified  
**Milestone:** Build the Chelan County **"How Do I?"** Public Directory Manager under **Pages > How Do I**, wire full SQL Server persistence (`how_do_i_categories`, `how_do_i_items`), resolve Edit/Save issues (CFML JSON casing, CSRF headers, SQL Server `ANSI_NULLS`/`QUOTED_IDENTIFIER`), and replace native browser `alert()` / `confirm()` with CMSAdmin's custom dialog system (`window.adminAlert` / `window.adminConfirm`).  
**Host URL:** `http://cmsadmin.chelancounty.gov/`  
**Datasource:** `ChelanCountyWebsite` (SQL Server; queries use `queryExecute`)

---

## ✅ Completed in this Checkpoint

### 1. Database Schema & Seed Data — [`config/sql/schema-how-do-i.sql`](file:///c:/inetpub/CMSAdmin2.0/config/sql/schema-how-do-i.sql)
- **`dbo.how_do_i_categories`**: Stores action-verb categories (`Apply for`, `Contact`, `Find`, `File`, `Get`, `Learn About`, `Pay`, `Register for`, `Report`, `Request`, `Submit`, `View`) modeled after `https://www.co.chelan.wa.us/howdoi`, with `title`, `slug`, `description`, `icon_name`, `sort_order`, `is_active`, and soft-delete (`deletedat`).
- **`dbo.how_do_i_items`**: Stores individual questions/links belonging to a category, supporting three destination types:
  - `page` → links to an internal CMS Page (`page_id` + resolved `pages.slug`)
  - `form` → links to an online Form Builder form (`form_id` + resolved `forms.slug`)
  - `url` → links to an external URL or custom path (`target_url`)
  - Includes `site_id` (workspace scoping), `open_in_new_tab`, `is_published`, `show_in_mega_menu`, `sort_order`, and soft-delete (`deletedat`).
- **Auto-Bootstrap & Seed**: [`Pages.cfc:ensureHowDoITables()`](file:///c:/inetpub/CMSAdmin2.0/app/controllers/Pages.cfc#L1408-L1651) automatically creates both tables and seeds the 12 official Chelan County categories and 75+ canonical "How Do I?" links if the tables are missing or empty.

### 2. Models & Routing
- Created CFWheels models [`app/models/HowDoICategory.cfc`](file:///c:/inetpub/CMSAdmin2.0/app/models/HowDoICategory.cfc) and [`app/models/HowDoIItem.cfc`](file:///c:/inetpub/CMSAdmin2.0/app/models/HowDoIItem.cfc).
- Added sidebar navigation link **How Do I** under **Pages** in [`app/views/layout.cfm`](file:///c:/inetpub/CMSAdmin2.0/app/views/layout.cfm#L121-L128).
- Registered both hyphenated (`pages/how-do-i`, `pages/save-how-do-i-item`, etc.) and camelCase (`pages/howDoI`, `pages/saveHowDoIItem`, etc.) routes in [`config/routes.cfm`](file:///c:/inetpub/CMSAdmin2.0/config/routes.cfm#L45-L64) so `urlFor(controller="pages", action=...)` works immediately even before a route cache reload.

### 3. Backend Controller Actions — [`app/controllers/Pages.cfc`](file:///c:/inetpub/CMSAdmin2.0/app/controllers/Pages.cfc#L1345-L2108)
| Action | Route | What it does |
|---|---|---|
| `howDoI()` | `GET /pages/how-do-i` | Bootstraps tables, loads categories (`loadHowDoICategories`), items (`loadHowDoIItems`), published pages (`loadPickerPages`), and active forms (`loadPickerForms`), and computes KPI stats. |
| `saveHowDoIItem()` | `POST /pages/save-how-do-i-item` | Validates destination (`page` / `form` / `url`), inserts or updates `dbo.how_do_i_items` with `SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;`, and returns quoted lowercase JSON (`"success"`, `"message"`, `"id"`). |
| `deleteHowDoIItem()` | `POST /pages/delete-how-do-i-item` | Soft-deletes (`deletedat = SYSDATETIME()`) an item in `dbo.how_do_i_items`. |
| `saveHowDoICategory()` | `POST /pages/save-how-do-i-category` | Auto-generates slug, inserts or updates `dbo.how_do_i_categories`, and returns JSON. |
| `deleteHowDoICategory()` | `POST /pages/delete-how-do-i-category` | Soft-deletes a category and unpublishes its items. |

### 4. Frontend Studio & Bug Fixes — [`app/views/pages/howDoI.cfm`](file:///c:/inetpub/CMSAdmin2.0/app/views/pages/howDoI.cfm)
- **Dual View Modes**:
  1. **Manage Directory View**: Accordion/card groups by category with search, category filter, destination filter (`Page`, `Form`, `External URL`), quick `+ Add Item` per category, `Edit` / `Delete` actions, and **Manage Categories** modal.
  2. **Public Directory Preview (`co.chelan.wa.us/howdoi` style)**: Live 4-column responsive directory preview mirroring the public Chelan County "How Do I?" layout.
- **Edit Button Fix**:
  - Quoted struct keys in [`Pages.cfc`](file:///c:/inetpub/CMSAdmin2.0/app/controllers/Pages.cfc#L1684-L1819) so `SerializeJSON()` preserves camelCase keys.
  - Added case-insensitive key normalization (`getField`, `normalizeItem`, `normalizeCategory`) and full `data-*` attribute fallbacks directly on `.js-edit-item` buttons and `.hdi-item-row` rows in [`howDoI.cfm`](file:///c:/inetpub/CMSAdmin2.0/app/views/pages/howDoI.cfm#L533-L579).
- **Add / Save Item Fix**:
  - Updated [`hdiPostJson()`](file:///c:/inetpub/CMSAdmin2.0/app/views/pages/howDoI.cfm#L714-L742) to send `X-CSRF-Token` (from `meta[name="csrf-token"]`) and `X-Requested-With: XMLHttpRequest` to satisfy `Controller.cfc:protectsFromForgery()`.
  - Prepended `SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;` to all `INSERT` and `UPDATE` statements on `how_do_i_items` and `how_do_i_categories` (required by SQL Server filtered indexes `WHERE [deletedat] IS NULL`).
  - Added `value: ""` alongside `null: true` on nullable integer parameters (`pageId`, `formId`).
- **Custom Admin Dialogs (`window.adminAlert` / `window.adminConfirm`)**:
  - Replaced all native browser `alert()` and `confirm()` calls in [`howDoI.cfm`](file:///c:/inetpub/CMSAdmin2.0/app/views/pages/howDoI.cfm#L684-L712) and [`pages/index.cfm`](file:///c:/inetpub/CMSAdmin2.0/app/views/pages/index.cfm#L647-L658) with CMSAdmin's custom modal dialogs (`window.adminAlert`, `window.adminConfirm`) and `window.showToast`.
  - Lowered `.hdi-modal-backdrop` `z-index` to `9990` so `#adminPromptBackdrop` (`z-index: 100000` in [`layout.cfm`](file:///c:/inetpub/CMSAdmin2.0/app/views/layout.cfm#L533)) always layers above open modals.

---

## 🔍 Verification Checklist
1. Open `http://cmsadmin.chelancounty.gov/pages/how-do-i` (or click **Pages > How Do I** in the sidebar).
2. Click **Add "How Do I?" Link**, select a Category (e.g., `Apply for`), choose **Internal Page**, **Online Form**, or **External URL**, and click **Save Item** — item saves to SQL Server and reloads with a success toast.
3. Click **Edit** on any item row — modal opens populated with the item's category, question, destination type, target page/form/URL, sort order, and checkboxes.
4. Click **Delete** on any item or category — CMSAdmin's custom confirmation modal (`window.adminConfirm`) appears above the UI; confirming soft-deletes the record.
5. Toggle **Public Preview** in the header to verify the 4-column Chelan County "How Do I?" directory layout.
