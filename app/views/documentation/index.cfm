<cfset pageTitle = "Documentation &amp; Help Center">

<div class="page-header">
	<div>
		<h1 class="page-title">Documentation &amp; Help Center</h1>
		<ol class="breadcrumb" style="margin-top:0.35rem;">
			<li class="breadcrumb-item"><a href="<cfoutput>#urlFor(controller='main', action='index')#</cfoutput>">Home</a></li>
			<li class="breadcrumb-item active">Documentation</li>
		</ol>
	</div>
</div>

<section class="admin-card" aria-labelledby="kbIntroTitle" style="margin-bottom:1.25rem;">
	<div class="card-body" style="padding:1.5rem;">
		<h2 id="kbIntroTitle" style="margin:0 0 0.5rem; font-size:1.15rem;">CMS Admin Knowledge Base</h2>
		<p style="margin:0; color:var(--admin-text-muted); line-height:1.6;">
			Find practical instructions for working in CMS Admin. Guides are being added as each tool is completed.
		</p>
	</div>
</section>

<section aria-labelledby="kbGuidesTitle">
	<h2 id="kbGuidesTitle" style="font-size:1rem; margin:0 0 0.75rem;">Available guides</h2>
	<article class="admin-card">
		<div class="card-body" style="padding:1.25rem; display:flex; align-items:center; justify-content:space-between; gap:1rem; flex-wrap:wrap;">
			<div>
				<span class="badge badge-primary">Content Management</span>
				<h3 style="font-size:1.05rem; margin:0.6rem 0 0.3rem;">Form Builder Guide for Beginners</h3>
				<p style="margin:0; color:var(--admin-text-muted); line-height:1.5;">
					Follow a visual, step-by-step walkthrough to create, preview, save, and share a form. A separate technical reference documents the database design.
				</p>
			</div>
			<a href="<cfoutput>#urlFor(controller='documentation', action='formBuilder')#</cfoutput>" class="btn btn-primary btn-sm">
				Read the guide
			</a>
		</div>
	</article>
</section>
