<cfset pageTitle = "Users & Roles">
<cfparam name="activeFilterRole" default="all">
<cfparam name="activeFilterStatus" default="all">
<cfparam name="activeFilterDept" default="all">
<cfparam name="activeSearchQuery" default="">
<cfparam name="currentSimulatedRole" default="admin">
<cfparam name="users" default="#[]#">
<cfparam name="metrics" default="#{}#">
<cfparam name="workspaces" default="#[]#">
<cfscript>
	if (!structKeyExists(metrics, "total")) {
		metrics = { total: ArrayLen(users), admin: 0, pio: 0, hr: 0, author: 0, active: ArrayLen(users), inactive: 0 };
	}
	wsLookup = {};
	for (w in workspaces) {
		wsLookup[w.code] = w;
		if (structKeyExists(w, "alias") && len(trim(w.alias))) {
			wsLookup[trim(w.alias)] = w;
		}
	}
	urlAll = urlFor(controller='users', action='index');
	urlAdmin = urlFor(controller='users', action='index', params='role=admin');
	urlPio = urlFor(controller='users', action='index', params='role=pio');
	urlHr = urlFor(controller='users', action='index', params='role=hr');
	urlAuthor = urlFor(controller='users', action='index', params='role=author');

	if (activeFilterDept neq "all") {
		urlAll = urlAll & (Find("?", urlAll) ? "&" : "?") & "dept=" & activeFilterDept;
		urlAdmin = urlAdmin & (Find("?", urlAdmin) ? "&" : "?") & "dept=" & activeFilterDept;
		urlPio = urlPio & (Find("?", urlPio) ? "&" : "?") & "dept=" & activeFilterDept;
		urlHr = urlHr & (Find("?", urlHr) ? "&" : "?") & "dept=" & activeFilterDept;
		urlAuthor = urlAuthor & (Find("?", urlAuthor) ? "&" : "?") & "dept=" & activeFilterDept;
	}
</cfscript>
<cfoutput>
<div class="page-header">
	<div>
		<h1 class="page-title" style="margin-bottom:0.25rem;">Users &amp; Roles</h1>
		<nav aria-label="Breadcrumb">
			<ol class="breadcrumb" style="margin-top:0.25rem;">
				<li class="breadcrumb-item"><a href="#urlFor(controller='main', action='index')#">#svgIcon(name="dashboard", size=14)# Home</a></li>
				<li class="breadcrumb-item">Administration</li>
				<li class="breadcrumb-item active" aria-current="page">Users &amp; Roles</li>
			</ol>
		</nav>
	</div>
	<div class="page-header-actions" style="display:flex; gap:0.6rem; align-items:center;">
		<a href="#urlFor(controller='users', action='roles')#" class="btn btn-secondary btn-sm" title="View Roles & Permissions Matrix">
			#svgIcon(name="security", size=15)#
			<span>Roles &amp; Permissions Matrix</span>
		</a>
		<button type="button" class="btn btn-primary btn-sm" id="btnOpenAddUserModal" title="Add New User Account">
			#svgIcon(name="plus", size=15)#
			<span>Add New User</span>
		</button>
	</div>
</div>
<!--- 4 User Group KPI Stat Cards --->
<div class="kpi-grid" style="display:grid; grid-template-columns:repeat(auto-fit, minmax(200px, 1fr)); gap:1rem; margin-bottom:1.25rem;">
	<div class="admin-card" style="margin-bottom:0; border-left:4px solid var(--admin-primary);">
		<div class="card-body" style="padding:1rem 1.25rem; display:flex; align-items:center; justify-content:space-between;">
			<div>
				<div style="font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--admin-text-subtle); font-weight:700;">Total Users</div>
				<div style="font-size:1.6rem; font-weight:700; color:var(--admin-text-main); line-height:1.2; margin-top:0.25rem;">#metrics.total#</div>
				<div style="font-size:0.75rem; color:var(--admin-success); margin-top:0.15rem; font-weight:600;">#metrics.active# active accounts</div>
			</div>
			<div style="width:42px; height:42px; border-radius:var(--radius-md); background:var(--admin-primary-light); color:var(--admin-primary); display:flex; align-items:center; justify-content:center;">
				#svgIcon(name="users", size=22)#
			</div>
		</div>
	</div>

	<a href="#urlAdmin#" style="text-decoration:none;" class="admin-card" style="margin-bottom:0; border-left:4px solid var(--admin-danger);">
		<div class="card-body" style="padding:1rem 1.25rem; display:flex; align-items:center; justify-content:space-between;">
			<div>
				<div style="font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--admin-danger); font-weight:700;">Admin</div>
				<div style="font-size:1.6rem; font-weight:700; color:var(--admin-text-main); line-height:1.2; margin-top:0.25rem;">#metrics.admin#</div>
				<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:0.15rem;">Has Everything</div>
			</div>
			<div style="width:42px; height:42px; border-radius:var(--radius-md); background:var(--admin-danger-light); color:var(--admin-danger); display:flex; align-items:center; justify-content:center;">
				#svgIcon(name="shield", size=22)#
			</div>
		</div>
	</a>

	<a href="#urlPio#" style="text-decoration:none;" class="admin-card" style="margin-bottom:0; border-left:4px solid var(--admin-info);">
		<div class="card-body" style="padding:1rem 1.25rem; display:flex; align-items:center; justify-content:space-between;">
			<div>
				<div style="font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--admin-info); font-weight:700;">PIO</div>
				<div style="font-size:1.6rem; font-weight:700; color:var(--admin-text-main); line-height:1.2; margin-top:0.25rem;">#metrics.pio#</div>
				<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:0.15rem;">Content + PIO Group</div>
			</div>
			<div style="width:42px; height:42px; border-radius:var(--radius-md); background:var(--admin-info-light); color:var(--admin-info); display:flex; align-items:center; justify-content:center;">
				#svgIcon(name="megaphone", size=22)#
			</div>
		</div>
	</a>

	<a href="#urlHr#" style="text-decoration:none;" class="admin-card" style="margin-bottom:0; border-left:4px solid var(--admin-purple);">
		<div class="card-body" style="padding:1rem 1.25rem; display:flex; align-items:center; justify-content:space-between;">
			<div>
				<div style="font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--admin-purple); font-weight:700;">HR</div>
				<div style="font-size:1.6rem; font-weight:700; color:var(--admin-text-main); line-height:1.2; margin-top:0.25rem;">#metrics.hr#</div>
				<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:0.15rem;">Content + HRM Group</div>
			</div>
			<div style="width:42px; height:42px; border-radius:var(--radius-md); background:var(--admin-purple-light); color:var(--admin-purple); display:flex; align-items:center; justify-content:center;">
				#svgIcon(name="briefcase", size=22)#
			</div>
		</div>
	</a>

	<a href="#urlAuthor#" style="text-decoration:none;" class="admin-card" style="margin-bottom:0; border-left:4px solid var(--admin-primary);">
		<div class="card-body" style="padding:1rem 1.25rem; display:flex; align-items:center; justify-content:space-between;">
			<div>
				<div style="font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--admin-primary); font-weight:700;">Author</div>
				<div style="font-size:1.6rem; font-weight:700; color:var(--admin-text-main); line-height:1.2; margin-top:0.25rem;">#metrics.author#</div>
				<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:0.15rem;">General Web Update</div>
			</div>
			<div style="width:42px; height:42px; border-radius:var(--radius-md); background:var(--admin-primary-light); color:var(--admin-primary); display:flex; align-items:center; justify-content:center;">
				#svgIcon(name="edit", size=22)#
			</div>
		</div>
	</a>
</div>

