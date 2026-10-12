<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title><cfoutput>#encodeForHTML(variables.pageTitle)#</cfoutput></title>
	
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

	<style>
		:root {
			--primary: #0073aa;
			--primary-dark: #005a87;
			--bg: #f4f6fa;
			--surface: #ffffff;
			--border: #cbd5e1;
			--border-subtle: #e2e8f0;
			--text: #0f172a;
			--text-muted: #475569;
			--success: #15803d;
			--radius: 12px;
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
		.careers-hero {
			background: linear-gradient(135deg, #0b2545 0%, #134074 100%);
			color: #ffffff;
			padding: 3.5rem 1.5rem 3rem 1.5rem;
			text-align: center;
		}
		.hero-container {
			max-width: 860px;
			margin: 0 auto;
		}
		.hero-title {
			font-size: 2.25rem;
			font-weight: 800;
			margin: 0 0 0.75rem 0;
			letter-spacing: -0.025em;
		}
		.hero-subtitle {
			font-size: 1.1rem;
			opacity: 0.9;
			margin: 0 0 1.5rem 0;
		}
		.main-container {
			max-width: 1040px;
			margin: -1.5rem auto 3rem auto;
			padding: 0 1rem;
		}
		.job-card {
			background: var(--surface);
			border: 1px solid var(--border-subtle);
			border-radius: var(--radius);
			padding: 1.5rem 1.75rem;
			margin-bottom: 1rem;
			box-shadow: 0 1px 3px rgba(0,0,0,0.05);
			display: flex;
			justify-content: space-between;
			align-items: center;
			gap: 1.5rem;
			transition: all 0.2s ease;
		}
		.job-card:hover {
			box-shadow: 0 4px 12px rgba(0,0,0,0.08);
			border-color: var(--primary);
			transform: translateY(-2px);
		}
		.job-title {
			font-size: 1.25rem;
			font-weight: 700;
			color: #0b2545;
			margin: 0 0 0.35rem 0;
		}
		.job-meta {
			display: flex;
			gap: 0.75rem;
			font-size: 0.85rem;
			color: var(--text-muted);
			flex-wrap: wrap;
			align-items: center;
		}
		.badge {
			display: inline-block;
			padding: 0.25rem 0.55rem;
			font-size: 0.75rem;
			font-weight: 700;
			border-radius: 6px;
			background: #e2e8f0;
			color: #1e293b;
		}
		.badge-success { background: #dcfce7; color: #15803d; }
		.badge-primary { background: #e0f2fe; color: #0369a1; }
		.btn {
			display: inline-flex;
			align-items: center;
			gap: 0.4rem;
			padding: 0.65rem 1.25rem;
			font-size: 0.9rem;
			font-weight: 600;
			border-radius: 8px;
			text-decoration: none;
			cursor: pointer;
			border: none;
			transition: background 0.15s ease;
		}
		.btn-primary {
			background: var(--primary);
			color: #ffffff;
		}
		.btn-primary:hover {
			background: var(--primary-dark);
		}
		.btn-outline {
			background: transparent;
			border: 1px solid var(--border);
			color: var(--text);
		}
		.btn-outline:hover {
			background: #f1f5f9;
		}
		@media (max-width: 768px) {
			.job-card { flex-direction: column; align-items: flex-start; }
		}
	</style>
</head>
<body>

	<header class="careers-hero">
		<div class="hero-container">
			<div style="display:flex; justify-content:center; align-items:center; gap:0.75rem; margin-bottom:1rem;">
				<img src="/images/logo.png" alt="Chelan County" width="48" height="48" style="object-fit:contain;">
				<span style="font-weight:700; letter-spacing:0.05em; text-transform:uppercase; font-size:0.9rem; opacity:0.85;">Chelan County, Washington</span>
			</div>
			<h1 class="hero-title">Careers in Public Service</h1>
			<p class="hero-subtitle">Make an impact in your community. Explore active job openings across Chelan County departments.</p>
		</div>
	</header>

	<main class="main-container">
		
		<div style="margin-bottom:1.5rem; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem;">
			<h2 style="font-size:1.25rem; font-weight:700; margin:0;">
				Open Positions (<cfoutput>#variables.qJobs.recordCount#</cfoutput>)
			</h2>
			<a href="<cfoutput>#urlFor(controller='jobs', action='apply')#</cfoutput>" class="btn btn-outline">
				General Employment Intake Form
			</a>
		</div>

		<cfif variables.qJobs.recordCount eq 0>
			<div style="background:var(--surface); padding:3rem; text-align:center; border-radius:var(--radius); border:1px solid var(--border-subtle);">
				<h3 style="font-size:1.1rem; margin-bottom:0.5rem;">No Active Openings at this Time</h3>
				<p style="color:var(--text-muted); font-size:0.9rem;">Please check back soon or submit a general employment application.</p>
				<a href="<cfoutput>#urlFor(controller='jobs', action='apply')#</cfoutput>" class="btn btn-primary" style="margin-top:1rem;">Submit General Application</a>
			</div>
		<cfelse>
			<cfloop query="variables.qJobs">
				<cfset jType = (JobClasificationID eq 1 ? 'Full-Time' : (JobClasificationID eq 2 ? 'Part-Time' : (JobClasificationID eq 3 ? 'Seasonal' : (JobClasificationID eq 4 ? 'Temporary' : 'On-Call'))))>
				<article class="job-card">
					<div style="flex:1;">
						<div style="display:flex; align-items:center; gap:0.5rem; margin-bottom:0.35rem; flex-wrap:wrap;">
							<span class="badge badge-primary"><cfoutput>#encodeForHTML(department_name)#</cfoutput></span>
							<span class="badge"><cfoutput>#jType#</cfoutput></span>
							<cfif not isDate(ApplicationDeadline)>
								<span class="badge badge-success">Open Until Filled</span>
							<cfelse>
								<span class="badge">Closes: <cfoutput>#dateFormat(ApplicationDeadline, "mmm d, yyyy")#</cfoutput></span>
							</cfif>
						</div>

						<h3 class="job-title">
							<a href="<cfoutput>#urlFor(controller='jobs', action='publicView', params='id=' & JobID)#</cfoutput>" style="color:inherit; text-decoration:none;">
								<cfoutput>#encodeForHTML(Title)#</cfoutput>
							</a>
						</h3>

						<div class="job-meta">
							<span>Req: <strong style="font-family:monospace;"><cfoutput>#encodeForHTML(ClassCode)#</cfoutput></strong></span>
							<span>&bull;</span>
							<span>Location: <strong><cfoutput>#encodeForHTML(Location)#</cfoutput></strong></span>
							<cfif val(MinSalary) gt 0 and val(MaxSalary) gt 0>
								<span>&bull;</span>
								<span>Wage: <strong style="color:var(--success);">$#numberFormat(MinSalary, ",.__")# &ndash; $#numberFormat(MaxSalary, ",.__")# / #encodeForHTML(SalarySchedule)#</strong></span>
							<cfelseif val(MinSalary) gt 0>
								<span>&bull;</span>
								<span>Wage: <strong style="color:var(--success);">$#numberFormat(MinSalary, ",.__")# / #encodeForHTML(SalarySchedule)#</strong></span>
							</cfif>
						</div>

						<cfif len(Description)>
							<p style="font-size:0.875rem; color:var(--text-muted); margin:0.6rem 0 0 0; line-height:1.45; max-width:650px; overflow:hidden; text-overflow:ellipsis; display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical;">
								<cfoutput>#encodeForHTML(Description)#</cfoutput>
							</p>
						</cfif>
					</div>

					<div style="display:flex; flex-direction:column; gap:0.5rem; min-width:140px;">
						<a href="<cfoutput>#urlFor(controller='jobs', action='apply', params='id=' & JobID)#</cfoutput>" class="btn btn-primary" style="justify-content:center;">
							Apply Online
						</a>
						<a href="<cfoutput>#urlFor(controller='jobs', action='publicView', params='id=' & JobID)#</cfoutput>" class="btn btn-outline" style="justify-content:center; font-size:0.85rem;">
							View Details
						</a>
					</div>
				</article>
			</cfloop>
		</cfif>

	</main>

	<footer style="border-top:1px solid var(--border); padding:2rem 1rem; text-align:center; font-size:0.8rem; color:var(--text-muted); background:var(--surface);">
		<div>Chelan County Human Resources Management &bull; 400 Douglas St, Wenatchee, WA 98801 &bull; (509) 667-6400</div>
		<div style="margin-top:0.35rem;">Chelan County is an Equal Opportunity Employer (EOE) &bull; ADA Title II / Section 508 Compliant</div>
	</footer>

</body>
</html>
