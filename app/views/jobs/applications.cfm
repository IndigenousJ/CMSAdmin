<cfset pageTitle = "Candidate Applications & Intake">
<cfoutput>
<div class="page-header">
	<div>
		<h1 class="page-title" style="margin-bottom:0;">Candidate Applications</h1>
		<nav aria-label="Breadcrumb">
			<ol class="breadcrumb" style="margin-top:0.35rem;">
				<li class="breadcrumb-item"><a href="#urlFor(controller='main', action='index')#">#svgIcon(name="dashboard", size=14)# Home</a></li>
				<li class="breadcrumb-item"><a href="#urlFor(controller='jobs', action='index')#">Job Postings</a></li>
				<li class="breadcrumb-item active" aria-current="page">Applications</li>
			</ol>
		</nav>
	</div>

	<div class="page-actions" style="display:flex; gap:0.5rem; align-items:center;">
		<a href="#urlFor(controller='jobs', action='index')#" class="btn btn-outline btn-sm">
			#svgIcon(name="arrow-left", size=14)#
			<span>Back to Job Openings</span>
		</a>
		<a href="#urlFor(controller='jobs', action='exportCsv', params='jobId=' & variables.selectedJobId & '&status=' & URLEncodedFormat(variables.selectedStatus))#" class="btn btn-secondary btn-sm">
			#svgIcon(name="download", size=14)#
			<span>Export CSV</span>
		</a>
	</div>
</div>

<!--- Metric Cards for Applications (Standard stat-grid matching pages/index.cfm) --->
<div class="stat-grid" style="margin-bottom:1.5rem;">
	<div class="stat-card">
		<div class="stat-info">
			<span class="stat-label">Total Applicants</span>
			<span class="stat-value">#variables.appMetrics.total#</span>
		</div>
		<div class="stat-icon-wrapper stat-icon-primary" aria-hidden="true">#svgIcon(name="users", size=24)#</div>
	</div>

	<div class="stat-card">
		<div class="stat-info">
			<span class="stat-label">New / Unreviewed</span>
			<span class="stat-value">#variables.appMetrics.new_apps#</span>
		</div>
		<div class="stat-icon-wrapper stat-icon-info" aria-hidden="true">#svgIcon(name="clock", size=24)#</div>
	</div>

	<div class="stat-card">
		<div class="stat-info">
			<span class="stat-label">Interview Stage</span>
			<span class="stat-value">#variables.appMetrics.interview#</span>
		</div>
		<div class="stat-icon-wrapper stat-icon-purple" aria-hidden="true">#svgIcon(name="briefcase", size=24)#</div>
	</div>

	<div class="stat-card">
		<div class="stat-info">
			<span class="stat-label">Hired / Selected</span>
			<span class="stat-value">#variables.appMetrics.hired#</span>
		</div>
		<div class="stat-icon-wrapper stat-icon-success" aria-hidden="true">#svgIcon(name="check-circle", size=24)#</div>
	</div>
</div>