<!--- Main Filterable User Directory Card --->
<div class="admin-card">
	<!--- Role Filter Tabs & Search Bar Header --->
	<div class="card-header" style="display:flex; flex-direction:column; gap:0.85rem; padding:1.15rem 1.25rem; background:var(--admin-surface); border-bottom:1px solid var(--admin-border);">
		
		<!--- Row 1: Role Pills (Left) + Search & Filter Form (Right) --->
		<div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.85rem;">
			<!--- Accessible Role Filter Tabs --->
			<div class="tab-list" role="tablist" aria-label="Filter Users by Role" style="display:inline-flex; gap:0.25rem; background:var(--admin-bg); padding:0.25rem; border-radius:var(--radius-md); border:1px solid var(--admin-border);">
				<a href="#urlAll#" 
				   class="tab-item #(activeFilterRole eq 'all' ? 'active' : '')#" 
				   style="padding:0.35rem 0.75rem; border-radius:var(--radius-sm); font-size:0.8125rem; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; gap:0.35rem; color:#(activeFilterRole eq 'all' ? 'var(--admin-primary)' : 'var(--admin-text-muted)')#; background:#(activeFilterRole eq 'all' ? 'var(--admin-surface)' : 'transparent')#; box-shadow:#(activeFilterRole eq 'all' ? 'var(--shadow-sm)' : 'none')#;">
					<span>All Users</span>
					<span class="badge #(activeFilterRole eq 'all' ? 'badge-primary' : 'badge-neutral')#" style="font-size:0.7rem; padding:0.1rem 0.35rem;">#metrics.total#</span>
				</a>
				<a href="#urlAdmin#" 
				   class="tab-item #(activeFilterRole eq 'admin' ? 'active' : '')#" 
				   style="padding:0.35rem 0.75rem; border-radius:var(--radius-sm); font-size:0.8125rem; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; gap:0.35rem; color:#(activeFilterRole eq 'admin' ? 'var(--admin-danger)' : 'var(--admin-text-muted)')#; background:#(activeFilterRole eq 'admin' ? 'var(--admin-surface)' : 'transparent')#; box-shadow:#(activeFilterRole eq 'admin' ? 'var(--shadow-sm)' : 'none')#;">
					<span>Admin</span>
					<span class="badge #(activeFilterRole eq 'admin' ? 'badge-danger' : 'badge-neutral')#" style="font-size:0.7rem; padding:0.1rem 0.35rem;">#metrics.admin#</span>
				</a>
				<a href="#urlPio#" 
				   class="tab-item #(activeFilterRole eq 'pio' ? 'active' : '')#" 
				   style="padding:0.35rem 0.75rem; border-radius:var(--radius-sm); font-size:0.8125rem; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; gap:0.35rem; color:#(activeFilterRole eq 'pio' ? 'var(--admin-info)' : 'var(--admin-text-muted)')#; background:#(activeFilterRole eq 'pio' ? 'var(--admin-surface)' : 'transparent')#; box-shadow:#(activeFilterRole eq 'pio' ? 'var(--shadow-sm)' : 'none')#;">
					<span>PIO</span>
					<span class="badge #(activeFilterRole eq 'pio' ? 'badge-info' : 'badge-neutral')#" style="font-size:0.7rem; padding:0.1rem 0.35rem;">#metrics.pio#</span>
				</a>
				<a href="#urlHr#" 
				   class="tab-item #(activeFilterRole eq 'hr' ? 'active' : '')#" 
				   style="padding:0.35rem 0.75rem; border-radius:var(--radius-sm); font-size:0.8125rem; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; gap:0.35rem; color:#(activeFilterRole eq 'hr' ? 'var(--admin-purple)' : 'var(--admin-text-muted)')#; background:#(activeFilterRole eq 'hr' ? 'var(--admin-surface)' : 'transparent')#; box-shadow:#(activeFilterRole eq 'hr' ? 'var(--shadow-sm)' : 'none')#;">
					<span>HR</span>
					<span class="badge #(activeFilterRole eq 'hr' ? 'badge-purple' : 'badge-neutral')#" style="font-size:0.7rem; padding:0.1rem 0.35rem;">#metrics.hr#</span>
				</a>
				<a href="#urlAuthor#" 
				   class="tab-item #(activeFilterRole eq 'author' ? 'active' : '')#" 
				   style="padding:0.35rem 0.75rem; border-radius:var(--radius-sm); font-size:0.8125rem; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; gap:0.35rem; color:#(activeFilterRole eq 'author' ? 'var(--admin-primary)' : 'var(--admin-text-muted)')#; background:#(activeFilterRole eq 'author' ? 'var(--admin-surface)' : 'transparent')#; box-shadow:#(activeFilterRole eq 'author' ? 'var(--shadow-sm)' : 'none')#;">
					<span>Author</span>
					<span class="badge #(activeFilterRole eq 'author' ? 'badge-primary' : 'badge-neutral')#" style="font-size:0.7rem; padding:0.1rem 0.35rem;">#metrics.author#</span>
				</a>
			</div>

			<!--- Search and Filter Controls (Aligned horizontally in a toolbar) --->
			<form action="#urlFor(controller='users', action='index')#" method="get" style="display:flex; align-items:center; gap:0.45rem; flex-wrap:wrap; margin:0;">
				<cfif activeFilterRole neq "all">
					<input type="hidden" name="role" value="#activeFilterRole#">
				</cfif>
				
				<!--- Search Input --->
				<div style="position:relative; width:210px; flex:0 0 auto;">
					<span style="position:absolute; left:9px; top:50%; transform:translateY(-50%); color:var(--admin-text-subtle); pointer-events:none; display:flex;">
						#svgIcon(name="search", size=13)#
					</span>
					<input type="text" name="q" value="#activeSearchQuery#" placeholder="Search staff name..." class="form-control" style="width:100%; height:32px; padding:0 0.5rem 0 28px; font-size:0.8rem; border-radius:var(--radius-sm); background:var(--admin-surface);">
				</div>

				<!--- Status Select --->
				<div style="width:110px; flex:0 0 auto;">
					<select name="status" class="form-control" onchange="this.form.submit()" style="width:100%; height:32px; font-size:0.8rem; border-radius:var(--radius-sm); padding:0 0.45rem; background:var(--admin-surface);" title="Filter by Account Status">
						<option value="all" #(activeFilterStatus eq 'all' ? 'selected' : '')#>All Status</option>
						<option value="active" #(activeFilterStatus eq 'active' ? 'selected' : '')#>Active</option>
						<option value="inactive" #(activeFilterStatus eq 'inactive' ? 'selected' : '')#>Inactive</option>
					</select>
				</div>

				<!--- Workspace / Portal Select --->
				<div style="width:160px; flex:0 0 auto;">
					<select name="dept" class="form-control" onchange="this.form.submit()" style="width:100%; height:32px; font-size:0.8rem; border-radius:var(--radius-sm); padding:0 0.45rem; background:var(--admin-surface);" title="Filter by Assigned Workspace or Portal">
						<option value="all" #(activeFilterDept eq 'all' ? 'selected' : '')#>All Workspaces</option>
						<option value="global" #(activeFilterDept eq 'global' ? 'selected' : '')#>Global (County-wide)</option>
						<optgroup label="Departments &amp; Divisions">
							<cfloop array="#workspaces#" index="wsItem">
								<cfif wsItem.type eq "dept">
									<option value="#wsItem.code#" #(activeFilterDept eq wsItem.code ? 'selected' : '')#>#wsItem.name#</option>
								</cfif>
							</cfloop>
						</optgroup>
						<optgroup label="Public Sites &amp; Portals">
							<cfloop array="#workspaces#" index="wsItem">
								<cfif wsItem.type eq "site">
									<option value="#wsItem.code#" #(activeFilterDept eq wsItem.code ? 'selected' : '')#>#wsItem.name#</option>
								</cfif>
							</cfloop>
						</optgroup>
					</select>
				</div>

				<!--- Submit Button --->
				<button type="submit" class="btn btn-secondary btn-sm" style="height:32px; padding:0 0.75rem; font-size:0.8rem; font-weight:600; flex:0 0 auto;">Filter</button>
				
				<!--- Reset Button if filter active --->
				<cfif len(activeSearchQuery) or activeFilterRole neq "all" or activeFilterStatus neq "all" or activeFilterDept neq "all">
					<a href="#urlFor(controller='users', action='index')#" class="btn btn-outline-secondary btn-sm" style="height:32px; width:32px; padding:0; display:inline-flex; align-items:center; justify-content:center; flex:0 0 auto;" title="Reset All Filters">
						#svgIcon(name="x", size=13)#
					</a>
				</cfif>
			</form>
		</div>

		<!--- Row 2: Sleek Role Scope Legend Strip & Matrix Link --->
		<div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.65rem; background:var(--admin-bg); padding:0.45rem 0.85rem; border-radius:var(--radius-sm); border:1px solid var(--admin-border-subtle); font-size:0.75rem;">
			<div style="display:flex; align-items:center; gap:0.85rem; flex-wrap:wrap;">
				<div style="display:flex; align-items:center; gap:0.35rem; color:var(--admin-text-subtle); font-weight:700; text-transform:uppercase; letter-spacing:0.04em; font-size:0.68rem;">
					#svgIcon(name="info", size=12)#
					<span>Role Scopes:</span>
				</div>
				<div style="display:flex; align-items:center; gap:0.35rem;">
					<span class="badge badge-danger" style="font-size:0.65rem; padding:0.1rem 0.4rem;">Admin</span>
					<span style="color:var(--admin-text-muted);">Has Everything</span>
				</div>
				<span style="color:var(--admin-border);">&bull;</span>
				<div style="display:flex; align-items:center; gap:0.35rem;">
					<span class="badge badge-info" style="font-size:0.65rem; padding:0.1rem 0.4rem;">PIO</span>
					<span style="color:var(--admin-text-muted);">Content + PIO Group</span>
				</div>
				<span style="color:var(--admin-border);">&bull;</span>
				<div style="display:flex; align-items:center; gap:0.35rem;">
					<span class="badge badge-purple" style="font-size:0.65rem; padding:0.1rem 0.4rem;">HR</span>
					<span style="color:var(--admin-text-muted);">Content + HRM Group</span>
				</div>
				<span style="color:var(--admin-border);">&bull;</span>
				<div style="display:flex; align-items:center; gap:0.35rem;">
					<span class="badge badge-primary" style="font-size:0.65rem; padding:0.1rem 0.4rem;">Author</span>
					<span style="color:var(--admin-text-muted);">General Web Update</span>
				</div>
			</div>

			<a href="#urlFor(controller='users', action='roles')#" style="color:var(--admin-primary); text-decoration:none; font-weight:600; display:inline-flex; align-items:center; gap:0.3rem; font-size:0.75rem; white-space:nowrap;" title="View Full Roles &amp; Permissions Matrix">
				<span>Roles &amp; Permissions Matrix</span>
				<span style="font-size:0.85rem;">&rarr;</span>
			</a>
		</div>
	</div>

	<!--- Users Directory Table --->
	<div class="card-body" style="padding:0; overflow-x:auto;">
		<table class="admin-table" style="width:100%; border-collapse:collapse; margin:0;" aria-label="County Staff and Users Directory">
			<thead>
				<tr style="background:var(--admin-bg); border-bottom:1px solid var(--admin-border); text-align:left;">
					<th scope="col" style="padding:0.85rem 1.25rem; font-weight:700; color:var(--admin-text-subtle); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em;">Staff Member</th>
					<th scope="col" style="padding:0.85rem 1rem; font-weight:700; color:var(--admin-text-subtle); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em;">User Group / Role</th>
					<th scope="col" style="padding:0.85rem 1rem; font-weight:700; color:var(--admin-text-subtle); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em;">Assigned Workspaces / Sites</th>
					<th scope="col" style="padding:0.85rem 1rem; font-weight:700; color:var(--admin-text-subtle); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em;">Accessible Groups</th>
					<th scope="col" style="padding:0.85rem 1rem; font-weight:700; color:var(--admin-text-subtle); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em;">2FA / Security</th>
					<th scope="col" style="padding:0.85rem 1rem; font-weight:700; color:var(--admin-text-subtle); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em;">Status</th>
					<th scope="col" style="padding:0.85rem 1.25rem; font-weight:700; color:var(--admin-text-subtle); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em; text-align:right;">Actions</th>
				</tr>
			</thead>
			<tbody>
				<cfif ArrayLen(users) eq 0>
					<tr>
						<td colspan="7" style="padding:3rem 1.5rem; text-align:center; color:var(--admin-text-muted);">
							<div style="display:flex; flex-direction:column; align-items:center; gap:0.5rem;">
								<span style="color:var(--admin-text-subtle);">#svgIcon(name="users", size=36)#</span>
								<div style="font-weight:600; font-size:1rem; color:var(--admin-text-main);">No staff accounts matched your filters</div>
								<div style="font-size:0.825rem;">Try adjusting your role or search parameters, or create a new user.</div>
								<div style="margin-top:0.5rem;">
									<a href="#urlFor(controller='users', action='index')#" class="btn btn-secondary btn-sm">Clear Filters</a>
								</div>
							</div>
						</td>
					</tr>
				<cfelse>
					<cfloop array="#users#" index="u">
						<cfscript>
							initials = Left(u.first_name, 1) & Left(u.last_name, 1);
							roleBadge = "badge-neutral";
							roleLabel = "Author";
							roleDesc = "Content Management Only";
							accessModules = [];
							
							switch(u.role_code) {
								case "admin":
									roleBadge = "badge-danger";
									roleLabel = "Administrator";
									roleDesc = "Has everything (Admin, Content, HRM, PIO)";
									accessModules = ["Content", "HRM", "PIO", "Admin"];
									break;
								case "pio":
									roleBadge = "badge-info";
									roleLabel = "PIO";
									roleDesc = "Content Management + PIO Group";
									accessModules = ["Content", "PIO"];
									break;
								case "hr":
									roleBadge = "badge-purple";
									roleLabel = "HR";
									roleDesc = "Content Management + HRM Group";
									accessModules = ["Content", "HRM"];
									break;
								default:
									roleBadge = "badge-primary";
									roleLabel = "Author";
									roleDesc = "General Web Update (Content Management)";
									accessModules = ["Content"];
									break;
							}

							uWorkspaces = structKeyExists(u, "workspaces") && isArray(u.workspaces) ? u.workspaces : [u.department_code];
						</cfscript>
						<tr style="border-bottom:1px solid var(--admin-border-subtle); transition:background 0.15s ease;">
							<!--- User Info Cell --->
							<td style="padding:0.9rem 1.25rem;">
								<div style="display:flex; align-items:center; gap:0.75rem;">
									<div class="user-avatar" style="width:36px; height:36px; border-radius:50%; background:#(u.role_code eq 'admin' ? 'var(--admin-danger-light)' : (u.role_code eq 'pio' ? 'var(--admin-info-light)' : (u.role_code eq 'hr' ? 'var(--admin-purple-light)' : 'var(--admin-primary-light)')))#; color:#(u.role_code eq 'admin' ? 'var(--admin-danger)' : (u.role_code eq 'pio' ? 'var(--admin-info)' : (u.role_code eq 'hr' ? 'var(--admin-purple)' : 'var(--admin-primary)')))#; font-weight:700; font-size:0.85rem; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
										#initials#
									</div>
									<div>
										<div style="font-weight:600; color:var(--admin-text-main); font-size:0.875rem;">
											<a href="#urlFor(controller='users', action='edit', params='id=' & u.id)#" style="color:var(--admin-text-main); text-decoration:none;" class="user-link">
												#u.first_name# #u.last_name#
											</a>
										</div>
										<div style="font-size:0.75rem; color:var(--admin-text-muted);">
											#u.email# &bull; <span style="font-family:monospace; color:var(--admin-text-subtle);">#u.username#</span>
										</div>
										<div style="font-size:0.72rem; color:var(--admin-text-subtle); margin-top:1px;">
											#u.job_title#
										</div>
									</div>
								</div>
							</td>

							<!--- Role Badge Cell --->
							<td style="padding:0.9rem 1rem;">
								<div style="display:flex; flex-direction:column; align-items:flex-start; gap:0.25rem;">
									<span class="badge #roleBadge#" style="font-weight:700; font-size:0.78rem; padding:0.25rem 0.6rem;">
										#roleLabel#
									</span>
									<span style="font-size:0.72rem; color:var(--admin-text-muted); line-height:1.2;">
										#roleDesc#
									</span>
								</div>
							</td>

							<!--- Assigned Workspaces & Sites Cell --->
							<td style="padding:0.9rem 1rem;">
								<cfif arrayFindNoCase(uWorkspaces, "global")>
									<div style="display:flex; align-items:center; gap:0.4rem;">
										<span class="badge badge-neutral" style="font-size:0.75rem; padding:0.25rem 0.55rem; font-weight:600; display:inline-flex; align-items:center; gap:0.35rem;" title="County-wide access across all departments and websites">
											#svgIcon(name="grid", size=13)#
											<span>All Workspaces (Global)</span>
										</span>
									</div>
								<cfelse>
									<div style="display:flex; gap:0.3rem; flex-wrap:wrap; max-width:260px; align-items:center;">
										<cfset wsIdx = 0>
										<cfloop array="#uWorkspaces#" index="wsCode">
											<cfset wsIdx = wsIdx + 1>
											<cfif wsIdx lte 3>
												<cfif structKeyExists(wsLookup, wsCode)>
													<cfset wsInfo = wsLookup[wsCode]>
													<span class="badge #wsInfo.badgeClass#" style="font-size:0.7rem; padding:0.15rem 0.45rem; display:inline-flex; align-items:center; gap:0.25rem;" title="#wsInfo.name#">
														#svgIcon(name=wsInfo.icon, size=11)#
														#wsInfo.badge#
													</span>
												<cfelse>
													<span class="badge badge-neutral" style="font-size:0.7rem; padding:0.15rem 0.45rem;">#wsCode#</span>
												</cfif>
											</cfif>
										</cfloop>
										<cfif ArrayLen(uWorkspaces) gt 3>
											<cfset extraCount = ArrayLen(uWorkspaces) - 3>
											<cfset extraNames = "">
											<cfloop from="4" to="#ArrayLen(uWorkspaces)#" index="ei">
												<cfset extraCode = uWorkspaces[ei]>
												<cfset extraName = structKeyExists(wsLookup, extraCode) ? wsLookup[extraCode].name : extraCode>
												<cfset extraNames = ListAppend(extraNames, extraName, "; ")>
											</cfloop>
											<span class="badge badge-neutral" style="font-size:0.7rem; padding:0.15rem 0.45rem; cursor:help;" title="Additional assigned: #extraNames#">+#extraCount# more</span>
										</cfif>
									</div>
								</cfif>
							</td>

							<!--- Accessible Groups Badges --->
							<td style="padding:0.9rem 1rem;">
								<div style="display:flex; gap:0.3rem; flex-wrap:wrap;">
									<cfloop array="#accessModules#" index="mItem">
										<cfif mItem eq "Content">
											<span class="badge badge-neutral" style="font-size:0.7rem; padding:0.15rem 0.45rem;" title="Access to Content Management (Pages, Media, Forms)">Content</span>
										<cfelseif mItem eq "HRM">
											<span class="badge badge-purple" style="font-size:0.7rem; padding:0.15rem 0.45rem;" title="Access to HRM (Human Resources Management)">HRM</span>
										<cfelseif mItem eq "PIO">
											<span class="badge badge-info" style="font-size:0.7rem; padding:0.15rem 0.45rem;" title="Access to PIO (Public Information Office)">PIO</span>
										<cfelseif mItem eq "Admin">
											<span class="badge badge-danger" style="font-size:0.7rem; padding:0.15rem 0.45rem;" title="Full Administrator Access">Admin</span>
										</cfif>
									</cfloop>
								</div>
							</td>

							<!--- Security & Last Login Cell --->
							<td style="padding:0.9rem 1rem;">
								<div style="display:flex; flex-direction:column; gap:0.2rem;">
									<div style="display:flex; align-items:center; gap:0.35rem; font-size:0.75rem;">
										<cfif u.two_factor_enabled>
											<span style="color:var(--admin-success);">#svgIcon(name="check-circle", size=13)#</span>
											<span style="color:var(--admin-text-main); font-weight:500;">2FA Active</span>
										<cfelse>
											<span style="color:var(--admin-text-subtle);">#svgIcon(name="clock", size=13)#</span>
											<span style="color:var(--admin-text-muted);">2FA Optional</span>
										</cfif>
									</div>
									<div style="font-size:0.72rem; color:var(--admin-text-subtle);">
										Login: #u.last_login#
									</div>
								</div>
							</td>

							<!--- Status Cell --->
							<td style="padding:0.9rem 1rem;">
								<cfif u.status eq "active">
									<span class="badge badge-success" style="font-weight:600;">Active</span>
								<cfelse>
									<span class="badge badge-neutral" style="font-weight:600; color:var(--admin-text-subtle);">Inactive</span>
								</cfif>
							</td>

							<!--- Actions Cell --->
							<td style="padding:0.9rem 1.25rem; text-align:right;">
								<div style="display:inline-flex; align-items:center; gap:0.35rem;">
									<a href="#urlFor(controller='users', action='edit', params='id=' & u.id)#" class="btn btn-outline-secondary btn-sm" title="Edit User Account" style="padding:0.25rem 0.55rem; height:28px;">
										#svgIcon(name="edit", size=13)#
										<span class="sr-only">Edit</span>
									</a>
									<button type="button" class="btn btn-outline-secondary btn-sm btn-view-perms" data-user-name="#u.first_name# #u.last_name#" data-user-role="#roleLabel#" data-user-badge="#roleBadge#" data-role-code="#u.role_code#" data-user-workspaces="#ArrayToList(uWorkspaces)#" title="View Module Permissions" style="padding:0.25rem 0.55rem; height:28px;">
										#svgIcon(name="security", size=13)#
										<span class="sr-only">Permissions</span>
									</button>
									<form action="#urlFor(controller='users', action='toggleStatus')#" method="post" style="display:inline; margin:0;">
										#csrfMetaTags()#
										<input type="hidden" name="id" value="#u.id#">
										<button type="submit" class="btn btn-outline-secondary btn-sm" title="#(u.status eq 'active' ? 'Deactivate account' : 'Activate account')#" style="padding:0.25rem 0.55rem; height:28px;">
											<cfif u.status eq "active">
												<span style="color:var(--admin-warning);">#svgIcon(name="lock", size=13)#</span>
											<cfelse>
												<span style="color:var(--admin-success);">#svgIcon(name="check", size=13)#</span>
											</cfif>
										</button>
									</form>
								</div>
							</td>
						</tr>
					</cfloop>
				</cfif>
			</tbody>
		</table>
	</div>

	<!--- Card Footer with Role Simulation Quick Switcher --->
	<div class="card-footer" style="padding:1rem 1.5rem; background:var(--admin-bg); border-top:1px solid var(--admin-border); display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem;">
		<div style="display:flex; align-items:center; gap:0.5rem; font-size:0.825rem; color:var(--admin-text-muted);">
			<span>#svgIcon(name="info", size=15)#</span>
			<span>Showing <strong>#ArrayLen(users)#</strong> of <strong>#metrics.total#</strong> registered staff accounts</span>
		</div>
		<cfif isRealAdmin()>
			<div style="display:flex; align-items:center; gap:0.75rem;">
				<span style="font-size:0.8rem; font-weight:600; color:var(--admin-text-main);">Test Active View As:</span>
				<div class="btn-group" style="display:inline-flex; border:1px solid var(--admin-border); border-radius:var(--radius-sm); overflow:hidden; background:var(--admin-surface);">
					<a href="#urlFor(controller='users', action='simulate', params='role=admin')#" class="btn btn-sm #(currentSimulatedRole eq 'admin' ? 'btn-primary' : 'btn-outline-secondary')#" style="border:none; padding:0.25rem 0.65rem; font-size:0.75rem;" title="Simulate Administrator">
						Admin
					</a>
					<a href="#urlFor(controller='users', action='simulate', params='role=pio')#" class="btn btn-sm #(currentSimulatedRole eq 'pio' ? 'btn-primary' : 'btn-outline-secondary')#" style="border:none; padding:0.25rem 0.65rem; font-size:0.75rem;" title="Simulate PIO">
						PIO
					</a>
					<a href="#urlFor(controller='users', action='simulate', params='role=hr')#" class="btn btn-sm #(currentSimulatedRole eq 'hr' ? 'btn-primary' : 'btn-outline-secondary')#" style="border:none; padding:0.25rem 0.65rem; font-size:0.75rem;" title="Simulate HR">
						HR
					</a>
					<a href="#urlFor(controller='users', action='simulate', params='role=author')#" class="btn btn-sm #(currentSimulatedRole eq 'author' ? 'btn-primary' : 'btn-outline-secondary')#" style="border:none; padding:0.25rem 0.65rem; font-size:0.75rem;" title="Simulate Author">
						Author
					</a>
				</div>
			</div>
		</cfif>
	</div>
