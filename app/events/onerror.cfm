<!--- Place HTML here that should be displayed when an error is encountered while running in "production" mode. --->
<div class="admin-card" style="margin:2rem auto; max-width:800px; padding:2rem; border-left:4px solid var(--admin-danger, #dc2626);">
	<h1 style="color:var(--admin-danger, #dc2626); font-size:1.5rem; margin-top:0;">System Notice</h1>
	<p style="color:var(--admin-text-main, #1e293b); font-size:1rem;">
		An unexpected error occurred while processing this request. The system administrator has been logged regarding this event.
	</p>
	<p style="font-size:0.875rem; color:var(--admin-text-muted, #64748b);">
		Please return to the <a href="/" style="color:var(--admin-primary, #1e3a8a); text-decoration:underline;">Dashboard</a> or try again shortly.
	</p>

	<cfif get("showErrorInformation")>
		<hr style="margin:1.5rem 0; border:0; border-top:1px solid #e2e8f0;">
		<h2 style="font-size:1.1rem; color:#475569;">Diagnostic Information (Development Mode)</h2>
		<cfif structKeyExists(variables, "error")>
			<cfdump var="#error#">
		<cfelseif structKeyExists(request, "wheels") and structKeyExists(request.wheels, "exception")>
			<cfdump var="#request.wheels.exception#">
		</cfif>
	</cfif>
</div>
