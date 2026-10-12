# Workspace Guide for Beginners

This guide shows you how to work with the Workspace module in CMS Admin. You do
not need to know code.

**Quick-start:** Open the workspace directory, review the available workspaces,
create a new one only when needed, and confirm the directory path and project
settings before saving.

This module manages the county's site and department scope. Each workspace
represents a department, public portal, or shared county-wide area. The module is
used to organize access, folder structure, site routing, and content ownership.

For the technical background, see the [Workspace Architecture](./Workspace.md).

## The screen in one minute

| Area | What it does |
| --- | --- |
| **Workspace Directory** (top) | Lists all available workspaces and portal entries. |
| **Filter and search** | Narrow the list by type or text. |
| **Workspace cards** | Show each workspace's name, type, folder, and contact information. |
| **Action buttons** | Create a new workspace or open an existing one for editing. |

## What a workspace is

A workspace is a CMS container used to scope content to a specific place, team,
or public-facing site.

Common types include:

- **Global** — county-wide overview or shared administrative scope
- **Department** — a county department or divisional office
- **Site / Portal** — a public-facing website or microsite

Each workspace usually includes:

- a name and internal code
- a virtual directory or routing alias
- a filesystem folder path
- a department or public-portal category
- contact details and a redirect URL when applicable

## Open the Workspace module

1. Sign in with an admin account.
2. Open the **Administration** area in the left navigation.
3. Choose **Workspaces & Portals**.
4. Review the list of existing workspaces.

If you do not have an admin role, the module is locked and you are redirected
back to the main dashboard.

## Browse the workspace directory

The directory is the first place to check before creating anything.

Use the page to:

- review all workspaces in one place
- see counts for global, department, and portal records
- filter by category or search by name or keyword
- check whether a workspace folder exists on disk
- review assigned staff and department grouping

### Search and filters

The page includes a simple filter bar. Use it to narrow the list by workspace
category, such as:

- **All**
- **Department**
- **Site / Portal**
- **Global**

Use the search box to look up a workspace by name, code, department, or other
metadata.

## Create a new workspace

1. Click **Add New Workspace** in the workspace directory.
2. Complete the required form fields.
3. Choose the workspace type:
   - **Department**
   - **Site / Portal**
4. Enter a site name and a virtual directory.
5. Add department or portal metadata as needed.
6. If this is a public portal, provide the redirect URL if one is required.
7. Fill in the contact information for the department or site owner.
8. Click **Create Workspace**.

### Required items to check before saving

The most important fields are:

- **Site Name** — the public-facing label
- **Virtual Directory** — the short identifier used for routing and folder names
- **Department category** — used for filtering and admin grouping
- **Folder path** — where the workspace's files live on disk

The system also creates a filesystem structure for the new workspace, including
`media/` and `documents/` folders.

> Important: the virtual directory should be unique. If it matches an existing
> workspace, the system blocks the save.

## Workspace form fields

### Site & directory configuration

This section controls the core workspace identity:

- **Classification / Marker** — Department or Site / Portal
- **Site Name** — display name for the workspace
- **Virtual Directory** — URL-friendly internal alias
- **Department** — owning department or office name
- **Department Category** — organizational grouping
- **Custom Redirect URL** — optional public redirect target

### Official contact information

This section records the contact for the workspace:

- first name
- last name
- email
- phone
- fax
- address
- city, state, zip
- office hours

This information is used for staff reference and admin management.

## Edit an existing workspace

1. Open the workspace directory.
2. Select the workspace you want to adjust.
3. Choose **Edit**.
4. Update the necessary fields.
5. Save the changes.

Use editing when:

- a workspace has a different department owner
- a site moves or changes its redirect URL
- contact information changes
- a public portal needs a different folder mapping or category

## Understand how workspace data is used

The workspace record is not just a list. It influences real application behavior:

- content and assets are grouped by workspace
- media and document folders are created on disk by workspace
- route and site scoping is organized around the workspace metadata
- staff access is associated with each workspace
- forms and navigation may reference the active workspace or site scope

This makes the workspace module the foundation for multi-site organization across
the CMS.

## Staff assignment and visibility

The workspace directory includes user and assignment data, so staff visibility can
be reviewed from the admin page.

Users may be:

- assigned directly to a workspace
- implicitly tied to a department or global workspace
- scoped through a shared county-wide view

For non-admin users, the system shows only the workspaces they are allowed to
see. Admins can manage the full directory.

## Best practices

- Use a clear, consistent workspace name and code.
- Keep the virtual directory short and stable.
- Do not reuse a virtual directory from another workspace.
- Confirm the folder path matches the actual storage location before sharing the
  workspace with staff.
- Review contact and redirect data before finalizing a public portal.
- Keep department categories consistent so filtering works as expected.

## Common issues

| What happened? | What to try |
| --- | --- |
| I cannot create a workspace. | Confirm you are signed in as an admin. |
| The save is blocked. | Check that the virtual directory is unique and the required fields are filled in. |
| I cannot find the workspace. | Search by name or code in the workspace directory. |
| A folder does not appear. | Check the workspace's folder path and verify it was created on disk. |
| The site is not showing correctly. | Confirm the redirect URL, site name, and virtual directory are accurate. |

## Quick reference

| Task | Where to do it |
| --- | --- |
| Review all workspaces | **Workspaces & Portals** |
| Create a new workspace | **Add New Workspace** |
| Update workspace details | **Edit** on the workspace row |
| Review staff scope | Workspace list and details view |
| Search and filter | Workspace directory toolbar |

## Summary

The Workspace module is the admin control center for the CMS's multi-site and
multi-division structure. Use it to create and maintain the sites, departments,
and shared scopes that the rest of the application depends on.

If you are setting up a new department or public portal, start here: create the
workspace, verify the folder path, confirm the virtual directory, and then check
that the department or site information is complete before handing it to staff.