</div>

<!--- Accessible Add User Modal Dialog --->
<div class="admin-modal-backdrop" id="modalAddUser" role="dialog" aria-modal="true" aria-labelledby="modalAddUserTitle">
	<div class="admin-modal-dialog" style="max-width:680px;">
		<div class="admin-modal-header">
			<h2 class="admin-modal-title" id="modalAddUserTitle">
				#svgIcon(name="users", size=18)#
				<span>Add New User Account</span>
			</h2>
			<button type="button" class="admin-modal-close" id="btnCloseAddUserModal" aria-label="Close Add User Dialog">&times;</button>
		</div>

		<form action="#urlFor(controller='users', action='create')#" method="post" style="display:flex; flex-direction:column; flex:1; min-height:0; overflow:hidden;">
			#authenticityTokenField()#
			<div class="admin-modal-body" style="padding:1.5rem; display:flex; flex-direction:column; gap:1.15rem; flex:1; min-height:0; overflow-y:auto;">
				
				<!--- Personal Name Details --->
				<div style="display:grid; grid-template-columns:1fr 1fr; gap:1rem;">
					<div>
						<label for="new_first_name" class="form-label" style="font-weight:600; font-size:0.825rem;">First Name <span style="color:var(--admin-danger);">*</span></label>
						<input type="text" id="new_first_name" name="first_name" required class="form-control" placeholder="e.g. Jordan" autocomplete="given-name">
					</div>
					<div>
						<label for="new_last_name" class="form-label" style="font-weight:600; font-size:0.825rem;">Last Name <span style="color:var(--admin-danger);">*</span></label>
						<input type="text" id="new_last_name" name="last_name" required class="form-control" placeholder="e.g. Miller" autocomplete="family-name">
					</div>
				</div>

				<!--- Email & Username --->
				<div style="display:grid; grid-template-columns:1.2fr 0.8fr; gap:1rem;">
					<div>
						<label for="new_email" class="form-label" style="font-weight:600; font-size:0.825rem;">Chelan County Email <span style="color:var(--admin-danger);">*</span></label>
						<input type="email" id="new_email" name="email" required class="form-control" placeholder="jordan.miller@chelancounty.gov" autocomplete="email">
					</div>
					<div>
						<label for="new_username" class="form-label" style="font-weight:600; font-size:0.825rem;">Username</label>
						<input type="text" id="new_username" name="username" class="form-control" placeholder="jmiller" autocomplete="username">
					</div>
				</div>

				<!--- Job Title & Phone --->
				<div style="display:grid; grid-template-columns:1.2fr 0.8fr; gap:1rem;">
					<div>
						<label for="new_job_title" class="form-label" style="font-weight:600; font-size:0.825rem;">Job Title</label>
						<input type="text" id="new_job_title" name="job_title" class="form-control" placeholder="e.g. Communications Specialist">
					</div>
					<div>
						<label for="new_phone" class="form-label" style="font-weight:600; font-size:0.825rem;">Office Phone</label>
						<input type="tel" id="new_phone" name="phone" class="form-control" placeholder="(509) 667-6000" autocomplete="tel">
					</div>
				</div>

				<!--- Role Selection Radio Cards: 4 User Groups --->
				<div>
					<label class="form-label" style="font-weight:700; font-size:0.85rem; margin-bottom:0.4rem; display:block;">
						Assign User Group / Role <span style="color:var(--admin-danger);">*</span>
					</label>
					<div class="pg-help" style="margin-bottom:0.65rem;">Select one of the 4 defined role tiers for this staff member:</div>

					<div style="display:grid; grid-template-columns:1fr 1fr; gap:0.75rem;" id="roleSelectorGrid">
						<!--- Admin Option --->
						<label class="role-select-card" style="border:2px solid var(--admin-border); border-radius:var(--radius-md); padding:0.85rem 1rem; display:flex; gap:0.75rem; cursor:pointer; background:var(--admin-surface); transition:all 0.15s ease;">
							<input type="radio" name="role_code" value="admin" style="margin-top:3px;" onchange="updateRoleSummary('admin')">
							<div>
								<div style="display:flex; align-items:center; gap:0.4rem;">
									<span class="badge badge-danger">Admin</span>
									<span style="font-weight:700; font-size:0.85rem; color:var(--admin-text-main);">Administrator</span>
								</div>
								<div style="font-size:0.725rem; color:var(--admin-text-muted); margin-top:0.25rem; line-height:1.35;">
									Administrator will have <strong>everything</strong> (Content, HRM, PIO, Settings, Users).
								</div>
							</div>
						</label>

						<!--- PIO Option --->
						<label class="role-select-card" style="border:2px solid var(--admin-border); border-radius:var(--radius-md); padding:0.85rem 1rem; display:flex; gap:0.75rem; cursor:pointer; background:var(--admin-surface); transition:all 0.15s ease;">
							<input type="radio" name="role_code" value="pio" style="margin-top:3px;" onchange="updateRoleSummary('pio')">
							<div>
								<div style="display:flex; align-items:center; gap:0.4rem;">
									<span class="badge badge-info">PIO</span>
									<span style="font-weight:700; font-size:0.85rem; color:var(--admin-text-main);">PIO</span>
								</div>
								<div style="font-size:0.725rem; color:var(--admin-text-muted); margin-top:0.25rem; line-height:1.35;">
									Will have <strong>Content Management + PIO Group</strong> (Articles, Alerts, Press).
								</div>
							</div>
						</label>

						<!--- HR Option --->
						<label class="role-select-card" style="border:2px solid var(--admin-border); border-radius:var(--radius-md); padding:0.85rem 1rem; display:flex; gap:0.75rem; cursor:pointer; background:var(--admin-surface); transition:all 0.15s ease;">
							<input type="radio" name="role_code" value="hr" style="margin-top:3px;" onchange="updateRoleSummary('hr')">
							<div>
								<div style="display:flex; align-items:center; gap:0.4rem;">
									<span class="badge badge-purple">HR</span>
									<span style="font-weight:700; font-size:0.85rem; color:var(--admin-text-main);">HR</span>
								</div>
								<div style="font-size:0.725rem; color:var(--admin-text-muted); margin-top:0.25rem; line-height:1.35;">
									Update to <strong>Content Management and HRM</strong> (Jobs, Onboarding, Policies).
								</div>
							</div>
						</label>

						<!--- Author Option (Default) --->
						<label class="role-select-card is-selected" style="border:2px solid var(--admin-primary); border-radius:var(--radius-md); padding:0.85rem 1rem; display:flex; gap:0.75rem; cursor:pointer; background:var(--admin-primary-light); transition:all 0.15s ease;">
							<input type="radio" name="role_code" value="author" checked style="margin-top:3px;" onchange="updateRoleSummary('author')">
							<div>
								<div style="display:flex; align-items:center; gap:0.4rem;">
									<span class="badge badge-primary">Author</span>
									<span style="font-weight:700; font-size:0.85rem; color:var(--admin-text-main);">Author</span>
								</div>
								<div style="font-size:0.725rem; color:var(--admin-text-muted); margin-top:0.25rem; line-height:1.35;">
									General web update &bull; Access to <strong>Content Management Group</strong> only.
								</div>
							</div>
						</label>
					</div>
				</div>

				<!--- Assigned Workspaces & Sites (Multi-select) --->
				<div>
					<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:0.4rem;">
						<label class="form-label" style="font-weight:700; font-size:0.85rem; margin-bottom:0;">
							Assigned Workspaces &amp; Sites <span style="color:var(--admin-danger);">*</span>
						</label>
						<span class="badge badge-primary" id="modalWsCount">All Workspaces (Global)</span>
					</div>
					<div class="pg-help" style="margin-bottom:0.5rem;">A user can be assigned to multiple departmental workspaces and public portals.</div>

					<div style="display:flex; justify-content:flex-end; gap:0.35rem; margin-bottom:0.5rem;">
						<button type="button" class="btn btn-outline-secondary btn-sm" style="font-size:0.72rem; padding:0.15rem 0.45rem;" onclick="modalSelectWorkspaces('dept')">All Departments</button>
						<button type="button" class="btn btn-outline-secondary btn-sm" style="font-size:0.72rem; padding:0.15rem 0.45rem;" onclick="modalSelectWorkspaces('site')">All Sites</button>
						<button type="button" class="btn btn-outline-secondary btn-sm" style="font-size:0.72rem; padding:0.15rem 0.45rem;" onclick="modalClearWorkspaces()">Clear</button>
					</div>

					<!--- Master Global Option --->
					<label id="modalWsGlobalLabel" style="border:1.5px solid var(--admin-primary); background:var(--admin-primary-light); border-radius:var(--radius-sm); padding:0.6rem 0.75rem; cursor:pointer; display:flex; gap:0.65rem; align-items:center; margin-bottom:0.75rem; transition:all 0.15s ease;">
						<input type="checkbox" name="workspaces" value="global" id="modal_ws_global" checked onchange="modalToggleGlobal(this)" style="width:16px; height:16px; margin:0;">
						<div style="flex:1;">
							<div style="display:flex; align-items:center; gap:0.4rem;">
								<span style="color:var(--admin-primary);">#svgIcon(name="grid", size=14)#</span>
								<strong style="font-size:0.825rem; color:var(--admin-text-main);">All Workspaces (Global Overview)</strong>
								<span class="badge badge-neutral" style="font-size:0.65rem; padding:0.1rem 0.35rem;">Full Scope</span>
							</div>
							<div style="font-size:0.72rem; color:var(--admin-text-muted); margin-top:1px;">
								Grants user county-wide content editing and form permissions across all departments and websites.
							</div>
						</div>
					</label>

					<!--- Workspace Subsections Container (Scrollable) --->
					<div style="max-height:210px; overflow-y:auto; padding-right:4px; display:flex; flex-direction:column; gap:0.75rem; border:1px solid var(--admin-border-subtle); border-radius:var(--radius-sm); padding:0.65rem; background:var(--admin-bg);">
						<!--- Departments --->
						<div>
							<div style="font-weight:700; font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--admin-text-subtle); margin-bottom:0.4rem; display:flex; align-items:center; gap:0.35rem;">
								#svgIcon(name="building", size=13)#
								<span>Departments &amp; Divisions</span>
							</div>
							<div style="display:grid; grid-template-columns:1fr 1fr; gap:0.45rem;">
								<cfloop array="#workspaces#" index="ws">
									<cfif ws.type eq "dept">
										<label class="modal-ws-item" style="border:1px solid var(--admin-border); background:var(--admin-surface); border-radius:var(--radius-sm); padding:0.45rem 0.6rem; cursor:pointer; display:flex; gap:0.45rem; align-items:center; transition:all 0.15s ease;">
											<input type="checkbox" name="workspaces" value="#ws.code#" class="modal-ws-dept-check" onchange="modalUpdateItemState(this)" style="width:15px; height:15px; margin:0;">
											<span style="color:var(--admin-text-muted);">#svgIcon(name=ws.icon, size=13)#</span>
											<span style="font-weight:600; font-size:0.75rem; color:var(--admin-text-main); flex:1; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">#ws.name#</span>
											<span class="badge #ws.badgeClass#" style="font-size:0.65rem; padding:0.1rem 0.35rem;">#ws.badge#</span>
										</label>
									</cfif>
								</cfloop>
							</div>
						</div>

						<!--- Sites & Portals --->
						<div>
							<div style="font-weight:700; font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--admin-text-subtle); margin-bottom:0.4rem; display:flex; align-items:center; gap:0.35rem;">
								#svgIcon(name="globe", size=13)#
								<span>Public Portals &amp; Web Sites</span>
							</div>
							<div style="display:grid; grid-template-columns:1fr 1fr; gap:0.45rem;">
								<cfloop array="#workspaces#" index="ws">
									<cfif ws.type eq "site">
										<label class="modal-ws-item" style="border:1px solid var(--admin-border); background:var(--admin-surface); border-radius:var(--radius-sm); padding:0.45rem 0.6rem; cursor:pointer; display:flex; gap:0.45rem; align-items:center; transition:all 0.15s ease;">
											<input type="checkbox" name="workspaces" value="#ws.code#" class="modal-ws-site-check" onchange="modalUpdateItemState(this)" style="width:15px; height:15px; margin:0;">
											<span style="color:var(--admin-text-muted);">#svgIcon(name="globe", size=13)#</span>
											<span style="font-weight:600; font-size:0.75rem; color:var(--admin-text-main); flex:1; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">#ws.name#</span>
											<span class="badge #ws.badgeClass#" style="font-size:0.65rem; padding:0.1rem 0.35rem;">#ws.badge#</span>
										</label>
									</cfif>
								</cfloop>
							</div>
						</div>
					</div>
				</div>

				<!--- Live Permission Feedback Box --->
				<div id="rolePermissionFeedback" style="background:var(--admin-bg); border:1px solid var(--admin-border); border-radius:var(--radius-md); padding:0.85rem 1rem; font-size:0.8rem;">
					<div style="font-weight:700; color:var(--admin-text-main); margin-bottom:0.25rem; display:flex; align-items:center; gap:0.4rem;">
						#svgIcon(name="security", size=14)#
						<span id="roleFeedbackTitle">Author Capabilities:</span>
					</div>
					<div id="roleFeedbackDetail" style="color:var(--admin-text-muted); line-height:1.4;">
						Has access to the <strong>Content Management Group</strong> (Pages, Media Library, Form Builder/Forms, Feedback &amp; Inquiries). Does NOT have access to HRM, PIO, or Administration.
					</div>
				</div>

			</div>

			<div class="admin-modal-footer" style="flex-shrink:0; position:sticky; bottom:0; z-index:10; background:var(--admin-bg); border-top:1px solid var(--admin-border-subtle);">
				<button type="button" class="btn btn-secondary" id="btnCancelAddUserModal">Cancel</button>
				<button type="submit" class="btn btn-primary">
					#svgIcon(name="plus", size=15)#
					<span>Create User Account</span>
				</button>
			</div>
		</form>
	</div>
