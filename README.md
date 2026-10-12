# CMSAdmin
Content Management System for Chelan County

Built on [Wheels](https://wheels.dev) (v4.x) and Lucee CFML.

## Overview
CMSAdmin provides management interfaces for:
- Pages & Subpages (`/pages`)
- Form Builder & Submissions (`/forms`)
- Navigation Menus (`/navigation`)
- Media & Document Management (`/media`)
- Jobs & Applications (`/jobs`)
- Workspaces & User Permissions (`/workspaces`, `/users`)

## Setup & Running
1. Copy `env.example` to `.env` and configure local database and reload credentials.
2. Start the Lucee/IIS application or CommandBox (`box server start`).
3. Reload application mappings using `?reload=true`.
