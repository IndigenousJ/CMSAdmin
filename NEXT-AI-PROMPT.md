# Continuation Prompt for Next AI Agent

```markdown
You are continuing work on Chelan County CMSAdmin 2.0, a ColdFusion (CFWheels 4.1.2) administrative application running on IIS 10.0 and Lucee CFML engine.
The database is Microsoft SQL Server (Datasource: `ChelanCountyWebsite`). Direct SQL queries use `queryExecute()`.

## 📌 Context & Current Status
We just wired up the SQL Server database persistence layer for the **Online Form Builder** (`schema-form-builder.sql`).
The backend persistence endpoints are coded in `app/controllers/Forms.cfc` (`save`, `builder`, `index`, `softDelete`, `submit`, `submissions`, `exportCsv`).
The `forms/builder.cfm` and `javascripts/form-builder.js` now save and update form definitions to the database.
However, several remaining frontend/intake integration items remain to complete 100% full wiring.

Reference documentation:
- `STATUS.md`: Global status and open items
- `CHECKPOINT.md`: Comprehensive details of changes made and pending items
- `Form-Builder.md`: Schema definition and field specifications
- `app/controllers/Forms.cfc`: Form builder backend controller

---

## 🎯 Next Tasks to Implement

### 1. Wire Public Form Intake View (`app/views/forms/preview.cfm`)
- Currently, `preview.cfm` still relies on `TEMPLATE_PRESETS` and `localStorage.getItem("cmsadmin_active_form")`.
- When `/forms/preview?slug=...`, `?key=...`, or `?id=...` is loaded, the controller already sets `variables.fbPublicFormJson` with the sanitized form definition from SQL Server (and tracks `views_count`).
- Update `preview.cfm` script to:
  1. Inspect `variables.fbPublicFormJson` (via inline `<script>const SERVER_FORM = #fbPublicFormJson#;</script>`).
  2. If `SERVER_FORM` is present, use it as `activeForm`.
  3. If a slug/key/id was passed in the URL but `SERVER_FORM` is null/empty (e.g. invalid slug or unpublished form accessed by anonymous user), display an accessible "Form Not Found / Currently Unavailable" message rather than falling back to default/localStorage templates.
  4. Ensure form submission sends `_form_key: activeForm.formKey` (or `_form_id: activeForm.dbId`), `_payload: JSON.stringify(formDataValues)`, plus native file fields.
  5. Remove the mock `setTimeout(() => showSuccess(...))` fallback in `catch` for live DB forms so actual server errors (e.g. 422 validation, honeypot 400) are surfaced correctly.
  6. If `data.redirectUrl` is present in successful JSON response, redirect the user after displaying confirmation.

### 2. Connect Submissions Modal & CSV Export in `app/views/forms/index.cfm`
- Currently, clicking `.btn-view-subs` shows mock hardcoded rows (`SUB-94B82A1C`), and `btnExportCSV` only shows a toast.
- Update `forms/index.cfm` to:
  1. Have `.btn-view-subs` pass `data-form-id` and fetch real submissions from `/forms/submissions?id=${formId}`.
  2. Render live submission records (Reference ID, Respondent, Contact, Elapsed Time, Security Status, Actions).
  3. Wire the `#btnExportCSV` button to trigger `/forms/exportCsv?id=${formId}` download.
  4. Clean up the dead legacy mock table rows wrapped in `<cfif false>...</cfif>`.
  5. In `renderGridView()`, use the row's `data-edit-url`, `data-preview-url`, and `data-public-url` attributes instead of assuming template query params.

### 3. Missing Mailer Include (`app/lib/formNotificationMail.cfm`)
- In `Forms.cfc:sendSubmissionNotification()`, the controller tries to `include "/app/lib/formNotificationMail.cfm"`.
- Create `app/lib/formNotificationMail.cfm` using `<cfmail>` with fallback/guarding (or logging) so notifications do not throw an error when notification emails are enabled.

### 4. Named Route Additions in `config/routes.cfm`
- Add explicit named routes for submissions viewer and export:
  - `.get(name="formSubmissions", pattern="forms/submissions", to="forms##submissions")`
  - `.get(name="formExportCsv", pattern="forms/export-csv", to="forms##exportCsv")`

### 5. Form Builder Studio Fine-tuning (`javascripts/form-builder.js`)
- In `openShareModal()`, update the public share link to use `?slug=${currentForm.slug}` instead of `?id=${currentForm.id}` when available.
- In `populateFormSettings()`, dynamically populate the Department `<select>` using `window.CMSAdminFormBuilderConfig.departments` instead of hardcoded `<option>` elements.
- Add a Form Status selector (`Draft`, `Published`, `Archived`) in Form Settings so authors can change form status.

---

## ⚠️ Important Rules to Follow
- Zero external CSS/JS libraries (keep vanilla ES6+ & native CSS).
- Maintain ADA WCAG 2.1/2.2 AA accessibility standards (labels, focus rings, roving tabindex, contrast).
- To reload application routes in production: `http://cmsadmin.chelancounty.gov/[route]?reload=true&password=chelancms`.
```

