<cfset pageTitle = "Add New User">
<cfparam name="user" default="#{}#">
<cfparam name="roles" default="#[]#">
<cfparam name="departments" default="#[]#">
<cfparam name="workspaces" default="#[]#">
<cfscript>
	if (!structKeyExists(user, "first_name")) user.first_name = "";
	if (!structKeyExists(user, "last_name")) user.last_name = "";
	if (!structKeyExists(user, "email")) user.email = "";
	if (!structKeyExists(user, "username")) user.username = "";
	if (!structKeyExists(user, "job_title")) user.job_title = "";
	if (!structKeyExists(user, "phone")) user.phone = "";
	if (!structKeyExists(user, "role_code")) user.role_code = "author";
	if (!structKeyExists(user, "department_code")) user.department_code = "global";
	if (!structKeyExists(user, "workspaces") or !isArray(user.workspaces)) user.workspaces = ["global"];
	if (!structKeyExists(user, "status")) user.status = "active";
	if (!structKeyExists(user, "two_factor_enabled")) user.two_factor_enabled = false;
	if (arrayLen(workspaces) eq 0 and arrayLen(departments) gt 0) workspaces = departments;
</cfscript>
<cfoutput>
<div class="page-header">
	<div>
		<h1 class="page-title" style="margin-bottom:0.25rem;">Add New User</h1>
		<nav aria-label="Breadcrumb">
			<ol class="breadcrumb" style="margin-top:0.25rem;">
				<li class="breadcrumb-item"><a href="#urlFor(controller='main', action='index')#">#svgIcon(name="dashboard", size=14)# Home</a></li>
				<li class="breadcrumb-item">Administration</li>
				<li class="breadcrumb-item"><a href="#urlFor(controller='users', action='index')#">Users &amp; Roles</a></li>
				<li class="breadcrumb-item active" aria-current="page">Add New User</li>
			</ol>
		</nav>
	</div>
	<div class="page-header-actions">
		<a href="#urlFor(controller='users', action='index')#" class="btn btn-secondary btn-sm">
			#svgIcon(name="chevron-left", size=14)#
			<span>Back to User Directory</span>
		</a>
	</div>
</div>

<style>
.user-form-grid {
	display: grid;
	grid-template-columns: repeat(12, 1fr);
	gap: 1.5rem;
	align-items: stretch;
}
.col-6 {
	grid-column: span 6;
}
.col-12 {
	grid-column: span 12;
}
@media (max-width: 992px) {
	.col-6 {
		grid-column: span 12 !important;
	}
}
</style>

