# Checkpoint: Form Builder — SQL Server Wiring (In Progress)

**Timestamp:** 2026-10-05  
**Status:** 🟡 Partially wired. Code is written but has **not been run end to end**.  
**Milestone:** Move the Form Builder off its localStorage mockup and onto the `schema-form-builder.sql` tables  
**Host URL:** `http://cmsadmin.chelancounty.gov/`  
**Datasource:** `ChelanCountyWebsite` (SQL Server; queries use `queryExecute`, not Wheels models)

---

## ✅ Done in this checkpoint

### Backend — [`app/controllers/Forms.cfc`](file:///c:/inetpub/CMSAdmin2.0/app/controllers/Forms.cfc) (~1,230 lines)
| Action | Route | What it does |
|---|---|---|
| `builder()` | `GET /forms/builder?id=N` | Loads form + active fields into `window.CMSAdminFormBuilderConfig` (`form`, `departments`, `saveUrl`, `previewUrl`). Redirects if not found or the user can't access the workspace. |
| `index()` | `GET /forms` | Lists DB forms scoped by the `cmsadmin_workspace` cookie and the user's assigned workspaces. Builds `formsList`, `formMetrics` (counts, submissions, pending, spam blocked, WCAG %) and `deptTabs`. |
| `save()` | `POST /forms/save` (JSON, CSRF header) | Inserts or updates `forms`. Upserts `form_fields` by `field_key` so `field_id` stays stable for old submissions. Soft-deletes fields that were removed. Generates `form_key` + unique `slug`, caches `schema_json`, writes `FORM_CREATED` / `FORM_UPDATED` audit rows. |
| `softDelete()` | `POST /forms/delete` | Sets `forms.deletedat`. Submissions and audit history are kept. *(Added by a later session.)* |
| `preview()` | `GET /forms/preview?slug=\|key=\|id=` | Loads the form (published only, unless a staff session exists), increments `views_count`, strips notification emails, and sets `variables.fbPublicFormJson`. |
| `submit()` | `POST /forms/submit` | With `_form_key`: per-form honeypot + speed trap (logs `SPAM_BLOCKED`), required-field validation (422), file upload allowlist (25 MB) to `files/_form-uploads/<form_key>/<ref>/` (auto-creates a deny-all `web.config`), then inserts `form_submissions` + `form_submission_values`, bumps `submissions_count`, audits, and calls the email include. Without a key it falls back to `legacySubmit()`, which only validates (`persisted:false`). |
| `submissions()` | `GET /forms/submissions?id=N` *(wildcard)* | JSON list of the latest 100 submissions with their values. |
| `exportCsv()` | `GET /forms/exportCsv?id=N` *(wildcard)* | UTF-8 CSV download with formula-injection guarding. |

- `ensureFormDepartments()` seeds ADMIN, HRM, PIO, COMMDEV, PW and NR once per app start (idempotent). It overlaps with [`config/sql/seeds.sql`](file:///c:/inetpub/CMSAdmin2.0/config/sql/seeds.sql), which has no NR row.
- `resolveDepartmentId()` accepts a code, a name, or a legacy builder value (e.g. `"Public Works"` → `PW`).

### Frontend
- [`builder.cfm`](file:///c:/inetpub/CMSAdmin2.0/app/views/forms/builder.cfm#L42) injects `window.CMSAdminFormBuilderConfig`.
- [`form-builder.js`](file:///c:/inetpub/CMSAdmin2.0/javascripts/form-builder.js#L284-L416):
  - `loadForm()` prefers the server form.
  - `syncFormWorkspace()` keeps saved forms pinned to their `siteid`.
  - `saveForm()` is an async `fetch` that updates `?id=` in the URL and shows "Saved to database".
- [`forms/index.cfm`](file:///c:/inetpub/CMSAdmin2.0/app/views/forms/index.cfm#L266-L304):
  - DB-driven rows, KPI cards, status pills, department tabs, and a delete button.
  - The old mock rows are still in the file, wrapped in `<cfif false>`.

---

## ❌ Not done yet (next session)
1. **`preview.cfm` does not use `fbPublicFormJson` yet.** So `/forms/preview?slug=x` still renders the template or localStorage draft, and submissions are sent without `_form_key`. As a result, **no public submission reaches the DB today.**
2. **`app/lib/formNotificationMail.cfm` doesn't exist.** The include fails inside a try/catch, so no email is sent.
3. **Builder gaps:**
   - The share link uses `?id=form_N` (should be `?slug=`).
   - The department `<select>` is still hard-coded.
   - There is no status select, so every save publishes the form.
4. **Index gaps:**
   - The submissions modal and the CSV button are still mock.
   - The `<cfif false>` mock block still needs deleting.
   - The grid view uses the old hard-coded department mapping.
5. **Routes:** there are no named routes for `submissions` / `exportCsv` (they only work through the wildcard).
6. **Not tested:** nothing has been verified against the live DB (no reload or curl tests run).

---

## 🔍 How to verify (once finished)
1. `http://cmsadmin.chelancounty.gov/forms?reload=true&password=chelancms`
2. Builder → create a form → **Save**. Check that a `forms` row and `form_fields` rows exist, and that the URL gains `?id=N`.
3. Reload `/forms/builder?id=N`. All fields should come back.
4. Open `/forms/preview?slug=<slug>`, wait more than 3 seconds, and submit. Check for a `form_submissions` row plus value rows, and that `forms.submissions_count` went up.
5. Fill in the honeypot field. Expect HTTP 400 and a `SPAM_BLOCKED` audit row.
6. `/forms/submissions?id=N` should return JSON. `/forms/exportCsv?id=N` should download a CSV.

---

## Previous checkpoint
`CMSAdmin-wheels4.1-Admin Menu-Blank` (2026-10-02): clean Wheels 4.1.2 admin shell, a custom zero-dependency theme, the SVG icon helper, and IIS flat-root URL rewriting. See git history for the full text.
