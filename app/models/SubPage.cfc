component extends="Model" {

	function config() {
		table("page_SubPage");
		setPrimaryKey("ID");

		validatesPresenceOf(properties="ContentID,Title");
	}

}
