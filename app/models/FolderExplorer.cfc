component extends="Model" {

	function config() {
		table("page_FolderExplorer");
		setPrimaryKey("ID");

		validatesPresenceOf(properties="ContentID,Title");
	}

}
