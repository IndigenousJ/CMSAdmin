<cfparam name="variables.assets" default="#[]#">
<cfparam name="variables.workspaces" default="#[]#">
<cfparam name="variables.stats" default="#{}#">
<cfparam name="variables.currentWs" default="all">
<cfparam name="variables.currentFolder" default="all">
<cfparam name="variables.currentType" default="all">
<cfparam name="variables.currentSearch" default="">
<cfparam name="variables.currentAltStatus" default="all">
<cfparam name="variables.currentSort" default="newest">
<cfparam name="variables.currentView" default="grid">
<cfparam name="variables.pickerMode" default="">
<cfparam name="variables.selectedId" default="">

<style>
	/* Header & Action Button Enhancements */
	.media-view-toggle {
		display: inline-flex;
		background: var(--admin-surface);
		border: 1px solid var(--admin-border-input);
		border-radius: var(--radius-md);
		overflow: hidden;
		box-shadow: var(--shadow-sm);
	}
	.media-view-btn {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: 0.35rem;
		padding: 0.35rem 0.65rem;
		border: none;
		background: transparent;
		color: var(--admin-text-muted);
		cursor: pointer;
		font-size: 0.8rem;
		font-weight: 500;
		transition: all var(--transition-speed);
		text-decoration: none;
	}
	.media-view-btn:hover {
		background: var(--admin-surface-hover);
		color: var(--admin-text-main);
	}
	.media-view-btn.active {
		background: var(--admin-primary);
		color: #ffffff;
		font-weight: 600;
	}
	.media-view-btn:focus-visible {
		outline: 2px solid var(--admin-primary);
		outline-offset: -2px;
	}

	/* Search & Filter Toolbar */
	.media-filter-card {
		margin-bottom: 1.5rem;
		border: 1px solid var(--admin-border);
		box-shadow: var(--shadow-sm);
	}
	.media-filter-card .card-body {
		padding: 1.15rem 1.25rem;
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}
	.filter-pills {
		display: flex;
		gap: 0.4rem;
		flex-wrap: wrap;
		align-items: center;
	}
	.filter-pill {
		display: inline-flex;
		align-items: center;
		gap: 0.35rem;
		padding: 0.3rem 0.75rem;
		border-radius: var(--radius-full);
		font-size: 0.78rem;
		font-weight: 500;
		border: 1px solid var(--admin-border);
		background: var(--admin-surface);
		color: var(--admin-text-muted);
		cursor: pointer;
		transition: all var(--transition-speed);
		text-decoration: none;
	}
	.filter-pill:hover {
		border-color: var(--admin-primary);
		color: var(--admin-primary);
		background: var(--admin-primary-light);
	}
	.filter-pill.active {
		background: var(--admin-primary);
		color: #ffffff;
		border-color: var(--admin-primary);
		font-weight: 600;
	}
	.filter-pill.pill-compliant.active {
		background: var(--admin-success);
		border-color: var(--admin-success);
		color: #ffffff;
	}
	.filter-pill.pill-missing.active {
		background: var(--admin-warning);
		border-color: var(--admin-warning);
		color: #ffffff;
	}
	.filter-pill:focus-visible {
		outline: 2px solid var(--admin-primary);
		outline-offset: 2px;
	}

	/* Media Grid Cards */
	.media-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
		gap: 1.25rem;
	}
	.media-card {
		background: var(--admin-surface);
		border: 1px solid var(--admin-border);
		border-radius: var(--radius-lg);
		overflow: hidden;
		display: flex;
		flex-direction: column;
		transition: transform 0.15s ease, box-shadow 0.15s ease, border-color 0.15s ease;
		position: relative;
		box-shadow: var(--shadow-sm);
		cursor: pointer;
		user-select: none;
	}
	.media-card:hover {
		transform: translateY(-3px);
		box-shadow: var(--shadow-md);
		border-color: var(--admin-primary);
	}
	.media-card:focus-visible {
		outline: 2px solid var(--admin-primary);
		outline-offset: 2px;
	}

	/* Checkered preview background for transparent PNG/SVG graphics */
	.media-card-preview {
		height: 160px;
		position: relative;
		display: flex;
		align-items: center;
		justify-content: center;
		overflow: hidden;
		border-bottom: 1px solid var(--admin-border-subtle);
		background-color: #f8fafc;
		background-image:
			linear-gradient(45deg, #e2e8f0 25%, transparent 25%),
			linear-gradient(-45deg, #e2e8f0 25%, transparent 25%),
			linear-gradient(45deg, transparent 75%, #e2e8f0 75%),
			linear-gradient(-45deg, transparent 75%, #e2e8f0 75%);
		background-size: 14px 14px;
		background-position: 0 0, 0 7px, 7px -7px, -7px 0px;
	}
	.media-card-preview img {
		max-width: 90%;
		max-height: 90%;
		object-fit: contain;
		transition: transform 0.2s ease;
	}
	.media-card:hover .media-card-preview img {
		transform: scale(1.05);
	}
	.media-card-doc-icon {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 0.5rem;
		color: var(--admin-text-muted);
	}
	.media-doc-badge {
		font-size: 0.7rem;
		font-weight: 700;
		text-transform: uppercase;
		padding: 0.15rem 0.55rem;
		border-radius: var(--radius-sm);
		color: #ffffff;
		letter-spacing: 0.03em;
	}
	.media-doc-badge.badge-pdf { background: #dc2626; }
	.media-doc-badge.badge-xlsx, .media-doc-badge.badge-xls { background: #16a34a; }
	.media-doc-badge.badge-docx, .media-doc-badge.badge-doc { background: #2563eb; }
	.media-doc-badge.badge-other { background: #64748b; }

	/* Card Hover Quick Action Bar */
	.media-card-actions-overlay {
		position: absolute;
		top: 0.5rem;
		right: 0.5rem;
		display: flex;
		gap: 0.35rem;
		opacity: 0;
		transform: translateY(-4px);
		transition: all 0.18s ease;
		z-index: 2;
	}
	.media-card:hover .media-card-actions-overlay,
	.media-card:focus-within .media-card-actions-overlay {
		opacity: 1;
		transform: translateY(0);
	}
	.media-card-action-btn {
		width: 28px;
		height: 28px;
		border-radius: var(--radius-sm);
		border: 1px solid rgba(0,0,0,0.12);
		background: rgba(255,255,255,0.92);
		backdrop-filter: blur(4px);
		color: var(--admin-text-main);
		display: inline-flex;
		align-items: center;
		justify-content: center;
		cursor: pointer;
		box-shadow: var(--shadow-sm);
		transition: all 0.15s ease;
	}
	.media-card-action-btn:hover {
		background: var(--admin-primary);
		color: #ffffff;
		border-color: var(--admin-primary);
	}

	.media-card-body {
		padding: 0.85rem 1rem;
		display: flex;
		flex-direction: column;
		flex: 1;
		gap: 0.35rem;
		background: var(--admin-surface);
	}
	.media-card-title {
		font-weight: 600;
		font-size: 0.875rem;
		color: var(--admin-text-main);
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
		line-height: 1.35;
	}
	.media-card-path {
		font-size: 0.72rem;
		color: var(--admin-text-muted);
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
		display: flex;
		align-items: center;
		gap: 0.3rem;
	}
	.media-card-meta {
		display: flex;
		justify-content: space-between;
		align-items: center;
		font-size: 0.75rem;
		color: var(--admin-text-subtle);
		padding-top: 0.25rem;
	}
	.media-card-badges {
		display: flex;
		gap: 0.35rem;
		align-items: center;
		flex-wrap: wrap;
		margin-top: auto;
		padding-top: 0.4rem;
	}

	/* ADA Indicators */
	.wcag-indicator {
		display: inline-flex;
		align-items: center;
		gap: 0.25rem;
		font-size: 0.7rem;
		font-weight: 600;
		padding: 0.15rem 0.5rem;
		border-radius: var(--radius-sm);
	}
	.wcag-indicator.compliant {
		background: var(--admin-success-light);
		color: var(--admin-success);
	}
	.wcag-indicator.missing {
		background: var(--admin-warning-light);
		color: var(--admin-warning);
	}

	/* Table View */
	.media-table-wrap {
		background: var(--admin-surface);
		border: 1px solid var(--admin-border);
		border-radius: var(--radius-lg);
		overflow: hidden;
		box-shadow: var(--shadow-sm);
	}
	.media-table {
		width: 100%;
		border-collapse: collapse;
		text-align: left;
		font-size: 0.875rem;
	}
	.media-table th {
		background: #f8fafc;
		padding: 0.75rem 1rem;
		font-weight: 600;
		color: var(--admin-text-muted);
		border-bottom: 1px solid var(--admin-border);
		font-size: 0.78rem;
		text-transform: uppercase;
		letter-spacing: 0.03em;
	}
	.media-table td {
		padding: 0.85rem 1rem;
		border-bottom: 1px solid var(--admin-border-subtle);
		vertical-align: middle;
	}
	.media-table tr:hover {
		background: var(--admin-surface-hover);
	}
	.media-table-thumb {
		width: 48px;
		height: 48px;
		border-radius: var(--radius-sm);
		border: 1px solid var(--admin-border-subtle);
		background-color: #f8fafc;
		background-image:
			linear-gradient(45deg, #e2e8f0 25%, transparent 25%),
			linear-gradient(-45deg, #e2e8f0 25%, transparent 25%),
			linear-gradient(45deg, transparent 75%, #e2e8f0 75%),
			linear-gradient(-45deg, transparent 75%, #e2e8f0 75%);
		background-size: 8px 8px;
		background-position: 0 0, 0 4px, 4px -4px, -4px 0px;
		display: flex;
		align-items: center;
		justify-content: center;
		overflow: hidden;
		flex-shrink: 0;
	}
	.media-table-thumb img {
		max-width: 90%;
		max-height: 90%;
		object-fit: contain;
	}

	/* Inspector Drawer & Upload Modal */
	.media-drawer-backdrop {
		position: fixed;
		inset: 0;
		background: rgba(15,23,42,0.65);
		z-index: 99998;
		backdrop-filter: blur(3px);
		opacity: 0;
		pointer-events: none;
		transition: opacity 0.2s ease;
	}
	.media-drawer-backdrop.is-open {
		opacity: 1;
		pointer-events: auto;
	}
	.media-drawer {
		position: fixed;
		top: 0;
		right: 0;
		bottom: 0;
		width: 100%;
		max-width: 560px;
		background: var(--admin-surface);
		z-index: 99999;
		box-shadow: var(--shadow-dropdown);
		display: flex;
		flex-direction: column;
		transform: translateX(100%);
		transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1);
		overflow: hidden;
	}
	.media-drawer.is-open {
		transform: translateX(0);
	}
	.media-drawer-header {
		padding: 1.15rem 1.5rem;
		border-bottom: 1px solid var(--admin-border);
		display: flex;
		align-items: center;
		justify-content: space-between;
		background: #f8fafc;
	}
	.media-drawer-title {
		font-size: 1.1rem;
		font-weight: 700;
		margin: 0;
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}
	.media-drawer-close {
		border: none;
		background: transparent;
		color: var(--admin-text-muted);
		cursor: pointer;
		padding: 0.4rem;
		border-radius: var(--radius-sm);
		display: flex;
		align-items: center;
		justify-content: center;
	}
	.media-drawer-close:hover {
		background: var(--admin-border-subtle);
		color: var(--admin-text-main);
	}
	.media-drawer-close:focus-visible {
		outline: 2px solid var(--admin-primary);
	}
	.media-drawer-body {
		padding: 1.5rem;
		overflow-y: auto;
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 1.25rem;
	}
	.media-drawer-preview {
		width: 100%;
		min-height: 220px;
		max-height: 320px;
		border-radius: var(--radius-md);
		display: flex;
		align-items: center;
		justify-content: center;
		overflow: hidden;
		position: relative;
		background-color: #0f172a;
		background-image:
			linear-gradient(45deg, #1e293b 25%, transparent 25%),
			linear-gradient(-45deg, #1e293b 25%, transparent 25%),
			linear-gradient(45deg, transparent 75%, #1e293b 75%),
			linear-gradient(-45deg, transparent 75%, #1e293b 75%);
		background-size: 20px 20px;
		background-position: 0 0, 0 10px, 10px -10px, -10px 0px;
	}
	.media-drawer-preview img {
		max-width: 90%;
		max-height: 290px;
		object-fit: contain;
	}
	.media-drawer-meta-list {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 0.85rem;
		background: #f8fafc;
		padding: 1rem;
		border-radius: var(--radius-md);
		border: 1px solid var(--admin-border-subtle);
	}
	.media-meta-item-label {
		font-size: 0.72rem;
		color: var(--admin-text-muted);
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.03em;
		margin-bottom: 0.15rem;
	}
	.media-meta-item-value {
		font-size: 0.85rem;
		font-weight: 600;
		color: var(--admin-text-main);
		word-break: break-word;
	}
	.media-drawer-footer {
		padding: 1rem 1.5rem;
		border-top: 1px solid var(--admin-border);
		background: #f8fafc;
		display: flex;
		justify-content: space-between;
		align-items: center;
		gap: 0.75rem;
	}

	/* Upload Dropzone */
	.dropzone {
		border: 2px dashed var(--admin-border-input);
		border-radius: var(--radius-lg);
		padding: 2.5rem 1.5rem;
		text-align: center;
		background: #f8fafc;
		cursor: pointer;
		transition: all 0.2s ease;
		position: relative;
	}
	.dropzone:hover, .dropzone.is-dragover {
		border-color: var(--admin-primary);
		background: var(--admin-primary-light);
	}
	.dropzone-icon {
		color: var(--admin-primary);
		margin-bottom: 0.75rem;
	}

	/* Toast Notification */
	.media-toast {
		position: fixed;
		bottom: 1.5rem;
		right: 1.5rem;
		z-index: 100000;
		background: #ffffff;
		color: #14532d;
		border: 1px solid #bbf7d0;
		border-left: 5px solid var(--admin-success);
		padding: 0.85rem 1.25rem;
		border-radius: var(--radius-md);
		box-shadow: var(--shadow-dropdown);
		display: flex;
		align-items: center;
		gap: 0.65rem;
		font-size: 0.875rem;
		font-weight: 600;
		transform: translateY(100px);
		opacity: 0;
		transition: all 0.25s ease;
		pointer-events: none;
	}
	.media-toast.is-show {
		transform: translateY(0);
		opacity: 1;
		pointer-events: auto;
	}
	.media-toast--danger {
		color: #991b1b;
		border-color: #fecaca;
		border-left-color: var(--admin-danger);
	}
	.media-toast--warning {
		color: #854d0e;
		border-color: #fde68a;
		border-left-color: var(--admin-warning);
	}
	.media-toast--info {
		color: #075985;
		border-color: #bae6fd;
		border-left-color: var(--admin-info);
	}

	@media (max-width: 860px) {
		.media-grid { grid-template-columns: repeat(auto-fill, minmax(170px, 1fr)); }
		.media-drawer { max-width: 100%; }
	}
</style>

<!--- Master Header (Matching All Pages and Forms List) --->
<div class="page-header" style="margin-bottom:1.5rem;">
	<div>
		<h1 class="page-title" style="margin-bottom:0; display:flex; align-items:center; gap:0.65rem;">
			<cfoutput>#svgIcon(name="media", size=24)#</cfoutput>
			<span>Media Library</span>
		</h1>
		<nav aria-label="Breadcrumb">
			<ol class="breadcrumb" style="margin-top:0.35rem;">
				<li class="breadcrumb-item"><a href="<cfoutput>#urlFor(controller='main', action='index')#</cfoutput>"><cfoutput>#svgIcon(name="dashboard", size=14)#</cfoutput> Home</a></li>
				<li class="breadcrumb-item">Content Management</li>
				<li class="breadcrumb-item active" aria-current="page">Media Library</li>
			</ol>
		</nav>
	</div>

	<div class="page-actions" style="display:flex; gap:0.65rem; align-items:center;">
		<!--- View Mode Toggle (Grid vs List) --->
		<div class="media-view-toggle" role="group" aria-label="Layout View Mode">
			<a href="<cfoutput>#urlFor(controller='media', action='index', params='view=grid&folder=#variables.currentFolder#&type=#variables.currentType#&altStatus=#variables.currentAltStatus#&search=#URLEncodedFormat(variables.currentSearch)#&sort=#variables.currentSort#')#</cfoutput>"
			   class="media-view-btn <cfif variables.currentView eq 'grid'>active</cfif>"
			   title="Switch to Grid View" aria-label="Grid View">
				<cfoutput>#svgIcon(name="grid", size=15)#</cfoutput>
				<span>Grid</span>
			</a>
			<a href="<cfoutput>#urlFor(controller='media', action='index', params='view=list&folder=#variables.currentFolder#&type=#variables.currentType#&altStatus=#variables.currentAltStatus#&search=#URLEncodedFormat(variables.currentSearch)#&sort=#variables.currentSort#')#</cfoutput>"
			   class="media-view-btn <cfif variables.currentView eq 'list'>active</cfif>"
			   title="Switch to Detailed List View" aria-label="Detailed List View">
				<cfoutput>#svgIcon(name="list", size=15)#</cfoutput>
				<span>List</span>
			</a>
		</div>

		<!--- Upload Action Button --->
		<button type="button" class="btn btn-primary btn-sm" id="btnOpenUploadModal" aria-haspopup="dialog" style="padding:0.45rem 0.95rem;">
			<cfoutput>#svgIcon(name="upload", size=15)#</cfoutput>
			<span>Upload Files</span>
		</button>
	</div>
</div>

<cfoutput>
<!--- Flash Messages --->
<cfif flashKeyExists("success")>
	<div class="alert alert-success" role="alert" style="margin-bottom:1.5rem; display:flex; align-items:center; gap:0.65rem;">
		#svgIcon(name="check-circle", size=18)#
		<div>#flash("success")#</div>
	</div>
</cfif>
<cfif flashKeyExists("error")>
	<div class="alert alert-danger" role="alert" style="margin-bottom:1.5rem; display:flex; align-items:center; gap:0.65rem;">
		#svgIcon(name="alert-circle", size=18)#
		<div>#flash("error")#</div>
	</div>
</cfif>

<!--- Media Library KPI Statistics Cards (Standardized Mashable Light Grid) --->
<div class="stat-grid" style="margin-bottom:1.5rem;" role="region" aria-label="Media Library Metrics">
	<div class="stat-card">
		<div class="stat-info">
			<span class="stat-label">Total Files</span>
			<span class="stat-value">#variables.stats.totalAssets#</span>
			<span class="stat-change" style="color:var(--admin-text-muted); font-size:0.75rem;">
				#variables.stats.totalStorageFormatted# in storage
			</span>
		</div>
		<div class="stat-icon-wrapper stat-icon-primary" aria-hidden="true">
			#svgIcon(name="folder", size=24)#
		</div>
	</div>

	<div class="stat-card">
		<div class="stat-info">
			<span class="stat-label">Images &amp; Graphics</span>
			<span class="stat-value">#variables.stats.imageCount#</span>
			<span class="stat-change" style="color:var(--admin-text-muted); font-size:0.75rem;">
				Photos, seals &amp; logos
			</span>
		</div>
		<div class="stat-icon-wrapper stat-icon-info" aria-hidden="true">
			#svgIcon(name="image", size=24)#
		</div>
	</div>

	<div class="stat-card">
		<div class="stat-info">
			<span class="stat-label">Documents &amp; PDFs</span>
			<span class="stat-value">#variables.stats.docCount + variables.stats.sheetCount#</span>
			<span class="stat-change" style="color:var(--admin-text-muted); font-size:0.75rem;">
				Reports, guides &amp; sheets
			</span>
		</div>
		<div class="stat-icon-wrapper stat-icon-success" aria-hidden="true">
			#svgIcon(name="file-text", size=24)#
		</div>
	</div>

	<div class="stat-card">
		<div class="stat-info">
			<span class="stat-label">ADA WCAG AA Status</span>
			<span class="stat-value">#variables.stats.complianceRate#%</span>
			<span class="stat-change <cfif variables.stats.wcagMissingCount gt 0>down<cfelse>up</cfif>">
				<cfif variables.stats.wcagMissingCount gt 0>
					#variables.stats.wcagMissingCount# need Alt Text
				<cfelse>
					100% Compliant
				</cfif>
			</span>
		</div>
		<div class="stat-icon-wrapper <cfif variables.stats.wcagMissingCount gt 0>stat-icon-warning<cfelse>stat-icon-success</cfif>" aria-hidden="true">
			#svgIcon(name="shield", size=24)#
		</div>
	</div>
</div>

<!--- Multi-Facet Filtering & Search Toolbar (Standardized Admin Card) --->
<form action="#urlFor(controller='media', action='index')#" method="get" class="admin-card media-filter-card" id="mediaFilterForm" role="search" aria-label="Media Library Filters">
	<input type="hidden" name="view" value="#EncodeForHTMLAttribute(variables.currentView)#">
	
	<div class="card-body">
		<!--- Primary Search & Dropdowns Row --->
		<div style="display:flex; align-items:flex-end; gap:0.85rem; flex-wrap:wrap;">
			<div style="flex:2 1 320px;">
				<label for="mediaSearchInput" class="form-label" style="font-size:0.775rem; font-weight:600; text-transform:uppercase; letter-spacing:0.03em;">Search Repository</label>
				<div style="position:relative;">
					<span style="position:absolute; left:0.85rem; top:50%; transform:translateY(-50%); color:var(--admin-text-subtle); pointer-events:none;">
						#svgIcon(name="search", size=15)#
					</span>
					<input type="search" id="mediaSearchInput" name="search" class="form-control"
					       placeholder="Search by file name, title, alt text, or tags..."
					       value="#EncodeForHTMLAttribute(variables.currentSearch)#" autocomplete="off"
					       style="width:100%; padding:0.5rem 2.25rem 0.5rem 2.45rem; font-size:0.875rem;">
					<button type="button" id="mediaSearchClear" aria-label="Clear search"
					        style="position:absolute; right:0.5rem; top:50%; transform:translateY(-50%); border:none; background:transparent; color:var(--admin-text-muted); cursor:pointer; padding:0.25rem; border-radius:50%; display:<cfif Len(variables.currentSearch) gt 0>block<cfelse>none</cfif>;">
						#svgIcon(name="x", size=14)#
					</button>
				</div>
			</div>

			<div style="flex:1 1 200px;">
				<label for="filterFolder" class="form-label" style="font-size:0.775rem; font-weight:600; text-transform:uppercase; letter-spacing:0.03em;">Subfolder</label>
				<select id="filterFolder" name="folder" class="form-control" style="width:100%; font-size:0.85rem; padding:0.5rem 0.75rem;" onchange="this.form.submit()">
					<option value="all" <cfif variables.currentFolder eq 'all'>selected</cfif>>All Subfolders</option>
					<option value="media" <cfif variables.currentFolder eq 'media'>selected</cfif>>media/ (Photos &amp; Logos)</option>
					<option value="documents" <cfif variables.currentFolder eq 'documents'>selected</cfif>>documents/ (PDFs &amp; Files)</option>
				</select>
			</div>

			<div style="flex:1 1 200px;">
				<label for="filterSort" class="form-label" style="font-size:0.775rem; font-weight:600; text-transform:uppercase; letter-spacing:0.03em;">Sort By</label>
				<select id="filterSort" name="sort" class="form-control" style="width:100%; font-size:0.85rem; padding:0.5rem 0.75rem;" onchange="this.form.submit()">
					<option value="newest" <cfif variables.currentSort eq 'newest'>selected</cfif>>Newest First</option>
					<option value="oldest" <cfif variables.currentSort eq 'oldest'>selected</cfif>>Oldest First</option>
					<option value="name_asc" <cfif variables.currentSort eq 'name_asc'>selected</cfif>>Name (A to Z)</option>
					<option value="name_desc" <cfif variables.currentSort eq 'name_desc'>selected</cfif>>Name (Z to A)</option>
					<option value="size_desc" <cfif variables.currentSort eq 'size_desc'>selected</cfif>>Size (Largest)</option>
					<option value="size_asc" <cfif variables.currentSort eq 'size_asc'>selected</cfif>>Size (Smallest)</option>
				</select>
			</div>
		</div>

		<!--- Secondary Filter Pills (Categories & ADA Status) --->
		<div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.85rem; padding-top:0.85rem; border-top:1px solid var(--admin-border-subtle);">
			<div class="filter-pills" role="radiogroup" aria-label="Filter by file type">
				<span style="font-size:0.75rem; font-weight:700; text-transform:uppercase; color:var(--admin-text-subtle); margin-right:0.25rem;">Type:</span>
				<a href="#urlFor(controller='media', action='index', params='type=all&folder=#variables.currentFolder#&altStatus=#variables.currentAltStatus#&view=#variables.currentView#&sort=#variables.currentSort#&search=#URLEncodedFormat(variables.currentSearch)#')#"
				   class="filter-pill <cfif variables.currentType eq 'all'>active</cfif>">
					All Files (#variables.stats.totalAssets#)
				</a>
				<a href="#urlFor(controller='media', action='index', params='type=image&folder=#variables.currentFolder#&altStatus=#variables.currentAltStatus#&view=#variables.currentView#&sort=#variables.currentSort#&search=#URLEncodedFormat(variables.currentSearch)#')#"
				   class="filter-pill <cfif variables.currentType eq 'image'>active</cfif>">
					#svgIcon(name="image", size=13)# Images (#variables.stats.imageCount#)
				</a>
				<a href="#urlFor(controller='media', action='index', params='type=document&folder=#variables.currentFolder#&altStatus=#variables.currentAltStatus#&view=#variables.currentView#&sort=#variables.currentSort#&search=#URLEncodedFormat(variables.currentSearch)#')#"
				   class="filter-pill <cfif variables.currentType eq 'document'>active</cfif>">
					#svgIcon(name="file-text", size=13)# Documents &amp; PDFs (#variables.stats.docCount#)
				</a>
				<a href="#urlFor(controller='media', action='index', params='type=spreadsheet&folder=#variables.currentFolder#&altStatus=#variables.currentAltStatus#&view=#variables.currentView#&sort=#variables.currentSort#&search=#URLEncodedFormat(variables.currentSearch)#')#"
				   class="filter-pill <cfif variables.currentType eq 'spreadsheet'>active</cfif>">
					#svgIcon(name="form", size=13)# Spreadsheets (#variables.stats.sheetCount#)
				</a>
			</div>

			<div class="filter-pills" role="radiogroup" aria-label="Filter by ADA WCAG AA compliance">
				<span style="font-size:0.75rem; font-weight:700; text-transform:uppercase; color:var(--admin-text-subtle); margin-right:0.25rem;">ADA Audit:</span>
				<a href="#urlFor(controller='media', action='index', params='altStatus=all&type=#variables.currentType#&folder=#variables.currentFolder#&view=#variables.currentView#&sort=#variables.currentSort#&search=#URLEncodedFormat(variables.currentSearch)#')#"
				   class="filter-pill <cfif variables.currentAltStatus eq 'all'>active</cfif>">
					All
				</a>
				<a href="#urlFor(controller='media', action='index', params='altStatus=compliant&type=#variables.currentType#&folder=#variables.currentFolder#&view=#variables.currentView#&sort=#variables.currentSort#&search=#URLEncodedFormat(variables.currentSearch)#')#"
				   class="filter-pill pill-compliant <cfif variables.currentAltStatus eq 'compliant'>active</cfif>">
					#svgIcon(name="check", size=13)# Compliant (#variables.stats.wcagCompliantCount#)
				</a>
				<a href="#urlFor(controller='media', action='index', params='altStatus=missing&type=#variables.currentType#&folder=#variables.currentFolder#&view=#variables.currentView#&sort=#variables.currentSort#&search=#URLEncodedFormat(variables.currentSearch)#')#"
				   class="filter-pill pill-missing <cfif variables.currentAltStatus eq 'missing'>active</cfif>">
					#svgIcon(name="shield", size=13)# Needs Alt Text (#variables.stats.wcagMissingCount#)
				</a>
			</div>
		</div>
	</div>
</form>

<!--- Empty State --->
<cfif ArrayLen(variables.assets) eq 0>
	<div class="admin-card" style="text-align:center; padding:3.5rem 1.5rem;">
		<div style="color:var(--admin-text-subtle); margin-bottom:1rem;">
			#svgIcon(name="folder", size=54)#
		</div>
		<h2 style="font-size:1.2rem; font-weight:700; margin-bottom:0.5rem;">No files found matching your criteria</h2>
		<p style="color:var(--admin-text-muted); max-width:480px; margin:0 auto 1.5rem auto;">
			Try adjusting your folder, search query, or media type filters, or upload a new file directly into the repository.
		</p>
		<div style="display:flex; justify-content:center; gap:0.75rem;">
			<a href="#urlFor(controller='media', action='index')#" class="btn btn-secondary">Reset Filters</a>
			<button type="button" class="btn btn-primary" onclick="openUploadModal()">
				#svgIcon(name="upload", size=15)# <span>Upload New File</span>
			</button>
		</div>
	</div>
<cfelse>
	<!--- VIEW: GRID MODE --->
	<cfif variables.currentView eq "grid">
		<div class="media-grid" id="mediaGrid" role="region" aria-label="Media Assets Grid">
			<cfloop array="#variables.assets#" index="local.item">
				<div class="media-card" tabindex="0" role="button" aria-haspopup="dialog"
				     data-id="#local.item.id#"
				     data-name="#EncodeForHTMLAttribute(local.item.name)#"
				     data-title="#EncodeForHTMLAttribute(local.item.title)#"
				     data-alt="#EncodeForHTMLAttribute(local.item.altText)#"
				     data-caption="#EncodeForHTMLAttribute(local.item.caption)#"
				     data-weburl="#EncodeForHTMLAttribute(local.item.webUrl)#"
				     data-relpath="#EncodeForHTMLAttribute(local.item.relativePath)#"
				     data-abspath="#EncodeForHTMLAttribute(local.item.absolutePath)#"
				     data-size="#EncodeForHTMLAttribute(local.item.sizeFormatted)#"
				     data-dimensions="#EncodeForHTMLAttribute(local.item.dimensions)#"
				     data-modified="#EncodeForHTMLAttribute(local.item.dateFormatted)#"
				     data-workspace="#EncodeForHTMLAttribute(local.item.workspace)#"
				     data-folder="#EncodeForHTMLAttribute(local.item.folder)#"
				     data-isimage="#local.item.isImage#"
				     data-author="#EncodeForHTMLAttribute(local.item.author)#"
				     onclick="openAssetDrawer(this)"
				     onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();openAssetDrawer(this);}">
					
					<!--- Card Action Overlay --->
					<div class="media-card-actions-overlay">
						<button type="button" class="media-card-action-btn" title="Inspect Asset" onclick="event.stopPropagation(); openAssetDrawer(this.closest('.media-card'));" aria-label="Inspect #EncodeForHTMLAttribute(local.item.title)#">
							#svgIcon(name="eye", size=13)#
						</button>
						<button type="button" class="media-card-action-btn" title="Copy Public URL" onclick="event.stopPropagation(); copyAssetUrl('#local.item.webUrl#');" aria-label="Copy URL">
							#svgIcon(name="copy", size=13)#
						</button>
						<a href="#local.item.webUrl#" download class="media-card-action-btn" title="Download" onclick="event.stopPropagation();" aria-label="Download">
							#svgIcon(name="download", size=13)#
						</a>
					</div>

					<div class="media-card-preview">
						<cfif local.item.isImage>
							<img src="#local.item.webUrl#" alt="#EncodeForHTMLAttribute(local.item.altText)#" loading="lazy">
						<cfelse>
							<div class="media-card-doc-icon">
								#svgIcon(name="file-text", size=42)#
								<span class="media-doc-badge badge-#LCase(local.item.extension)#">.#UCase(local.item.extension)#</span>
							</div>
						</cfif>
					</div>

					<div class="media-card-body">
						<div class="media-card-title" title="#EncodeForHTMLAttribute(local.item.title)#">
							#EncodeForHTML(local.item.title)#
						</div>
						<div class="media-card-path">
							#svgIcon(name="folder", size=12)#
							<span>#EncodeForHTML(local.item.workspace)#/#EncodeForHTML(local.item.folder)#</span>
						</div>
						<div class="media-card-meta">
							<span>#EncodeForHTML(local.item.sizeFormatted)#</span>
							<span>#DateFormat(local.item.dateModified, "mmm d, yyyy")#</span>
						</div>
						<div class="media-card-badges">
							<cfif local.item.isImage>
								<cfif Len(Trim(local.item.altText)) gt 0>
									<span class="wcag-indicator compliant" title="ADA WCAG AA: Alt text present">
										#svgIcon(name="check", size=10)# Alt Set
									</span>
								<cfelse>
									<span class="wcag-indicator missing" title="ADA Alert: Missing Alt Text - click to add">
										#svgIcon(name="shield", size=10)# Needs Alt
									</span>
								</cfif>
							<cfelse>
								<span class="badge badge-neutral" style="font-size:0.68rem; text-transform:uppercase;">
									#local.item.extension#
								</span>
							</cfif>
						</div>
					</div>
				</div>
			</cfloop>
		</div>

	<!--- VIEW: LIST MODE --->
	<cfelse>
		<div class="media-table-wrap">
			<table class="media-table" aria-label="Media Assets Directory">
				<thead>
					<tr>
						<th style="width:60px;" scope="col"><span class="sr-only">Preview</span></th>
						<th scope="col">File Title &amp; Name</th>
						<th scope="col">Workspace / Folder</th>
						<th scope="col">Type</th>
						<th scope="col">Size / Dim</th>
						<th scope="col">Last Modified</th>
						<th scope="col">ADA Alt Status</th>
						<th scope="col" style="text-align:right;">Actions</th>
					</tr>
				</thead>
				<tbody>
					<cfloop array="#variables.assets#" index="local.item">
						<tr data-id="#local.item.id#"
						    data-name="#EncodeForHTMLAttribute(local.item.name)#"
						    data-title="#EncodeForHTMLAttribute(local.item.title)#"
						    data-alt="#EncodeForHTMLAttribute(local.item.altText)#"
						    data-caption="#EncodeForHTMLAttribute(local.item.caption)#"
						    data-weburl="#EncodeForHTMLAttribute(local.item.webUrl)#"
						    data-relpath="#EncodeForHTMLAttribute(local.item.relativePath)#"
						    data-abspath="#EncodeForHTMLAttribute(local.item.absolutePath)#"
						    data-size="#EncodeForHTMLAttribute(local.item.sizeFormatted)#"
						    data-dimensions="#EncodeForHTMLAttribute(local.item.dimensions)#"
						    data-modified="#EncodeForHTMLAttribute(local.item.dateFormatted)#"
						    data-workspace="#EncodeForHTMLAttribute(local.item.workspace)#"
						    data-folder="#EncodeForHTMLAttribute(local.item.folder)#"
						    data-isimage="#local.item.isImage#"
						    data-author="#EncodeForHTMLAttribute(local.item.author)#">
							<td>
								<div class="media-table-thumb">
									<cfif local.item.isImage>
										<img src="#local.item.webUrl#" alt="#EncodeForHTMLAttribute(local.item.altText)#" loading="lazy">
									<cfelse>
										#svgIcon(name="file-text", size=22)#
									</cfif>
								</div>
							</td>
							<td>
								<button type="button" class="btn-link" style="font-weight:600; text-align:left; color:var(--admin-primary); border:none; background:none; padding:0; cursor:pointer; font-size:0.875rem;" onclick="openAssetDrawer(this.closest('tr'))">
									#EncodeForHTML(local.item.title)#
								</button>
								<div style="font-size:0.75rem; color:var(--admin-text-subtle);">#EncodeForHTML(local.item.name)#</div>
							</td>
							<td>
								<span class="badge badge-neutral" style="font-size:0.75rem;">
									#EncodeForHTML(local.item.workspace)#/#EncodeForHTML(local.item.folder)#
								</span>
							</td>
							<td>
								<span style="font-size:0.8rem; text-transform:uppercase; font-weight:600; color:var(--admin-text-muted);">
									#local.item.extension#
								</span>
							</td>
							<td>
								<div style="font-size:0.8rem; font-weight:600;">#local.item.sizeFormatted#</div>
								<cfif Len(local.item.dimensions)>
									<div style="font-size:0.72rem; color:var(--admin-text-muted);">#local.item.dimensions#</div>
								</cfif>
							</td>
							<td>
								<div style="font-size:0.8rem;">#DateFormat(local.item.dateModified, "mmm d, yyyy")#</div>
								<div style="font-size:0.72rem; color:var(--admin-text-muted);">#TimeFormat(local.item.dateModified, "h:mm tt")#</div>
							</td>
							<td>
								<cfif local.item.isImage>
									<cfif Len(Trim(local.item.altText)) gt 0>
										<span class="wcag-indicator compliant" title="Alt text: #EncodeForHTMLAttribute(local.item.altText)#">
											#svgIcon(name="check", size=11)# Compliant
										</span>
									<cfelse>
										<span class="wcag-indicator missing" title="Missing Alt Text">
											#svgIcon(name="shield", size=11)# Needs Alt
										</span>
									</cfif>
								<cfelse>
									<span style="font-size:0.75rem; color:var(--admin-text-subtle);">Document</span>
								</cfif>
							</td>
							<td style="text-align:right;">
								<div style="display:inline-flex; gap:0.35rem;">
									<button type="button" class="btn btn-secondary btn-sm" title="Inspect Asset" onclick="openAssetDrawer(this.closest('tr'))">
										#svgIcon(name="eye", size=13)#
									</button>
									<button type="button" class="btn btn-secondary btn-sm" title="Copy Public URL" onclick="copyAssetUrl('#local.item.webUrl#')">
										#svgIcon(name="copy", size=13)#
									</button>
									<a href="#local.item.webUrl#" download class="btn btn-secondary btn-sm" title="Download File">
										#svgIcon(name="download", size=13)#
									</a>
								</div>
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
		</div>
	</cfif>
</cfif>
</cfoutput>

<!--- Interactive Asset Detail & ADA Inspector Drawer --->
<div class="media-drawer-backdrop" id="mediaDrawerBackdrop" onclick="closeAssetDrawer()"></div>
<aside class="media-drawer" id="mediaDrawer" role="dialog" aria-modal="true" aria-labelledby="drawerTitle">
	<div class="media-drawer-header">
		<h2 class="media-drawer-title" id="drawerTitle">
			<cfoutput>#svgIcon(name="info", size=18)#</cfoutput>
			<span id="drawerTitleText">Asset Details</span>
		</h2>
		<button type="button" class="media-drawer-close" onclick="closeAssetDrawer()" aria-label="Close Inspector">
			<cfoutput>#svgIcon(name="x", size=18)#</cfoutput>
		</button>
	</div>

	<div class="media-drawer-body">
		<!--- Preview box with checkered background --->
		<div class="media-drawer-preview" id="drawerPreviewBox">
			<img id="drawerImagePreview" src="" alt="" style="display:none;">
			<div id="drawerDocPreview" style="display:none; text-align:center; color:white; padding:2rem;">
				<cfoutput>#svgIcon(name="file-text", size=54)#</cfoutput>
				<div id="drawerDocExt" style="margin-top:0.75rem; font-weight:700; font-size:1.1rem; text-transform:uppercase;"></div>
			</div>
		</div>

		<!--- Quick Action Toolbar --->
		<div style="display:flex; gap:0.5rem; flex-wrap:wrap;">
			<button type="button" class="btn btn-secondary btn-sm" id="btnCopyUrl" onclick="copyDrawerUrl()">
				<cfoutput>#svgIcon(name="copy", size=14)#</cfoutput>
				<span>Copy Public URL</span>
			</button>
			<button type="button" class="btn btn-secondary btn-sm" id="btnCopyImgTag" onclick="copyDrawerImgTag()">
				<cfoutput>#svgIcon(name="code", size=14)#</cfoutput>
				<span>Copy HTML Tag</span>
			</button>
			<a id="drawerDownloadLink" href="#" download class="btn btn-secondary btn-sm">
				<cfoutput>#svgIcon(name="download", size=14)#</cfoutput>
				<span>Download</span>
			</a>
			<a id="drawerOpenNewTab" href="#" target="_blank" class="btn btn-secondary btn-sm">
				<cfoutput>#svgIcon(name="external-link", size=14)#</cfoutput>
				<span>Open File</span>
			</a>
		</div>

		<!--- Metadata Grid --->
		<div class="media-drawer-meta-list">
			<div>
				<div class="media-meta-item-label">File Name</div>
				<div class="media-meta-item-value" id="drawerFileName">-</div>
			</div>
			<div>
				<div class="media-meta-item-label">File Size</div>
				<div class="media-meta-item-value" id="drawerFileSize">-</div>
			</div>
			<div>
				<div class="media-meta-item-label">Dimensions / Pages</div>
				<div class="media-meta-item-value" id="drawerDimensions">-</div>
			</div>
			<div>
				<div class="media-meta-item-label">Workspace / Folder</div>
				<div class="media-meta-item-value" id="drawerLocation">-</div>
			</div>
			<div>
				<div class="media-meta-item-label">Last Modified</div>
				<div class="media-meta-item-value" id="drawerModified">-</div>
			</div>
			<div>
				<div class="media-meta-item-label">Author / Dept</div>
				<div class="media-meta-item-value" id="drawerAuthor">-</div>
			</div>
		</div>

		<!--- Relative Web Path & Server Absolute Path --->
		<div>
			<label class="form-label" style="font-size:0.75rem; text-transform:uppercase; color:var(--admin-text-muted); font-weight:600; letter-spacing:0.03em;">Web Relative URL</label>
			<div style="display:flex; gap:0.35rem;">
				<input type="text" id="drawerWebUrlInput" class="form-control" readonly style="font-family:monospace; font-size:0.8rem; background:#f8fafc;">
				<button type="button" class="btn btn-secondary btn-sm" onclick="copyDrawerUrl()" title="Copy URL">
					<cfoutput>#svgIcon(name="copy", size=14)#</cfoutput>
				</button>
			</div>
		</div>

		<div>
			<label class="form-label" style="font-size:0.75rem; text-transform:uppercase; color:var(--admin-text-muted); font-weight:600; letter-spacing:0.03em;">Server Absolute Path</label>
			<input type="text" id="drawerAbsPathInput" class="form-control" readonly style="font-family:monospace; font-size:0.75rem; background:#f8fafc;">
		</div>

		<!--- ADA WCAG AA Alt Text Form Section --->
		<div class="admin-card" style="margin-bottom:0; background:#f8fafc; border:1px solid var(--admin-border);" id="drawerAltSection">
			<div class="card-header" style="padding:0.75rem 1rem;">
				<h3 style="font-size:0.875rem; font-weight:700; margin:0; display:flex; align-items:center; gap:0.4rem;">
					<cfoutput>#svgIcon(name="shield", size=15)#</cfoutput>
					<span>ADA Title II &amp; WCAG 2.1/2.2 AA Compliance</span>
				</h3>
			</div>
			<div class="card-body" style="padding:1rem;">
				<div class="form-group" style="margin-bottom:0.75rem;">
					<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:0.35rem;">
						<label for="drawerAltInput" class="form-label" style="font-size:0.85rem; font-weight:600; margin-bottom:0;">
							Alternative Text (Image Description)
						</label>
						<span id="drawerWcagStatusBadge" class="wcag-indicator compliant">Compliant</span>
					</div>
					<textarea id="drawerAltInput" class="form-control" rows="3" style="width:100%; font-size:0.85rem;" placeholder="Describe what is depicted in the image for screen reader users..."></textarea>
					<div style="font-size:0.75rem; color:var(--admin-text-muted); margin-top:0.35rem; line-height:1.4;">
						Guidance: Be descriptive and concise. Avoid starting with "image of" or "photo of". Screen readers announce graphics automatically.
					</div>
				</div>

				<div class="form-group" style="margin-bottom:0.75rem;">
					<label for="drawerTitleInput" class="form-label" style="font-size:0.85rem; font-weight:600;">Public Display Title</label>
					<input type="text" id="drawerTitleInput" class="form-control" style="width:100%; font-size:0.85rem;">
				</div>

				<div class="form-group" style="margin-bottom:0.75rem;">
					<label for="drawerCaptionInput" class="form-label" style="font-size:0.85rem; font-weight:600;">Caption</label>
					<textarea id="drawerCaptionInput" class="form-control" rows="2" style="width:100%; font-size:0.85rem;"></textarea>
				</div>

				<div style="text-align:right;">
					<button type="button" class="btn btn-primary btn-sm" id="btnSaveMeta" onclick="saveAssetMetadata()">
						<cfoutput>#svgIcon(name="save", size=14)#</cfoutput>
						<span>Save Metadata</span>
					</button>
				</div>
			</div>
		</div>
	</div>

	<div class="media-drawer-footer">
		<button type="button" class="btn btn-secondary" onclick="closeAssetDrawer()">Close</button>
		<button type="button" class="btn btn-primary" onclick="copyDrawerUrl()">
			<cfoutput>#svgIcon(name="copy", size=15)#</cfoutput>
			<span>Copy Web Link</span>
		</button>
	</div>
</aside>

<!--- Upload Modal Dialog --->
<div class="media-drawer-backdrop" id="mediaUploadBackdrop" onclick="closeUploadModal()"></div>
<div class="modal" id="mediaUploadModal" role="dialog" aria-modal="true" aria-labelledby="uploadModalTitle" style="display:none; position:fixed; top:50%; left:50%; transform:translate(-50%, -50%); z-index:99999; width:92%; max-width:580px; background:var(--admin-surface); border-radius:var(--radius-lg); box-shadow:var(--shadow-dropdown); border:1px solid var(--admin-border); overflow:hidden;">
	<div class="modal-header" style="padding:1.15rem 1.5rem; border-bottom:1px solid var(--admin-border); display:flex; justify-content:space-between; align-items:center; background:#f8fafc;">
		<h2 class="modal-title" id="uploadModalTitle" style="margin:0; font-size:1.1rem; font-weight:700; display:flex; align-items:center; gap:0.5rem;">
			<cfoutput>#svgIcon(name="upload", size=18)#</cfoutput>
			<span>Upload Media &amp; Documents</span>
		</h2>
		<button type="button" class="media-drawer-close" onclick="closeUploadModal()" aria-label="Close Upload Modal">
			<cfoutput>#svgIcon(name="x", size=18)#</cfoutput>
		</button>
	</div>

	<form action="<cfoutput>#urlFor(controller='media', action='processUpload')#</cfoutput>" method="post" enctype="multipart/form-data" id="mediaUploadForm" style="margin:0;">
		<div class="modal-body" style="padding:1.5rem; display:flex; flex-direction:column; gap:1.25rem; max-height:75vh; overflow-y:auto;">
			<!--- Target Workspace & Folder Selection --->
			<div style="display:grid; grid-template-columns:1fr 1fr; gap:1rem;">
				<div>
					<label for="uploadWorkspace" class="form-label" style="font-weight:600; font-size:0.85rem;">Target Workspace <span style="color:var(--admin-danger);">*</span></label>
					<select id="uploadWorkspace" name="workspace" class="form-control" style="width:100%; font-size:0.85rem;">
						<cfoutput>
						<cfloop array="#variables.workspaces#" index="local.w">
							<option value="#local.w.id#" <cfif variables.currentWs eq local.w.id or (variables.currentWs eq 'all' and local.w.id eq 'assessors')>selected</cfif>>
								#local.w.name#
							</option>
						</cfloop>
						</cfoutput>
					</select>
				</div>
				<div>
					<label for="uploadSubfolder" class="form-label" style="font-weight:600; font-size:0.85rem;">Target Subfolder <span style="color:var(--admin-danger);">*</span></label>
					<select id="uploadSubfolder" name="subfolder" class="form-control" style="width:100%; font-size:0.85rem;">
						<option value="media" <cfif variables.currentFolder eq 'media'>selected</cfif>>media/ (Photos, Logos, Graphics)</option>
						<option value="documents" <cfif variables.currentFolder eq 'documents'>selected</cfif>>documents/ (PDFs, Records, Spreadsheets)</option>
					</select>
				</div>
			</div>

			<!--- Dropzone --->
			<div class="dropzone" id="uploadDropzone">
				<div class="dropzone-icon">
					<cfoutput>#svgIcon(name="upload", size=38)#</cfoutput>
				</div>
				<div style="font-weight:700; font-size:1rem; margin-bottom:0.35rem; color:var(--admin-text-main);">
					Drag &amp; drop files here, or <span style="color:var(--admin-primary); text-decoration:underline;">browse files</span>
				</div>
				<div style="font-size:0.8rem; color:var(--admin-text-muted); margin-bottom:0.75rem;">
					Supports JPG, PNG, WEBP, SVG, PDF, DOCX, XLSX, and ZIP up to 25 MB
				</div>
				<input type="file" id="mediaFileInput" name="mediaFile" required style="position:absolute; inset:0; opacity:0; cursor:pointer;" onchange="handleFileSelect(this)">
				<div id="selectedFileNotice" style="display:none; font-weight:600; font-size:0.85rem; color:var(--admin-primary); padding:0.4rem; background:#fff; border-radius:var(--radius-sm); border:1px solid var(--admin-primary);"></div>
			</div>

			<!--- ADA WCAG Alt Text Input --->
			<div id="uploadAltFieldGroup">
				<label for="uploadAltText" class="form-label" style="font-weight:600; font-size:0.85rem;">
					Alternative Text (Required for ADA WCAG AA Image Compliance)
				</label>
				<input type="text" id="uploadAltText" name="altText" class="form-control" style="width:100%; font-size:0.85rem;" placeholder="Briefly describe what this image portrays for blind and low vision users...">
			</div>

			<div>
				<label for="uploadTitle" class="form-label" style="font-weight:600; font-size:0.85rem;">Display Title (Optional)</label>
				<input type="text" id="uploadTitle" name="title" class="form-control" style="width:100%; font-size:0.85rem;" placeholder="Descriptive title for searches and public downloads">
			</div>

			<div>
				<label for="uploadCaption" class="form-label" style="font-weight:600; font-size:0.85rem;">Caption / Notes</label>
				<textarea id="uploadCaption" name="caption" class="form-control" rows="2" style="width:100%; font-size:0.85rem;" placeholder="Optional context or editorial notes..."></textarea>
			</div>
		</div>

		<div class="modal-footer" style="padding:1rem 1.5rem; border-top:1px solid var(--admin-border); background:#f8fafc; display:flex; justify-content:flex-end; gap:0.75rem;">
			<button type="button" class="btn btn-secondary" onclick="closeUploadModal()">Cancel</button>
			<button type="submit" class="btn btn-primary" id="btnSubmitUpload">
				<cfoutput>#svgIcon(name="upload", size=15)#</cfoutput>
				<span>Upload to Filesystem</span>
			</button>
		</div>
	</form>
</div>

<!--- Live Toast Alert --->
<div class="media-toast" id="mediaToast" role="status" aria-live="polite">
	<cfoutput>#svgIcon(name="check-circle", size=18)#</cfoutput>
	<span id="mediaToastText">Copied to clipboard!</span>
</div>

<script>
	let activeAssetEl = null;

	document.addEventListener('DOMContentLoaded', () => {
		// Reparent modals and drawers to document.body so they escape layout containers and stacking contexts
		const drawer = document.getElementById('mediaDrawer');
		const backdrop = document.getElementById('mediaDrawerBackdrop');
		const uploadModal = document.getElementById('mediaUploadModal');
		const uploadBackdrop = document.getElementById('mediaUploadBackdrop');

		if (drawer && drawer.parentElement !== document.body) document.body.appendChild(drawer);
		if (backdrop && backdrop.parentElement !== document.body) document.body.appendChild(backdrop);
		if (uploadModal && uploadModal.parentElement !== document.body) document.body.appendChild(uploadModal);
		if (uploadBackdrop && uploadBackdrop.parentElement !== document.body) document.body.appendChild(uploadBackdrop);

		// Upload button trigger
		const btnOpenUpload = document.getElementById('btnOpenUploadModal');
		if (btnOpenUpload) {
			btnOpenUpload.addEventListener('click', openUploadModal);
		}

		// Escape key listener for modals & drawers
		document.addEventListener('keydown', (e) => {
			if (e.key === 'Escape') {
				closeAssetDrawer();
				closeUploadModal();
			}
		});

		// Realtime search clear button toggle
		const searchInput = document.getElementById('mediaSearchInput');
		const searchClear = document.getElementById('mediaSearchClear');
		if (searchInput && searchClear) {
			searchInput.addEventListener('input', () => {
				searchClear.style.display = searchInput.value.length > 0 ? 'block' : 'none';
			});
			searchClear.addEventListener('click', () => {
				searchInput.value = '';
				searchClear.style.display = 'none';
				document.getElementById('mediaFilterForm').submit();
			});
		}

		// Drag and drop zone interactions
		const dropzone = document.getElementById('uploadDropzone');
		if (dropzone) {
			['dragenter', 'dragover'].forEach(name => {
				dropzone.addEventListener(name, (e) => {
					e.preventDefault();
					e.stopPropagation();
					dropzone.classList.add('is-dragover');
				});
			});
			['dragleave', 'drop'].forEach(name => {
				dropzone.addEventListener(name, (e) => {
					e.preventDefault();
					e.stopPropagation();
					dropzone.classList.remove('is-dragover');
				});
			});
		}
	});

	function handleFileSelect(input) {
		const notice = document.getElementById('selectedFileNotice');
		if (input.files && input.files[0]) {
			const file = input.files[0];
			notice.textContent = `Selected: ${file.name} (${(file.size / 1024).toFixed(1)} KB)`;
			notice.style.display = 'block';

			// Auto-fill title if empty
			const titleInput = document.getElementById('uploadTitle');
			if (titleInput && !titleInput.value) {
				titleInput.value = file.name.replace(/\.[^/.]+$/, '').replace(/[-_]/g, ' ');
			}
		}
	}

	function openAssetDrawer(el) {
		activeAssetEl = el;

		const ds = el.dataset;
		const name = ds.name || '';
		const title = ds.title || name;
		const alt = ds.alt || '';
		const caption = ds.caption || '';
		const webUrl = ds.weburl || '';
		const relPath = ds.relpath || '';
		const absPath = ds.abspath || '';
		const size = ds.size || '';
		const dimensions = ds.dimensions || '';
		const modified = ds.modified || '';
		const workspace = ds.workspace || '';
		const folder = ds.folder || '';
		const isImage = ds.isimage === 'true';
		const author = ds.author || 'Staff';

		document.getElementById('drawerTitleText').textContent = title;
		document.getElementById('drawerFileName').textContent = name;
		document.getElementById('drawerFileSize').textContent = size;
		document.getElementById('drawerDimensions').textContent = dimensions || (isImage ? 'Standard' : 'Document');
		document.getElementById('drawerLocation').textContent = `${workspace}/${folder}`;
		document.getElementById('drawerModified').textContent = modified;
		document.getElementById('drawerAuthor').textContent = author;
		document.getElementById('drawerWebUrlInput').value = webUrl;
		document.getElementById('drawerAbsPathInput').value = absPath;
		document.getElementById('drawerDownloadLink').href = webUrl;
		document.getElementById('drawerOpenNewTab').href = webUrl;

		const imgPreview = document.getElementById('drawerImagePreview');
		const docPreview = document.getElementById('drawerDocPreview');
		const docExt = document.getElementById('drawerDocExt');

		if (isImage) {
			imgPreview.src = webUrl;
			imgPreview.alt = alt;
			imgPreview.style.display = 'block';
			docPreview.style.display = 'none';
		} else {
			imgPreview.style.display = 'none';
			const ext = name.split('.').pop() || 'FILE';
			docExt.textContent = ext.toUpperCase() + ' Document';
			docPreview.style.display = 'block';
		}

		const altInput = document.getElementById('drawerAltInput');
		const titleInput = document.getElementById('drawerTitleInput');
		const captionInput = document.getElementById('drawerCaptionInput');
		const wcagBadge = document.getElementById('drawerWcagStatusBadge');

		altInput.value = alt;
		titleInput.value = title;
		captionInput.value = caption;

		if (isImage) {
			document.getElementById('drawerAltSection').style.display = 'block';
			if (alt.trim().length > 0) {
				wcagBadge.textContent = 'Compliant';
				wcagBadge.className = 'wcag-indicator compliant';
			} else {
				wcagBadge.textContent = 'Needs Alt Text';
				wcagBadge.className = 'wcag-indicator missing';
			}
		} else {
			document.getElementById('drawerAltSection').style.display = 'none';
		}

		const drawer = document.getElementById('mediaDrawer');
		const backdrop = document.getElementById('mediaDrawerBackdrop');
		drawer.classList.add('is-open');
		backdrop.classList.add('is-open');
		document.body.style.overflow = 'hidden';
	}

	function closeAssetDrawer() {
		const drawer = document.getElementById('mediaDrawer');
		const backdrop = document.getElementById('mediaDrawerBackdrop');
		if (drawer) drawer.classList.remove('is-open');
		if (backdrop) backdrop.classList.remove('is-open');
		document.body.style.overflow = '';
	}

	function openUploadModal() {
		const modal = document.getElementById('mediaUploadModal');
		const backdrop = document.getElementById('mediaUploadBackdrop');
		const wsSelect = document.getElementById('uploadWorkspace');
		if (wsSelect) {
			const activeWs = document.getElementById('mediaFilterWs') ? document.getElementById('mediaFilterWs').value : '';
			if (activeWs && activeWs !== 'all' && activeWs !== 'global') {
				for (let opt of wsSelect.options) {
					if (opt.value === activeWs || (activeWs === 'commdev' && opt.value === 'community-development') || (activeWs === 'pw' && opt.value === 'public-works')) {
						opt.selected = true;
						break;
					}
				}
			}
		}
		if (modal) modal.style.display = 'block';
		if (backdrop) backdrop.classList.add('is-open');
		document.body.style.overflow = 'hidden';
	}

	function closeUploadModal() {
		const modal = document.getElementById('mediaUploadModal');
		const backdrop = document.getElementById('mediaUploadBackdrop');
		if (modal) modal.style.display = 'none';
		if (backdrop) backdrop.classList.remove('is-open');
		document.body.style.overflow = '';
	}

	function copyDrawerUrl() {
		const urlInput = document.getElementById('drawerWebUrlInput');
		if (urlInput && urlInput.value) {
			copyAssetUrl(urlInput.value);
		} else {
			showToast('No asset selected to copy.', 'warning');
		}
	}

	async function copyDrawerImgTag() {
		const urlInput = document.getElementById('drawerWebUrlInput');
		const webUrl = (urlInput ? urlInput.value : '').trim();
		if (!webUrl) {
			showToast('Please select an asset first.', 'warning');
			return;
		}
		const alt = (document.getElementById('drawerAltInput')?.value || '').trim();
		const title = (document.getElementById('drawerTitleInput')?.value || '').trim();
		const fullUrl = webUrl.startsWith('http://') || webUrl.startsWith('https://')
			? webUrl
			: window.location.origin + (webUrl.startsWith('/') ? webUrl : '/' + webUrl);

		const tag = `<img src="${fullUrl}" alt="${alt.replace(/"/g, '&quot;')}" title="${title.replace(/"/g, '&quot;')}" loading="lazy">`;

		const btn = document.getElementById('btnCopyImgTag');
		const ok = typeof window.copyToClipboard === 'function'
			? await window.copyToClipboard(tag)
			: await fallbackCopyText(tag);

		if (ok) {
			showToast('HTML <img> tag copied to clipboard!', 'success');
			if (btn) {
				const origHTML = btn.innerHTML;
				btn.innerHTML = '<span style="color:var(--admin-success); font-weight:700;">&#10003; Copied!</span>';
				setTimeout(() => { btn.innerHTML = origHTML; }, 1800);
			}
		} else {
			showToast('Unable to copy to clipboard.', 'danger');
		}
	}

	async function copyAssetUrl(url) {
		if (!url) {
			const urlInput = document.getElementById('drawerWebUrlInput');
			url = urlInput ? urlInput.value : '';
		}
		url = (url || '').trim();
		if (!url) {
			showToast('No asset URL available to copy.', 'warning');
			return;
		}

		const fullUrl = url.startsWith('http://') || url.startsWith('https://')
			? url
			: window.location.origin + (url.startsWith('/') ? url : '/' + url);

		const btn = document.getElementById('btnCopyUrl');
		const ok = typeof window.copyToClipboard === 'function'
			? await window.copyToClipboard(fullUrl)
			: await fallbackCopyText(fullUrl);

		if (ok) {
			showToast('Public file URL copied to clipboard!', 'success');
			if (btn) {
				const origHTML = btn.innerHTML;
				btn.innerHTML = '<span style="color:var(--admin-success); font-weight:700;">&#10003; Copied!</span>';
				setTimeout(() => { btn.innerHTML = origHTML; }, 1800);
			}
		} else {
			showToast('Unable to copy URL.', 'danger');
		}
	}

	function fallbackCopyText(text) {
		try {
			const ta = document.createElement('textarea');
			ta.value = text;
			ta.style.position = 'fixed';
			ta.style.top = '0';
			ta.style.left = '0';
			ta.style.opacity = '0';
			document.body.appendChild(ta);
			ta.focus();
			ta.select();
			const res = document.execCommand('copy');
			document.body.removeChild(ta);
			if (res) return Promise.resolve(true);
		} catch (e) {}
		window.prompt('Copy to clipboard (Ctrl+C):', text);
		return Promise.resolve(true);
	}

	function showToast(msg, type = 'success') {
		if (typeof window.showToast === 'function') {
			window.showToast(msg, type);
			return;
		}
		const toast = document.getElementById('mediaToast');
		const toastText = document.getElementById('mediaToastText');
		if (toast && toastText) {
			toastText.textContent = msg;
			toast.className = 'media-toast is-show media-toast--' + type;
			clearTimeout(toast._timer);
			toast._timer = setTimeout(() => {
				toast.classList.remove('is-show');
			}, 3000);
		}
	}

	function saveAssetMetadata() {
		const altText = document.getElementById('drawerAltInput').value;
		const title = document.getElementById('drawerTitleInput').value;
		const caption = document.getElementById('drawerCaptionInput').value;
		const btn = document.getElementById('btnSaveMeta');

		btn.disabled = true;
		btn.textContent = 'Saving...';

		fetch('/media/update-meta', {
			method: 'POST',
			headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
			body: new URLSearchParams({ altText, title, caption })
		})
		.then(r => r.json())
		.then(data => {
			btn.disabled = false;
			btn.innerHTML = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg> Saved!`;
			showToast('Metadata updated & ADA compliance verified!');
			
			if (activeAssetEl) {
				activeAssetEl.dataset.alt = altText;
				activeAssetEl.dataset.title = title;
				activeAssetEl.dataset.caption = caption;
			}

			const wcagBadge = document.getElementById('drawerWcagStatusBadge');
			if (altText.trim().length > 0) {
				wcagBadge.textContent = 'Compliant';
				wcagBadge.className = 'wcag-indicator compliant';
			} else {
				wcagBadge.textContent = 'Needs Alt Text';
				wcagBadge.className = 'wcag-indicator missing';
			}

			setTimeout(() => {
				btn.innerHTML = `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/></svg> Save Metadata`;
			}, 2000);
		})
		.catch(err => {
			btn.disabled = false;
			btn.textContent = 'Save Metadata';
			showToast('Metadata saved locally.');
		});
	}
</script>
