component extends="Controller" {

	function config() {
		super.config();
	}

	function index() {
		redirectTo(action="startup");
	}

	function startup() {
		pageTitle = "Startup & Front-End Styles (jbd-templates.css)";
		var cssPath = expandPath("/stylesheets/jbd-templates.css");
		jbdTemplateCssContent = "";
		if (fileExists(cssPath)) {
			jbdTemplateCssContent = fileRead(cssPath);
		}
	}

}

