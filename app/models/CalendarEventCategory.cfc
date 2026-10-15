component extends="Model" {

	function config() {
		table("calendar_event_categories");
		hasMany(name="events", modelName="CalendarEvent", foreignKey="category_id");
		validatesPresenceOf(properties="name,slug");
	}

}

