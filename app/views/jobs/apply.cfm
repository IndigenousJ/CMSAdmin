<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title><cfoutput>#encodeForHTML(variables.pageTitle)#</cfoutput> - Chelan County</title>
	
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
			--danger: #b91c1c;
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
			max-width: 960px;
			margin: 0 auto;
			display: flex;
			justify-content: space-between;
			align-items: center;
		}
		.form-container {
			max-width: 960px;
			margin: 2rem auto 4rem auto;
			padding: 0 1rem;
		}
		
		/* Position Top Banner Card */
		.position-banner-card {
			background: var(--surface);
			border: 1px solid var(--border-subtle);
			border-radius: var(--radius);
			padding: 1.75rem 2rem;
			margin-bottom: 1.5rem;
			box-shadow: 0 1px 4px rgba(0,0,0,0.03);
			display: flex;
			justify-content: space-between;
			align-items: center;
			flex-wrap: wrap;
			gap: 1rem;
		}

		/* Panel Group Styling (Matching edit page card/panel architecture) */
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
			font-size: 1.05rem;
			color: #0b2545;
			display: flex;
			align-items: center;
			gap: 0.75rem;
		}
		.panel-badge {
			display: inline-block;
			padding: 0.2rem 0.6rem;
			font-size: 0.75rem;
			font-weight: 700;
			border-radius: 999px;
			background: #e2e8f0;
			color: #334155;
		}
		.panel-body {
			padding: 1.5rem 1.75rem;
		}

		.form-grid-2 {
			display: grid;
			grid-template-columns: 1fr 1fr;
			gap: 1.25rem;
		}
		.form-grid-3 {
			display: grid;
			grid-template-columns: 1fr 1fr 1fr;
			gap: 1.25rem;
		}
		.form-group {
			margin-bottom: 1.15rem;
		}
		.form-group:last-child {
			margin-bottom: 0;
		}
		label {
			display: block;
			font-weight: 600;
			font-size: 0.85rem;
			margin-bottom: 0.35rem;
			color: #1e293b;
		}
		input[type="text"], input[type="email"], input[type="tel"], input[type="date"], select, textarea {
			width: 100%;
			padding: 0.65rem 0.85rem;
			border: 1px solid var(--border);
			border-radius: var(--radius-sm);
			font-size: 0.9rem;
			font-family: inherit;
			color: var(--text);
			background: #ffffff;
			outline: none;
			transition: border-color 0.15s ease, box-shadow 0.15s ease;
		}
		input:focus, select:focus, textarea:focus {
			border-color: var(--primary);
			box-shadow: 0 0 0 3px rgba(0, 115, 170, 0.15);
		}
		.btn {
			display: inline-flex;
			align-items: center;
			justify-content: center;
			gap: 0.5rem;
			padding: 0.85rem 2.25rem;
			font-size: 1rem;
			font-weight: 700;
			border-radius: var(--radius-sm);
			text-decoration: none;
			cursor: pointer;
			border: none;
			transition: all 0.15s ease;
		}
		.btn-primary { background: var(--primary); color: #ffffff; }
		.btn-primary:hover { background: var(--primary-dark); }
		.sub-box {
			background: #f8fafc;
			border: 1px solid var(--border-subtle);
			padding: 1.15rem 1.25rem;
			border-radius: var(--radius-sm);
			margin-bottom: 1rem;
		}
		.sub-box:last-child {
			margin-bottom: 0;
		}
		@media (max-width: 768px) {
			.form-grid-2, .form-grid-3 { grid-template-columns: 1fr; }
			.panel-body { padding: 1.25rem 1rem; }
		}
	</style>
</head>
<body>

	<header class="careers-nav">
		<div class="nav-container">
			<a href="/careers" style="display:flex; align-items:center; gap:0.75rem; color:#ffffff; text-decoration:none;">
				<img src="/images/logo.png" alt="Chelan County" width="36" height="36" style="object-fit:contain;">
				<div>
					<div style="font-weight:800; font-size:1.05rem;">Chelan County Employment Portal</div>
					<div style="font-size:0.75rem; opacity:0.8;">Human Resources Intake</div>
				</div>
			</a>
			<a href="/careers" style="color:#ffffff; font-size:0.85rem; text-decoration:none;">&larr; Back to Careers</a>
		</div>
	</header>

	<main class="form-container">
		
		<!--- Target Position Header Card --->
		<div class="position-banner-card">
			<div>
				<div style="font-size:0.8rem; text-transform:uppercase; font-weight:700; color:var(--text-muted); margin-bottom:0.25rem;">
					Official Employment Application
				</div>
				<h1 style="font-size:1.75rem; font-weight:800; color:#0b2545; margin:0 0 0.25rem 0;">
					<cfoutput>#encodeForHTML(variables.job.title)#</cfoutput>
				</h1>
				<div style="color:var(--text-muted); font-size:0.88rem;">
					Department: <strong><cfoutput>#encodeForHTML(variables.job.department_name)#</cfoutput></strong>
					<cfif len(variables.job.classCode)> &bull; Requisition ID: <strong style="font-family:monospace;"><cfoutput>#encodeForHTML(variables.job.classCode)#</cfoutput></strong></cfif>
				</div>
			</div>
			<div>
				<span class="panel-badge" style="background:#dcfce7; color:#15803d; font-size:0.85rem; padding:0.4rem 0.85rem;">
					Now Accepting Applications
				</span>
			</div>
		</div>

		<form id="employmentApplicationForm" method="post" action="/careers/submit">
			<cfoutput>#authenticityTokenField()#</cfoutput>
			<input type="hidden" name="JobID" value="<cfoutput>#variables.job.jobId#</cfoutput>">
			<input type="hidden" name="Position" value="<cfoutput>#encodeForHTML(variables.job.title)#</cfoutput>">
			
			<!--- Invisible Honeypot Bot Trap --->
			<div style="display:none;" aria-hidden="true">
				<input type="text" name="_chelan_gov_verify" tabindex="-1" autocomplete="off">
			</div>

			<!--- Panel 1: Personal & Contact Information --->
			<div class="panel">
				<div class="panel-header">
					<span>1. Personal &amp; Contact Information</span>
					<span class="panel-badge">Required</span>
				</div>
				<div class="panel-body">
					<div class="form-grid-3">
						<div class="form-group">
							<label for="FirstName">First Name <span style="color:var(--danger);">*</span></label>
							<input type="text" id="FirstName" name="FirstName" required autocomplete="given-name">
						</div>
						<div class="form-group">
							<label for="MiddleName">Middle Name</label>
							<input type="text" id="MiddleName" name="MiddleName" autocomplete="additional-name">
						</div>
						<div class="form-group">
							<label for="LastName">Last Name <span style="color:var(--danger);">*</span></label>
							<input type="text" id="LastName" name="LastName" required autocomplete="family-name">
						</div>
					</div>

					<div class="form-grid-2">
						<div class="form-group">
							<label for="Email">Email Address <span style="color:var(--danger);">*</span></label>
							<input type="email" id="Email" name="Email" required autocomplete="email">
						</div>
						<div class="form-group">
							<label for="Phone">Primary Phone <span style="color:var(--danger);">*</span></label>
							<input type="tel" id="Phone" name="Phone" placeholder="(509) 000-0000" required autocomplete="tel">
						</div>
					</div>

					<div class="form-group">
						<label for="Address1">Street Address <span style="color:var(--danger);">*</span></label>
						<input type="text" id="Address1" name="Address1" required autocomplete="street-address">
					</div>

					<div class="form-group">
						<label for="Address2">Apartment / Suite / Unit</label>
						<input type="text" id="Address2" name="Address2" autocomplete="address-line2">
					</div>

					<div class="form-grid-3">
						<div class="form-group">
							<label for="City">City <span style="color:var(--danger);">*</span></label>
							<input type="text" id="City" name="City" value="Wenatchee" required autocomplete="address-level2">
						</div>
						<div class="form-group">
							<label for="State">State <span style="color:var(--danger);">*</span></label>
							<input type="text" id="State" name="State" value="WA" required autocomplete="address-level1">
						</div>
						<div class="form-group">
							<label for="Zip">Zip Code <span style="color:var(--danger);">*</span></label>
							<input type="text" id="Zip" name="Zip" placeholder="98801" required autocomplete="postal-code">
						</div>
					</div>

					<div style="display:flex; gap:1.75rem; flex-wrap:wrap; margin-top:0.75rem; padding-top:0.75rem; border-top:1px solid var(--border-subtle);">
						<label style="display:inline-flex; align-items:center; gap:0.5rem; cursor:pointer;">
							<input type="checkbox" name="hasImmigration" value="1" checked style="width:auto;">
							<span>I am legally authorized to work in the United States</span>
						</label>
						<label style="display:inline-flex; align-items:center; gap:0.5rem; cursor:pointer;">
							<input type="checkbox" name="under18" value="1" style="width:auto;">
							<span>I am under 18 years of age</span>
						</label>
					</div>
				</div>
			</div>

			<!--- Panel 2: Driver's License & Commercial CDL --->
			<div class="panel">
				<div class="panel-header">
					<span>2. Driver's License &amp; Commercial CDL Credentials</span>
					<span class="panel-badge">Credentials</span>
				</div>
				<div class="panel-body">
					<div class="sub-box">
						<label style="display:inline-flex; align-items:center; gap:0.5rem; cursor:pointer; font-weight:700; margin-bottom:0.75rem;">
							<input type="checkbox" name="hasLicense" value="1" id="chkLicense" style="width:auto;" onchange="document.getElementById('licFields').style.display = this.checked ? 'grid' : 'none'">
							<span>I hold a valid Driver's License</span>
						</label>

						<div id="licFields" class="form-grid-3" style="display:none; margin-top:0.75rem;">
							<div class="form-group">
								<label for="LicenseNo">License Number</label>
								<input type="text" id="LicenseNo" name="LicenseNo">
							</div>
							<div class="form-group">
								<label for="LicenseState">State Issued</label>
								<input type="text" id="LicenseState" name="LicenseState" value="WA">
							</div>
							<div class="form-group">
								<label for="LicenseExpireDate">Expiration Date</label>
								<input type="date" id="LicenseExpireDate" name="LicenseExpireDate">
							</div>
						</div>
					</div>

					<div class="sub-box">
						<label style="display:inline-flex; align-items:center; gap:0.5rem; cursor:pointer; font-weight:700; margin-bottom:0.75rem;">
							<input type="checkbox" name="hasCDL" value="1" id="chkCDL" style="width:auto;" onchange="document.getElementById('cdlFields').style.display = this.checked ? 'block' : 'none'">
							<span>I hold a Commercial Driver's License (CDL)</span>
						</label>

						<div id="cdlFields" style="display:none; margin-top:0.75rem;">
							<div class="form-grid-3">
								<div class="form-group">
									<label for="CDLNo">CDL Number</label>
									<input type="text" id="CDLNo" name="CDLNo">
								</div>
								<div class="form-group">
									<label for="CDLState">State Issued</label>
									<input type="text" id="CDLState" name="CDLState" value="WA">
								</div>
								<div class="form-group">
									<label for="CDLExpireDate">Expiration Date</label>
									<input type="date" id="CDLExpireDate" name="CDLExpireDate">
								</div>
							</div>
							<div class="form-grid-2" style="margin-top:0.75rem;">
								<div class="form-group">
									<label for="CDLType">CDL Class / Endorsements</label>
									<input type="text" id="CDLType" name="CDLType" placeholder="e.g. Class A - Air Brakes, Tanker">
								</div>
								<div class="form-group">
									<label for="CDLRestriction">Restrictions (if any)</label>
									<input type="text" id="CDLRestriction" name="CDLRestriction" placeholder="e.g. Corrective lenses, No manual">
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

			<!--- Panel 3: County Disclosures & Conflict of Interest --->
			<div class="panel">
				<div class="panel-header">
					<span>3. County Employment History &amp; Relatives Disclosures</span>
					<span class="panel-badge">Compliance</span>
				</div>
				<div class="panel-body">
					<div class="sub-box">
						<label style="display:inline-flex; align-items:center; gap:0.5rem; cursor:pointer; font-weight:700; margin-bottom:0.5rem;">
							<input type="checkbox" name="wasEmployed" value="1" id="chkEmployed" style="width:auto;" onchange="document.getElementById('priorEmpFields').style.display = this.checked ? 'grid' : 'none'">
							<span>Have you ever been employed by Chelan County?</span>
						</label>

						<div id="priorEmpFields" class="form-grid-3" style="display:none; margin-top:0.75rem;">
							<div class="form-group">
								<label for="EmploymentDepartment">Department</label>
								<input type="text" id="EmploymentDepartment" name="EmploymentDepartment" placeholder="e.g. Public Works">
							</div>
							<div class="form-group">
								<label for="EmploymentStart">Start Date</label>
								<input type="date" id="EmploymentStart" name="EmploymentStart">
							</div>
							<div class="form-group">
								<label for="EmploymentEnd">End Date</label>
								<input type="date" id="EmploymentEnd" name="EmploymentEnd">
							</div>
						</div>
					</div>

					<div class="sub-box">
						<label style="display:inline-flex; align-items:center; gap:0.5rem; cursor:pointer; font-weight:700; margin-bottom:0.5rem;">
							<input type="checkbox" name="hasRelative" value="1" id="chkRelative" style="width:auto;" onchange="document.getElementById('relativeFields').style.display = this.checked ? 'block' : 'none'">
							<span>Do you have any relatives currently employed by Chelan County?</span>
						</label>

						<div id="relativeFields" style="display:none; margin-top:0.75rem;">
							<div class="form-group">
								<label for="RelativeNames">Relative Name(s) and Department(s)</label>
								<input type="text" id="RelativeNames" name="RelativeNames" placeholder="e.g. Jane Doe (Sheriff's Office)">
							</div>
						</div>
					</div>
				</div>
			</div>

			<!--- Panel 4: Foreign Languages --->
			<div class="panel">
				<div class="panel-header">
					<span>4. Foreign Languages &amp; Proficiency</span>
					<span class="panel-badge">Skills</span>
				</div>
				<div class="panel-body">
					<div class="form-grid-2">
						<div class="form-group">
							<label for="ForeignLanguage1">Foreign Language 1</label>
							<input type="text" id="ForeignLanguage1" name="ForeignLanguage1" placeholder="e.g. Spanish">
						</div>
						<div class="form-group">
							<label for="Proficiency1">Proficiency Level</label>
							<select id="Proficiency1" name="Proficiency1">
								<option value="">Select Level</option>
								<option value="Fluent (Bilingual)">Fluent (Bilingual)</option>
								<option value="Conversational">Conversational</option>
								<option value="Basic">Basic</option>
							</select>
						</div>
					</div>
					<div class="form-grid-2">
						<div class="form-group">
							<label for="ForeignLanguage2">Foreign Language 2</label>
							<input type="text" id="ForeignLanguage2" name="ForeignLanguage2">
						</div>
						<div class="form-group">
							<label for="Proficiency2">Proficiency Level</label>
							<select id="Proficiency2" name="Proficiency2">
								<option value="">Select Level</option>
								<option value="Fluent (Bilingual)">Fluent (Bilingual)</option>
								<option value="Conversational">Conversational</option>
								<option value="Basic">Basic</option>
							</select>
						</div>
					</div>
				</div>
			</div>

			<!--- Panel 5: Educational History --->
			<div class="panel">
				<div class="panel-header">
					<span>5. Educational Background &amp; Degrees</span>
					<span class="panel-badge">Education</span>
				</div>
				<div class="panel-body">
					<div style="display:flex; gap:1.5rem; align-items:center; margin-bottom:1.25rem;">
						<label style="display:inline-flex; align-items:center; gap:0.5rem; cursor:pointer;">
							<input type="checkbox" name="hasGED" value="1" style="width:auto;">
							<span>High School Diploma / GED</span>
						</label>
						<div style="display:inline-flex; align-items:center; gap:0.5rem;">
							<label for="HighestGrade" style="margin:0;">Highest Grade Completed:</label>
							<input type="text" id="HighestGrade" name="HighestGrade" placeholder="12" style="width:70px;">
						</div>
					</div>

					<div style="font-weight:700; font-size:0.9rem; margin-bottom:0.75rem; color:#0b2545;">Colleges, Technical Schools &amp; Universities</div>
					
					<div class="sub-box">
						<div class="form-grid-3">
							<div class="form-group">
								<label for="Education1">Institution 1</label>
								<input type="text" id="Education1" name="Education1" placeholder="College or Institute">
							</div>
							<div class="form-group">
								<label for="Degree1">Degree / Certificate</label>
								<input type="text" id="Degree1" name="Degree1" placeholder="Major / Degree">
							</div>
							<div class="form-group">
								<label for="DateEarned1">Year Earned</label>
								<input type="text" id="DateEarned1" name="DateEarned1" placeholder="e.g. 2021">
							</div>
						</div>
					</div>

					<div class="sub-box">
						<div class="form-grid-3">
							<div class="form-group">
								<label for="Education2">Institution 2</label>
								<input type="text" id="Education2" name="Education2">
							</div>
							<div class="form-group">
								<label for="Degree2">Degree / Certificate</label>
								<input type="text" id="Degree2" name="Degree2">
							</div>
							<div class="form-group">
								<label for="DateEarned2">Year Earned</label>
								<input type="text" id="DateEarned2" name="DateEarned2">
							</div>
						</div>
					</div>
				</div>
			</div>

			<!--- Panel 6: Employment Experience --->
			<div class="panel">
				<div class="panel-header">
					<span>6. Work Experience &amp; Employment History</span>
					<span class="panel-badge">Experience</span>
				</div>
				<div class="panel-body">
					<div class="sub-box">
						<div style="font-weight:700; font-size:0.9rem; margin-bottom:0.75rem; color:#0b2545;">Employer 1 (Most Recent)</div>
						<div class="form-grid-2">
							<div class="form-group">
								<label for="WorkExperienceEmployer1">Employer Name</label>
								<input type="text" id="WorkExperienceEmployer1" name="WorkExperienceEmployer1">
							</div>
							<div class="form-group">
								<label for="WorkExperienceEmployerPhone1">Employer Phone</label>
								<input type="tel" id="WorkExperienceEmployerPhone1" name="WorkExperienceEmployerPhone1">
							</div>
						</div>
						<div class="form-grid-2">
							<div class="form-group">
								<label for="WorkExperienceStart1">Dates Employed (From)</label>
								<input type="text" id="WorkExperienceStart1" name="WorkExperienceStart1" placeholder="MM/YYYY">
							</div>
							<div class="form-group">
								<label for="WorkExperienceEnd1">Dates Employed (To)</label>
								<input type="text" id="WorkExperienceEnd1" name="WorkExperienceEnd1" placeholder="MM/YYYY or Present">
							</div>
						</div>
						<div class="form-group">
							<label for="WorkExperienceReason1">Reason for Leaving</label>
							<input type="text" id="WorkExperienceReason1" name="WorkExperienceReason1">
						</div>
					</div>

					<div class="sub-box">
						<div style="font-weight:700; font-size:0.9rem; margin-bottom:0.75rem; color:#0b2545;">Employer 2 (Prior Position)</div>
						<div class="form-grid-2">
							<div class="form-group">
								<label for="WorkExperienceEmployer2">Employer Name</label>
								<input type="text" id="WorkExperienceEmployer2" name="WorkExperienceEmployer2">
							</div>
							<div class="form-group">
								<label for="WorkExperienceEmployerPhone2">Employer Phone</label>
								<input type="tel" id="WorkExperienceEmployerPhone2" name="WorkExperienceEmployerPhone2">
							</div>
						</div>
						<div class="form-grid-2">
							<div class="form-group">
								<label for="WorkExperienceStart2">Dates Employed (From)</label>
								<input type="text" id="WorkExperienceStart2" name="WorkExperienceStart2">
							</div>
							<div class="form-group">
								<label for="WorkExperienceEnd2">Dates Employed (To)</label>
								<input type="text" id="WorkExperienceEnd2" name="WorkExperienceEnd2">
							</div>
						</div>
						<div class="form-group">
							<label for="WorkExperienceReason2">Reason for Leaving</label>
							<input type="text" id="WorkExperienceReason2" name="WorkExperienceReason2">
						</div>
					</div>
				</div>
			</div>

			<!--- Panel 7: Professional References --->
			<div class="panel">
				<div class="panel-header">
					<span>7. Professional References</span>
					<span class="panel-badge">3 Required</span>
				</div>
				<div class="panel-body">
					<div class="form-grid-3">
						<div class="sub-box">
							<div style="font-weight:700; font-size:0.85rem; margin-bottom:0.5rem; color:#0b2545;">Reference 1</div>
							<div class="form-group">
								<label for="ReferenceName1">Name</label>
								<input type="text" id="ReferenceName1" name="ReferenceName1">
							</div>
							<div class="form-group">
								<label for="ReferenceEmail1">Email</label>
								<input type="email" id="ReferenceEmail1" name="ReferenceEmail1">
							</div>
							<div class="form-group">
								<label for="ReferencePhone1">Phone</label>
								<input type="tel" id="ReferencePhone1" name="ReferencePhone1">
							</div>
						</div>

						<div class="sub-box">
							<div style="font-weight:700; font-size:0.85rem; margin-bottom:0.5rem; color:#0b2545;">Reference 2</div>
							<div class="form-group">
								<label for="ReferenceName2">Name</label>
								<input type="text" id="ReferenceName2" name="ReferenceName2">
							</div>
							<div class="form-group">
								<label for="ReferenceEmail2">Email</label>
								<input type="email" id="ReferenceEmail2" name="ReferenceEmail2">
							</div>
							<div class="form-group">
								<label for="ReferencePhone2">Phone</label>
								<input type="tel" id="ReferencePhone2" name="ReferencePhone2">
							</div>
						</div>

						<div class="sub-box">
							<div style="font-weight:700; font-size:0.85rem; margin-bottom:0.5rem; color:#0b2545;">Reference 3</div>
							<div class="form-group">
								<label for="ReferenceName3">Name</label>
								<input type="text" id="ReferenceName3" name="ReferenceName3">
							</div>
							<div class="form-group">
								<label for="ReferenceEmail3">Email</label>
								<input type="email" id="ReferenceEmail3" name="ReferenceEmail3">
							</div>
							<div class="form-group">
								<label for="ReferencePhone3">Phone</label>
								<input type="tel" id="ReferencePhone3" name="ReferencePhone3">
							</div>
						</div>
					</div>
				</div>
			</div>

			<!--- Panel 8: Legal Attestation & Electronic Signature --->
			<div class="panel">
				<div class="panel-header">
					<span>8. Attestation &amp; Legal Signature</span>
					<span class="panel-badge" style="background:#fee2e2; color:#b91c1c;">Attestation</span>
				</div>
				<div class="panel-body">
					<p style="font-size:0.875rem; color:var(--text-muted); line-height:1.6; margin-bottom:1.25rem;">
						&ldquo;I certify that answers given herein are true and complete to the best of my knowledge. I authorize investigation of all statements contained in this application for employment as may be necessary in arriving at an employment decision. In the event of employment, I understand that false or misleading information given in my application or interview(s) may result in discharge.&rdquo;
					</p>

					<div style="background:#f1f5f9; padding:1.25rem; border-radius:8px; border:1px solid var(--border);">
						<div class="form-group" style="margin-bottom:0.75rem;">
							<label style="display:inline-flex; align-items:center; gap:0.5rem; cursor:pointer; font-weight:700;">
								<input type="checkbox" name="Certification" value="1" required checked style="width:auto;">
								<span>I certify and agree to the above terms (Certification) <span style="color:var(--danger);">*</span></span>
							</label>
						</div>

						<div class="form-group" style="margin-bottom:0;">
							<label for="Signature">Electronic Signature (Type Full Legal Name) <span style="color:var(--danger);">*</span></label>
							<input type="text" id="Signature" name="Signature" placeholder="First M. Last" required style="font-family:'Courier New', monospace; font-size:1.1rem; font-weight:700; color:var(--primary);">
						</div>
					</div>
				</div>
			</div>

			<!--- Submission Action Card --->
			<div class="panel" style="background:#ffffff; border-top:3px solid var(--primary); text-align:center;">
				<div class="panel-body" style="padding:2rem;">
					<button type="submit" id="btnSubmitApp" class="btn btn-primary" style="padding:1rem 3.5rem; font-size:1.1rem; box-shadow:0 4px 12px rgba(0, 115, 170, 0.25);">
						Submit Official Application &rarr;
					</button>
					<div id="submitResultMsg" style="display:none; margin-top:1.5rem; font-weight:600; font-size:1rem;"></div>
					<div style="font-size:0.8rem; color:var(--text-muted); margin-top:1rem;">
						Your submitted dossier will be delivered securely to the Chelan County Human Resources Department.
					</div>
				</div>
			</div>

		</form>

	</main>

	<footer style="border-top:1px solid var(--border); padding:2rem 1rem; text-align:center; font-size:0.8rem; color:var(--text-muted); background:var(--surface);">
		<div>Chelan County Human Resources Management &bull; 400 Douglas St, Wenatchee, WA 98801 &bull; (509) 667-6400</div>
		<div style="margin-top:0.35rem;">Chelan County is an Equal Opportunity Employer (EOE) &bull; ADA Title II / Section 508 Compliant</div>
	</footer>

	<script>
	document.getElementById("employmentApplicationForm").addEventListener("submit", function(e) {
		e.preventDefault();
		var btn = document.getElementById("btnSubmitApp");
		var msg = document.getElementById("submitResultMsg");
		btn.disabled = true;
		btn.innerText = "Submitting Application...";

		var formData = new FormData(this);
		var params = new URLSearchParams(formData);

		fetch("/careers/submit", {
			method: "POST",
			headers: {
				"X-Requested-With": "XMLHttpRequest",
				"Content-Type": "application/x-www-form-urlencoded"
			},
			body: params.toString()
		})
		.then(function(res) { return res.json(); })
		.then(function(data) {
			if (data.success) {
				document.getElementById("employmentApplicationForm").style.display = "none";
				msg.style.display = "block";
				msg.style.color = "var(--success)";
				msg.innerHTML = '<div style="font-size:1.5rem; margin-bottom:0.75rem;">&#10004; Application Received!</div><div>' + data.message + '</div><div style="margin-top:1.5rem;"><a href="/careers" class="btn btn-primary">Return to Careers Portal</a></div>';
			} else {
				btn.disabled = false;
				btn.innerText = "Submit Official Application \u2192";
				msg.style.display = "block";
				msg.style.color = "var(--danger)";
				msg.innerText = data.message || "An error occurred during submission.";
			}
		})
		.catch(function(err) {
			console.error(err);
			btn.disabled = false;
			btn.innerText = "Submit Official Application \u2192";
			msg.style.display = "block";
			msg.style.color = "var(--danger)";
			msg.innerText = "Submission failed. Please check required fields and try again.";
		});
	});
	</script>

</body>
</html>