</div>

<!--- Accessible Role Permissions Inspector Modal --->
<div class="admin-modal-backdrop" id="modalRoleInspector" role="dialog" aria-modal="true" aria-labelledby="modalRoleInspectorTitle">
	<div class="admin-modal-dialog" style="max-width:540px;">
		<div class="admin-modal-header">
			<h2 class="admin-modal-title" id="modalRoleInspectorTitle">
				#svgIcon(name="security", size=18)#
				<span>User Permissions Scope</span>
			</h2>
			<button type="button" class="admin-modal-close" id="btnCloseRoleInspector" aria-label="Close Permissions Dialog">&times;</button>
		</div>
		<div class="admin-modal-body" style="padding:1.5rem;">
			<div style="display:flex; align-items:center; gap:0.75rem; margin-bottom:1.25rem;">
				<div style="width:40px; height:40px; border-radius:var(--radius-md); background:var(--admin-primary-light); color:var(--admin-primary); display:flex; align-items:center; justify-content:center;">
					#svgIcon(name="users", size=22)#
				</div>
				<div>
					<h3 id="inspectorUserName" style="margin:0; font-size:1.05rem; font-weight:700; color:var(--admin-text-main);">Sarah Jenkins</h3>
					<div id="inspectorRoleBadge" style="margin-top:0.2rem;">
						<span class="badge badge-danger">Administrator</span>
					</div>
				</div>
			</div>

			<div style="display:flex; flex-direction:column; gap:0.75rem;" id="inspectorModulesList">
				<!--- Dynamic Module Access Rows --->
			</div>

			<!--- Assigned Workspaces & Sites in Inspector --->
			<div style="margin-top:1.25rem; padding-top:1rem; border-top:1px solid var(--admin-border);">
				<div style="font-weight:700; font-size:0.78rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--admin-text-subtle); margin-bottom:0.5rem; display:flex; align-items:center; gap:0.4rem;">
					#svgIcon(name="building", size=14)#
					<span>Assigned Workspaces &amp; Sites</span>
				</div>
				<div id="inspectorWorkspacesList" style="display:flex; gap:0.35rem; flex-wrap:wrap; align-items:center;">
					<!--- Dynamic Workspace Badges --->
				</div>
			</div>
		</div>
		<div class="admin-modal-footer" style="justify-content:space-between;">
			<a href="#urlFor(controller='users', action='roles')#" class="btn btn-outline-secondary btn-sm">Open Full Matrix</a>
			<button type="button" class="btn btn-secondary btn-sm" id="btnDismissRoleInspector">Close</button>
		</div>
	</div>