<form action="#urlFor(controller='users', action='create')#" method="post" class="user-form">
	#authenticityTokenField()#

	<div class="user-form-grid">
			
			<!--- Card 1: Staff Personal Information (6-col) --->
			<div class="admin-card col-6" style="display:flex; flex-direction:column;">
				<div class="card-header" style="padding:1rem 1.25rem; border-bottom:1px solid var(--admin-border);">
					<h2 style="font-size:0.95rem; font-weight:700; margin:0; color:var(--admin-text-main); display:flex; align-items:center; gap:0.5rem;">
						#svgIcon(name="user", size=16)#
						<span>Staff Profile Information</span>
					</h2>
				</div>
				<div class="card-body" style="padding:1.25rem; display:flex; flex-direction:column; gap:1rem;">
					<div style="display:grid; grid-template-columns:1fr 1fr; gap:1rem;">
						<div>
							<label for="first_name" class="form-label" style="font-weight:600; font-size:0.825rem;">First Name <span style="color:var(--admin-danger);">*</span></label>
							<input type="text" id="first_name" name="first_name" required value="#user.first_name#" class="form-control" placeholder="e.g. Rachel" autocomplete="given-name">
						</div>
						<div>
							<label for="last_name" class="form-label" style="font-weight:600; font-size:0.825rem;">Last Name <span style="color:var(--admin-danger);">*</span></label>
							<input type="text" id="last_name" name="last_name" required value="#user.last_name#" class="form-control" placeholder="e.g. Martinez" autocomplete="family-name">
						</div>
					</div>

					<div style="display:grid; grid-template-columns:1.2fr 0.8fr; gap:1rem;">
						<div>
							<label for="email" class="form-label" style="font-weight:600; font-size:0.825rem;">Chelan County Email <span style="color:var(--admin-danger);">*</span></label>
							<input type="email" id="email" name="email" required value="#user.email#" class="form-control" placeholder="rachel.martinez@chelancounty.gov" autocomplete="email">
							<div class="pg-help" style="margin-top:0.25rem;">Official @chelancounty.gov address required.</div>
						</div>
						<div>
							<label for="username" class="form-label" style="font-weight:600; font-size:0.825rem;">Username</label>
							<input type="text" id="username" name="username" value="#user.username#" class="form-control" placeholder="rmartinez" autocomplete="username">
						</div>
					</div>

					<div style="display:grid; grid-template-columns:1.2fr 0.8fr; gap:1rem;">
						<div>
							<label for="job_title" class="form-label" style="font-weight:600; font-size:0.825rem;">Job Title</label>
							<input type="text" id="job_title" name="job_title" value="#user.job_title#" class="form-control" placeholder="e.g. Public Information Specialist">
						</div>
						<div>
							<label for="phone" class="form-label" style="font-weight:600; font-size:0.825rem;">Office Phone</label>
							<input type="tel" id="phone" name="phone" value="#user.phone#" class="form-control" placeholder="(509) 667-6000" autocomplete="tel">
						</div>
					</div>
				</div>
			</div>

			<!--- Card 2: 4 User Groups / Role Selection (6-col) --->
			<div class="admin-card col-6" style="display:flex; flex-direction:column;">
				<div class="card-header" style="padding:1rem 1.25rem; border-bottom:1px solid var(--admin-border);">
					<h2 style="font-size:0.95rem; font-weight:700; margin:0; color:var(--admin-text-main); display:flex; align-items:center; gap:0.5rem;">
						#svgIcon(name="security", size=16)#
						<span>User Group &amp; Role Assignment</span>
					</h2>
				</div>
				<div class="card-body" style="padding:1.25rem; display:flex; flex-direction:column; gap:1rem; flex:1;">
					<div class="pg-help">Choose one of the 4 standard Chelan County usergroups:</div>

					<div style="display:grid; grid-template-columns:1fr 1fr; gap:0.85rem;" id="newRoleGrid">
						<!--- Admin Option --->
						<label class="role-select-box" style="border:2px solid #(user.role_code eq 'admin' ? 'var(--admin-primary)' : 'var(--admin-border)')#; background:#(user.role_code eq 'admin' ? 'var(--admin-primary-light)' : 'var(--admin-surface)')#; border-radius:var(--radius-md); padding:1rem; cursor:pointer; display:flex; gap:0.75rem; transition:all 0.15s ease;">
							<input type="radio" name="role_code" value="admin" #(user.role_code eq 'admin' ? 'checked' : '')# style="margin-top:3px;" onchange="setPageRoleSummary('admin')">
							<div>
								<div style="display:flex; align-items:center; gap:0.4rem;">
									<span class="badge badge-danger">Admin</span>
									<span style="font-weight:700; font-size:0.875rem; color:var(--admin-text-main);">Administrator</span>
								</div>
								<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:0.35rem; line-height:1.4;">
									Administrator will have <strong>everything</strong>: Content, HRM, PIO, Navigation, and Administration.
								</div>
							</div>
						</label>

						<!--- PIO Option --->
						<label class="role-select-box" style="border:2px solid #(user.role_code eq 'pio' ? 'var(--admin-primary)' : 'var(--admin-border)')#; background:#(user.role_code eq 'pio' ? 'var(--admin-primary-light)' : 'var(--admin-surface)')#; border-radius:var(--radius-md); padding:1rem; cursor:pointer; display:flex; gap:0.75rem; transition:all 0.15s ease;">
							<input type="radio" name="role_code" value="pio" #(user.role_code eq 'pio' ? 'checked' : '')# style="margin-top:3px;" onchange="setPageRoleSummary('pio')">
							<div>
								<div style="display:flex; align-items:center; gap:0.4rem;">
									<span class="badge badge-info">PIO</span>
									<span style="font-weight:700; font-size:0.875rem; color:var(--admin-text-main);">PIO</span>
								</div>
								<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:0.35rem; line-height:1.4;">
									Will have <strong>Content Management and PIO Group</strong> (Articles, Alerts, Press).
								</div>
							</div>
						</label>

						<!--- HR Option --->
						<label class="role-select-box" style="border:2px solid #(user.role_code eq 'hr' ? 'var(--admin-primary)' : 'var(--admin-border)')#; background:#(user.role_code eq 'hr' ? 'var(--admin-primary-light)' : 'var(--admin-surface)')#; border-radius:var(--radius-md); padding:1rem; cursor:pointer; display:flex; gap:0.75rem; transition:all 0.15s ease;">
							<input type="radio" name="role_code" value="hr" #(user.role_code eq 'hr' ? 'checked' : '')# style="margin-top:3px;" onchange="setPageRoleSummary('hr')">
							<div>
								<div style="display:flex; align-items:center; gap:0.4rem;">
									<span class="badge badge-purple">HR</span>
									<span style="font-weight:700; font-size:0.875rem; color:var(--admin-text-main);">HR</span>
								</div>
								<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:0.35rem; line-height:1.4;">
									Update to <strong>Content Management and HRM</strong> (Jobs, Onboarding, Policies).
								</div>
							</div>
						</label>

						<!--- Author Option --->
						<label class="role-select-box" style="border:2px solid #(user.role_code eq 'author' ? 'var(--admin-primary)' : 'var(--admin-border)')#; background:#(user.role_code eq 'author' ? 'var(--admin-primary-light)' : 'var(--admin-surface)')#; border-radius:var(--radius-md); padding:1rem; cursor:pointer; display:flex; gap:0.75rem; transition:all 0.15s ease;">
							<input type="radio" name="role_code" value="author" #(user.role_code eq 'author' ? 'checked' : '')# style="margin-top:3px;" onchange="setPageRoleSummary('author')">
							<div>
								<div style="display:flex; align-items:center; gap:0.4rem;">
									<span class="badge badge-primary">Author</span>
									<span style="font-weight:700; font-size:0.875rem; color:var(--admin-text-main);">Author</span>
								</div>
								<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:0.35rem; line-height:1.4;">
									General web update &bull; Access to <strong>Content Management Group</strong> only.
								</div>
							</div>
						</label>
					</div>

					<!--- Dynamic Capability Explanation --->
					<div id="newRoleFeedback" style="background:var(--admin-bg); border:1px solid var(--admin-border); border-radius:var(--radius-md); padding:1rem; font-size:0.825rem; margin-top:auto;">
						<div style="font-weight:700; color:var(--admin-text-main); margin-bottom:0.35rem; display:flex; align-items:center; gap:0.5rem;">
							#svgIcon(name="info", size=16)#
							<span id="newFeedbackTitle">Author (General Web Update) Access:</span>
						</div>
						<div id="newFeedbackDetail" style="color:var(--admin-text-muted); line-height:1.5;">
							Can create and edit Pages, upload Media Library assets, and build Online Forms. Restricted from HR, PIO, and Administration.
						</div>
					</div>
				</div>
			</div>

			<!--- Card 3: Assigned Workspaces & Sites (12-col full width) --->
			<div class="admin-card col-12">
				<div class="card-header" style="padding:1rem 1.25rem; border-bottom:1px solid var(--admin-border); display:flex; justify-content:space-between; align-items:center;">
					<h2 style="font-size:0.95rem; font-weight:700; margin:0; color:var(--admin-text-main); display:flex; align-items:center; gap:0.5rem;">
						#svgIcon(name="building", size=16)#
						<span>Assigned Workspaces &amp; Sites</span>
					</h2>
					<span class="badge badge-primary" id="wsSelectedCount">#(arrayFindNoCase(user.workspaces, 'global') ? 'All Workspaces (Global)' : ArrayLen(user.workspaces) & ' Selected')#</span>
				</div>
				<div class="card-body" style="padding:1.25rem; display:flex; flex-direction:column; gap:1.25rem;">
					<div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.5rem;">
						<div class="pg-help" style="margin:0;">A user can be assigned to multiple workspaces and portals. Select all that apply:</div>
						<div style="display:flex; gap:0.35rem;">
							<button type="button" class="btn btn-outline-secondary btn-sm" style="font-size:0.75rem; padding:0.2rem 0.5rem;" onclick="selectAllWorkspaces('dept')">All Departments</button>
							<button type="button" class="btn btn-outline-secondary btn-sm" style="font-size:0.75rem; padding:0.2rem 0.5rem;" onclick="selectAllWorkspaces('site')">All Sites</button>
							<button type="button" class="btn btn-outline-secondary btn-sm" style="font-size:0.75rem; padding:0.2rem 0.5rem;" onclick="clearAllWorkspaces()">Clear</button>
						</div>
					</div>

					<!--- Master Global Scope Option --->
					<label class="workspace-select-box" style="border:1.5px solid #(arrayFindNoCase(user.workspaces, 'global') ? 'var(--admin-primary)' : 'var(--admin-border)')#; background:#(arrayFindNoCase(user.workspaces, 'global') ? 'var(--admin-primary-light)' : 'var(--admin-bg)')#; border-radius:var(--radius-md); padding:0.85rem 1rem; cursor:pointer; display:flex; gap:0.75rem; align-items:center; transition:all 0.15s ease;">
						<input type="checkbox" name="workspaces" value="global" id="ws_global" #(arrayFindNoCase(user.workspaces, 'global') ? 'checked' : '')# onchange="toggleGlobalWorkspace(this)" style="width:17px; height:17px; margin:0;">
						<div style="flex:1;">
							<div style="display:flex; align-items:center; gap:0.5rem;">
								<span style="color:var(--admin-primary);">#svgIcon(name="grid", size=16)#</span>
								<strong style="font-size:0.875rem; color:var(--admin-text-main);">All Workspaces (Global Overview)</strong>
								<span class="badge badge-neutral">Full Scope</span>
							</div>
							<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:2px;">
								Grants user county-wide content editing, media uploads, and form permissions across all departments and public websites.
							</div>
						</div>
					</label>

					<!--- Section 1: County Departments & Divisions --->
					<div>
						<div style="font-weight:700; font-size:0.8rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--admin-text-subtle); margin-bottom:0.65rem; display:flex; align-items:center; gap:0.4rem;">
							#svgIcon(name="building", size=14)#
							<span>County Departments &amp; Divisions</span>
						</div>
						<div style="display:grid; grid-template-columns:1fr 1fr; gap:0.65rem;" id="deptWorkspacesGrid">
							<cfloop array="#workspaces#" index="ws">
								<cfif ws.type eq "dept">
									<cfset isAssigned = arrayFindNoCase(user.workspaces, ws.code) or arrayFindNoCase(user.workspaces, "global")>
									<label class="workspace-item-checkbox" style="border:1px solid #(isAssigned ? 'var(--admin-primary)' : 'var(--admin-border)')#; background:#(isAssigned ? 'var(--admin-primary-light)' : 'var(--admin-surface)')#; border-radius:var(--radius-sm); padding:0.6rem 0.75rem; cursor:pointer; display:flex; gap:0.55rem; align-items:center; transition:all 0.15s ease;">
										<input type="checkbox" name="workspaces" value="#ws.code#" class="ws-dept-check" #(isAssigned ? 'checked' : '')# onchange="updateWorkspaceCardState(this)" style="width:16px; height:16px; margin:0;">
										<span style="color:var(--admin-text-muted);">#svgIcon(name=ws.icon, size=15)#</span>
										<div style="flex:1; min-width:0;">
											<div style="font-weight:600; font-size:0.8rem; color:var(--admin-text-main); white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">#ws.name#</div>
										</div>
										<span class="badge #ws.badgeClass#" style="font-size:0.68rem; padding:0.1rem 0.4rem;">#ws.badge#</span>
									</label>
								</cfif>
							</cfloop>
						</div>
					</div>

					<!--- Section 2: Public Portals & Sites --->
					<div>
						<div style="font-weight:700; font-size:0.8rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--admin-text-subtle); margin-bottom:0.65rem; display:flex; align-items:center; gap:0.4rem;">
							#svgIcon(name="globe", size=14)#
							<span>Public Portals &amp; Web Sites</span>
						</div>
						<div style="display:grid; grid-template-columns:1fr 1fr; gap:0.65rem;" id="siteWorkspacesGrid">
							<cfloop array="#workspaces#" index="ws">
								<cfif ws.type eq "site">
									<cfset isAssigned = arrayFindNoCase(user.workspaces, ws.code) or arrayFindNoCase(user.workspaces, "global")>
									<label class="workspace-item-checkbox" style="border:1px solid #(isAssigned ? 'var(--admin-primary)' : 'var(--admin-border)')#; background:#(isAssigned ? 'var(--admin-primary-light)' : 'var(--admin-surface)')#; border-radius:var(--radius-sm); padding:0.6rem 0.75rem; cursor:pointer; display:flex; gap:0.55rem; align-items:center; transition:all 0.15s ease;">
										<input type="checkbox" name="workspaces" value="#ws.code#" class="ws-site-check" #(isAssigned ? 'checked' : '')# onchange="updateWorkspaceCardState(this)" style="width:16px; height:16px; margin:0;">
										<span style="color:var(--admin-text-muted);">#svgIcon(name="globe", size=15)#</span>
										<div style="flex:1; min-width:0;">
											<div style="font-weight:600; font-size:0.8rem; color:var(--admin-text-main); white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">#ws.name#</div>
										</div>
										<span class="badge #ws.badgeClass#" style="font-size:0.68rem; padding:0.1rem 0.4rem;">#ws.badge#</span>
									</label>
								</cfif>
							</cfloop>
						</div>
					</div>

				</div>
			</div>

			<!--- Card 4: Primary Home Department (6-col) --->
			<div class="admin-card col-6" style="display:flex; flex-direction:column;">
				<div class="card-header" style="padding:1rem 1.25rem; border-bottom:1px solid var(--admin-border);">
					<h2 style="font-size:0.95rem; font-weight:700; margin:0; color:var(--admin-text-main); display:flex; align-items:center; gap:0.5rem;">
						#svgIcon(name="building", size=16)#
						<span>Primary Home Department</span>
					</h2>
				</div>
				<div class="card-body" style="padding:1.25rem; display:flex; flex-direction:column; gap:1rem; flex:1;">
					<div>
						<label for="department_code" class="form-label" style="font-weight:600; font-size:0.825rem;">Default Home Workspace</label>
						<select id="department_code" name="department_code" class="form-control">
							<cfloop array="#workspaces#" index="d">
								<option value="#d.code#" #(user.department_code eq d.code ? 'selected' : '')#>#d.name#</option>
							</cfloop>
						</select>
						<div class="pg-help" style="margin-top:0.35rem;">Used as staff profile home department label and initial landing scope.</div>
					</div>

					<div>
						<label for="status" class="form-label" style="font-weight:600; font-size:0.825rem;">Account Status</label>
						<select id="status" name="status" class="form-control">
							<option value="active" #(user.status eq 'active' ? 'selected' : '')#>Active (Can Log In)</option>
							<option value="inactive" #(user.status eq 'inactive' ? 'selected' : '')#>Inactive (Access Disabled)</option>
						</select>
					</div>
				</div>
				<div class="card-footer" style="padding:1rem 1.25rem; background:var(--admin-bg); border-top:1px solid var(--admin-border); font-size:0.75rem; color:var(--admin-text-muted); display:flex; align-items:center; min-height:57px; box-sizing:border-box;">
					<span>Default landing workspace for new session</span>
				</div>
			</div>

			<!--- Card 5: Credentials & Security (6-col) --->
			<div class="admin-card col-6" style="display:flex; flex-direction:column;">
				<div class="card-header" style="padding:1rem 1.25rem; border-bottom:1px solid var(--admin-border);">
					<h2 style="font-size:0.95rem; font-weight:700; margin:0; color:var(--admin-text-main); display:flex; align-items:center; gap:0.5rem;">
						#svgIcon(name="lock", size=16)#
						<span>Credentials &amp; Security</span>
					</h2>
				</div>
				<div class="card-body" style="padding:1.25rem; display:flex; flex-direction:column; gap:1rem; flex:1;">
					<div>
						<label class="form-label" style="font-weight:600; font-size:0.825rem;">Authentication Method</label>
						<div style="font-size:0.8rem; color:var(--admin-text-muted);">
							Chelan County Microsoft Entra ID (Single Sign-On) &bull; Local Backup
						</div>
					</div>

					<div style="display:flex; flex-direction:column; gap:0.6rem; padding-top:0.5rem; border-top:1px solid var(--admin-border-subtle);">
						<label style="display:flex; align-items:flex-start; gap:0.5rem; cursor:pointer; font-size:0.825rem;">
							<input type="checkbox" name="two_factor_enabled" value="1" #(user.two_factor_enabled ? 'checked' : '')# style="margin-top:2px;">
							<span>Require Two-Factor Authentication (2FA)</span>
						</label>

						<label style="display:flex; align-items:flex-start; gap:0.5rem; cursor:pointer; font-size:0.825rem;">
							<input type="checkbox" name="send_welcome" value="1" checked style="margin-top:2px;">
							<span>Send welcome email with account activation instructions</span>
						</label>
					</div>
				</div>

				<div class="card-footer" style="padding:1rem 1.25rem; background:var(--admin-bg); border-top:1px solid var(--admin-border); display:flex; justify-content:space-between; align-items:center; min-height:57px; box-sizing:border-box;">
					<a href="#urlFor(controller='users', action='index')#" class="btn btn-secondary btn-sm">Cancel</a>
					<button type="submit" class="btn btn-primary btn-sm">
						#svgIcon(name="save", size=15)#
						<span>Create User Account</span>
					</button>
				</div>
			</div>

	</div>
