component extends="Model" {

	function config() {
		table("pages");
		setPrimaryKey("ContentID");

		hasMany(name="subpages", modelName="SubPage", foreignKey="ContentID");
		hasMany(name="folderExplorers", modelName="FolderExplorer", foreignKey="ContentID");

		validatesPresenceOf(properties="Title,Permalink");
		validatesUniquenessOf(properties="Permalink", scope="SiteID");
	}

}

