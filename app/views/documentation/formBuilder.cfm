<cfset pageTitle = "Form Builder Guide for Beginners">

<style>
	.kb-layout { display:grid; grid-template-columns:minmax(0, 1fr) 230px; gap:1.25rem; align-items:start; }
	.kb-article { min-width:0; }
	.kb-section { padding:1.25rem; margin-bottom:1rem; scroll-margin-top:1rem; }
	.kb-section h2 { font-size:1.1rem; margin:0 0 0.65rem; }
	.kb-section h3 { font-size:0.95rem; margin:1rem 0 0.4rem; }
	.kb-section p, .kb-section li { color:var(--admin-text-muted); line-height:1.6; }
	.kb-section p { margin:0.4rem 0; }
	.kb-section ul, .kb-section ol { padding-left:1.25rem; margin:0.4rem 0; }
	.kb-toc { position:sticky; top:1rem; padding:1rem; }
	.kb-toc a { display:block; padding:0.35rem 0; color:var(--admin-text-muted); text-decoration:none; font-size:0.85rem; }
	.kb-toc a:hover, .kb-toc a:focus { color:var(--admin-primary); text-decoration:underline; }
	.kb-visual { display:block; width:100%; height:auto; border:1px solid var(--admin-border); border-radius:var(--radius-md); background:#f4f8fc; }
	.kb-caption { color:var(--admin-text-muted); font-size:0.8rem; margin-top:0.5rem; }
	.kb-note { border-left:4px solid var(--admin-info); background:var(--admin-info-light); padding:0.85rem 1rem; border-radius:var(--radius-sm); color:var(--admin-text-main); line-height:1.55; margin-top:0.85rem; }
	.kb-warning { border-left-color:var(--admin-warning); background:var(--admin-warning-light); }
	.kb-steps { display:grid; grid-template-columns:repeat(3, minmax(0, 1fr)); gap:0.75rem; margin-top:1rem; }
	.kb-step { padding:0.9rem; border:1px solid var(--admin-border); border-radius:var(--radius-md); background:var(--admin-bg); }
	.kb-step strong { display:block; margin-bottom:0.35rem; color:var(--admin-text-main); }
	.kb-step span { display:block; color:var(--admin-text-muted); font-size:0.85rem; line-height:1.5; }
	.kb-table-wrap { overflow-x:auto; }
	.kb-table { width:100%; border-collapse:collapse; font-size:0.88rem; }
	.kb-table th, .kb-table td { text-align:left; vertical-align:top; padding:0.6rem; border-bottom:1px solid var(--admin-border); }
	.kb-table th { color:var(--admin-text-main); }
	.kb-table td { color:var(--admin-text-muted); }
	@media print {
		.page-header, .kb-toc { display:none !important; }
		.kb-layout { display:block; }
		.kb-section { break-inside:avoid; box-shadow:none !important; }
	}
	@media (max-width: 850px) {
		.kb-layout { grid-template-columns:1fr; }
		.kb-toc { position:static; order:-1; }
		.kb-steps { grid-template-columns:1fr; }
	}
</style>

<div class="page-header">
	<div>
		<h1 class="page-title">Form Builder Guide for Beginners</h1>
		<ol class="breadcrumb" style="margin-top:0.35rem;">
			<li class="breadcrumb-item"><a href="<cfoutput>#urlFor(controller='main', action='index')#</cfoutput>">Home</a></li>
			<li class="breadcrumb-item"><a href="<cfoutput>#urlFor(controller='documentation', action='index')#</cfoutput>">Documentation</a></li>
			<li class="breadcrumb-item active">Form Builder Guide for Beginners</li>
		</ol>
	</div>
	<div class="page-actions" style="display:flex; gap:0.5rem;">
		<a href="<cfoutput>#urlFor(controller='forms', action='builder')#</cfoutput>" class="btn btn-primary btn-sm">Open Form Builder</a>
		<button type="button" id="printFormBuilderGuide" class="btn btn-outline btn-sm">Print this guide</button>
	</div>
</div>

<div class="kb-layout">
	<article class="kb-article">
		<section class="admin-card kb-section" id="overview" aria-labelledby="overviewTitle">
			<h2 id="overviewTitle">Welcome! You can build a form without coding.</h2>
			<p>Think of the builder like putting together a simple questionnaire: choose a question, place it on your form, and tell it what to say.</p>
			<figure style="margin:1rem 0 0;">
				<img class="kb-visual" src="/images/form-builder-guide.svg" alt="The Form Builder has three areas: Form Elements on the left, your form in the middle, and Settings on the right.">
				<figcaption class="kb-caption">Left: choose a building block. Middle: see your form. Right: edit the selected item.</figcaption>
			</figure>
			<div class="kb-steps" aria-label="The three parts of the Form Builder">
				<div class="kb-step"><strong>1. Choose</strong><span>Pick a question or layout item from Form Elements.</span></div>
				<div class="kb-step"><strong>2. Arrange</strong><span>See it appear on your form canvas in the middle.</span></div>
				<div class="kb-step"><strong>3. Edit</strong><span>Click the question, then adjust it in Settings.</span></div>
			</div>
		</section>

		<section class="admin-card kb-section" id="start" aria-labelledby="startTitle">
			<h2 id="startTitle">Make your first form</h2>
			<ol>
				<li>Choose <strong>Open Form Builder</strong> above, or use <strong>Form Builder → + Create / Builder Studio</strong> in the left menu.</li>
				<li>Start with the blank form, or select <strong>Templates</strong> for a head start. Choosing a template replaces what is currently on the canvas.</li>
				<li>Click <strong>Form Settings</strong> on the right. Add a title and a short description explaining what people should do.</li>
				<li>Choose a question from the left panel. Click to add it, or drag it onto the canvas.</li>
				<li>Click the question on the canvas. In <strong>Field Settings</strong>, write the label and decide if an answer is required.</li>
				<li>Repeat for your other questions. Click <strong>Preview Form</strong> and try it out.</li>
				<li>When it looks right, click <strong>Save Form</strong>. Wait until the status says <strong>Saved to database</strong>.</li>
			</ol>
			<div class="kb-note kb-warning"><strong>Important:</strong> New forms are currently saved as published and may be publicly viewable. Review your form before saving, and check with your CMS administrator before sharing its link.</div>
		</section>

		<section class="admin-card kb-section" id="fields" aria-labelledby="fieldsTitle">
			<h2 id="fieldsTitle">Which question should I choose?</h2>
			<div class="kb-table-wrap">
				<table class="kb-table">
					<thead><tr><th>Choose</th><th>Use it for</th></tr></thead>
					<tbody>
						<tr><td><strong>Short Text</strong></td><td>Name, subject, or a short answer.</td></tr>
						<tr><td><strong>Email</strong> or <strong>Phone</strong></td><td>Contact details.</td></tr>
						<tr><td><strong>Paragraph (Long Text)</strong></td><td>A longer written answer.</td></tr>
						<tr><td><strong>Dropdown</strong></td><td>One answer from a list that opens when clicked.</td></tr>
						<tr><td><strong>Radio Group</strong></td><td>One answer from a few choices shown on screen.</td></tr>
						<tr><td><strong>Checkboxes</strong></td><td>One or more answers from a list.</td></tr>
						<tr><td><strong>Number</strong> or <strong>Date Picker</strong></td><td>A number or a calendar date.</td></tr>
						<tr><td><strong>File Upload</strong></td><td>A document or image attachment.</td></tr>
						<tr><td><strong>Address Block</strong>, <strong>Star Rating</strong>, or <strong>Signature</strong></td><td>An address, a rating, or a signature.</td></tr>
						<tr><td><strong>Section Title</strong>, <strong>Text / Instructions</strong>, or <strong>Divider</strong></td><td>Break up the form or explain something. These do not collect answers.</td></tr>
					</tbody>
				</table>
			</div>
			<p>For a dropdown, radio group, or checkbox question, select the question and add its choices in <strong>Field Settings</strong>.</p>
			<h3>Move, copy, or remove a question</h3>
			<p>Click a question on the canvas to see its small toolbar. Use the arrows to move it, the copy button to duplicate it, or the delete button to remove it.</p>
		</section>

		<section class="admin-card kb-section" id="settings" aria-labelledby="settingsTitle">
			<h2 id="settingsTitle">Make it clear and easy to fill in</h2>
			<ul>
				<li>Use a short, plain-language label: “What is your email address?” is clearer than “Email”.</li>
				<li>Turn on <strong>Required</strong> only when someone must answer before submitting.</li>
				<li>Use help text to explain what belongs in an answer or how to find it.</li>
				<li>Use <strong>100%</strong> width for long questions. Short fields can sit side-by-side at <strong>50%</strong> or <strong>33%</strong>.</li>
				<li>Choose <strong>Form Settings</strong> for the form title, department, button text, theme, confirmation message, and alert email.</li>
			</ul>
			<p>The department may suggest an alert email and theme color. Confirm the email is right for your team.</p>
		</section>

		<section class="admin-card kb-section" id="preview" aria-labelledby="previewTitle">
			<h2 id="previewTitle">Preview before you share</h2>
			<p>Use <strong>Preview Form</strong> to test questions and required answers. The desktop, tablet, and phone buttons above the canvas show how the layout changes at different sizes.</p>
			<ul>
				<li>Try every answer choice and make sure it says what you mean.</li>
				<li>Check that required questions are not marked by mistake.</li>
				<li>Switch to phone view. Long questions are usually easier to read at full width.</li>
				<li>Ask a coworker to review the wording and alert email.</li>
			</ul>
			<div class="kb-note">The preview helps you test the form. It does not confirm that alert emails or a production publishing workflow are configured. Check with your CMS administrator before distributing a form.</div>
		</section>

		<section class="admin-card kb-section" id="save-share" aria-labelledby="saveShareTitle">
			<h2 id="saveShareTitle">Save and find your form later</h2>
			<ul>
				<li><strong>Save Form</strong> saves to the CMS database. Look for <strong>Saved to database</strong> before leaving the page.</li>
				<li>After saving, the address bar includes an ID. Bookmark that address to come back to edit your form.</li>
				<li>You can also find your saved forms on the <strong>Forms</strong> page.</li>
				<li><strong>Share &amp; Embed</strong> shows the preview link and code for embedding. It also offers HTML and JSON downloads.</li>
				<li>Use the trash-can button beside a saved form on the Forms page to remove it from the list. It stops accepting new submissions, while existing submissions and audit history are kept.</li>
				<li><strong>Reset Canvas</strong> clears the form you are working on. It does not delete other saved forms.</li>
			</ul>
			<div class="kb-note kb-warning"><strong>Before sharing:</strong> New forms are currently published when saved. Please have your team review the contents first. Confirm with your CMS administrator that any email notifications and publishing settings are ready.</div>
		</section>

		<section class="admin-card kb-section" id="help" aria-labelledby="helpTitle">
			<h2 id="helpTitle">If something does not look right</h2>
			<ul>
				<li><strong>Can’t find the form?</strong> Open the Forms page and search by title. Confirm you saw “Saved to database”.</li>
				<li><strong>Can’t save?</strong> Give the form a title, check the selected workspace, and read the error next to the save status.</li>
				<li><strong>No dropdown choices?</strong> Select that question and add choices in Field Settings.</li>
				<li><strong>Phone layout feels crowded?</strong> Switch the canvas to phone view and make long questions full width.</li>
			</ul>
		</section>
	</article>

	<nav class="admin-card kb-toc" aria-label="Form Builder guide contents">
		<strong style="display:block; margin-bottom:0.35rem;">In this guide</strong>
		<a href="#overview">The screen</a>
		<a href="#start">Make your first form</a>
		<a href="#fields">Choose questions</a>
		<a href="#settings">Make it clear</a>
		<a href="#preview">Preview</a>
		<a href="#save-share">Save and share</a>
		<a href="#help">Quick fixes</a>
	</nav>
</div>

<script>
	document.getElementById("printFormBuilderGuide").addEventListener("click", function() {
		window.print();
	});
</script>