</form>
</cfoutput>

<script>
function setPageRoleSummary(role) {
	const boxes = document.querySelectorAll("#newRoleGrid .role-select-box");
	boxes.forEach(b => {
		const rad = b.querySelector("input[type='radio']");
		if (rad && rad.value === role) {
			b.style.borderColor = "var(--admin-primary)";
			b.style.background = "var(--admin-primary-light)";
		} else {
			b.style.borderColor = "var(--admin-border)";
			b.style.background = "var(--admin-surface)";
		}
	});

	const titleEl = document.getElementById("newFeedbackTitle");
	const detailEl = document.getElementById("newFeedbackDetail");

	if (role === "admin") {
		titleEl.textContent = "Administrator Access:";
		detailEl.innerHTML = "Administrator will have <strong>everything</strong>: unrestricted access to Content Management, HRM Group, PIO Group, Administration, Navigation Menus, and System Settings.";
	} else if (role === "pio") {
		titleEl.textContent = "PIO Access:";
		detailEl.innerHTML = "Access to <strong>Content Management Group</strong> (Pages, Media, Forms) + <strong>PIO Group</strong> (Articles &amp; Posts, Press Releases, Media Alerts, PRR). Locked out of HRM and Administration.";
	} else if (role === "hr") {
		titleEl.textContent = "HR Access:";
		detailEl.innerHTML = "Access to <strong>Content Management Group</strong> (Pages, Media, Forms) + <strong>HRM Group</strong> (Job Postings, Onboarding, Personnel Policies, HRM Inquiries). Locked out of PIO and Administration.";
	} else {
		titleEl.textContent = "Author (General Web Update) Access:";
		detailEl.innerHTML = "Author is general web update &bull; Access to <strong>Content Management Group</strong> only (Pages, Media Library, Form Builder/Forms, Feedback &amp; Inquiries). Locked out of HRM, PIO, and Administration.";
	}
}