</div>
</cfoutput>

<script>
document.addEventListener("DOMContentLoaded", function() {
	// Modal Controls
	const modalAdd = document.getElementById("modalAddUser");
	const btnOpenAdd = document.getElementById("btnOpenAddUserModal");
	const btnCloseAdd = document.getElementById("btnCloseAddUserModal");
	const btnCancelAdd = document.getElementById("btnCancelAddUserModal");

	if (btnOpenAdd && modalAdd) {
		btnOpenAdd.addEventListener("click", () => modalAdd.classList.add("open"));
	}
	if (btnCloseAdd && modalAdd) {
		btnCloseAdd.addEventListener("click", () => modalAdd.classList.remove("open"));
	}
	if (btnCancelAdd && modalAdd) {
		btnCancelAdd.addEventListener("click", () => modalAdd.classList.remove("open"));
	}

	// Modal Backdrop Close & Escape
	[modalAdd, document.getElementById("modalRoleInspector")].forEach(m => {
		if (m) {
			m.addEventListener("click", (e) => {
				if (e.target === m) m.classList.remove("open");
			});
		}
	});

	document.addEventListener("keydown", (e) => {
		if (e.key === "Escape") {
			if (modalAdd) modalAdd.classList.remove("open");
			const inspector = document.getElementById("modalRoleInspector");
			if (inspector) inspector.classList.remove("open");
		}
	});

	// Role Permission Inspector Dialog
	const inspectorModal = document.getElementById("modalRoleInspector");
	const btnCloseInspector = document.getElementById("btnCloseRoleInspector");
	const btnDismissInspector = document.getElementById("btnDismissRoleInspector");
	if (btnCloseInspector && inspectorModal) btnCloseInspector.addEventListener("click", () => inspectorModal.classList.remove("open"));
	if (btnDismissInspector && inspectorModal) btnDismissInspector.addEventListener("click", () => inspectorModal.classList.remove("open"));

	const roleCapabilities = {
		"admin": {
			title: "Administrator (Has Everything)",
			modules: [
				{ name: "Content Management Group", access: "Full Control (Pages, Media, Forms, Feedback)", granted: true },
				{ name: "HRM Group (Human Resources)", access: "Full Control (Jobs, Onboarding, Personnel)", granted: true },
				{ name: "PIO Group (Public Information)", access: "Full Control (Articles, Press, Urgent Alerts)", granted: true },
				{ name: "Administration & Security", access: "Full Control (Users, Roles, Navigation, Settings)", granted: true }
			]
		},
		"pio": {
			title: "PIO (Public Information Officer)",
			modules: [
				{ name: "Content Management Group", access: "Full Control (Pages, Media, Forms, Feedback)", granted: true },
				{ name: "PIO Group (Public Information)", access: "Full Control (Articles, Press, Urgent Alerts, PRR)", granted: true },
				{ name: "HRM Group (Human Resources)", access: "Restricted / No Access", granted: false },
				{ name: "Administration & Security", access: "Restricted / No Access", granted: false }
			]
		},
		"hr": {
			title: "HR (Human Resources)",
			modules: [
				{ name: "Content Management Group", access: "Full Control (Pages, Media, Forms, Feedback)", granted: true },
				{ name: "HRM Group (Human Resources)", access: "Full Control (Jobs, Onboarding, Policies, Forms)", granted: true },
				{ name: "PIO Group (Public Information)", access: "Restricted / No Access", granted: false },
				{ name: "Administration & Security", access: "Restricted / No Access", granted: false }
			]
		},
		"author": {
			title: "Author (General Web Update)",
			modules: [
				{ name: "Content Management Group", access: "Full Control (Pages, Media, Forms, Feedback)", granted: true },
				{ name: "HRM Group (Human Resources)", access: "Restricted / No Access", granted: false },
				{ name: "PIO Group (Public Information)", access: "Restricted / No Access", granted: false },
				{ name: "Administration & Security", access: "Restricted / No Access", granted: false }
			]
		}
	};

	const workspacesData = <cfoutput>#serializeJSON(workspaces)#</cfoutput>;
	const wsDataMap = {};
	if (Array.isArray(workspacesData)) {
		workspacesData.forEach(w => { wsDataMap[w.code] = w; });
	}

	document.querySelectorAll(".btn-view-perms").forEach(btn => {
		btn.addEventListener("click", function() {
			const uName = this.getAttribute("data-user-name");
			const uRole = this.getAttribute("data-user-role");
			const uBadge = this.getAttribute("data-user-badge");
			const roleCode = this.getAttribute("data-role-code") || "author";
			const wsAttr = this.getAttribute("data-user-workspaces") || "";
			const userWorkspaces = wsAttr.split(",").map(s => s.trim()).filter(Boolean);

			document.getElementById("inspectorUserName").textContent = uName;
			document.getElementById("inspectorRoleBadge").innerHTML = `<span class="badge ${uBadge}">${uRole}</span>`;

			const listCont = document.getElementById("inspectorModulesList");
			listCont.innerHTML = "";

			const cap = roleCapabilities[roleCode] || roleCapabilities["author"];
			cap.modules.forEach(m => {
				const row = document.createElement("div");
				row.style.cssText = "display:flex; justify-content:space-between; align-items:center; padding:0.65rem 0.85rem; border-radius:var(--radius-sm); border:1px solid " + (m.granted ? "var(--admin-border-subtle)" : "var(--admin-border)") + "; background:" + (m.granted ? "var(--admin-surface)" : "var(--admin-bg)") + ";";
				row.innerHTML = `
					<div>
						<div style="font-weight:600; font-size:0.825rem; color:${m.granted ? 'var(--admin-text-main)' : 'var(--admin-text-muted)'};">${m.name}</div>
						<div style="font-size:0.73rem; color:${m.granted ? 'var(--admin-text-subtle)' : 'var(--admin-text-subtle)'};">${m.access}</div>
					</div>
					<span class="badge ${m.granted ? 'badge-success' : 'badge-neutral'}" style="font-size:0.72rem;">${m.granted ? 'Granted' : 'Locked'}</span>
				`;
				listCont.appendChild(row);
			});

			const wsListCont = document.getElementById("inspectorWorkspacesList");
			if (wsListCont) {
				wsListCont.innerHTML = "";
				if (userWorkspaces.includes("global") || userWorkspaces.length === 0) {
					wsListCont.innerHTML = '<span class="badge badge-neutral" style="font-size:0.75rem; padding:0.25rem 0.55rem; font-weight:600;">Global Overview (All 16 Workspaces &amp; Portals)</span>';
				} else {
					userWorkspaces.forEach(code => {
						const meta = wsDataMap[code] || { name: code, badge: code, badgeClass: "badge-neutral" };
						const chip = document.createElement("span");
						chip.className = `badge ${meta.badgeClass}`;
						chip.style.fontSize = "0.72rem";
						chip.style.padding = "0.2rem 0.5rem";
						chip.textContent = meta.name;
						wsListCont.appendChild(chip);
					});
				}
			}

			if (inspectorModal) inspectorModal.classList.add("open");
		});
	});
});

