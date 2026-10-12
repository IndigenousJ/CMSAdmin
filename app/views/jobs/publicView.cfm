<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title><cfoutput>#encodeForHTML(variables.qJob.Title)# - Chelan County Careers</cfoutput></title>
	
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

	<style>
		:root {
			--primary: #0073aa;
			--primary-dark: #005a87;
			--bg: #f8fafc;
			--surface: #ffffff;
			--surface-alt: #f1f5f9;
			--border: #cbd5e1;
			--border-subtle: #e2e8f0;
			--text: #0f172a;
			--text-muted: #475569;
			--success: #15803d;
			--success-bg: #dcfce7;
			--info: #0369a1;
			--info-bg: #e0f2fe;
			--purple: #7e22ce;
			--purple-bg: #f3e8ff;
			--radius: 12px;
			--radius-sm: 8px;
		}
		*, *::before, *::after { box-sizing: border-box; }
		body {
			margin: 0;
			padding: 0;
			font-family: "Plus Jakarta Sans", system-ui, -apple-system, sans-serif;
			background-color: var(--bg);
			color: var(--text);
			font-size: 15px;
			line-height: 1.6;
		}
		.careers-nav {
			background: #0b2545;
			color: #ffffff;
			padding: 1rem 1.5rem;
		}
		.nav-container {
			max-width: 1140px;
			margin: 0 auto;
			display: flex;
			justify-content: space-between;
			align-items: center;
		}
		.main-container {
			max-width: 1140px;
			margin: 2rem auto 4rem auto;
			padding: 0 1rem;
		}
		.job-header-card {
			background: var(--surface);
			border: 1px solid var(--border-subtle);
			border-radius: var(--radius);
			padding: 2rem 2.25rem;
			margin-bottom: 1.5rem;
			box-shadow: 0 2px 6px rgba(0,0,0,0.03);
		}
		.badge {
			display: inline-block;
			padding: 0.25rem 0.6rem;
			font-size: 0.75rem;
			font-weight: 700;
			border-radius: 6px;
			background: #e2e8f0;
			color: #1e293b;
		}
		.badge-success { background: var(--success-bg); color: var(--success); }
		.badge-primary { background: var(--info-bg); color: var(--info); }
		.badge-purple { background: var(--purple-bg); color: var(--purple); }
		
		/* 2-Column Responsive Panel Grid (matching edit page architecture) */
		.job-layout-grid {
			display: grid;
			grid-template-columns: minmax(0, 2fr) minmax(320px, 1fr);
			gap: 1.5rem;
			align-items: start;
		}
		@media (max-width: 900px) {
			.job-layout-grid { grid-template-columns: 1fr; }
		}

		.panel {
			background: var(--surface);
			border: 1px solid var(--border-subtle);
			border-radius: var(--radius);
			box-shadow: 0 1px 4px rgba(0,0,0,0.02);
			margin-bottom: 1.5rem;
			overflow: hidden;
		}
		.panel-header {
			padding: 1rem 1.5rem;
			background: #ffffff;
			border-bottom: 1px solid var(--border-subtle);
			font-weight: 700;
			font-size: 1rem;
			color: #0b2545;
			display: flex;
			align-items: center;
			gap: 0.75rem;
		}
		.panel-body {
			padding: 1.5rem;
		}
		.content-text {
			font-size: 0.95rem;
			line-height: 1.7;
			color: #334155;
			white-space: pre-line;
		}
		.meta-list {
			display: flex;
			flex-direction: column;
			gap: 0.85rem;
		}
		.meta-row {
			display: flex;
			justify-content: space-between;
			align-items: flex-start;
			gap: 0.75rem;
			padding-bottom: 0.75rem;
			border-bottom: 1px solid var(--border-subtle);
			font-size: 0.88rem;
		}
		.meta-row:last-child {
			border-bottom: none;
			padding-bottom: 0;
		}
		.meta-label {
			color: var(--text-muted);
			font-weight: 500;
		}
		.meta-value {
			font-weight: 600;
			color: var(--text);
			text-align: right;
		}

		.btn {
			display: inline-flex;
			align-items: center;
			justify-content: center;
			gap: 0.5rem;
			padding: 0.75rem 1.5rem;
			font-size: 0.95rem;
			font-weight: 700;
			border-radius: var(--radius-sm);
			text-decoration: none;
			cursor: pointer;
			border: none;
			transition: all 0.15s ease;
		}
		.btn-primary { background: var(--primary); color: #ffffff; }
		.btn-primary:hover { background: var(--primary-dark); }
		.btn-outline { background: transparent; border: 1px solid var(--border); color: var(--text); }
		.btn-outline:hover { background: #f1f5f9; }
		.btn-block { width: 100%; }
	</style>
</head>
<body>

	<header class="careers-nav">
		<div class="nav-container">
			<a href="/careers" style="display:flex; align-items:center; gap:0.75rem; color:#ffffff; text-decoration:none;">
				<img src="/images/logo.png" alt="Chelan County" width="36" height="36" style="object-fit:contain;">
				<div>
					<div style="font-weight:800; font-size:1.05rem; letter-spacing:-0.01em;">Chelan County Careers</div>
					<div style="font-size:0.75rem; opacity:0.8;">Wenatchee, Washington</div>
				</div>
			</a>
			<a href="/careers" style="color:#ffffff; font-size:0.85rem; text-decoration:none; opacity:0.9;">&larr; Back to All Openings</a>
		</div>
	</header>

	<main class="main-container">
		
		<cfoutput query="variables.qJob">
			<!--- Top Header Overview Card --->
			<div class="job-header-card">
				<div style="display:flex; align-items:center; gap:0.5rem; margin-bottom:0.75rem; flex-wrap:wrap;">
					<span class="badge badge-primary">#encodeForHTML(department_name)#</span>
					<span class="badge">
						<cfif JobClasificationID eq 1>Full-Time
						<cfelseif JobClasificationID eq 2>Part-Time
						<cfelseif JobClasificationID eq 3>Seasonal
						<cfelseif JobClasificationID eq 4>Temporary
						<cfelse>On-Call</cfif>
					</span>
					<span class="badge">FLSA: <cfif FLSAClassificationID eq 2>Exempt<cfelse>Non-Exempt</cfif></span>
					<cfif not isDate(ApplicationDeadline)>
						<span class="badge badge-success">Open Until Filled</span>
					<cfelse>
						<span class="badge">Deadline: #dateFormat(ApplicationDeadline, "mmm d, yyyy")#</span>
					</cfif>
				</div>

				<h1 style="font-size:2rem; font-weight:800; color:##0b2545; margin:0 0 0.5rem 0; letter-spacing:-0.02em;">
					#encodeForHTML(Title)#
				</h1>

				<div style="display:flex; gap:1.75rem; font-size:0.9rem; color:var(--text-muted); flex-wrap:wrap; align-items:center; margin-bottom:1.5rem;">
					<div>Requisition: <strong style="font-family:monospace; color:var(--text);">#encodeForHTML(ClassCode)#</strong></div>
					<div>Location: <strong>#encodeForHTML(Location)#</strong> (#encodeForHTML(City)#, #encodeForHTML(State)#)</div>
					<cfif val(MinSalary) gt 0 and val(MaxSalary) gt 0>
						<div>Salary: <strong style="color:var(--success); font-size:1.05rem;">$#numberFormat(MinSalary, ",.__")# &ndash; $#numberFormat(MaxSalary, ",.__")# / #encodeForHTML(SalarySchedule)#</strong></div>
					<cfelseif val(MinSalary) gt 0>
						<div>Salary: <strong style="color:var(--success); font-size:1.05rem;">$#numberFormat(MinSalary, ",.__")# / #encodeForHTML(SalarySchedule)#</strong></div>
					</cfif>
				</div>

				<div style="display:flex; gap:0.75rem; flex-wrap:wrap;">
					<a href="/careers/apply?id=#JobID#" class="btn btn-primary" style="font-size:1rem; padding:0.85rem 2rem;">
						Apply Online for this Position &rarr;
					</a>
					<cfif len(Attachment)>
						<a href="#Attachment#" target="_blank" class="btn btn-outline">
							Download Official Job Description (PDF)
						</a>
					</cfif>
				</div>
			</div>

			<!--- Main 2-Column Content Layout (Matching Edit Page Panel Structure) --->
			<div class="job-layout-grid">
				
				<!--- Left Column: Main Narrative Panels --->
				<div>
					
					<!--- Position Description & Overview Panel (Supports Rich HTML from JBDEditor) --->
					<cfif len(Description)>
						<div class="panel">
							<div class="panel-header">
								<span>Job Description &amp; Overview</span>
							</div>
							<div class="panel-body">
								<div class="content-text rich-content" style="white-space:normal;">
									<!--- Check if content has HTML tags from JBDEditor, otherwise encode and preserve line breaks --->
									<cfif reFind("<[a-z][\s\S]*>", Description)>
										#Description#
									<cfelse>
										#replace(encodeForHTML(Description), chr(10), "<br>", "all")#
									</cfif>
								</div>
							</div>
						</div>
					</cfif>

					<!--- Legacy Fallback: Essential Responsibilities Panel --->
					<cfif len(Responsibilities)>
						<div class="panel">
							<div class="panel-header">
								<span>Essential Duties &amp; Responsibilities</span>
							</div>
							<div class="panel-body">
								<div class="content-text">#replace(encodeForHTML(Responsibilities), chr(10), "<br>", "all")#</div>
							</div>
						</div>
					</cfif>

					<!--- Legacy Fallback: Qualifications Panel --->
					<cfif len(Qualification)>
						<div class="panel">
							<div class="panel-header">
								<span>Qualifications, Licenses &amp; Experience</span>
							</div>
							<div class="panel-body">
								<div class="content-text">#replace(encodeForHTML(Qualification), chr(10), "<br>", "all")#</div>
							</div>
						</div>
					</cfif>

					<!--- Legacy Fallback: Additional Information Panel --->
					<cfif len(AdditionalInformation)>
						<div class="panel">
							<div class="panel-header">
								<span>Compensation, Benefits &amp; Working Conditions</span>
							</div>
							<div class="panel-body">
								<div class="content-text">#replace(encodeForHTML(AdditionalInformation), chr(10), "<br>", "all")#</div>
							</div>
						</div>
					</cfif>

					<!--- Bottom Application CTA Card --->
					<div style="background:linear-gradient(135deg, ##0b2545 0%, ##134074 100%); color:##ffffff; border-radius:var(--radius); padding:2.25rem; text-align:center; margin-bottom:1.5rem;">
						<h2 style="font-size:1.4rem; font-weight:800; margin:0 0 0.5rem 0;">Ready to apply for this role?</h2>
						<p style="margin:0 0 1.5rem 0; opacity:0.9; font-size:0.95rem;">Submit your official application directly through the Chelan County online portal.</p>
						<a href="/careers/apply?id=#JobID#" class="btn btn-primary" style="background:##ffffff; color:##0b2545; font-size:1rem; padding:0.85rem 2.25rem;">
							Begin Online Application &rarr;
						</a>
					</div>

				</div>

				<!--- Right Column: Grouped Information Panels (Matching Edit Page Sidebar) --->
				<div>
					
					<!--- Application Quick Action Panel --->
					<div class="panel" style="border-top:4px solid var(--primary);">
						<div class="panel-body" style="text-align:center;">
							<div style="font-size:0.8rem; text-transform:uppercase; font-weight:700; color:var(--text-muted); margin-bottom:0.25rem;">Chelan County Recruitment</div>
							<div style="font-size:1.1rem; font-weight:800; color:##0b2545; margin-bottom:1rem;">Online Application Intake</div>
							<a href="/careers/apply?id=#JobID#" class="btn btn-primary btn-block" style="font-size:1rem; padding:0.85rem 1rem;">
								Apply Online Now &rarr;
							</a>
							<cfif len(Attachment)>
								<div style="margin-top:0.75rem;">
									<a href="#Attachment#" target="_blank" class="btn btn-outline btn-block" style="font-size:0.85rem; padding:0.65rem 1rem;">
										View Official PDF Flyer
									</a>
								</div>
							</cfif>
						</div>
					</div>

					<!--- Compensation & Classification Panel --->
					<div class="panel">
						<div class="panel-header">
							<span>Compensation &amp; Classification</span>
						</div>
						<div class="panel-body">
							<div class="meta-list">
								<div class="meta-row">
									<span class="meta-label">Salary Range</span>
									<span class="meta-value" style="color:var(--success);">
										<cfif val(MinSalary) gt 0 and val(MaxSalary) gt 0>
											$#numberFormat(MinSalary, ",.__")# &ndash; $#numberFormat(MaxSalary, ",.__")#
										<cfelseif val(MinSalary) gt 0>
											$#numberFormat(MinSalary, ",.__")#
										<cfelse>
											Competitive / DOE
										</cfif>
									</span>
								</div>
								<div class="meta-row">
									<span class="meta-label">Schedule Frequency</span>
									<span class="meta-value">#encodeForHTML(SalarySchedule)#</span>
								</div>
								<div class="meta-row">
									<span class="meta-label">Job Classification</span>
									<span class="meta-value">
										<cfif JobClasificationID eq 1>Full-Time
										<cfelseif JobClasificationID eq 2>Part-Time
										<cfelseif JobClasificationID eq 3>Seasonal
										<cfelseif JobClasificationID eq 4>Temporary
										<cfelse>On-Call</cfif>
									</span>
								</div>
								<div class="meta-row">
									<span class="meta-label">FLSA Status</span>
									<span class="meta-value"><cfif FLSAClassificationID eq 2>Exempt<cfelse>Non-Exempt</cfif></span>
								</div>
								<cfif len(SalaryGroup)>
									<div class="meta-row">
										<span class="meta-label">Salary Group / Unit</span>
										<span class="meta-value">#encodeForHTML(SalaryGroup)#</span>
									</div>
								</cfif>
								<cfif isSupervisor>
									<div class="meta-row">
										<span class="meta-label">Role Type</span>
										<span class="meta-value" style="color:var(--info);">Supervisory Position</span>
									</div>
								</cfif>
							</div>
						</div>
					</div>

					<!--- Timeline & Recruitment Status Panel --->
					<div class="panel">
						<div class="panel-header">
							<span>Status &amp; Timeline</span>
						</div>
						<div class="panel-body">
							<div class="meta-list">
								<div class="meta-row">
									<span class="meta-label">Posting Date</span>
									<span class="meta-value">
										<cfif isDate(PostDate)>#dateFormat(PostDate, "mmmm d, yyyy")#<cfelse>Recently Posted</cfif>
									</span>
								</div>
								<div class="meta-row">
									<span class="meta-label">Application Deadline</span>
									<span class="meta-value">
										<cfif not isDate(ApplicationDeadline)>
											<span class="badge badge-success">Open Until Filled</span>
										<cfelse>
											<strong>#dateFormat(ApplicationDeadline, "mmmm d, yyyy")#</strong>
										</cfif>
									</span>
								</div>
								<div class="meta-row">
									<span class="meta-label">Requisition ID</span>
									<span class="meta-value" style="font-family:monospace;">#encodeForHTML(ClassCode)#</span>
								</div>
								<div class="meta-row">
									<span class="meta-label">Recruitment Status</span>
									<span class="meta-value">
										<span class="badge badge-primary">#encodeForHTML(StatusCode)#</span>
									</span>
								</div>
							</div>
						</div>
					</div>

					<!--- Work Location & Facility Panel --->
					<div class="panel">
						<div class="panel-header">
							<span>Workplace Location</span>
						</div>
						<div class="panel-body">
							<div class="meta-list">
								<div class="meta-row">
									<span class="meta-label">Facility / Station</span>
									<span class="meta-value">#encodeForHTML(Location)#</span>
								</div>
								<cfif len(Address)>
									<div class="meta-row">
										<span class="meta-label">Street Address</span>
										<span class="meta-value">#encodeForHTML(Address)#</span>
									</div>
								</cfif>
								<div class="meta-row">
									<span class="meta-label">City, State &amp; Zip</span>
									<span class="meta-value">#encodeForHTML(City)#, #encodeForHTML(State)# #encodeForHTML(Zip)#</span>
								</div>
								<div class="meta-row">
									<span class="meta-label">Department</span>
									<span class="meta-value">#encodeForHTML(department_name)#</span>
								</div>
							</div>
						</div>
					</div>

					<!--- Equal Employment Opportunity Statement Panel --->
					<div class="panel" style="background:var(--surface-alt); border-style:dashed;">
						<div class="panel-body" style="font-size:0.8rem; color:var(--text-muted); line-height:1.5;">
							<strong style="color:var(--text); display:block; margin-bottom:0.25rem;">Equal Opportunity Employer</strong>
							Chelan County is an equal opportunity employer and does not discriminate on the basis of race, color, national origin, sex, religion, age, disability, or sexual orientation. ADA Title II accommodations available upon request.
						</div>
					</div>

				</div>

			</div>
		</cfoutput>

	</main>

	<footer style="border-top:1px solid var(--border); padding:2rem 1rem; text-align:center; font-size:0.8rem; color:var(--text-muted); background:var(--surface);">
		<div>Chelan County Human Resources Management &bull; 400 Douglas St, Wenatchee, WA 98801</div>
		<div style="margin-top:0.35rem;">Chelan County is an Equal Opportunity Employer (EOE) &bull; ADA Title II Accessible</div>
	</footer>

</body>
</html>