function toggleGlobalWorkspace(chk) {
	const allDept = document.querySelectorAll(".ws-dept-check");
	const allSite = document.querySelectorAll(".ws-site-check");
	if (chk.checked) {
		allDept.forEach(c => { c.checked = true; updateWorkspaceCardVisual(c); });
		allSite.forEach(c => { c.checked = true; updateWorkspaceCardVisual(c); });
	}
	updateWorkspaceCardVisual(chk);
	updateWorkspaceCount();
}

function selectAllWorkspaces(type) {
	if (type === 'dept') {
		document.querySelectorAll(".ws-dept-check").forEach(c => { c.checked = true; updateWorkspaceCardVisual(c); });
	} else if (type === 'site') {
		document.querySelectorAll(".ws-site-check").forEach(c => { c.checked = true; updateWorkspaceCardVisual(c); });
	}
	updateWorkspaceCount();
}

function clearAllWorkspaces() {
	const glob = document.getElementById("ws_global");
	if (glob) { glob.checked = false; updateWorkspaceCardVisual(glob); }
	document.querySelectorAll(".ws-dept-check, .ws-site-check").forEach(c => {
		c.checked = false;
		updateWorkspaceCardVisual(c);
	});
	updateWorkspaceCount();
}

function updateWorkspaceCardState(chk) {
	updateWorkspaceCardVisual(chk);
	const glob = document.getElementById("ws_global");
	if (!chk.checked && glob) {
		glob.checked = false;
		updateWorkspaceCardVisual(glob);
	}
	updateWorkspaceCount();
}

function updateWorkspaceCardVisual(chk) {
	const label = chk.closest("label");
	if (!label) return;
	if (chk.checked) {
		label.style.borderColor = "var(--admin-primary)";
		label.style.background = "var(--admin-primary-light)";
	} else {
		label.style.borderColor = "var(--admin-border)";
		label.style.background = "var(--admin-surface)";
	}
}

function updateWorkspaceCount() {
	const checked = document.querySelectorAll("input[name='workspaces']:checked");
	const glob = document.getElementById("ws_global");
	const badge = document.getElementById("wsSelectedCount");
	if (badge) {
		if (glob && glob.checked) {
			badge.textContent = "All Workspaces (Global)";
		} else {
			badge.textContent = checked.length + " Selected";
		}
	}
}
</script>