function updateRoleSummary(role) {
	const cards = document.querySelectorAll("#roleSelectorGrid .role-select-card");
	cards.forEach(c => {
		const rad = c.querySelector("input[type='radio']");
		if (rad && rad.value === role) {
			c.style.borderColor = "var(--admin-primary)";
			c.style.background = "var(--admin-primary-light)";
		} else {
			c.style.borderColor = "var(--admin-border)";
			c.style.background = "var(--admin-surface)";
		}
	});

	const titleEl = document.getElementById("roleFeedbackTitle");
	const detailEl = document.getElementById("roleFeedbackDetail");

	if (role === "admin") {
		titleEl.textContent = "Administrator Capabilities:";
		detailEl.innerHTML = "Administrator will have <strong>everything</strong>: unrestricted access to Content Management, HRM Group, PIO Group, Administration, Navigation Menus, and System Settings.";
	} else if (role === "pio") {
		titleEl.textContent = "PIO (Public Information Officer) Capabilities:";
		detailEl.innerHTML = "Access to <strong>Content Management Group</strong> (Pages, Media, Forms) + <strong>PIO Group</strong> (Articles &amp; Posts, Press Releases, Media Alerts, PRR). Locked out of HRM and Administration.";
	} else if (role === "hr") {
		titleEl.textContent = "HR (Human Resources) Capabilities:";
		detailEl.innerHTML = "Access to <strong>Content Management Group</strong> (Pages, Media, Forms) + <strong>HRM Group</strong> (Job Postings, Onboarding, Personnel Policies, HRM Inquiries). Locked out of PIO and Administration.";
	} else {
		titleEl.textContent = "Author Capabilities:";
		detailEl.innerHTML = "Author is general web update &bull; Access to <strong>Content Management Group</strong> only (Pages, Media Library, Form Builder/Forms, Feedback &amp; Inquiries). Locked out of HRM, PIO, and Administration.";
	}
}

