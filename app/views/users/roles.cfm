<cfset pageTitle = "Roles & Permissions Matrix">
<cfparam name="currentSimulatedRole" default="admin">
<cfparam name="roles" default="#[]#">
<cfparam name="allUsers" default="#[]#">
<cfparam name="capabilities" default="#[]#">
<cfoutput>
<div class="page-header">
	<div>
		<h1 class="page-title" style="margin-bottom:0.25rem;">Roles &amp; Permissions Matrix</h1>
		<nav aria-label="Breadcrumb">
			<ol class="breadcrumb" style="margin-top:0.25rem;">
				<li class="breadcrumb-item"><a href="#urlFor(controller='main', action='index')#">#svgIcon(name="dashboard", size=14)# Home</a></li>
				<li class="breadcrumb-item">Administration</li>
				<li class="breadcrumb-item"><a href="#urlFor(controller='users', action='index')#">Users &amp; Roles</a></li>
				<li class="breadcrumb-item active" aria-current="page">Roles &amp; Permissions</li>
			</ol>
		</nav>
	</div>
	<div class="page-header-actions" style="display:flex; gap:0.6rem; align-items:center;">
		<a href="#urlFor(controller='users', action='index')#" class="btn btn-secondary btn-sm">
			#svgIcon(name="users", size=15)#
			<span>Staff User Directory</span>
		</a>
		<a href="#urlFor(controller='users', action='new')#" class="btn btn-primary btn-sm">
			#svgIcon(name="plus", size=15)#
			<span>Add New User</span>
		</a>
	</div>
</div>

<!--- Role Simulation Active Notification Banner (Exclusively for Administrators) --->
<cfif currentSimulatedRole neq "admin" and isRealAdmin()>
	<div class="alert alert-info" style="margin-bottom:1.25rem; display:flex; justify-content:space-between; align-items:center; border-left:4px solid var(--admin-info); background:var(--admin-info-light); padding:0.9rem 1.25rem; border-radius:var(--radius-md);">
		<div style="display:flex; align-items:center; gap:0.75rem;">
			<span style="color:var(--admin-info);">#svgIcon(name="security", size=20)#</span>
			<div>
				<strong style="color:var(--admin-text-main); font-size:0.875rem;">Active Persona Simulator:</strong>
				<span style="font-size:0.825rem; color:var(--admin-text-main); margin-left:0.25rem;">
					Currently previewing CMS Admin with 
					<cfif currentSimulatedRole eq "author">
						<span class="badge badge-primary">Author</span> (General web update - Content Management group only).
					<cfelseif currentSimulatedRole eq "hr">
						<span class="badge badge-purple">HR</span> (Content Management and HRM group).
					<cfelseif currentSimulatedRole eq "pio">
						<span class="badge badge-info">PIO</span> (Content Management and PIO group).
					</cfif>
				</span>
			</div>
		</div>
		<a href="#urlFor(controller='users', action='simulate', params='role=admin')#" class="btn btn-primary btn-sm" style="padding:0.3rem 0.75rem; font-size:0.75rem;">
			Reset to Administrator
		</a>
	</div>
</cfif>

