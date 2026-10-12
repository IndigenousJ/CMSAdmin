<cfscript>
// Use this file to set the current environment for your application.
// You can set it to "development", "testing", "maintenance" or "production".
// Don't forget to issue a reload request (e.g. reload=true) after making changes.
// See https://guides.wheels.dev/v4-0-0/core-concepts/environments-and-configuration/ for more info.

// Automatically detect environment based on hostname/domain:
// - Access via localhost, 127.0.0.1, or local IP -> "development"
// - Access via a domain name -> "production" (or value of WHEELS_ENV if set)
if (
	FindNoCase("localhost", cgi.server_name) ||
	FindNoCase("127.0.0.1", cgi.server_name) ||
	FindNoCase("cmsadmin", cgi.server_name) ||
	cgi.server_name == "::1" ||
	(StructKeyExists(url, "dev") && url.dev == "true")
) {
	set(environment="development");
} else {
	set(environment=env("WHEELS_ENV", "production"));
}
</cfscript>
