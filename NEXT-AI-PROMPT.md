# Continuation Prompt for Next AI Agent

```markdown
You are continuing work on Chelan County CMSAdmin 2.0, a ColdFusion (CFWheels 4.1.2) administrative application running on IIS 10.0 and Lucee CFML engine.
The database is Microsoft SQL Server (Datasource: `ChelanCountyWebsite`). Direct SQL queries use `queryExecute()`.

## 📌 Context & Current Status
We recently completed and hardened the **Pages > How Do I?** Public Directory Manager (`/pages/how-do-i`), modeled after `https://www.co.chelan.wa.us/howdoi`:
- Database tables `dbo.how_do_i_categories` and `dbo.how_do_i_items` (`config/sql/schema-how-do-i.sql`, auto-bootstrapped and seeded in `Pages.cfc:ensureHowDoITables()`).
- Full SQL Server CRUD actions in `app/controllers/Pages.cfc` (`howDoI`, `saveHowDoIItem`, `deleteHowDoIItem`, `saveHowDoICategory`, `deleteHowDoICategory`).
- Interactive manager & 4-column Public Directory Preview in `app/views/pages/howDoI.cfm` supporting 3 destination types (`page` -> CMS Page, `form` -> Form Builder Form, `url` -> External URL).
- Replaced native browser `alert()` / `confirm()` dialogs with CMSAdmin's custom `window.adminAlert()` and `window.adminConfirm()` modal system (`javascripts/admin.js` + `#adminPromptBackdrop` in `app/views/layout.cfm`).

Reference documentation:
- `STATUS.md`: Global status and module matrix
- `CHECKPOINT.md`: Latest checkpoint details and verification checklist
- `PROMPT.md`: Complete prompt history and architectural rules
- `config/sql/schema-how-do-i.sql`: How Do I? SQL Server DDL & seed data

---

## 🎯 Potential Next Tasks

1. **Public Website / Mega-Menu Integration for "How Do I?"**:
   - Expose a JSON API endpoint or public view helper for the public Chelan County site and global header mega-menu (`show_in_mega_menu = 1`) to consume active categories and published items.
2. **Quick Sort / Reordering in "How Do I?" Manager**:
   - Add up/down or drag-and-drop sort order controls inside each category card in `app/views/pages/howDoI.cfm`.
3. **PIO Articles & Posts / Press Release Studio**:
   - Scaffold the dedicated Articles & Posts module under the PIO division in the sidebar.
4. **Media Library SQL Server Metadata Sync**:
   - Persist alt-text and ADA audit metadata from `Media.cfc` into SQL Server.

---

## ⚠️ Important Engineering Rules to Follow
1. **Zero external CSS/JS libraries**: Keep vanilla ES6+ & native CSS.
2. **ADA WCAG 2.1/2.2 AA accessibility**: Explicit `<label for="...">`, visible 2px focus rings, contrast >= 4.5:1.
3. **No Native `alert()` / `confirm()`**: Always use `window.adminAlert({ title, message, type })`, `window.adminConfirm({ title, message, type, confirmText, cancelText })`, and `window.showToast(msg, type)`. Keep custom modal backdrops below `z-index: 100000` (e.g., `9990`) so `#adminPromptBackdrop` (`z-index: 100000`) renders above open modals.
4. **CFML JSON & CSRF**:
   - Quote all struct keys in CFML before calling `SerializeJSON()` so keys are not uppercased.
   - Include `"X-Requested-With": "XMLHttpRequest"` and `"X-CSRF-Token"` (from `meta[name="csrf-token"]`) on all `POST` `fetch()` calls (`Controller.cfc` enforces `protectsFromForgery()`).
5. **SQL Server Filtered Indexes**:
   - Prepend `SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;` to `INSERT` and `UPDATE` queries on tables with filtered indexes (`WHERE [deletedat] IS NULL`), and pass `value: ""` alongside `null: true` on nullable integer query params.
```
