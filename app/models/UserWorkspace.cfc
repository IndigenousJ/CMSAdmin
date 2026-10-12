component extends="Model" {

	function config() {
		table("cms_user_workspaces");
		belongsTo(name="User", foreignKey="user_id");
	}

}
