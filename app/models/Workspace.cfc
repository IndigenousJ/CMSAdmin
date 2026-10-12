component extends="Model" {

	function config() {
		// Table mapping in SQL Server
		table("cms_workspaces");

		// Associations
		hasMany(name="UserWorkspaces", foreignKey="workspace_code");
		hasMany(name="Forms", foreignKey="siteid");
		hasMany(name="NavigationMenus", foreignKey="siteid");

		// Validations
		validatesPresenceOf(property="code,name,type,virtual_directory,folder_path");
		validatesUniquenessOf(property="code,virtual_directory");
		validatesInclusionOf(property="type", list="global,dept,site");
	}

}
