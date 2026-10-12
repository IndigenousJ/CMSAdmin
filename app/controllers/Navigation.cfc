component extends="Controller" {

	function config() {
		super.config();
		filters(through="requireAdmin");
	}

	private void function requireAdmin() {
		local.role = getCurrentActiveRole();
		if (local.role != "admin") {
			if (isAjaxRequest()) {
				renderJson({ success: false, message: "Access Denied: Navigation management is strictly restricted to System Administrators." }, 403);
			} else {
				flashInsert(error="Access Denied: Navigation menu management is strictly restricted to System Administrators.");
				redirectTo(controller="main", action="index");
			}
		}
	}

	function index() {
		variables.pageTitle = "Navigation Manager";
		local.siteid = activeNavigationSiteId();
		local.workspaceName = local.siteid;
		local.workspaceHomeUrl = "";
		local.workspaces = getMasterWorkspaces();
		local.primarySiteHost = "";
		local.currentWorkspaceType = "";
		local.currentWorkspaceRedirectUrl = "";
		for (local.workspace in local.workspaces) {
			if (CompareNoCase(local.workspace.id, "site-main") == 0) {
				local.primarySiteHost = StructKeyExists(local.workspace, "alias") && Len(Trim(local.workspace.alias))
					? Trim(local.workspace.alias)
					: Trim(local.workspace.name);
			}
			if (CompareNoCase(local.workspace.id, local.siteid) == 0) {
				local.workspaceName = local.workspace.name;
				local.currentWorkspaceType = StructKeyExists(local.workspace, "type") ? local.workspace.type : "";
				local.currentWorkspaceRedirectUrl = StructKeyExists(local.workspace, "redirect_url")
					&& IsSimpleValue(local.workspace.redirect_url)
					? Trim(local.workspace.redirect_url)
					: "";
			}
		}
		if (!REFindNoCase("^https?://", local.currentWorkspaceRedirectUrl) && local.siteid != "global" && Len(local.primarySiteHost)) {
			// No redirect URL set: fall back to the workspace's virtual directory on the primary site.
			local.homeSlug = local.siteid;
			for (local.workspace in local.workspaces) {
				if (CompareNoCase(local.workspace.id, local.siteid) == 0
					&& StructKeyExists(local.workspace, "virtual_directory")
					&& IsSimpleValue(local.workspace.virtual_directory)
					&& Len(Trim(local.workspace.virtual_directory))) {
					local.homeSlug = Trim(local.workspace.virtual_directory);
				}
			}
			local.workspaceHomeUrl = "https://" & local.primarySiteHost & (local.siteid == "site-main" ? "" : "/" & local.homeSlug);
		} else if (REFindNoCase("^https?://", local.currentWorkspaceRedirectUrl)) {
			if (local.siteid == "site-main" && Len(local.primarySiteHost)) {
				local.workspaceHomeUrl = "https://" & local.primarySiteHost;
			} else if (local.currentWorkspaceType == "site") {
				local.workspaceHomeUrl = local.currentWorkspaceRedirectUrl;
			} else if (Len(local.primarySiteHost)) {
				local.workspaceHomeUrl = ReReplaceNoCase(
					local.currentWorkspaceRedirectUrl,
					"^https?://[^/]*",
					"https://" & local.primarySiteHost,
					"one"
				);
			}
		}
		if (!isWorkspaceAccessible(local.siteid, getCurrentActiveRole())) {
			flashInsert(error="You do not have access to manage navigation for this workspace.");
			redirectTo(controller="main", action="index");
			return;
		}

		ensureIconColumn();
		local.menuId = findNavigationMenuId(local.siteid);
		variables.navigationItems = [];
		if (local.menuId > 0) {
			local.rows = navigationQuery("
				SELECT id, parent_item_id, label, destination_type, destination,
				       sort_order, is_active, open_in_new_tab, icon
				FROM navigation_menu_items
				WHERE navigation_menu_id = :menuId AND deletedat IS NULL
				ORDER BY CASE WHEN parent_item_id IS NULL THEN 0 ELSE 1 END,
				         parent_item_id, sort_order, id
			", { menuId: intParam(local.menuId) });

			for (local.row in local.rows) {
				ArrayAppend(variables.navigationItems, {
					id: local.row.id,
					title: local.row.label,
					url: local.row.destination,
					destinationType: local.row.destination_type == "url" ? "custom" : "page",
					parentId: IsNumeric(local.row.parent_item_id) ? Val(local.row.parent_item_id) : "",
					sortOrder: local.row.sort_order,
					active: local.row.is_active ? true : false,
					newWindow: local.row.open_in_new_tab ? true : false,
					icon: IsSimpleValue(local.row.icon) ? local.row.icon : ""
				});
			}
		}

		variables.navigationConfigJson = safeJsonForScript({
			"items": variables.navigationItems,
			"workspaceId": local.siteid,
			"workspaceName": local.workspaceName,
			"homeUrl": local.workspaceHomeUrl,
			"saveUrl": urlFor(controller="navigation", action="saveItem"),
			"deleteUrl": urlFor(controller="navigation", action="deleteItem"),
			"reorderUrl": urlFor(controller="navigation", action="reorder")
		});
	}

	function saveItem() {
		local.body = readJsonBody();
		if (!IsStruct(local.body)) {
			renderJson({ success: false, message: "Invalid request payload." }, 400);
			return;
		}

		local.siteid = activeNavigationSiteId();
		if (!isWorkspaceAccessible(local.siteid, getCurrentActiveRole())) {
			renderJson({ success: false, message: "You do not have access to manage this workspace's navigation." }, 403);
			return;
		}

		local.title = Left(Trim(local.body.title ?: ""), 150);
		local.destinationType = LCase(Trim(local.body.destinationType ?: ""));
		local.destination = Left(Trim(local.body.url ?: ""), 1000);
		if (!Len(local.title) || !Len(local.destination) || !ListFindNoCase("page,custom", local.destinationType)) {
			renderJson({ success: false, message: "A label, valid link type, and destination are required." }, 422);
			return;
		}
		if (
			(local.destinationType == "custom" && !REFindNoCase("^(https?://|/)", local.destination))
			|| (local.destinationType == "page" && Left(local.destination, 1) != "/")
			|| Left(local.destination, 2) == "//"
		) {
			renderJson({ success: false, message: "Destinations must use an HTTP(S) URL or a site-relative path." }, 422);
			return;
		}

		local.itemIdRaw = StructKeyExists(local.body, "id") && IsSimpleValue(local.body.id) ? Trim(local.body.id) : "0";
		local.parentIdRaw = StructKeyExists(local.body, "parentId") && IsSimpleValue(local.body.parentId) ? Trim(local.body.parentId) : "";
		local.sortOrderRaw = StructKeyExists(local.body, "sortOrder") && IsSimpleValue(local.body.sortOrder) ? Trim(local.body.sortOrder) : "0";
		if (!REFind("^[0-9]+$", local.itemIdRaw)) {
			renderJson({ success: false, message: "The menu item ID must be a non-negative integer." }, 422);
			return;
		}
		if (Len(local.parentIdRaw) && !REFind("^[0-9]+$", local.parentIdRaw)) {
			renderJson({ success: false, message: "Choose a valid parent item or select Top level." }, 422);
			return;
		}
		if (!REFind("^[0-9]+$", local.sortOrderRaw)) {
			renderJson({ success: false, message: "The menu item order must be a non-negative integer." }, 422);
			return;
		}
		local.itemId = Val(local.body.id ?: 0);
		local.parentId = Val(local.parentIdRaw);
		local.sortOrder = Int(Val(local.sortOrderRaw));
		local.isActive = StructKeyExists(local.body, "active") && IsBoolean(local.body.active) && local.body.active;
		local.newWindow = StructKeyExists(local.body, "newWindow") && IsBoolean(local.body.newWindow) && local.body.newWindow;
		local.icon = StructKeyExists(local.body, "icon") && IsSimpleValue(local.body.icon) ? LCase(Trim(local.body.icon)) : "";
		if (Len(local.icon) && !REFind("^[a-z0-9-]{1,50}$", local.icon)) {
			renderJson({ success: false, message: "Choose a valid icon." }, 422);
			return;
		}

		ensureIconColumn();
		try {
			transaction {
				local.menuId = findNavigationMenuId(local.siteid);
				if (local.menuId == 0) {
					local.insertedMenu = navigationQuery("
						INSERT INTO navigation_menus (siteid, menu_key, name)
						OUTPUT INSERTED.id
						VALUES (:siteid, :menuKey, :menuName)
					", {
						siteid: stringParam(local.siteid, 100),
						menuKey: stringParam("side", 100),
						menuName: stringParam("Side Navigation", 150)
					});
					local.menuId = local.insertedMenu.id;
				}

				if (local.parentId > 0) {
					if (local.parentId == local.itemId || !navigationItemExists(local.menuId, local.parentId)) {
						transactionRollback();
						renderJson({ success: false, message: "Choose a valid parent item from this menu." }, 422);
						return;
					}
					if (local.itemId > 0 && navigationParentWouldCycle(local.menuId, local.itemId, local.parentId)) {
						transactionRollback();
						renderJson({ success: false, message: "An item cannot be placed beneath one of its own descendants." }, 422);
						return;
					}
				}

				local.parentParam = local.parentId > 0
					? intParam(local.parentId)
					: { value: "", cfsqltype: "cf_sql_integer", null: true };
				local.itemParams = {
					menuId: intParam(local.menuId),
					parentId: local.parentParam,
					label: stringParam(local.title, 150),
					destinationType: stringParam(local.destinationType == "custom" ? "url" : "page", 20),
					destination: stringParam(local.destination, 1000),
					sortOrder: intParam(local.sortOrder),
					isActive: bitParam(local.isActive),
					newWindow: bitParam(local.newWindow),
					icon: Len(local.icon)
						? stringParam(local.icon, 50)
						: { value: "", cfsqltype: "cf_sql_nvarchar", null: true }
				};

				if (local.itemId > 0) {
					local.itemParams.id = intParam(local.itemId);
					local.updated = navigationQuery("
						UPDATE navigation_menu_items
						SET parent_item_id = :parentId,
						    label = :label,
						    destination_type = :destinationType,
						    destination = :destination,
						    sort_order = :sortOrder,
						    is_active = :isActive,
						    open_in_new_tab = :newWindow,
						    icon = :icon,
						    updatedat = SYSUTCDATETIME()
						OUTPUT INSERTED.id
						WHERE id = :id AND navigation_menu_id = :menuId AND deletedat IS NULL
					", local.itemParams);
					if (!local.updated.recordCount) {
						transactionRollback();
						renderJson({ success: false, message: "This menu item could not be found." }, 404);
						return;
					}
					local.itemId = local.updated.id;
				} else {
					local.insertedItem = navigationQuery("
						INSERT INTO navigation_menu_items
							(navigation_menu_id, parent_item_id, label, destination_type, destination, 							sort_order, is_active, open_in_new_tab, icon)
						OUTPUT INSERTED.id
						VALUES
														(:menuId, :parentId, :label, :destinationType, :destination, :sortOrder, :isActive, :newWindow, :icon)
					", local.itemParams);
					local.itemId = local.insertedItem.id;
				}
			}
		} catch (any e) {
			writeLog(type="error", file="navigation", text="Navigation item save failed: #e.message# #e.detail#");
			renderJson({ success: false, message: "Unable to save this navigation item. Please try again." }, 500);
			return;
		}

		renderJson({
			success: true,
			message: "Navigation item saved.",
			item: {
				id: local.itemId,
				title: local.title,
				url: local.destination,
				destinationType: local.destinationType,
				parentId: local.parentId > 0 ? local.parentId : "",
				sortOrder: local.sortOrder,
				active: local.isActive,
				newWindow: local.newWindow,
				icon: local.icon
			}
		});
	}

	function deleteItem() {
		local.body = readJsonBody();
		local.itemId = IsStruct(local.body) ? Val(local.body.id ?: 0) : 0;
		if (local.itemId <= 0) {
			renderJson({ success: false, message: "A valid menu item is required." }, 400);
			return;
		}

		local.siteid = activeNavigationSiteId();
		if (!isWorkspaceAccessible(local.siteid, getCurrentActiveRole())) {
			renderJson({ success: false, message: "You do not have access to manage this workspace's navigation." }, 403);
			return;
		}

		local.menuId = findNavigationMenuId(local.siteid);
		if (local.menuId == 0 || !navigationItemExists(local.menuId, local.itemId)) {
			renderJson({ success: false, message: "This menu item could not be found." }, 404);
			return;
		}

		try {
			navigationQuery("
				WITH descendants AS (
					SELECT id, CAST('/' + CAST(id AS VARCHAR(20)) + '/' AS VARCHAR(MAX)) AS path
					FROM navigation_menu_items
					WHERE id = :itemId AND navigation_menu_id = :menuId AND deletedat IS NULL
					UNION ALL
					SELECT child.id,
					       CAST(parent.path + CAST(child.id AS VARCHAR(20)) + '/' AS VARCHAR(MAX))
					FROM navigation_menu_items child
					INNER JOIN descendants parent ON child.parent_item_id = parent.id
					WHERE child.navigation_menu_id = :menuId
					  AND child.deletedat IS NULL
					  AND CHARINDEX('/' + CAST(child.id AS VARCHAR(20)) + '/', parent.path) = 0
				)
				UPDATE item
				SET is_active = 0, deletedat = SYSUTCDATETIME(), updatedat = SYSUTCDATETIME()
				FROM navigation_menu_items item
				WHERE item.id IN (SELECT id FROM descendants)
				OPTION (MAXRECURSION 32767)
			", { itemId: intParam(local.itemId), menuId: intParam(local.menuId) });
		} catch (any e) {
			writeLog(type="error", file="navigation", text="Navigation item delete failed: #e.message# #e.detail#");
			renderJson({ success: false, message: "Unable to remove this navigation item. Please try again." }, 500);
			return;
		}

		renderJson({ success: true, message: "Menu item and its nested items were removed." });
	}

	function reorder() {
		local.body = readJsonBody();
		if (!IsStruct(local.body) || !StructKeyExists(local.body, "items") || !IsArray(local.body.items)) {
			renderJson({ success: false, message: "Invalid menu order payload." }, 400);
			return;
		}

		local.siteid = activeNavigationSiteId();
		if (!isWorkspaceAccessible(local.siteid, getCurrentActiveRole())) {
			renderJson({ success: false, message: "You do not have access to manage this workspace's navigation." }, 403);
			return;
		}
		local.menuId = findNavigationMenuId(local.siteid);
		if (local.menuId == 0) {
			renderJson({ success: false, message: "This menu could not be found." }, 404);
			return;
		}

		local.menuRows = navigationQuery("
			SELECT id FROM navigation_menu_items
			WHERE navigation_menu_id = :menuId AND deletedat IS NULL
		", { menuId: intParam(local.menuId) });
		local.knownIds = {};
		for (local.row in local.menuRows) local.knownIds[local.row.id] = true;
		if (ArrayLen(local.body.items) != StructCount(local.knownIds)) {
			renderJson({ success: false, message: "The menu changed while you were editing. Reload and try again." }, 409);
			return;
		}

		local.order = [];
		local.parents = {};
		local.seenIds = {};
		for (local.entry in local.body.items) {
			if (!IsStruct(local.entry)) {
				renderJson({ success: false, message: "The menu order contains an invalid item." }, 422);
				return;
			}
			local.idRaw = StructKeyExists(local.entry, "id") && IsSimpleValue(local.entry.id) ? Trim(local.entry.id) : "";
			local.parentIdRaw = StructKeyExists(local.entry, "parentId") && IsSimpleValue(local.entry.parentId)
				? Trim(local.entry.parentId)
				: "";
			local.sortOrderRaw = StructKeyExists(local.entry, "sortOrder") && IsSimpleValue(local.entry.sortOrder)
				? Trim(local.entry.sortOrder)
				: "";
			if (!REFind("^[0-9]+$", local.idRaw)) {
				renderJson({ success: false, message: "The menu order contains an invalid item ID." }, 422);
				return;
			}
			if (Len(local.parentIdRaw) && !REFind("^[0-9]+$", local.parentIdRaw)) {
				renderJson({ success: false, message: "The menu order contains an invalid parent ID." }, 422);
				return;
			}
			if (!REFind("^[0-9]+$", local.sortOrderRaw)) {
				renderJson({ success: false, message: "The menu order contains an invalid sort order." }, 422);
				return;
			}
			local.id = Val(local.idRaw);
			local.parentId = Val(local.parentIdRaw);
			if (!StructKeyExists(local.knownIds, local.id) || StructKeyExists(local.seenIds, local.id)) {
				renderJson({ success: false, message: "The menu order contains an unknown or duplicate item." }, 422);
				return;
			}
			if (local.parentId > 0 && (!StructKeyExists(local.knownIds, local.parentId) || local.parentId == local.id)) {
				renderJson({ success: false, message: "The menu order contains an invalid parent." }, 422);
				return;
			}
			local.seenIds[local.id] = true;
			local.parents[local.id] = local.parentId;
			ArrayAppend(local.order, {
				id: local.id,
				parentId: local.parentId,
				sortOrder: Int(Val(local.sortOrderRaw))
			});
		}

		for (local.entry in local.order) {
			local.walkId = local.entry.parentId;
			local.visited = {};
			while (local.walkId > 0) {
				if (local.walkId == local.entry.id || StructKeyExists(local.visited, local.walkId)) {
					renderJson({ success: false, message: "Menu items cannot be nested beneath themselves." }, 422);
					return;
				}
				local.visited[local.walkId] = true;
				local.walkId = local.parents[local.walkId];
			}
		}

		try {
			transaction {
				for (local.entry in local.order) {
					navigationQuery("
						UPDATE navigation_menu_items
						SET parent_item_id = :parentId, sort_order = :sortOrder, updatedat = SYSUTCDATETIME()
						WHERE id = :id AND navigation_menu_id = :menuId AND deletedat IS NULL
					", {
						parentId: local.entry.parentId > 0
							? intParam(local.entry.parentId)
							: { value: "", cfsqltype: "cf_sql_integer", null: true },
						sortOrder: intParam(local.entry.sortOrder),
						id: intParam(local.entry.id),
						menuId: intParam(local.menuId)
					});
				}
			}
		} catch (any e) {
			writeLog(type="error", file="navigation", text="Navigation order update failed: #e.message# #e.detail#");
			renderJson({ success: false, message: "Unable to save the menu order. Please try again." }, 500);
			return;
		}

		renderJson({ success: true, message: "Menu order saved." });
	}

	private string function activeNavigationSiteId() {
		local.requested = (StructKeyExists(params, "ws") && Len(Trim(params.ws))) ? Trim(params.ws)
			: ((StructKeyExists(cookie, "cmsadmin_workspace") && Len(Trim(cookie.cmsadmin_workspace))) ? Trim(cookie.cmsadmin_workspace) : "global");
		local.workspace = resolveUserActiveWorkspace(
			requestedWs=local.requested,
			role=getCurrentActiveRole()
		);
		return local.workspace.id;
	}

	private numeric function findNavigationMenuId(required string siteid) {
		local.row = navigationQuery("
			SELECT id FROM navigation_menus
			WHERE siteid = :siteid AND menu_key = :menuKey
		", {
			siteid: stringParam(arguments.siteid, 100),
			menuKey: stringParam("side", 100)
		});
		return local.row.recordCount ? Val(local.row.id) : 0;
	}

	private boolean function navigationItemExists(required numeric menuId, required numeric itemId) {
		local.row = navigationQuery("
			SELECT id FROM navigation_menu_items
			WHERE id = :itemId AND navigation_menu_id = :menuId AND deletedat IS NULL
		", { itemId: intParam(arguments.itemId), menuId: intParam(arguments.menuId) });
		return local.row.recordCount > 0;
	}

	private boolean function navigationParentWouldCycle(required numeric menuId, required numeric itemId, required numeric parentId) {
		local.nextId = arguments.parentId;
		local.visited = {};
		while (local.nextId > 0) {
			if (local.nextId == arguments.itemId || StructKeyExists(local.visited, local.nextId)) return true;
			local.visited[local.nextId] = true;
			local.row = navigationQuery("
				SELECT parent_item_id FROM navigation_menu_items
				WHERE id = :itemId AND navigation_menu_id = :menuId AND deletedat IS NULL
			", { itemId: intParam(local.nextId), menuId: intParam(arguments.menuId) });
			if (!local.row.recordCount || !IsNumeric(local.row.parent_item_id)) return false;
			local.nextId = Val(local.row.parent_item_id);
		}
		return false;
	}

	private void function ensureIconColumn() {
		queryExecute("
			IF COL_LENGTH('navigation_menu_items', 'icon') IS NULL
				ALTER TABLE navigation_menu_items ADD icon NVARCHAR(50) NULL
		", {}, { datasource: "ChelanCountyWebsite" });
	}

	private any function navigationQuery(required string sql, struct params = {}) {
		return queryExecute(arguments.sql, arguments.params, { datasource: "ChelanCountyWebsite" });
	}

	private struct function intParam(required numeric value) {
		return { value: arguments.value, cfsqltype: "cf_sql_integer" };
	}

	private struct function stringParam(required string value, numeric maxLength = 0) {
		return {
			value: arguments.value,
			cfsqltype: "cf_sql_nvarchar",
			maxlength: arguments.maxLength > 0 ? arguments.maxLength : Len(arguments.value)
		};
	}

	private struct function bitParam(required boolean value) {
		return { value: arguments.value ? 1 : 0, cfsqltype: "cf_sql_bit" };
	}

	private any function readJsonBody() {
		try {
			local.content = GetHTTPRequestData().content;
			if (IsBinary(local.content)) local.content = CharsetEncode(local.content, "utf-8");
			if (Len(Trim(local.content)) && IsJSON(local.content)) return DeserializeJSON(local.content);
		} catch (any e) {
			writeLog(type="warning", file="navigation", text="Unable to read navigation request body: #e.message#");
			return "";
		}
		return "";
	}

	private void function renderJson(required any data, numeric status = 200) {
		cfheader(name="Content-Type", value="application/json; charset=utf-8");
		renderText(text=SerializeJSON(arguments.data), status=arguments.status);
	}

	private string function safeJsonForScript(required any data) {
		return Replace(Replace(SerializeJSON(arguments.data), "</", "<\/", "all"), Chr(8232), "\u2028", "all");
	}

}