<!--- 4 Core User Group Cards --->
<div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(260px, 1fr)); gap:1.15rem; margin-bottom:1.5rem;">
	<cfloop array="#roles#" index="r">
		<div class="admin-card" style="margin-bottom:0; display:flex; flex-direction:column; justify-content:space-between; border-top:4px solid #r.colorHex#;">
			<div class="card-body" style="padding:1.25rem;">
				<div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:0.75rem;">
					<div>
						<span class="badge #r.badgeClass#" style="font-size:0.8rem; font-weight:700; padding:0.3rem 0.65rem;">
							#r.name#
						</span>
						<div style="font-size:0.75rem; font-weight:600; color:var(--admin-text-subtle); margin-top:0.35rem; text-transform:uppercase; letter-spacing:0.04em;">
							#r.scope#
						</div>
					</div>
					<div style="width:36px; height:36px; border-radius:var(--radius-md); background:var(--admin-bg); color:#r.colorHex#; display:flex; align-items:center; justify-content:center;">
						#svgIcon(name=r.icon, size=18)#
					</div>
				</div>

				<p style="font-size:0.825rem; color:var(--admin-text-main); line-height:1.45; margin-bottom:1rem;">
					#r.description#
				</p>

				<div style="background:var(--admin-bg); border-radius:var(--radius-sm); padding:0.65rem 0.85rem; border:1px solid var(--admin-border-subtle); margin-bottom:1rem;">
					<div style="font-size:0.72rem; text-transform:uppercase; letter-spacing:0.05em; font-weight:700; color:var(--admin-text-subtle); margin-bottom:0.35rem;">
						Accessible Module Groups:
					</div>
					<div style="display:flex; flex-wrap:wrap; gap:0.3rem;">
						<cfloop array="#r.modules#" index="mItem">
							<span class="badge badge-neutral" style="font-size:0.7rem; padding:0.15rem 0.5rem; background:var(--admin-surface); border:1px solid var(--admin-border);">
								#mItem#
							</span>
						</cfloop>
					</div>
				</div>
			</div>

			<div class="card-footer" style="padding:0.85rem 1.25rem; background:var(--admin-bg); border-top:1px solid var(--admin-border); display:flex; justify-content:space-between; align-items:center;">
				<span style="font-size:0.78rem; color:var(--admin-text-muted); font-weight:600;">
					#r.userCount# Assigned Staff
				</span>
				<cfif isRealAdmin()>
					<a href="#urlFor(controller='users', action='simulate', params='role=' & r.code)#" class="btn btn-sm #(currentSimulatedRole eq r.code ? 'btn-primary' : 'btn-outline-secondary')#" style="font-size:0.75rem; padding:0.25rem 0.6rem;" title="Simulate this role in the CMS navigation">
						#(currentSimulatedRole eq r.code ? 'Active View' : 'Simulate Role')#
					</a>
				<cfelse>
					<span class="badge #(currentSimulatedRole eq r.code ? 'badge-primary' : 'badge-neutral')#" style="font-size:0.75rem; padding:0.25rem 0.6rem;">
						#(currentSimulatedRole eq r.code ? 'Active Group' : 'Group Defined')#
					</span>
				</cfif>
			</div>
		</div>
	</cfloop>
</div>