function modalToggleGlobal(globalCheckbox) {
	const isChecked = globalCheckbox.checked;
	const globalLabel = document.getElementById("modalWsGlobalLabel");
	const deptChecks = document.querySelectorAll(".modal-ws-dept-check");
	const siteChecks = document.querySelectorAll(".modal-ws-site-check");

	if (isChecked) {
		if (globalLabel) {
			globalLabel.style.borderColor = "var(--admin-primary)";
			globalLabel.style.background = "var(--admin-primary-light)";
		}
		deptChecks.forEach(cb => {
			cb.checked = false;
			const parent = cb.closest(".modal-ws-item");
			if (parent) {
				parent.style.borderColor = "var(--admin-border)";
				parent.style.background = "var(--admin-surface)";
			}
		});
		siteChecks.forEach(cb => {
			cb.checked = false;
			const parent = cb.closest(".modal-ws-item");
			if (parent) {
				parent.style.borderColor = "var(--admin-border)";
				parent.style.background = "var(--admin-surface)";
			}
		});
	} else {
		if (globalLabel) {
			globalLabel.style.borderColor = "var(--admin-border)";
			globalLabel.style.background = "var(--admin-bg)";
		}
	}
	modalUpdateCount();
}

function modalUpdateItemState(checkbox) {
	const globalCb = document.getElementById("modal_ws_global");
	const globalLabel = document.getElementById("modalWsGlobalLabel");
	const parent = checkbox.closest(".modal-ws-item");

	if (checkbox.checked) {
		if (parent) {
			parent.style.borderColor = "var(--admin-primary)";
			parent.style.background = "var(--admin-primary-light)";
		}
		if (globalCb && globalCb.checked) {
			globalCb.checked = false;
			if (globalLabel) {
				globalLabel.style.borderColor = "var(--admin-border)";
				globalLabel.style.background = "var(--admin-bg)";
			}
		}
	} else {
		if (parent) {
			parent.style.borderColor = "var(--admin-border)";
			parent.style.background = "var(--admin-surface)";
		}
	}
	modalUpdateCount();
}

