component extends="Controller" {

	function config() {
		super.config();
	}

	function index() {
		variables.pageTitle = "Documentation & Help Center";
	}

	function formBuilder() {
		variables.pageTitle = "Form Builder Guide for Beginners";
	}

	function editor() {
		variables.pageTitle = "Rich Text Editor (JBDEditor) Guide & Demo";
	}

}
