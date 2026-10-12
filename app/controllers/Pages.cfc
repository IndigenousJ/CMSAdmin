component extends="Controller" {

	function config() {
		super.config();
	}

	/**
	 * All Pages listing (reads from database with fallback to sample pages)
	 */
	function index() {
		variables.pageTitle = "All Pages";
		local.reqWs = (StructKeyExists(params, "ws") && Len(Trim(params.ws))) ? Trim(params.ws)
			: ((StructKeyExists(cookie, "cmsadmin_workspace") && Len(Trim(cookie.cmsadmin_workspace))) ? Trim(cookie.cmsadmin_workspace) : "");
		variables.activeWorkspace = resolveUserActiveWorkspace(
			local.reqWs,
			getCurrentActiveRole()
		);
		variables.pages = loadPagesList();
	}

	/**
	 * Add / Edit Page. Pass ?id=N to load a page from database, omit for a new page.
	 */
	function edit() {
		local.all = loadPagesList();
		variables.page = {
			id: 0, title: "", slug: "", siteId: activeWorkspaceId(), menuItem: false, status: "Active", visibility: "Published",
			parent: "", layout: "Full", sidebarIds: [], updated: "", author: "", locked: false, summary: "", body: "", content: "",
			metaTitle: "", metaDesc: "", metaKeywords: "", hasArchive: false
		};

		if (StructKeyExists(params, "id") && IsNumeric(params.id) && Val(params.id) > 0) {
			local.dbPage = loadPageFromDb(Val(params.id));
			if (StructCount(local.dbPage)) {
				variables.page = local.dbPage;
			}
		} else if (StructKeyExists(params, "parent")) {
			for (local.p in local.all) {
				if (CompareNoCase(local.p.title, params.parent) == 0) {
					variables.page.parent = local.p.title;
					break;
				}
			}
		} else {
			// Populate from Add Page modal parameters if provided
			if (StructKeyExists(params, "title") && Len(Trim(params.title))) {
				variables.page.title = Trim(params.title);
			}
			if (StructKeyExists(params, "slug") && Len(Trim(params.slug))) {
				variables.page.slug = Trim(params.slug);
			}
			if (StructKeyExists(params, "layout") && Len(Trim(params.layout))) {
				variables.page.layout = Trim(params.layout);
			}
		}
		variables.isNew = (variables.page.id == 0);
		variables.pageTitle = variables.isNew ? "Add Page" : "Edit Page";
		variables.allPages = local.all;
		local.currentActiveWs = activeWorkspaceId();
		if (!Len(local.currentActiveWs) && StructKeyExists(cookie, "cmsadmin_workspace") && Len(Trim(cookie.cmsadmin_workspace))) {
			local.rawCk = LCase(Trim(cookie.cmsadmin_workspace));
			if (local.rawCk != "global" && local.rawCk != "all") {
				local.currentActiveWs = local.rawCk;
			}
		}
		local.editSiteId = Len(local.currentActiveWs) ? local.currentActiveWs : ((StructKeyExists(variables.page, "siteId") && Len(Trim(variables.page.siteId)) && variables.page.siteId != "global" && variables.page.siteId != "all") ? Trim(variables.page.siteId) : "");
		variables.editSiteId = local.editSiteId;
		variables.availableSubpages = loadSubpages(contentId=variables.page.id, requestedWs=local.editSiteId, assignedIds=variables.page.sidebarIds);
		variables.availableSidebars = [];
		variables.availableFolders = loadFolderExplorers(variables.page.id);
		variables.menuItemOptions = loadMenuItemOptions(requestedWs=local.editSiteId, currentSelected=variables.page.parent);
		variables.availableForms = loadWorkspaceForms(requestedWs=local.editSiteId);
	}

	/**
	 * Resolves candidate SiteID values for a given workspace identifier (handles code, alias, virtual_dir, and singular/plural variations).
	 */
	private array function getCandidateSiteIds(string wsId = "") {
		local.candidates = [];
		local.rawId = Trim(arguments.wsId);
		if (!Len(local.rawId)) {
			local.rawId = activeWorkspaceId();
		}
		if (!Len(local.rawId) || local.rawId == "global" || local.rawId == "all") {
			return local.candidates;
		}

		local.wsObj = resolveUserActiveWorkspace(requestedWs=local.rawId, role=getCurrentActiveRole());
		local.siteid = LCase(Trim(StructKeyExists(local.wsObj, "id") ? local.wsObj.id : local.rawId));

		if (Len(local.siteid) && local.siteid != "global" && local.siteid != "all") {
			ArrayAppend(local.candidates, local.siteid);
		}
		if (StructKeyExists(local.wsObj, "code") && Len(Trim(local.wsObj.code)) && !ArrayFindNoCase(local.candidates, local.wsObj.code)) {
			ArrayAppend(local.candidates, LCase(Trim(local.wsObj.code)));
		}
		if (StructKeyExists(local.wsObj, "alias") && Len(Trim(local.wsObj.alias)) && !ArrayFindNoCase(local.candidates, local.wsObj.alias)) {
			ArrayAppend(local.candidates, LCase(Trim(local.wsObj.alias)));
		}
		if (StructKeyExists(local.wsObj, "virtual_directory") && Len(Trim(local.wsObj.virtual_directory)) && !ArrayFindNoCase(local.candidates, local.wsObj.virtual_directory)) {
			ArrayAppend(local.candidates, LCase(Trim(local.wsObj.virtual_directory)));
		}
		// Handle common Chelan County code/alias variations (e.g. assessor <-> assessors)
		if (Len(local.siteid)) {
			if (Right(local.siteid, 1) == "s") {
				local.singular = Left(local.siteid, Len(local.siteid) - 1);
				if (Len(local.singular) && !ArrayFindNoCase(local.candidates, local.singular)) ArrayAppend(local.candidates, local.singular);
			} else {
				local.plural = local.siteid & "s";
				if (!ArrayFindNoCase(local.candidates, local.plural)) ArrayAppend(local.candidates, local.plural);
			}
		}

		// Also add variations with/without 'site-' prefix
		for (local.c in Duplicate(local.candidates)) {
			if (Left(local.c, 5) == "site-") {
				local.noSite = Mid(local.c, 6, Len(local.c));
				if (Len(local.noSite) && !ArrayFindNoCase(local.candidates, local.noSite)) {
					ArrayAppend(local.candidates, local.noSite);
				}
			} else {
				local.withSite = "site-" & local.c;
				if (!ArrayFindNoCase(local.candidates, local.withSite)) {
					ArrayAppend(local.candidates, local.withSite);
				}
			}
		}

		return local.candidates;
	}

	/**
	 * POST JSON: creates a new page from the Add Page modal directly into database
	 * Accepts { title, slug, layout, siteId } and returns { success: true, id, redirectUrl }
	 */
	function createModal() {
		local.body = fxReadJsonBody();
		local.req = IsStruct(local.body) ? local.body : params;

		local.title = Left(Trim(local.req.title ?: ""), 255);
		local.rawSlug = Trim(local.req.slug ?: (local.req.permalink ?: ""));
		local.layout = Trim(local.req.layout ?: (local.req.layoutType ?: "Right Sidebar"));
		local.siteId = LCase(Trim(local.req.siteId ?: (local.req.siteID ?: "")));

		if (!Len(local.siteId) || local.siteId == "all" || local.siteId == "global") {
			local.siteId = activeWorkspaceId();
		}
		if (!Len(local.siteId) || local.siteId == "all" || local.siteId == "global") {
			fxRenderJson({ success: false, message: "Please select a workspace before creating a page." }, 422);
			return;
		}

		if (!Len(local.title)) {
			fxRenderJson({ success: false, message: "Page title is required." }, 422);
			return;
		}

		local.slug = Len(local.rawSlug) ? slugifyText(local.rawSlug) : slugifyText(local.title);
		if (!Len(local.slug)) {
			local.slug = "page-" & LCase(Left(CreateUUID(), 8));
		}

		if (local.layout != "Full" && local.layout != "Right Sidebar") {
			local.layout = "Right Sidebar";
		}

		local.actor = spCurrentActor();

		// Ensure unique slug per workspace (checking all candidate aliases for the workspace)
		local.candidateSiteIds = getCandidateSiteIds(local.siteId);
		if (ArrayLen(local.candidateSiteIds) == 0) ArrayAppend(local.candidateSiteIds, local.siteId);
		local.inPlaceholders = [];
		local.siteParams = {};
		for (local.idx = 1; local.idx <= ArrayLen(local.candidateSiteIds); local.idx++) {
			local.pName = "csId" & local.idx;
			ArrayAppend(local.inPlaceholders, ":" & local.pName);
			local.siteParams[local.pName] = { value: local.candidateSiteIds[local.idx], cfsqltype: "cf_sql_nvarchar" };
		}
		local.siteInClause = ArrayToList(local.inPlaceholders, ", ");

		local.candidateSlug = local.slug;
		local.counter = 2;
		while (true) {
			local.checkParams = StructCopy(local.siteParams);
			local.checkParams.slug = { value: local.candidateSlug, cfsqltype: "cf_sql_nvarchar" };
			local.existsQ = queryExecute("
				SELECT TOP 1 ContentID FROM pages WHERE SiteID IN (" & local.siteInClause & ") AND Permalink = :slug AND DeletedAt IS NULL
			", local.checkParams, { datasource: "ChelanCountyWebsite" });

			if (local.existsQ.recordCount == 0) {
				local.slug = local.candidateSlug;
				break;
			}
			local.candidateSlug = local.slug & "-" & local.counter;
			local.counter++;
			if (local.counter > 50) break;
		}

		try {
			local.res = queryExecute("
				SET ANSI_NULLS ON;
				SET QUOTED_IDENTIFIER ON;
				INSERT INTO pages (
					SiteID, PageType, MenuSelected, LayoutType, ParentID,
					StatusCode, Permalink, Title, MetaTitle, MetaDesc, MetaKeyWords,
					Summary, Body, isService, hasArchive, ShowInMenu, isLocked,
					isPublished, Visibility, ViewCount, Created, CreatedBy, Modified, ModifiedBy
				)
				OUTPUT INSERTED.ContentID AS newId
				VALUES (
					:siteId, 0, '', :layout, 0,
					'Active', :slug, :title, :title, '', '',
					'', '', 0, 0, 0, 0,
					0, 'Draft', 0, SYSUTCDATETIME(), :actor, SYSUTCDATETIME(), :actor
				)
			", {
				siteId: { value: local.siteId, cfsqltype: "cf_sql_nvarchar" },
				layout: { value: local.layout, cfsqltype: "cf_sql_nvarchar" },
				slug: { value: local.slug, cfsqltype: "cf_sql_nvarchar" },
				title: { value: local.title, cfsqltype: "cf_sql_nvarchar" },
				actor: { value: local.actor, cfsqltype: "cf_sql_nvarchar" }
			}, { datasource: "ChelanCountyWebsite" });

			local.newId = Val(local.res.newId);

			fxRenderJson({
				"success": true,
				"SUCCESS": true,
				"id": local.newId,
				"ID": local.newId,
				"newId": local.newId,
				"title": local.title,
				"slug": local.slug,
				"layout": local.layout,
				"siteId": local.siteId,
				"redirectUrl": "/pages/edit?id=" & local.newId & "&created=1"
			});
		} catch (any e) {
			writeLog(type="error", file="pages", text="Failed to create page via modal: #e.message# #e.detail#");
			fxRenderJson({ success: false, message: "Unable to create page: #e.message#" }, 500);
		}
	}

	/**
	 * POST JSON: saves full updates to an existing page in the database
	 */
	function save() {
		local.body = fxReadJsonBody();
		local.req = IsStruct(local.body) ? local.body : params;

		local.id = Val(local.req.id ?: 0);
		local.title = Left(Trim(local.req.title ?: ""), 255);
		local.slug = slugifyText(local.req.slug ?: (local.req.permalink ?: ""));
		local.content = local.req.content ?: (local.req.body ?: "");
		local.metaTitle = Left(Trim(local.req.metaTitle ?: ""), 255);
		local.metaDesc = Trim(local.req.metaDescription ?: (local.req.metaDesc ?: ""));
		local.metaKeywords = Trim(local.req.metaKeywords ?: (local.req.metaKeyWords ?: ""));
		local.status = Trim(local.req.status ?: "Active");
		local.visibility = Trim(local.req.visibility ?: "Published");
		local.hasPublishAt = StructKeyExists(local.req, "publishAt") && Len(Trim(local.req.publishAt)) && IsDate(local.req.publishAt);
		local.publishAtDate = local.hasPublishAt ? ParseDateTime(local.req.publishAt) : "";
		local.layout = Trim(local.req.layout ?: "Full");
		local.pageAssignment = Trim(local.req.parent ?: "");
		local.menuItemTarget = Trim(local.req.menuItemTarget ?: "");
		local.menuItem = StructKeyExists(local.req, "menuItem") && (local.req.menuItem == 1 || local.req.menuItem == "true" || local.req.menuItem == true || local.req.menuItem == "yes");
		local.folderListingEnabled = StructKeyExists(local.req, "folderListingEnabled") && (local.req.folderListingEnabled == 1 || local.req.folderListingEnabled == "true" || local.req.folderListingEnabled == true || local.req.folderListingEnabled == "yes");
		local.sidebarIds = local.req.sidebarIds ?: [];
		if (!IsArray(local.sidebarIds)) {
			local.sidebarIds = ListToArray(local.sidebarIds);
		}
		local.sidebarJson = SerializeJSON(local.sidebarIds);

		if (local.id <= 0) {
			fxRenderJson({ success: false, SUCCESS: false, message: "Valid page ID is required." }, 400);
			return;
		}
		if (!Len(local.title)) {
			fxRenderJson({ success: false, SUCCESS: false, message: "Page title is required." }, 422);
			return;
		}
		if (!Len(local.slug)) {
			local.slug = slugifyText(local.title);
		}

		local.actor = spCurrentActor();
		local.isPub = (local.visibility == "Published") ? 1 : 0;

		// Calculate PageType and MenuSelected based on Page Assignment
		if (local.pageAssignment == "Assign to Main Menu Item" || local.pageAssignment == "Assign to Menu Item") {
			local.pageType = 1;
			local.menuSelected = local.menuItemTarget;
		} else if (local.pageAssignment == "Top Level - Called from URL") {
			local.pageType = 0;
			local.menuSelected = "";
		} else {
			if (Len(local.pageAssignment) && local.pageAssignment != "Top Level - Called from URL") {
				local.pageType = 1;
				local.menuSelected = local.pageAssignment;
			} else {
				local.pageType = local.menuItem ? 1 : 0;
				local.menuSelected = local.menuItemTarget;
			}
		}

		try {
			// Retrieve existing record to check site, lock status, and avoid collisions
			local.curPageQ = queryExecute("
				SELECT SiteID, isLocked, isService, imageAttachment, imageAttribution, imageAlt, imageTitle, imageDescription
				FROM pages
				WHERE ContentID = :id AND DeletedAt IS NULL
			", { id: { value: local.id, cfsqltype: "cf_sql_integer" } }, { datasource: "ChelanCountyWebsite" });

			if (local.curPageQ.recordCount == 0) {
				fxRenderJson({ success: false, SUCCESS: false, message: "Page not found in database." }, 404);
				return;
			}

			local.siteId = local.curPageQ.SiteID ?: activeWorkspaceId();
			if (local.curPageQ.isLocked == 1) {
				// Locked / root pages keep their permalink
				local.slug = local.curPageQ.Permalink ?: local.slug;
			}

			// Validate duplicate permalink across workspace candidate aliases
			local.candidateSiteIds = getCandidateSiteIds(local.siteId);
			if (ArrayLen(local.candidateSiteIds) == 0 && Len(local.siteId)) ArrayAppend(local.candidateSiteIds, local.siteId);
			local.conflictPlaceholders = [];
			local.conflictParams = {
				slug: { value: local.slug, cfsqltype: "cf_sql_nvarchar" },
				id: { value: local.id, cfsqltype: "cf_sql_integer" }
			};
			for (local.idx = 1; local.idx <= ArrayLen(local.candidateSiteIds); local.idx++) {
				local.pName = "confSite" & local.idx;
				ArrayAppend(local.conflictPlaceholders, ":" & local.pName);
				local.conflictParams[local.pName] = { value: local.candidateSiteIds[local.idx], cfsqltype: "cf_sql_nvarchar" };
			}
			local.conflictInClause = ArrayLen(local.conflictPlaceholders) ? ArrayToList(local.conflictPlaceholders, ", ") : "''";

			local.conflictQ = queryExecute("
				SELECT TOP 1 ContentID FROM pages
				WHERE SiteID IN (" & local.conflictInClause & ") AND Permalink = :slug AND ContentID <> :id AND DeletedAt IS NULL
			", local.conflictParams, { datasource: "ChelanCountyWebsite" });

			if (local.conflictQ.recordCount > 0) {
				fxRenderJson({ success: false, SUCCESS: false, message: "The Page URL slug '" & local.slug & "' is already used by another page in this workspace." }, 422);
				return;
			}

			// Service & Image fields
			local.isService = StructKeyExists(local.req, "isService")
				? (local.req.isService == 1 || local.req.isService == "true" || local.req.isService == true || local.req.isService == "yes" ? 1 : 0)
				: Val(local.curPageQ.isService ?: 0);
			local.imageAttachment = StructKeyExists(local.req, "imageAttachment") ? Trim(local.req.imageAttachment) : (local.curPageQ.imageAttachment ?: "");
			local.imageAttribution = StructKeyExists(local.req, "imageAttribution") ? Trim(local.req.imageAttribution) : (local.curPageQ.imageAttribution ?: "");
			local.imageAlt = StructKeyExists(local.req, "imageAlt") ? Trim(local.req.imageAlt) : (local.curPageQ.imageAlt ?: "");
			local.imageTitle = StructKeyExists(local.req, "imageTitle") ? Trim(local.req.imageTitle) : (local.curPageQ.imageTitle ?: "");
			local.imageDescription = StructKeyExists(local.req, "imageDescription") ? Trim(local.req.imageDescription) : (local.curPageQ.imageDescription ?: "");

			queryExecute("
				SET ANSI_NULLS ON;
				SET QUOTED_IDENTIFIER ON;
				UPDATE pages
				SET Title = :title,
				    Permalink = :slug,
				    Body = :body,
				    MetaTitle = :metaTitle,
				    MetaDesc = :metaDesc,
				    MetaKeyWords = :metaKeywords,
				    Summary = :metaDesc,
				    StatusCode = :status,
				    Visibility = :visibility,
				    PublishAt = :publishAt,
				    isPublished = :isPub,
				    LayoutType = :layout,
				    MenuSelected = :menuSelected,
				    ShowInMenu = :showInMenu,
				    PageType = :pageType,
				    hasArchive = :hasArchive,
				    isService = :isService,
				    imageAttachment = :imageAttachment,
				    imageAttribution = :imageAttribution,
				    imageAlt = :imageAlt,
				    imageTitle = :imageTitle,
				    imageDescription = :imageDescription,
				    SidebarIDs = :sidebarIds,
				    Modified = SYSUTCDATETIME(),
				    ModifiedBy = :actor
				WHERE ContentID = :id
			", {
				title: { value: local.title, cfsqltype: "cf_sql_nvarchar" },
				slug: { value: local.slug, cfsqltype: "cf_sql_nvarchar" },
				body: { value: local.content, cfsqltype: "cf_sql_longvarchar" },
				metaTitle: { value: local.metaTitle, cfsqltype: "cf_sql_nvarchar" },
				metaDesc: { value: local.metaDesc, cfsqltype: "cf_sql_nvarchar" },
				metaKeywords: { value: local.metaKeywords, cfsqltype: "cf_sql_nvarchar" },
				status: { value: local.status, cfsqltype: "cf_sql_nvarchar" },
				visibility: { value: local.visibility, cfsqltype: "cf_sql_nvarchar" },
				publishAt: local.hasPublishAt ? { value: local.publishAtDate, cfsqltype: "cf_sql_timestamp" } : { null: true, cfsqltype: "cf_sql_timestamp" },
				isPub: { value: local.isPub, cfsqltype: "cf_sql_bit" },
				layout: { value: local.layout, cfsqltype: "cf_sql_nvarchar" },
				menuSelected: { value: local.menuSelected, cfsqltype: "cf_sql_nvarchar" },
				showInMenu: { value: local.menuItem ? 1 : 0, cfsqltype: "cf_sql_bit" },
				pageType: { value: local.pageType, cfsqltype: "cf_sql_tinyint" },
				hasArchive: { value: local.folderListingEnabled ? 1 : 0, cfsqltype: "cf_sql_bit" },
				isService: { value: local.isService, cfsqltype: "cf_sql_bit" },
				imageAttachment: { value: local.imageAttachment, cfsqltype: "cf_sql_nvarchar" },
				imageAttribution: { value: local.imageAttribution, cfsqltype: "cf_sql_nvarchar" },
				imageAlt: { value: local.imageAlt, cfsqltype: "cf_sql_nvarchar" },
				imageTitle: { value: local.imageTitle, cfsqltype: "cf_sql_nvarchar" },
				imageDescription: { value: local.imageDescription, cfsqltype: "cf_sql_longvarchar" },
				sidebarIds: { value: local.sidebarJson, cfsqltype: "cf_sql_nvarchar" },
				actor: { value: local.actor, cfsqltype: "cf_sql_nvarchar" },
				id: { value: local.id, cfsqltype: "cf_sql_integer" }
			}, { datasource: "ChelanCountyWebsite" });

			local.updatedStr = DateFormat(Now(), "mm/dd/yyyy") & " " & TimeFormat(Now(), "hh:mm:ss");
			fxRenderJson({
				success: true,
				SUCCESS: true,
				message: "Page saved successfully.",
				MESSAGE: "Page saved successfully.",
				updated: local.updatedStr,
				UPDATED: local.updatedStr,
				author: local.actor,
				AUTHOR: local.actor,
				title: local.title,
				TITLE: local.title,
				slug: local.slug,
				SLUG: local.slug
			});
		} catch (any e) {
			writeLog(type="error", file="pages", text="Failed to save page: #e.message# #e.detail#");
			fxRenderJson({ success: false, SUCCESS: false, message: "Unable to save page: #e.message#" }, 500);
		}
	}

	/**
	 * Navigation menu items (depth-ordered) selectable under Page Attributes - Menu Item Selection.
	 */
	private array function loadMenuItemOptions(string requestedWs = "", string currentSelected = "") {
		local.options = [];
		try {
			local.requested = Len(Trim(arguments.requestedWs)) ? Trim(arguments.requestedWs)
				: (StructKeyExists(cookie, "cmsadmin_workspace") && Len(Trim(cookie.cmsadmin_workspace))
					? Trim(cookie.cmsadmin_workspace)
					: "");
			if (!Len(local.requested) || local.requested == "global" || local.requested == "all") {
				return [];
			}
			local.wsObj = resolveUserActiveWorkspace(requestedWs=local.requested, role=getCurrentActiveRole());
			local.siteid = local.wsObj.id;

			local.candidateSiteIds = getCandidateSiteIds(local.siteid);
			if (ArrayLen(local.candidateSiteIds) == 0 && Len(local.siteid)) ArrayAppend(local.candidateSiteIds, local.siteid);

			local.rows = queryNew("id,parent_item_id,label,siteid,menu_name", "integer,integer,varchar,varchar,varchar");

			if (ArrayLen(local.candidateSiteIds) > 0) {
				local.params = {};
				local.inPlaceholders = [];
				for (local.idx = 1; local.idx <= ArrayLen(local.candidateSiteIds); local.idx++) {
					local.paramName = "siteid" & local.idx;
					ArrayAppend(local.inPlaceholders, ":" & local.paramName);
					local.params[local.paramName] = { value: local.candidateSiteIds[local.idx], cfsqltype: "cf_sql_nvarchar", maxlength: 100 };
				}
				local.inClause = ArrayToList(local.inPlaceholders, ", ");

				local.rows = queryExecute("
					SELECT i.id, i.parent_item_id, i.label, m.siteid, m.name AS menu_name
					FROM navigation_menu_items i
					INNER JOIN navigation_menus m ON m.id = i.navigation_menu_id
					WHERE m.siteid IN (" & local.inClause & ") AND m.menu_key = 'side' AND m.deletedat IS NULL AND i.deletedat IS NULL AND i.is_active = 1
					ORDER BY m.siteid, i.sort_order, i.id
				", local.params, { datasource: "ChelanCountyWebsite" });
			}

			// If no menu structure is defined for this workspace, return empty list immediately!
			if (local.rows.recordCount == 0) {
				return [];
			}

			// Build workspace name lookup for optgroup titles
			local.wsMap = {};
			try {
				for (local.w in getMasterWorkspaces()) {
					if (StructKeyExists(local.w, "name") && Len(local.w.name)) {
						if (StructKeyExists(local.w, "id")) local.wsMap[LCase(local.w.id)] = local.w.name;
						if (StructKeyExists(local.w, "code")) local.wsMap[LCase(local.w.code)] = local.w.name;
						if (StructKeyExists(local.w, "alias") && Len(local.w.alias)) local.wsMap[LCase(local.w.alias)] = local.w.name;
					}
				}
			} catch (any errWs) {}

			// Partition rows by menu/siteid to preserve hierarchy trees
			local.menuGroups = {};
			local.menuGroupKeys = [];
			for (local.row in local.rows) {
				local.mKey = local.row.siteid;
				if (!StructKeyExists(local.menuGroups, local.mKey)) {
					local.menuGroups[local.mKey] = [];
					ArrayAppend(local.menuGroupKeys, local.mKey);
				}
				ArrayAppend(local.menuGroups[local.mKey], local.row);
			}

			local.isMultiMenu = (ArrayLen(local.menuGroupKeys) > 1);

			// Walk each menu hierarchy depth-first
			for (local.mKey in local.menuGroupKeys) {
				local.groupRows = local.menuGroups[local.mKey];
				local.groupWsName = StructKeyExists(local.wsMap, LCase(local.mKey)) ? local.wsMap[LCase(local.mKey)] : local.mKey;
				local.groupMenuTitle = local.isMultiMenu ? local.groupWsName : "";

				local.itemIds = {};
				for (local.row in local.groupRows) {
					local.itemIds["k_" & local.row.id] = true;
				}

				local.children = {};
				for (local.row in local.groupRows) {
					local.pVal = (IsNumeric(local.row.parent_item_id) && Val(local.row.parent_item_id) > 0) ? Val(local.row.parent_item_id) : 0;
					// If parent is not in this group's rows, treat as root item (depth 0)
					if (local.pVal > 0 && !StructKeyExists(local.itemIds, "k_" & local.pVal)) {
						local.pVal = 0;
					}
					local.cKey = "k_" & local.pVal;
					if (!StructKeyExists(local.children, local.cKey)) local.children[local.cKey] = [];
					ArrayAppend(local.children[local.cKey], { id: local.row.id, label: local.row.label });
				}

				local.stack = [];
				if (StructKeyExists(local.children, "k_0")) {
					for (local.i = ArrayLen(local.children["k_0"]); local.i >= 1; local.i--) {
						ArrayAppend(local.stack, { item: local.children["k_0"][local.i], depth: 0 });
					}
				}

				local.guard = 0;
				while (ArrayLen(local.stack) && local.guard < 5000) {
					local.guard++;
					local.node = local.stack[ArrayLen(local.stack)];
					ArrayDeleteAt(local.stack, ArrayLen(local.stack));

					ArrayAppend(local.options, {
						id: local.node.item.id,
						label: local.node.item.label,
						depth: local.node.depth,
						group: local.groupMenuTitle
					});

					local.childKey = "k_" & local.node.item.id;
					if (StructKeyExists(local.children, local.childKey)) {
						for (local.i = ArrayLen(local.children[local.childKey]); local.i >= 1; local.i--) {
							ArrayAppend(local.stack, { item: local.children[local.childKey][local.i], depth: local.node.depth + 1 });
						}
					}
				}
			}
		} catch (any e) {
			local.options = [];
		}
		return local.options;
	}

	/**
	 * JSON menu item options for the workspace chosen in the header switcher.
	 */
	function menuItems() {
		local.ws = StructKeyExists(params, "ws") ? LCase(Trim(params.ws)) : "";
		if (!REFind("^[a-z0-9_-]{1,100}$", local.ws)) local.ws = "";
		local.selected = StructKeyExists(params, "selected") ? Trim(params.selected) : "";
		local.opts = loadMenuItemOptions(local.ws, local.selected);
		renderText(text=SerializeJSON({ "options": local.opts, "OPTIONS": local.opts }), contentType="application/json", layout=false);
	}

	/**
	 * Add Folder Explorer (form asking for title, absolute path, relative path, and layout)
	 */
	function folderExplorer() {
		variables.pageTitle = "Add Folder Explorer";
		variables.explorer = {
			title: StructKeyExists(params, "title") ? Trim(params.title) : "",
			absolutePath: StructKeyExists(params, "absolutePath") ? Trim(params.absolutePath) : "C:\inetpub\CMSAdmin2.0\files\assessors",
			relativePath: StructKeyExists(params, "relativePath") ? Trim(params.relativePath) : "files/assessors",
			layout: StructKeyExists(params, "layout") && (params.layout eq "Full" or params.layout eq "3/9") ? Trim(params.layout) : "3/9",
			allowedExtensions: "pdf,doc,docx,xls,xlsx,jpg,png,zip",
			showBreadcrumbs: true,
			showFileSizes: true,
			showLastModified: true,
			enableSearch: true,
			status: "Active"
		};
	}

	/**
	 * Folder Explorer items saved for a page (page_FolderExplorer.ContentID = page id).
	 */
	private array function loadFolderExplorers(required numeric contentId) {
		local.items = [];
		if (arguments.contentId <= 0) return local.items;
		local.siteId = activeWorkspaceId();
		if (!Len(local.siteId) || local.siteId == "global" || local.siteId == "all") return local.items;

		local.candidateSiteIds = getCandidateSiteIds(local.siteId);
		if (ArrayLen(local.candidateSiteIds) == 0) ArrayAppend(local.candidateSiteIds, local.siteId);
		local.inPlaceholders = [];
		local.params = { contentId: { value: arguments.contentId, cfsqltype: "cf_sql_integer" } };
		for (local.idx = 1; local.idx <= ArrayLen(local.candidateSiteIds); local.idx++) {
			local.pName = "feSite" & local.idx;
			ArrayAppend(local.inPlaceholders, ":" & local.pName);
			local.params[local.pName] = { value: local.candidateSiteIds[local.idx], cfsqltype: "cf_sql_nvarchar" };
		}
		local.inClause = ArrayToList(local.inPlaceholders, ", ");

		try {
			local.rows = queryExecute("
				SELECT ID, ContentID, Title, RelativePath, AbsolutePath, Absolute, Weight, Layout, Placement
				FROM page_FolderExplorer
				WHERE ContentID = :contentId AND SiteID IN (" & local.inClause & ")
				ORDER BY Weight, ID
			", local.params, { datasource: "ChelanCountyWebsite" });
			for (local.row in local.rows) {
				ArrayAppend(local.items, {
					id: local.row.ID,
					contentId: local.row.ContentID,
					name: local.row.Title,
					path: Len(local.row.AbsolutePath) ? local.row.AbsolutePath : local.row.RelativePath,
					absolutePath: local.row.AbsolutePath,
					relativePath: local.row.RelativePath,
					absolute: local.row.Absolute,
					weight: local.row.Weight,
					layout: local.row.Layout,
					placement: local.row.Placement
				});
			}
		} catch (any e) {
			writeLog(type="error", file="pages", text="Folder explorer load failed: #e.message# #e.detail#");
		}
		return local.items;
	}

	/**
	 * Loads available forms that belong strictly to the requested workspace / department
	 */
	private array function loadWorkspaceForms(string requestedWs = "") {
		local.forms = [];
		try {
			local.targetWs = Trim(arguments.requestedWs);
			if (!Len(local.targetWs) || local.targetWs == "global" || local.targetWs == "all") {
				local.targetWs = activeWorkspaceId();
			}
			if (!Len(local.targetWs) && StructKeyExists(cookie, "cmsadmin_workspace") && Len(Trim(cookie.cmsadmin_workspace))) {
				local.rawCk = LCase(Trim(cookie.cmsadmin_workspace));
				if (local.rawCk != "global" && local.rawCk != "all") {
					local.targetWs = local.rawCk;
				}
			}
			// If still empty or global, check if page has a specific workspace
			if ((!Len(local.targetWs) || local.targetWs == "global" || local.targetWs == "all") && StructKeyExists(variables, "page") && StructKeyExists(variables.page, "siteId") && Len(Trim(variables.page.siteId))) {
				local.pageWs = LCase(Trim(variables.page.siteId));
				if (local.pageWs != "global" && local.pageWs != "all") {
					local.targetWs = local.pageWs;
				}
			}

			local.cands = [];
			if (Len(local.targetWs) && local.targetWs != "global" && local.targetWs != "all") {
				local.cands = getCandidateSiteIds(local.targetWs);
				if (!ArrayFindNoCase(local.cands, local.targetWs)) {
					ArrayAppend(local.cands, LCase(Trim(local.targetWs)));
				}
				// Also include singular/plural variations
				local.lowTarget = LCase(Trim(local.targetWs));
				if (Right(local.lowTarget, 1) == "s") {
					local.sing = Left(local.lowTarget, Len(local.lowTarget) - 1);
					if (Len(local.sing) && !ArrayFindNoCase(local.cands, local.sing)) ArrayAppend(local.cands, local.sing);
				} else {
					local.plur = local.lowTarget & "s";
					if (!ArrayFindNoCase(local.cands, local.plur)) ArrayAppend(local.cands, local.plur);
				}
			}

			local.q = queryExecute("
				SELECT f.id, f.form_key, f.slug, f.title, f.description, f.siteid, f.status,
				       d.name AS dept_name, d.badge_class AS dept_badge
				FROM forms f
				LEFT JOIN form_departments d ON d.id = f.department_id
				WHERE f.deletedat IS NULL
				ORDER BY f.title ASC
			", {}, { datasource: "ChelanCountyWebsite" });

			for (local.row in local.q) {
				local.rowSiteId = LCase(Trim(local.row.siteid ?: (local.row.SITEID ?: "")));
				local.isMatch = false;

				if (ArrayLen(local.cands) > 0) {
					if (ArrayFindNoCase(local.cands, local.rowSiteId) > 0) {
						local.isMatch = true;
					}
				} else if (Len(local.targetWs) && local.targetWs != "global" && local.targetWs != "all") {
					if (local.rowSiteId == LCase(local.targetWs)) {
						local.isMatch = true;
					}
				} else {
					// Fallback only if no workspace filter at all
					local.isMatch = true;
				}

				// Only show forms that belong to the workspace
				if (!local.isMatch) {
					continue;
				}

				local.formId = Val(local.row.id ?: (local.row.ID ?: 0));
				local.formKey = local.row.form_key ?: (local.row.FORM_KEY ?: "");
				local.formSlug = local.row.slug ?: (local.row.SLUG ?: "");
				local.formTitle = Len(Trim(local.row.title ?: (local.row.TITLE ?: ""))) ? (local.row.title ?: local.row.TITLE) : "Untitled Form";
				local.formDesc = local.row.description ?: (local.row.DESCRIPTION ?: "");
				local.formSite = local.row.siteid ?: (local.row.SITEID ?: "");
				local.formStatus = LCase(local.row.status ?: (local.row.STATUS ?: "published"));
				local.rawDept = local.row.dept_name ?: (local.row.DEPT_NAME ?: "");
				local.deptName = Len(Trim(local.rawDept)) ? local.rawDept : (Len(Trim(local.formSite)) ? local.formSite : "General");
				local.rawBadge = local.row.dept_badge ?: (local.row.DEPT_BADGE ?: "");
				local.deptBadge = Len(Trim(local.rawBadge)) ? local.rawBadge : "badge-primary";

				ArrayAppend(local.forms, {
					id: local.formId,
					formKey: local.formKey,
					slug: local.formSlug,
					title: local.formTitle,
					description: local.formDesc,
					siteid: local.formSite,
					status: local.formStatus,
					deptName: local.deptName,
					deptBadge: local.deptBadge,
					isCurrentWorkspace: true
				});
			}

			// Sort alphabetically by title
			ArraySort(local.forms, function(a, b) {
				return CompareNoCase(a.title, b.title);
			});
		} catch (any e) {
			writeLog(type="error", file="pages", text="Failed to load forms: #e.message# #e.detail#");
		}
		return local.forms;
	}

	/**
	 * JSON endpoint returning available forms for a given workspace
	 * /pages/workspaceForms?ws=assessor
	 */
	function workspaceForms() {
		local.ws = StructKeyExists(params, "ws") ? LCase(Trim(params.ws)) : "";
		if (!REFind("^[a-z0-9_-]{1,100}$", local.ws)) local.ws = "";
		local.forms = loadWorkspaceForms(requestedWs=local.ws);
		renderText(text=SerializeJSON({
			"success": true,
			"workspace": local.ws,
			"count": ArrayLen(local.forms),
			"forms": local.forms
		}), contentType="application/json", layout=false);
	}

	/**
	 * POST JSON { id, contentId, title, absolutePath, relativePath, layout } - insert or update.
	 */
	function saveFolderExplorer() {
		local.body = fxReadJsonBody();
		if (!IsStruct(local.body)) {
			fxRenderJson({ success: false, message: "Invalid request payload." }, 400);
			return;
		}
		local.id = Val(local.body.id ?: 0);
		local.contentId = Val(local.body.contentId ?: 0);
		local.title = Left(Trim(local.body.title ?: ""), 255);
		local.absolutePath = Left(Trim(local.body.absolutePath ?: ""), 500);
		local.relativePath = Left(Trim(local.body.relativePath ?: ""), 500);
		local.layoutValue = Trim(local.body.layout ?: "Full");
		if (local.contentId <= 0) {
			fxRenderJson({ success: false, message: "Save the page before adding folder explorer items." }, 422);
			return;
		}
		if (!Len(local.title)) {
			fxRenderJson({ success: false, message: "A title is required." }, 422);
			return;
		}
		if (local.layoutValue != "Full" && local.layoutValue != "3/9") local.layoutValue = "Full";
		local.isAbsolute = Len(local.absolutePath) ? 1 : 0;
		local.siteId = activeWorkspaceId();
		if (!Len(local.siteId) || local.siteId == "global" || local.siteId == "all") {
			fxRenderJson({ success: false, message: "Please select a workspace before saving folder explorer items." }, 422);
			return;
		}

		local.candidateSiteIds = getCandidateSiteIds(local.siteId);
		if (ArrayLen(local.candidateSiteIds) == 0) ArrayAppend(local.candidateSiteIds, local.siteId);
		local.inPlaceholders = [];
		local.siteParams = {};
		for (local.idx = 1; local.idx <= ArrayLen(local.candidateSiteIds); local.idx++) {
			local.pName = "sfe" & local.idx;
			ArrayAppend(local.inPlaceholders, ":" & local.pName);
			local.siteParams[local.pName] = { value: local.candidateSiteIds[local.idx], cfsqltype: "cf_sql_nvarchar" };
		}
		local.siteInClause = ArrayToList(local.inPlaceholders, ", ");

		try {
			if (local.id > 0) {
				local.updateParams = StructCopy(local.siteParams);
				local.updateParams.title = { value: local.title, cfsqltype: "cf_sql_nvarchar" };
				local.updateParams.rel = { value: local.relativePath, cfsqltype: "cf_sql_nvarchar" };
				local.updateParams.abs = { value: local.absolutePath, cfsqltype: "cf_sql_nvarchar" };
				local.updateParams.isAbs = { value: local.isAbsolute, cfsqltype: "cf_sql_bit" };
				local.updateParams.layoutValue = { value: local.layoutValue, cfsqltype: "cf_sql_nvarchar" };
				local.updateParams.id = { value: local.id, cfsqltype: "cf_sql_integer" };

				queryExecute("
					UPDATE page_FolderExplorer
					SET Title = :title, RelativePath = :rel, AbsolutePath = :abs, Absolute = :isAbs, Layout = :layoutValue
					WHERE ID = :id AND SiteID IN (" & local.siteInClause & ")
				", local.updateParams, { datasource: "ChelanCountyWebsite" });
			} else {
				local.insertParams = StructCopy(local.siteParams);
				local.insertParams.siteId = { value: local.siteId, cfsqltype: "cf_sql_nvarchar" };
				local.insertParams.contentId = { value: local.contentId, cfsqltype: "cf_sql_integer" };
				local.insertParams.title = { value: local.title, cfsqltype: "cf_sql_nvarchar" };
				local.insertParams.rel = { value: local.relativePath, cfsqltype: "cf_sql_nvarchar" };
				local.insertParams.abs = { value: local.absolutePath, cfsqltype: "cf_sql_nvarchar" };
				local.insertParams.isAbs = { value: local.isAbsolute, cfsqltype: "cf_sql_bit" };
				local.insertParams.layoutValue = { value: local.layoutValue, cfsqltype: "cf_sql_nvarchar" };

				local.res = queryExecute("
					INSERT INTO page_FolderExplorer (ContentID, SiteID, Title, RelativePath, AbsolutePath, Absolute, Weight, Layout)
					OUTPUT INSERTED.ID AS newId
					SELECT :contentId, :siteId, :title, :rel, :abs, :isAbs, ISNULL(MAX(Weight), 0) + 1, :layoutValue
					FROM page_FolderExplorer WHERE SiteID IN (" & local.siteInClause & ")
				", local.insertParams, { datasource: "ChelanCountyWebsite" });
				local.id = local.res.newId;
			}
		} catch (any e) {
			writeLog(type="error", file="pages", text="Folder explorer save failed: #e.message# #e.detail#");
			fxRenderJson({ success: false, message: "Unable to save this folder explorer item: #e.message# #e.detail#" }, 500);
			return;
		}
		fxRenderJson({
			success: true,
			item: {
				id: local.id,
				title: local.title,
				absolutePath: local.absolutePath,
				relativePath: local.relativePath,
				layout: local.layoutValue,
				path: Len(local.absolutePath) ? local.absolutePath : local.relativePath
			}
		});
	}

	/**
	 * POST JSON { id, contentId } - hard delete.
	 */
	function deleteFolderExplorer() {
		local.body = fxReadJsonBody();
		local.id = IsStruct(local.body) ? Val(local.body.id ?: 0) : 0;
		local.contentId = IsStruct(local.body) ? Val(local.body.contentId ?: 0) : 0;
		if (local.id <= 0 || local.contentId <= 0) {
			fxRenderJson({ success: false, message: "A valid folder explorer item is required." }, 400);
			return;
		}
		local.siteId = activeWorkspaceId();
		if (!Len(local.siteId) || local.siteId == "global" || local.siteId == "all") {
			fxRenderJson({ success: false, message: "Please select a workspace before deleting items." }, 422);
			return;
		}

		local.candidateSiteIds = getCandidateSiteIds(local.siteId);
		if (ArrayLen(local.candidateSiteIds) == 0) ArrayAppend(local.candidateSiteIds, local.siteId);
		local.inPlaceholders = [];
		local.params = { id: { value: local.id, cfsqltype: "cf_sql_integer" } };
		for (local.idx = 1; local.idx <= ArrayLen(local.candidateSiteIds); local.idx++) {
			local.pName = "dfe" & local.idx;
			ArrayAppend(local.inPlaceholders, ":" & local.pName);
			local.params[local.pName] = { value: local.candidateSiteIds[local.idx], cfsqltype: "cf_sql_nvarchar" };
		}
		local.inClause = ArrayToList(local.inPlaceholders, ", ");

		try {
			queryExecute("DELETE FROM page_FolderExplorer WHERE ID = :id AND SiteID IN (" & local.inClause & ")", local.params, { datasource: "ChelanCountyWebsite" });
		} catch (any e) {
			writeLog(type="error", file="pages", text="Folder explorer delete failed: #e.message# #e.detail#");
			fxRenderJson({ success: false, message: "Unable to remove this item. Please try again." }, 500);
			return;
		}
		fxRenderJson({ success: true });
	}

	/**
	 * Subpages belonging to the active workspace (or assigned to this page).
	 */
	private array function loadSubpages(numeric contentId = 0, string requestedWs = "", any assignedIds = []) {
		local.items = [];
		local.targetWs = Len(Trim(arguments.requestedWs)) ? Trim(arguments.requestedWs) : activeWorkspaceId();
		if (!Len(local.targetWs) && StructKeyExists(cookie, "cmsadmin_workspace") && Len(Trim(cookie.cmsadmin_workspace))) {
			local.rawCk = LCase(Trim(cookie.cmsadmin_workspace));
			if (local.rawCk != "global" && local.rawCk != "all") {
				local.targetWs = local.rawCk;
			}
		}

		local.candidateSiteIds = Len(local.targetWs) ? getCandidateSiteIds(local.targetWs) : [];
		if (Len(local.targetWs) && ArrayLen(local.candidateSiteIds) == 0 && local.targetWs != "global" && local.targetWs != "all") {
			ArrayAppend(local.candidateSiteIds, local.targetWs);
		}

		// Extract numeric IDs from assignedIds like ["subpage-8", "subpage-13"] or numeric [8, 13]
		local.assignedNumericIds = [];
		local.rawAssigned = IsArray(arguments.assignedIds) ? arguments.assignedIds : ListToArray(ToString(arguments.assignedIds));
		for (local.aid in local.rawAssigned) {
			local.cleanAid = ReReplaceNoCase(ToString(local.aid), "^subpage-", "");
			if (IsNumeric(local.cleanAid) && Val(local.cleanAid) > 0 && !ArrayFind(local.assignedNumericIds, Val(local.cleanAid))) {
				ArrayAppend(local.assignedNumericIds, Val(local.cleanAid));
			}
		}

		local.params = {};
		local.whereClauses = [];

		if (ArrayLen(local.candidateSiteIds) > 0) {
			local.inPlaceholders = [];
			for (local.idx = 1; local.idx <= ArrayLen(local.candidateSiteIds); local.idx++) {
				local.pName = "spSite" & local.idx;
				ArrayAppend(local.inPlaceholders, ":" & local.pName);
				local.params[local.pName] = { value: local.candidateSiteIds[local.idx], cfsqltype: "cf_sql_nvarchar" };
			}
			local.inClause = ArrayToList(local.inPlaceholders, ", ");
			ArrayAppend(local.whereClauses, "(sp.SiteID IN (" & local.inClause & ") OR sp.ContentID IN (SELECT p.ContentID FROM pages p WHERE p.SiteID IN (" & local.inClause & ")))");
		}

		if (arguments.contentId > 0) {
			local.params.contentId = { value: arguments.contentId, cfsqltype: "cf_sql_integer" };
			ArrayAppend(local.whereClauses, "sp.ContentID = :contentId");
		}

		if (ArrayLen(local.assignedNumericIds) > 0) {
			local.aidPlaceholders = [];
			for (local.aIdx = 1; local.aIdx <= ArrayLen(local.assignedNumericIds); local.aIdx++) {
				local.apName = "spAid" & local.aIdx;
				ArrayAppend(local.aidPlaceholders, ":" & local.apName);
				local.params[local.apName] = { value: local.assignedNumericIds[local.aIdx], cfsqltype: "cf_sql_integer" };
			}
			ArrayAppend(local.whereClauses, "sp.ID IN (" & ArrayToList(local.aidPlaceholders, ", ") & ")");
		}

		if (ArrayLen(local.whereClauses) == 0) {
			if (local.targetWs != "global" && local.targetWs != "all") {
				return local.items;
			}
		}

		local.sql = "
			SELECT sp.ID, sp.Title, sp.Body, sp.Position, sp.ContentID, sp.SiteID
			FROM page_SubPage sp
		";
		if (ArrayLen(local.whereClauses) > 0) {
			local.sql &= " WHERE (" & ArrayToList(local.whereClauses, " OR ") & ")";
		}
		local.sql &= " ORDER BY sp.Position, sp.Title, sp.ID";

		try {
			local.rows = queryExecute(local.sql, local.params, { datasource: "ChelanCountyWebsite" });
			for (local.row in local.rows) {
				ArrayAppend(local.items, {
					id: local.row.ID,
					title: local.row.Title,
					body: local.row.Body ?: "",
					position: local.row.Position,
					contentId: local.row.ContentID,
					siteId: local.row.SiteID ?: ""
				});
			}
		} catch (any e) {
			writeLog(type="error", file="pages", text="Subpage load failed: #e.message# #e.detail#");
		}
		return local.items;
	}

	/**
	 * Workspace the current user is working in, resolved server-side from the workspace cookie.
	 */
	private string function activeWorkspaceId() {
		local.requested = (StructKeyExists(params, "ws") && Len(Trim(params.ws))) ? Trim(params.ws)
			: ((StructKeyExists(cookie, "cmsadmin_workspace") && Len(Trim(cookie.cmsadmin_workspace))) ? Trim(cookie.cmsadmin_workspace) : "");
		if (!Len(local.requested) || local.requested == "global" || local.requested == "all") {
			return "";
		}
		local.ws = resolveUserActiveWorkspace(requestedWs=local.requested, role=getCurrentActiveRole());
		local.id = LCase(Trim(local.ws.id ?: ""));
		if (local.id == "global" || local.id == "all") return "";
		return Len(local.id) ? Left(local.id, 100) : "";
	}

	private string function spCurrentActor() {
		if (StructKeyExists(session, "user") && IsStruct(session.user)) {
			if (Len(session.user.email ?: "")) return Left(session.user.email, 255);
			if (Len(session.user.username ?: "")) return Left(session.user.username, 255);
		}
		return "System";
	}

	/**
	 * POST JSON { id, contentId, title, body, position, siteId } - insert or update a subpage.
	 */
	function saveSubpage() {
		local.body = fxReadJsonBody();
		if (!IsStruct(local.body)) {
			fxRenderJson({ success: false, message: "Invalid request payload." }, 400);
			return;
		}
		local.id = Val(local.body.id ?: 0);
		local.contentId = Val(local.body.contentId ?: 0);
		local.title = Left(Trim(local.body.title ?: ""), 255);
		local.content = local.body.body ?: "";
		local.position = Max(0, Int(Val(local.body.position ?: 0)));
		if (local.contentId <= 0 && local.id <= 0) {
			fxRenderJson({ success: false, message: "Save the page before adding new subpages." }, 422);
			return;
		}
		if (!Len(local.title)) {
			fxRenderJson({ success: false, message: "A title / header is required." }, 422);
			return;
		}
		local.actor = spCurrentActor();
		local.siteId = (StructKeyExists(local.body, "siteId") && Len(Trim(local.body.siteId)) && local.body.siteId != "global" && local.body.siteId != "all")
			? Trim(local.body.siteId)
			: activeWorkspaceId();

		if (!Len(local.siteId) || local.siteId == "global" || local.siteId == "all") {
			if (local.contentId > 0) {
				local.pageSiteQ = queryExecute("SELECT SiteID FROM pages WHERE ContentID = :contentId", { contentId: { value: local.contentId, cfsqltype: "cf_sql_integer" } }, { datasource: "ChelanCountyWebsite" });
				if (local.pageSiteQ.recordCount && Len(Trim(local.pageSiteQ.SiteID)) && local.pageSiteQ.SiteID != "global" && local.pageSiteQ.SiteID != "all") {
					local.siteId = Trim(local.pageSiteQ.SiteID);
				}
			}
		}

		if (!Len(local.siteId) || local.siteId == "global" || local.siteId == "all") {
			fxRenderJson({ success: false, message: "Please select a workspace before saving subpages." }, 422);
			return;
		}

		local.candidateSiteIds = getCandidateSiteIds(local.siteId);
		if (ArrayLen(local.candidateSiteIds) == 0) ArrayAppend(local.candidateSiteIds, local.siteId);
		local.inPlaceholders = [];
		local.siteParams = {};
		for (local.idx = 1; local.idx <= ArrayLen(local.candidateSiteIds); local.idx++) {
			local.pName = "ssp" & local.idx;
			ArrayAppend(local.inPlaceholders, ":" & local.pName);
			local.siteParams[local.pName] = { value: local.candidateSiteIds[local.idx], cfsqltype: "cf_sql_nvarchar" };
		}
		local.siteInClause = ArrayToList(local.inPlaceholders, ", ");

		try {
			if (local.id > 0) {
				local.updateParams = StructCopy(local.siteParams);
				local.updateParams.title = { value: local.title, cfsqltype: "cf_sql_nvarchar" };
				local.updateParams.body = { value: local.content, cfsqltype: "cf_sql_longvarchar" };
				local.updateParams.position = { value: local.position, cfsqltype: "cf_sql_integer" };
				local.updateParams.actor = { value: local.actor, cfsqltype: "cf_sql_nvarchar" };
				local.updateParams.id = { value: local.id, cfsqltype: "cf_sql_integer" };
				local.updateParams.contentId = { value: local.contentId, cfsqltype: "cf_sql_integer" };

				queryExecute("
					UPDATE page_SubPage
					SET Title = :title, Body = :body, Position = :position, ModifiedAt = SYSDATETIME(), ModifiedBy = :actor
					WHERE ID = :id AND (SiteID IN (" & local.siteInClause & ") OR ContentID = :contentId)
				", local.updateParams, { datasource: "ChelanCountyWebsite" });
			} else {
				local.insertParams = StructCopy(local.siteParams);
				local.insertParams.siteId = { value: local.siteId, cfsqltype: "cf_sql_nvarchar" };
				local.insertParams.contentId = { value: local.contentId, cfsqltype: "cf_sql_integer" };
				local.insertParams.title = { value: local.title, cfsqltype: "cf_sql_nvarchar" };
				local.insertParams.body = { value: local.content, cfsqltype: "cf_sql_longvarchar" };
				local.insertParams.position = { value: local.position, cfsqltype: "cf_sql_integer" };
				local.insertParams.actor = { value: local.actor, cfsqltype: "cf_sql_nvarchar" };

				local.res = queryExecute("
					INSERT INTO page_SubPage (ContentID, SiteID, Title, Body, Position, CreatedAt, CreatedBy)
					OUTPUT INSERTED.ID AS newId
					VALUES (:contentId, :siteId, :title, :body, :position, SYSDATETIME(), :actor)
				", local.insertParams, { datasource: "ChelanCountyWebsite" });
				local.id = local.res.newId;
			}
		} catch (any e) {
			writeLog(type="error", file="pages", text="Subpage save failed: #e.message# #e.detail#");
			fxRenderJson({ success: false, message: "Unable to save this subpage: #e.message# #e.detail#" }, 500);
			return;
		}
		fxRenderJson({
			success: true,
			item: { id: local.id, title: local.title, body: local.content, position: local.position, siteId: local.siteId }
		});
	}

	/**
	 * POST JSON { id, contentId, siteId } - hard delete a subpage.
	 */
	function deleteSubpage() {
		local.body = fxReadJsonBody();
		local.id = IsStruct(local.body) ? Val(local.body.id ?: 0) : 0;
		if (local.id <= 0) {
			fxRenderJson({ success: false, message: "A valid subpage is required." }, 400);
			return;
		}
		local.siteId = (IsStruct(local.body) && StructKeyExists(local.body, "siteId") && Len(Trim(local.body.siteId))) ? Trim(local.body.siteId) : activeWorkspaceId();

		local.subQ = queryExecute("SELECT SiteID FROM page_SubPage WHERE ID = :id", { id: { value: local.id, cfsqltype: "cf_sql_integer" } }, { datasource: "ChelanCountyWebsite" });
		if (local.subQ.recordCount == 0) {
			fxRenderJson({ success: false, message: "Subpage not found." }, 404);
			return;
		}
		local.subSiteId = Trim(local.subQ.SiteID);
		if (!Len(local.siteId) || local.siteId == "global" || local.siteId == "all") {
			local.siteId = local.subSiteId;
		}

		local.candidateSiteIds = getCandidateSiteIds(local.siteId);
		if (ArrayLen(local.candidateSiteIds) == 0 && Len(local.siteId)) ArrayAppend(local.candidateSiteIds, local.siteId);
		if (Len(local.subSiteId) && !ArrayFindNoCase(local.candidateSiteIds, local.subSiteId)) {
			ArrayAppend(local.candidateSiteIds, local.subSiteId);
		}

		local.inPlaceholders = [];
		local.params = { id: { value: local.id, cfsqltype: "cf_sql_integer" } };
		for (local.idx = 1; local.idx <= ArrayLen(local.candidateSiteIds); local.idx++) {
			local.pName = "dsp" & local.idx;
			ArrayAppend(local.inPlaceholders, ":" & local.pName);
			local.params[local.pName] = { value: local.candidateSiteIds[local.idx], cfsqltype: "cf_sql_nvarchar" };
		}
		local.inClause = ArrayToList(local.inPlaceholders, ", ");

		try {
			queryExecute("DELETE FROM page_SubPage WHERE ID = :id AND SiteID IN (" & local.inClause & ")", local.params, { datasource: "ChelanCountyWebsite" });
		} catch (any e) {
			writeLog(type="error", file="pages", text="Subpage delete failed: #e.message# #e.detail#");
			fxRenderJson({ success: false, message: "Unable to remove this subpage. Please try again." }, 500);
			return;
		}
		fxRenderJson({ success: true });
	}

	private any function fxReadJsonBody() {
		try {
			local.content = GetHTTPRequestData().content;
			if (IsBinary(local.content)) local.content = CharsetEncode(local.content, "utf-8");
			if (Len(Trim(local.content)) && IsJSON(local.content)) return DeserializeJSON(local.content);
		} catch (any e) {
			return "";
		}
		return "";
	}

	private void function fxRenderJson(required any data, numeric status = 200) {
		cfheader(name="Content-Type", value="application/json; charset=utf-8");
		renderText(text=SerializeJSON(arguments.data), status=arguments.status);
	}

	private array function samplePages() {
		return [];
	}

	private string function slugifyText(required string text) {
		local.s = LCase(Trim(arguments.text));
		local.s = REReplace(local.s, "[^a-z0-9\s-]", "", "all");
		local.s = REReplace(local.s, "[\s_-]+", "-", "all");
		local.s = REReplace(local.s, "^-+|-+$", "", "all");
		return local.s;
	}

	private struct function loadPageFromDb(required numeric contentId) {
		local.res = {};
		if (arguments.contentId <= 0) return local.res;
		try {
			local.q = queryExecute("
				SELECT TOP 1 ContentID, SiteID, PageType, MenuSelected, LayoutType, ParentID,
				       StatusCode, Permalink, Title, MetaTitle, MetaDesc, MetaKeyWords,
				       Summary, Body, imageAttachment, imageAttribution, imageAlt, imageTitle, imageDescription,
				       isService, hasArchive, ShowInMenu, isLocked, SidebarIDs, SortOrder,
				       isPublished, Visibility, PublishAt, ViewCount, Created, CreatedBy, Modified, ModifiedBy
				FROM pages
				WHERE ContentID = :id AND DeletedAt IS NULL
			", { id: { value: arguments.contentId, cfsqltype: "cf_sql_integer" } }, { datasource: "ChelanCountyWebsite" });

			if (local.q.recordCount > 0) {
				local.row = local.q;
				local.sidebarList = [];
				if (Len(Trim(local.row.SidebarIDs))) {
					try {
						if (IsJSON(local.row.SidebarIDs)) {
							local.sidebarList = DeserializeJSON(local.row.SidebarIDs);
						} else {
							local.sidebarList = ListToArray(local.row.SidebarIDs);
						}
					} catch (any errSide) {
						local.sidebarList = [];
					}
				}
				local.updatedStr = "";
				if (IsDate(local.row.Modified)) {
					local.updatedStr = DateFormat(local.row.Modified, "mm/dd/yyyy") & " " & TimeFormat(local.row.Modified, "hh:mm:ss");
				} else if (IsDate(local.row.Created)) {
					local.updatedStr = DateFormat(local.row.Created, "mm/dd/yyyy") & " " & TimeFormat(local.row.Created, "hh:mm:ss");
				}

				local.res = {
					id: local.row.ContentID,
					title: local.row.Title ?: "",
					slug: local.row.Permalink ?: "",
					siteId: local.row.SiteID ?: "global",
					pageType: Val(local.row.PageType ?: 0),
					parent: local.row.MenuSelected ?: "",
					layout: Len(Trim(local.row.LayoutType)) ? local.row.LayoutType : "Full",
					status: local.row.StatusCode ?: "Active",
					visibility: local.row.Visibility ?: "Published",
					isPublished: (local.row.isPublished == 1),
					menuItem: (local.row.ShowInMenu == 1 || local.row.PageType == 1),
					locked: (local.row.isLocked == 1),
					summary: local.row.Summary ?: "",
					body: local.row.Body ?: "",
					content: local.row.Body ?: "",
					metaTitle: local.row.MetaTitle ?: "",
					metaDesc: local.row.MetaDesc ?: "",
					metaKeywords: local.row.MetaKeyWords ?: "",
					sidebarIds: local.sidebarList,
					author: Len(local.row.ModifiedBy) ? local.row.ModifiedBy : (local.row.CreatedBy ?: "Admin"),
					updated: local.updatedStr,
					hasArchive: (local.row.hasArchive == 1)
				};
			}
		} catch (any e) {
			writeLog(type="error", file="pages", text="Failed to load page from DB: #e.message# #e.detail#");
		}
		return local.res;
	}

	private array function loadPagesList() {
		local.pages = [];
		try {
			local.siteId = activeWorkspaceId();

			// If no workspace is selected (or invalid/global), strictly return empty list
			if (!Len(local.siteId) || local.siteId == "global" || local.siteId == "all") {
				return local.pages;
			}

			local.candidateSiteIds = getCandidateSiteIds(local.siteId);
			if (ArrayLen(local.candidateSiteIds) == 0) ArrayAppend(local.candidateSiteIds, local.siteId);

			local.params = {};
			local.inPlaceholders = [];
			for (local.idx = 1; local.idx <= ArrayLen(local.candidateSiteIds); local.idx++) {
				local.pName = "lpSite" & local.idx;
				ArrayAppend(local.inPlaceholders, ":" & local.pName);
				local.params[local.pName] = { value: local.candidateSiteIds[local.idx], cfsqltype: "cf_sql_nvarchar" };
			}
			local.inClause = ArrayToList(local.inPlaceholders, ", ");

			local.sql = "
				SELECT ContentID, SiteID, PageType, MenuSelected, LayoutType, ParentID,
				       StatusCode, Permalink, Title, Summary, isLocked, ShowInMenu,
				       isPublished, Visibility, Created, CreatedBy, Modified, ModifiedBy
				FROM pages
				WHERE DeletedAt IS NULL AND SiteID IN (" & local.inClause & ")
				ORDER BY Modified DESC, ContentID DESC
			";

			local.q = queryExecute(local.sql, local.params, { datasource: "ChelanCountyWebsite" });
			for (local.row in local.q) {
				local.updatedStr = "";
				if (IsDate(local.row.Modified)) {
					local.updatedStr = DateFormat(local.row.Modified, "mm/dd/yyyy") & " " & TimeFormat(local.row.Modified, "hh:mm:ss");
				} else if (IsDate(local.row.Created)) {
					local.updatedStr = DateFormat(local.row.Created, "mm/dd/yyyy") & " " & TimeFormat(local.row.Created, "hh:mm:ss");
				}
				ArrayAppend(local.pages, {
					id: local.row.ContentID,
					title: local.row.Title ?: "",
					slug: local.row.Permalink ?: "",
					siteId: local.row.SiteID ?: "",
					menuItem: (local.row.ShowInMenu == 1 || local.row.PageType == 1),
					status: local.row.StatusCode ?: "Active",
					visibility: local.row.Visibility ?: "Published",
					parent: local.row.MenuSelected ?: "",
					layout: local.row.LayoutType ?: "Full",
					updated: local.updatedStr,
					author: Len(local.row.ModifiedBy) ? local.row.ModifiedBy : (local.row.CreatedBy ?: "Admin"),
					locked: (local.row.isLocked == 1),
					summary: local.row.Summary ?: ""
				});
			}
		} catch (any e) {
			writeLog(type="error", file="pages", text="loadPagesList failed: #e.message# #e.detail#");
		}
		return local.pages;
	}

}