function modalSelectWorkspaces(type) {
	const globalCb = document.getElementById("modal_ws_global");
	const globalLabel = document.getElementById("modalWsGlobalLabel");
	if (globalCb) {
		globalCb.checked = false;
		if (globalLabel) {
			globalLabel.style.borderColor = "var(--admin-border)";
			globalLabel.style.background = "var(--admin-bg)";
		}
	}

	const selector = type === 'dept' ? '.modal-ws-dept-check' : '.modal-ws-site-check';
	document.querySelectorAll(selector).forEach(cb => {
		cb.checked = true;
		const parent = cb.closest(".modal-ws-item");
		if (parent) {
			parent.style.borderColor = "var(--admin-primary)";
			parent.style.background = "var(--admin-primary-light)";
		}
	});
	modalUpdateCount();
}

function modalClearWorkspaces() {
	const globalCb = document.getElementById("modal_ws_global");
	const globalLabel = document.getElementById("modalWsGlobalLabel");
	if (globalCb) {
		globalCb.checked = false;
		if (globalLabel) {
			globalLabel.style.borderColor = "var(--admin-border)";
			globalLabel.style.background = "var(--admin-bg)";
		}
	}
	document.querySelectorAll(".modal-ws-dept-check, .modal-ws-site-check").forEach(cb => {
		cb.checked = false;
		const parent = cb.closest(".modal-ws-item");
		if (parent) {
			parent.style.borderColor = "var(--admin-border)";
			parent.style.background = "var(--admin-surface)";
		}
	});
	modalUpdateCount();
}

function modalUpdateCount() {
	const countBadge = document.getElementById("modalWsCount");
	if (!countBadge) return;
	const globalCb = document.getElementById("modal_ws_global");
	if (globalCb && globalCb.checked) {
		countBadge.textContent = "All Workspaces (Global)";
		return;
	}
	const checked = document.querySelectorAll(".modal-ws-dept-check:checked, .modal-ws-site-check:checked");
	countBadge.textContent = checked.length === 0 ? "None Selected" : `${checked.length} Selected`;
}
</script>