<!--- Comprehensive Capability & Permissions Matrix --->
<div class="admin-card">
	<div class="card-header" style="padding:1.15rem 1.5rem; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem;">
		<div>
			<h2 style="font-size:1.05rem; font-weight:700; margin:0; color:var(--admin-text-main); display:flex; align-items:center; gap:0.5rem;">
				#svgIcon(name="security", size=18)#
				<span>Role Capabilities Matrix</span>
			</h2>
			<div style="font-size:0.78rem; color:var(--admin-text-muted); margin-top:0.2rem;">
				Granular functional module permissions across the 4 Chelan County CMS user groups.
			</div>
		</div>
		<div style="display:flex; align-items:center; gap:0.75rem; font-size:0.75rem;">
			<div style="display:flex; align-items:center; gap:0.35rem;">
				<span style="color:var(--admin-success); font-weight:bold;">#svgIcon(name="check-circle", size=14)#</span>
				<span style="color:var(--admin-text-main); font-weight:600;">Full Access</span>
			</div>
			<div style="display:flex; align-items:center; gap:0.35rem;">
				<span style="color:var(--admin-text-subtle);">#svgIcon(name="lock", size=14)#</span>
				<span style="color:var(--admin-text-muted);">Restricted / No Access</span>
			</div>
		</div>
	</div>

	<div class="card-body" style="padding:0; overflow-x:auto;">
		<table class="admin-table" style="width:100%; border-collapse:collapse; margin:0;" aria-label="Roles and Permissions Matrix">
			<thead>
				<tr style="background:var(--admin-bg); border-bottom:2px solid var(--admin-border); text-align:left;">
					<th scope="col" style="padding:0.9rem 1.25rem; font-weight:700; color:var(--admin-text-subtle); font-size:0.78rem; text-transform:uppercase; letter-spacing:0.05em; width:40%;">
						CMS Module &amp; Capability
					</th>
					<th scope="col" style="padding:0.9rem 1rem; font-weight:700; font-size:0.78rem; text-align:center; width:15%;">
						<span class="badge badge-primary" style="font-size:0.78rem; padding:0.25rem 0.6rem;">Author</span>
						<div style="font-size:0.68rem; color:var(--admin-text-muted); font-weight:normal; margin-top:0.2rem;">General Web</div>
					</th>
					<th scope="col" style="padding:0.9rem 1rem; font-weight:700; font-size:0.78rem; text-align:center; width:15%;">
						<span class="badge badge-purple" style="font-size:0.78rem; padding:0.25rem 0.6rem;">HR</span>
						<div style="font-size:0.68rem; color:var(--admin-text-muted); font-weight:normal; margin-top:0.2rem;">Content + HRM</div>
					</th>
					<th scope="col" style="padding:0.9rem 1rem; font-weight:700; font-size:0.78rem; text-align:center; width:15%;">
						<span class="badge badge-info" style="font-size:0.78rem; padding:0.25rem 0.6rem;">PIO</span>
						<div style="font-size:0.68rem; color:var(--admin-text-muted); font-weight:normal; margin-top:0.2rem;">Content + PIO</div>
					</th>
					<th scope="col" style="padding:0.9rem 1rem; font-weight:700; font-size:0.78rem; text-align:center; width:15%;">
						<span class="badge badge-danger" style="font-size:0.78rem; padding:0.25rem 0.6rem;">Admin</span>
						<div style="font-size:0.68rem; color:var(--admin-text-muted); font-weight:normal; margin-top:0.2rem;">Has Everything</div>
					</th>
				</tr>
			</thead>
			<tbody>
				<cfloop array="#capabilities#" index="group">
					<!--- Category Header Row --->
					<tr style="background:var(--admin-surface-hover); border-top:1px solid var(--admin-border); border-bottom:1px solid var(--admin-border);">
						<td colspan="5" style="padding:0.75rem 1.25rem;">
							<div style="font-weight:700; color:var(--admin-text-main); font-size:0.875rem;">
								#group.category#
							</div>
							<div style="font-size:0.74rem; color:var(--admin-text-muted);">
								#group.description#
							</div>
						</td>
					</tr>

					<!--- Capability Items Rows --->
					<cfloop array="#group.items#" index="item">
						<tr style="border-bottom:1px solid var(--admin-border-subtle); transition:background 0.15s ease;">
							<td style="padding:0.85rem 1.25rem;">
								<div style="font-weight:600; font-size:0.85rem; color:var(--admin-text-main);">
									#item.feature#
								</div>
								<div style="font-size:0.74rem; color:var(--admin-text-muted); margin-top:1px;">
									#item.detail#
								</div>
							</td>

							<!--- Author Cell --->
							<td style="padding:0.85rem 1rem; text-align:center;">
								<cfif item.author eq "Full Access" or item.author eq "Assigned Workspaces">
									<div style="display:inline-flex; align-items:center; gap:0.35rem; color:var(--admin-success); font-weight:600; font-size:0.78rem;">
										#svgIcon(name="check-circle", size=16)#
										<span>#item.author#</span>
									</div>
								<cfelse>
									<div style="display:inline-flex; align-items:center; gap:0.35rem; color:var(--admin-text-subtle); font-size:0.78rem;">
										#svgIcon(name="lock", size=14)#
										<span>Restricted</span>
									</div>
								</cfif>
							</td>

							<!--- HR Cell --->
							<td style="padding:0.85rem 1rem; text-align:center;">
								<cfif item.hr eq "Full Access">
									<div style="display:inline-flex; align-items:center; gap:0.35rem; color:var(--admin-success); font-weight:600; font-size:0.78rem;">
										#svgIcon(name="check-circle", size=16)#
										<span>Full Access</span>
									</div>
								<cfelse>
									<div style="display:inline-flex; align-items:center; gap:0.35rem; color:var(--admin-text-subtle); font-size:0.78rem;">
										#svgIcon(name="lock", size=14)#
										<span>Restricted</span>
									</div>
								</cfif>
							</td>

							<!--- PIO Cell --->
							<td style="padding:0.85rem 1rem; text-align:center;">
								<cfif item.pio eq "Full Access">
									<div style="display:inline-flex; align-items:center; gap:0.35rem; color:var(--admin-success); font-weight:600; font-size:0.78rem;">
										#svgIcon(name="check-circle", size=16)#
										<span>Full Access</span>
									</div>
								<cfelse>
									<div style="display:inline-flex; align-items:center; gap:0.35rem; color:var(--admin-text-subtle); font-size:0.78rem;">
										#svgIcon(name="lock", size=14)#
										<span>Restricted</span>
									</div>
								</cfif>
							</td>

							<!--- Admin Cell --->
							<td style="padding:0.85rem 1rem; text-align:center;">
								<div style="display:inline-flex; align-items:center; gap:0.35rem; color:var(--admin-success); font-weight:700; font-size:0.78rem;">
									#svgIcon(name="check-circle", size=16)#
									<span>Full Access</span>
								</div>
							</td>
						</tr>
					</cfloop>
				</cfloop>
			</tbody>
		</table>
	</div>

	<div class="card-footer" style="padding:1rem 1.5rem; background:var(--admin-bg); border-top:1px solid var(--admin-border); display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem;">
		<div style="font-size:0.8rem; color:var(--admin-text-muted);">
			Chelan County Departmental RBAC Model &bull; Security Level: <strong>Tier-4 Granular Scope</strong>
		</div>
		<a href="#urlFor(controller='users', action='new')#" class="btn btn-primary btn-sm">
			#svgIcon(name="plus", size=14)#
			<span>Assign Staff to a User Group</span>
		</a>
	</div>
</div>
</cfoutput>
