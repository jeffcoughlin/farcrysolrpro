<cfcomponent output="false">
	
	<cffunction name="getTextPropertiesByType" access="remote" output="false" returntype="array" returnformat="json">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="applicationName" type="string" required="true" />
		<cfapplication name="#arguments.applicationName#" sessionmanagement="true" />
		<cfcontent type="application/json" reset="true" />
		<cfreturn listToArray(application.fapi.getContentType("solrProContentType").getTextPropertiesByType(typename = arguments.typename)) />
	</cffunction>
	
</cfcomponent>