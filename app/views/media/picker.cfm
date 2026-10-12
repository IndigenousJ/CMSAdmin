<cfparam name="variables.assets" default="#[]#">
<cfparam name="variables.workspaces" default="#[]#">
<cfparam name="variables.currentWs" default="all">
<cfparam name="variables.currentFolder" default="all">
<cfparam name="variables.currentType" default="all">
<cfparam name="variables.currentSearch" default="">
<cfparam name="variables.pickerMode" default="image">
<cfparam name="variables.callback" default="onMediaSelected">

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Select Media Asset - Chelan County CMS</title>
	<link rel="stylesheet" href="/stylesheets/admin-theme.css?v=3.0">
	<style>
		body { background: #f8fafc; padding: 1.25rem; }
		.picker-layout { display: grid; grid-template-columns: 1fr 340px; gap: 1.25rem; height: calc(100vh - 2.5rem); }
		.picker-main { display: flex; flex-direction: column; overflow: hidden; background: #ffffff; border: 1px solid var(--admin-border); border-radius: var(--radius-lg); box-shadow: var(--shadow-sm); }
		.picker-header { padding: 1rem 1.25rem; border-bottom: 1px solid var(--admin-border); background: #f8fafc; display: flex; gap: 0.75rem; align-items: center; justify-content: space-between; flex-wrap: wrap; }
		.picker-grid-wrap { flex: 1; overflow-y: auto; padding: 1.25rem; }
		.picker-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); gap: 1rem; }
		.picker-item { border: 2px solid var(--admin-border); border-radius: var(--radius-md); background: #ffffff; overflow: hidden; cursor: pointer; transition: all 0.15s ease; display: flex; flex-direction: column; text-align: left; position: relative; }
		.picker-item:hover { border-color: var(--admin-primary); transform: translateY(-2px); box-shadow: var(--shadow-sm); }
		.picker-item.is-active { border-color: var(--admin-primary); box-shadow: 0 0 0 2px var(--admin-primary); background: var(--admin-primary-light); }
		.picker-item-thumb { height: 105px; background: #f1f5f9; display: flex; align-items: center; justify-content: center; overflow: hidden; border-bottom: 1px solid var(--admin-border-subtle); }
		.picker-item-thumb img { width: 100%; height: 100%; object-fit: contain; padding: 0.25rem; }
		.picker-item-info { padding: 0.5rem; font-size: 0.75rem; }
		.picker-item-title { font-weight: 600; color: var(--admin-text-main); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
		.picker-item-sub { color: var(--admin-text-muted); font-size: 0.7rem; }
		
		/* Inspector side panel */
		.picker-sidebar { background: #ffffff; border: 1px solid var(--admin-border); border-radius: var(--radius-lg); box-shadow: var(--shadow-sm); display: flex; flex-direction: column; overflow-y: auto; padding: 1.25rem; }
		.picker-sidebar-preview { width: 100%; height: 160px; background: #0f172a; border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; overflow: hidden; margin-bottom: 1rem; }
		.picker-sidebar-preview img { max-width: 100%; max-height: 150px; object-fit: contain; }
		.picker-actions-footer { margin-top: auto; padding-top: 1rem; border-top: 1px solid var(--admin-border); display: flex; justify-content: flex-end; gap: 0.5rem; }
		
		@media (max-width: 800px) {
			.picker-layout { grid-template-columns: 1fr; height: auto; }
			.picker-sidebar { height: auto; }
		}
	</style>
</head>
<body>

<cfoutput>
<div class="picker-layout">
	<!--- Main Grid Area --->
	<div class="picker-main">
		<div class="picker-header">
			<div style="font-weight:700; font-size:1rem; color:var(--admin-text-main); display:flex; align-items:center; gap:0.5rem;">
				#svgIcon(name="media", size=18)#
				<span>Select #variables.pickerMode eq 'document' ? 'Document' : 'Image'# Asset</span>
			</div>
			
			<div style="display:flex; gap:0.5rem; align-items:center;">
				<input type="text" id="pickerSearch" class="form-control" placeholder="Search..." value="#EncodeForHTMLAttribute(variables.currentSearch)#" style="font-size:0.8rem; padding:0.35rem 0.65rem;" onkeyup="filterPickerItems(this.value)">
				<select id="pickerWs" class="form-control" style="font-size:0.8rem; padding:0.35rem 0.65rem;" onchange="window.location.href='?picker=#variables.pickerMode#&type=#variables.currentType#&callback=#variables.callback#&ws=' + this.value">
					<cfif structKeyExists(variables, "isAdmin") and variables.isAdmin>
						<option value="all" <cfif variables.currentWs eq 'all'>selected</cfif>>All Workspaces</option>
					</cfif>
					<cfloop array="#variables.workspaces#" index="local.w">
						<option value="#local.w.id#" <cfif variables.currentWs eq local.w.id>selected</cfif>>#local.w.name#</option>
					</cfloop>
				</select>
			</div>
		</div>

		<div class="picker-grid-wrap">
			<div class="picker-grid" id="pickerGrid">
				<cfloop array="#variables.assets#" index="local.item">
					<div class="picker-item" tabindex="0" role="button"
					     data-id="#local.item.id#"
					     data-name="#EncodeForHTMLAttribute(local.item.name)#"
					     data-title="#EncodeForHTMLAttribute(local.item.title)#"
					     data-alt="#EncodeForHTMLAttribute(local.item.altText)#"
					     data-caption="#EncodeForHTMLAttribute(local.item.caption)#"
					     data-weburl="#EncodeForHTMLAttribute(local.item.webUrl)#"
					     data-size="#EncodeForHTMLAttribute(local.item.sizeFormatted)#"
					     data-dimensions="#EncodeForHTMLAttribute(local.item.dimensions)#"
					     data-isimage="#local.item.isImage ? 'true' : 'false'#"
					     onclick="selectPickerItem(this)">
						<div class="picker-item-thumb">
							<cfif local.item.isImage>
								<img src="#local.item.webUrl#" alt="#EncodeForHTMLAttribute(local.item.altText)#" loading="lazy">
							<cfelse>
								#svgIcon(name="file-text", size=32)#
							</cfif>
						</div>
						<div class="picker-item-info">
							<div class="picker-item-title" title="#EncodeForHTMLAttribute(local.item.title)#">#EncodeForHTML(local.item.title)#</div>
							<div class="picker-item-sub">#EncodeForHTML(local.item.sizeFormatted)#</div>
						</div>
					</div>
				</cfloop>
			</div>
		</div>
	</div>

	<!--- Sidebar: Insertion Settings --->
	<div class="picker-sidebar" id="pickerSidebar">
		<h3 style="font-size:0.95rem; font-weight:700; margin-bottom:1rem; border-bottom:1px solid var(--admin-border-subtle); padding-bottom:0.5rem;">
			Asset Insertion Settings
		</h3>

		<div class="picker-sidebar-preview" id="sidePreviewBox">
			<img id="sideImage" src="" alt="" style="display:none;">
			<div id="sideDoc" style="display:none; color:white; text-align:center;">
				#svgIcon(name="file-text", size=48)#
				<div id="sideDocExt" style="margin-top:0.5rem; font-weight:700; font-size:0.9rem;"></div>
			</div>
		</div>

		<div id="sideSettings" style="display:none; flex-direction:column; gap:0.85rem; flex:1;">
			<div class="form-group" id="altGroup">
				<label for="insertAltText" class="form-label" style="font-size:0.8rem; font-weight:600;">
					Alternative Text (ADA WCAG Required)
				</label>
				<textarea id="insertAltText" class="form-control" rows="2" style="font-size:0.8rem; width:100%;"></textarea>
			</div>

			<div class="form-group">
				<label for="insertTitle" class="form-label" style="font-size:0.8rem; font-weight:600;">
					Link / Image Title
				</label>
				<input type="text" id="insertTitle" class="form-control" style="font-size:0.8rem; width:100%;">
			</div>

			<cfif variables.pickerMode eq "image">
				<div class="form-group">
					<label for="insertAlign" class="form-label" style="font-size:0.8rem; font-weight:600;">Alignment</label>
					<select id="insertAlign" class="form-control" style="font-size:0.8rem; width:100%;">
						<option value="responsive">Full Width / Responsive (100%)</option>
						<option value="left">Left Aligned (Text Wraps Right)</option>
						<option value="right">Right Aligned (Text Wraps Left)</option>
						<option value="center">Centered</option>
					</select>
				</div>
			<cfelse>
				<div class="form-group">
					<label class="form-check" style="font-size:0.825rem; display:flex; align-items:center; gap:0.5rem;">
						<input type="checkbox" id="insertIncludeBadge" checked>
						<span>Include file extension &amp; size badge</span>
					</label>
				</div>
			</cfif>
		</div>

		<div class="picker-actions-footer">
			<button type="button" class="btn btn-secondary btn-sm" onclick="cancelPicker()">Cancel</button>
			<button type="button" class="btn btn-primary btn-sm" id="btnInsertAsset" disabled onclick="insertSelectedAsset()">
				#svgIcon(name="plus", size=14)#
				<span>Insert Asset</span>
			</button>
		</div>
	</div>
</div>
</cfoutput>

<script>
	let selectedData = null;
	const pickerMode = "<cfoutput>#variables.pickerMode#</cfoutput>";
	const callbackFn = "<cfoutput>#variables.callback#</cfoutput>";

	function checkIsImage(data) {
		if (!data) return false;
		const isImgVal = String(data.isimage || '').toLowerCase();
		if (isImgVal === 'true' || isImgVal === 'yes' || isImgVal === '1') return true;
		if (isImgVal === 'false' || isImgVal === 'no' || isImgVal === '0') return false;
		const name = (data.name || data.weburl || '').toLowerCase();
		return /\.(jpe?g|png|gif|webp|svg|ico|bmp)$/i.test(name);
	}

	function selectPickerItem(el) {
		document.querySelectorAll('.picker-item').forEach(i => i.classList.remove('is-active'));
		el.classList.add('is-active');

		selectedData = el.dataset;
		const isImage = checkIsImage(selectedData);

		// Update sidebar
		const sideImg = document.getElementById('sideImage');
		const sideDoc = document.getElementById('sideDoc');
		const sideDocExt = document.getElementById('sideDocExt');
		const settings = document.getElementById('sideSettings');
		const btnInsert = document.getElementById('btnInsertAsset');

		if (isImage) {
			sideImg.src = selectedData.weburl;
			sideImg.alt = selectedData.alt || selectedData.title || selectedData.name || '';
			sideImg.style.display = 'block';
			sideDoc.style.display = 'none';
			document.getElementById('altGroup').style.display = 'block';
		} else {
			sideImg.style.display = 'none';
			sideDocExt.textContent = (selectedData.name.split('.').pop() || 'FILE').toUpperCase();
			sideDoc.style.display = 'block';
			document.getElementById('altGroup').style.display = 'none';
		}

		document.getElementById('insertAltText').value = selectedData.alt || selectedData.title || '';
		document.getElementById('insertTitle').value = selectedData.title || selectedData.name || '';

		settings.style.display = 'flex';
		btnInsert.disabled = false;
	}

	function filterPickerItems(q) {
		q = q.toLowerCase();
		document.querySelectorAll('.picker-item').forEach(item => {
			const title = (item.dataset.title || '').toLowerCase();
			const name = (item.dataset.name || '').toLowerCase();
			const alt = (item.dataset.alt || '').toLowerCase();
			if (title.includes(q) || name.includes(q) || alt.includes(q)) {
				item.style.display = 'flex';
			} else {
				item.style.display = 'none';
			}
		});
	}

	function insertSelectedAsset() {
		if (!selectedData) return;

		const isImage = checkIsImage(selectedData);
		const webUrl = selectedData.weburl;
		const title = (document.getElementById('insertTitle').value || selectedData.title || selectedData.name || '').trim();
		let alt = (document.getElementById('insertAltText').value || '').trim();

		let htmlSnippet = '';

		if (isImage) {
			// WCAG 1.1.1 Non-text Content requirement: Images must have descriptive alt text
			if (!alt) {
				alt = title || selectedData.name || 'Chelan County Media Asset';
			}
			const align = document.getElementById('insertAlign') ? document.getElementById('insertAlign').value : 'responsive';
			let style = 'max-width:100%; height:auto;';
			if (align === 'left') style += ' float:left; margin:0 1.5rem 1rem 0;';
			else if (align === 'right') style += ' float:right; margin:0 0 1rem 1.5rem;';
			else if (align === 'center') style += ' display:block; margin:1rem auto;';

			const safeAlt = alt.replace(/"/g, '&quot;');
			const safeTitle = title.replace(/"/g, '&quot;');
			htmlSnippet = `<img src="${webUrl}" alt="${safeAlt}" title="${safeTitle}" style="${style}" loading="lazy">`;
		} else {
			const incBadge = document.getElementById('insertIncludeBadge') ? document.getElementById('insertIncludeBadge').checked : true;
			const ext = (selectedData.name.split('.').pop() || 'PDF').toUpperCase();
			const badge = incBadge ? ` (${ext}, ${selectedData.size})` : '';
			const adaNotice = `${title} (${ext}, opens in a new tab)`;
			htmlSnippet = `<a href="${webUrl}" class="document-download-link" target="_blank" rel="noopener noreferrer" aria-label="${adaNotice.replace(/"/g, '&quot;')}" title="${adaNotice.replace(/"/g, '&quot;')}">${title}${badge}</a>`;
		}

		// Dispatch to parent window
		if (window.parent && window.parent[callbackFn]) {
			window.parent[callbackFn]({
				html: htmlSnippet,
				url: webUrl,
				title: title,
				alt: alt,
				data: selectedData
			});
		} else if (window.parent) {
			window.parent.postMessage({
				type: 'CMS_MEDIA_SELECTED',
				html: htmlSnippet,
				url: webUrl,
				title: title,
				alt: alt
			}, '*');
		}
	}

	function cancelPicker() {
		if (window.parent && window.parent.closeMediaPickerModal) {
			window.parent.closeMediaPickerModal();
		}
	}

	// Auto-select first asset
	document.addEventListener('DOMContentLoaded', () => {
		const first = document.querySelector('.picker-item');
		if (first) selectPickerItem(first);
	});
</script>

</body>
</html>