<!--- Standard Filter & Search Bar (admin-card matching pages/index.cfm & jobs/index.cfm) --->
<div class="admin-card" style="margin-bottom:1.25rem;">
	<div class="card-body" style="padding:1rem 1.25rem;">
		<form method="get" action="#urlFor(controller='jobs', action='applications')#" id="appsFilterForm" style="display:flex; align-items:flex-end; flex-wrap:wrap; gap:0.85rem; margin:0;">
			
			<!--- Search Input --->
			<div style="flex:1 1 240px; max-width:340px;">
				<label for="appsSearch" class="form-label" style="font-size:0.775rem;">Search applicants</label>
				<input type="search" id="appsSearch" name="q" class="form-control" placeholder="Candidate name, email, phone..." value="#encodeForHTML(variables.searchQuery)#" style="width:100%; padding:0.5rem 0.75rem; font-size:0.85rem;">
			</div>

			<!--- Status Filter --->
			<div>
				<label for="appsStatus" class="form-label" style="font-size:0.775rem;">Application Status</label>
				<select id="appsStatus" name="status" class="form-control" style="padding:0.5rem 0.75rem; font-size:0.85rem;" onchange="this.form.submit()">
					<option value="All" <cfif variables.selectedStatus eq "All">selected</cfif>>All Candidates (#variables.appMetrics.total#)</option>
					<option value="New" <cfif variables.selectedStatus eq "New">selected</cfif>>New (#variables.appMetrics.new_apps#)</option>
					<option value="Under Review" <cfif variables.selectedStatus eq "Under Review">selected</cfif>>Under Review (#variables.appMetrics.reviewing#)</option>
					<option value="Interview" <cfif variables.selectedStatus eq "Interview">selected</cfif>>Interview (#variables.appMetrics.interview#)</option>
					<option value="Hired" <cfif variables.selectedStatus eq "Hired">selected</cfif>>Hired (#variables.appMetrics.hired#)</option>
				</select>
			</div>

			<!--- Position Filter --->
			<div style="flex:1 1 240px; max-width:320px;">
				<label for="appsJobId" class="form-label" style="font-size:0.775rem;">Position Opening</label>
				<select id="appsJobId" name="jobId" class="form-control" style="width:100%; padding:0.5rem 0.75rem; font-size:0.85rem;" onchange="this.form.submit()">
					<option value="0">All Job Openings</option>
					<cfloop query="variables.qJobList">
						<option value="#JobID#" <cfif variables.selectedJobId eq JobID>selected</cfif>>
							#encodeForHTML(Title)#<cfif len(trim(ClassCode))> (#encodeForHTML(ClassCode)#)</cfif>
						</option>
					</cfloop>
				</select>
			</div>

			<button type="submit" class="btn btn-secondary btn-sm" style="padding:0.5rem 0.85rem;">Filter</button>
			<cfif len(variables.searchQuery) or variables.selectedJobId gt 0 or variables.selectedStatus neq "All">
				<a href="#urlFor(controller='jobs', action='applications')#" class="btn btn-outline btn-sm" style="padding:0.5rem 0.85rem;">Reset</a>
			</cfif>

			<!--- Live Count on Right --->
			<div id="appsCount" role="status" aria-live="polite" style="margin-left:auto; font-size:0.8rem; color:var(--admin-text-muted); padding-bottom:0.55rem;">
				Showing #variables.qApps.recordCount# of #variables.appMetrics.total# candidates
			</div>
		</form>
	</div>
</div>

<!--- Candidates Table Card (admin-card with admin-table matching pages/index.cfm) --->
<div class="admin-card" id="applicationsTableCard">
	<div class="table-responsive">
		<table class="admin-table" id="applicationsTable" aria-label="Candidate applications">
			<thead>
				<tr>
					<th scope="col" style="width:56px;"><span class="sr-only">Actions</span></th>
					<th scope="col">Candidate Name &amp; Contact</th>
					<th scope="col">Position Applied For</th>
					<th scope="col" style="width:180px;">Qualifications</th>
					<th scope="col" style="width:140px;">Education</th>
					<th scope="col" style="width:110px;">Applied Date</th>
					<th scope="col" style="width:110px; text-align:center;">Status</th>
					<th scope="col" style="width:90px; text-align:center;">Rating</th>
				</tr>
			</thead>
			<tbody>
				<cfif variables.qApps.recordCount eq 0>
					<tr>
						<td colspan="8" style="text-align:center; padding:3.5rem 1.5rem; color:var(--admin-text-muted);">
							<div style="font-size:1.1rem; font-weight:600; color:var(--admin-text-main); margin-bottom:0.5rem;">No Applications Found</div>
							<p style="margin:0; font-size:0.875rem;">No candidates match your current filter selection.</p>
						</td>
					</tr>
				<cfelse>
					<cfloop query="variables.qApps">
						<tr class="app-row">
							<!--- Standard Action Icon (first column, matching pages/index.cfm) --->
							<td>
								<a href="#urlFor(controller='jobs', action='application', params='id=' & ApplicationID)#" class="btn btn-sm btn-icon-only btn-outline" aria-label="Review #EncodeForHTMLAttribute(FirstName & ' ' & LastName)#" title="Review Dossier">
									#svgIcon(name="eye", size=14)#
								</a>
							</td>

							<!--- Candidate Name & Contact --->
							<td>
								<div style="font-weight:600; color:var(--admin-text-main);">
									<a href="#urlFor(controller='jobs', action='application', params='id=' & ApplicationID)#" style="color:inherit; text-decoration:none;">
										#encodeForHTML(FirstName)# <cfif len(MiddleName)>#encodeForHTML(MiddleName)# </cfif>#encodeForHTML(LastName)#
									</a>
								</div>
								<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:2px; display:flex; flex-direction:column; gap:0.15rem;">
									<div>#encodeForHTML(Email)#</div>
									<div>#encodeForHTML(Phone)# &bull; #encodeForHTML(City)#, #encodeForHTML(State)#</div>
								</div>
							</td>

							<!--- Position Applied For --->
							<td>
								<div style="font-weight:600; color:var(--admin-text-main);">
									#encodeForHTML(Position)#
								</div>
								<cfif len(job_code)>
									<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:2px;">
										Req: <code style="color:var(--admin-primary);">#encodeForHTML(job_code)#</code>
										<cfif len(department_name)> &bull; #encodeForHTML(department_name)#</cfif>
									</div>
								<cfelse>
									<span class="badge badge-neutral" style="font-size:0.7rem;">General Intake</span>
								</cfif>
							</td>

							<!--- Qualifications Badges --->
							<td>
								<div style="display:flex; flex-wrap:wrap; gap:0.3rem;">
									<cfif hasCDL>
										<span class="badge badge-warning" style="font-size:0.7rem;" title="Commercial Driver's License">
											#svgIcon(name="truck", size=10)# #len(CDLType) ? encodeForHTML(CDLType) : 'CDL'#
										</span>
									</cfif>
									<cfif hasLicense>
										<span class="badge badge-neutral" style="font-size:0.7rem;" title="Valid Driver's License">
											WA Driver's Lic
										</span>
									</cfif>
									<cfif wasEmployed>
										<span class="badge badge-info" style="font-size:0.7rem;" title="Prior Chelan County Employee">
											Prior County
										</span>
									</cfif>
									<cfif hasRelative>
										<span class="badge badge-neutral" style="font-size:0.7rem;" title="Disclosed Relative in County">
											Disclosure
										</span>
									</cfif>
								</div>
							</td>

							<!--- Education --->
							<td>
								<cfif len(Education1)>
									<div style="font-weight:600; font-size:0.8rem; color:var(--admin-text-main); max-width:160px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="#encodeForHTML(Education1)#">
										#encodeForHTML(Education1)#
									</div>
									<cfif len(Degree1)>
										<div style="font-size:0.725rem; color:var(--admin-text-muted); max-width:160px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="#encodeForHTML(Degree1)#">
											#encodeForHTML(Degree1)#
										</div>
									</cfif>
								<cfelse>
									<span style="font-size:0.75rem; color:var(--admin-text-muted);">Grade: #encodeForHTML(HighestGrade)#</span>
								</cfif>
							</td>

							<!--- Applied Date --->
							<td>
								<div style="font-size:0.8rem; font-weight:600; color:var(--admin-text-main);">
									#dateFormat(EntryDate, "mmm d, yyyy")#
								</div>
								<div style="font-size:0.7rem; color:var(--admin-text-muted);">
									#timeFormat(EntryDate, "h:mm tt")#
								</div>
							</td>

							<!--- Candidate Status --->
							<td style="text-align:center;">
								<cfset sBadge = "badge-neutral">
								<cfif Status eq "New"><cfset sBadge = "badge-primary">
								<cfelseif Status eq "Under Review"><cfset sBadge = "badge-info">
								<cfelseif Status eq "Interview"><cfset sBadge = "badge-purple">
								<cfelseif Status eq "Offer"><cfset sBadge = "badge-warning">
								<cfelseif Status eq "Hired"><cfset sBadge = "badge-success">
								<cfelseif Status eq "Not Selected"><cfset sBadge = "badge-danger">
								</cfif>
								<span class="badge #sBadge#">#Status#</span>
							</td>

							<!--- Rating --->
							<td style="text-align:center;">
								<div style="color:var(--admin-warning, ##eab308); font-size:0.85rem;" title="#Rating# of 5 Stars">
									<cfloop from="1" to="5" index="starIdx">
										<cfif starIdx lte Rating>&starf;<cfelse><span style="color:var(--admin-border);">&starf;</span></cfif>
									</cfloop>
								</div>
							</td>
						</tr>
					</cfloop>
				</cfif>
			</tbody>
		</table>
	</div>
</div>
</cfoutput>
