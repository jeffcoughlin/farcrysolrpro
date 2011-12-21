<cfcomponent output="false">
	
	<cffunction name="getPropertiesByType" access="remote" output="false" returntype="array" returnformat="json">
		<cfargument name="typename" type="string" required="true" />
		<cfcontent type="application/json" reset="true" />
		<cfreturn listToArray(application.fapi.getContentType("solrProContentType").getPropertiesByType(typename = arguments.typename)) />
	</cffunction>
	
	<cffunction name="getTextPropertiesByType" access="remote" output="false" returntype="array" returnformat="json">
		<cfargument name="typename" type="string" required="true" />
		<cfcontent type="application/json" reset="true" />
		<cfreturn listToArray(application.fapi.getContentType("solrProContentType").getTextPropertiesByType(typename = arguments.typename)) />
	</cffunction>
	
	<cffunction name="getSolrFieldTypes" access="remote" output="false" returntype="array" returnformat="json">
		<cfcontent type="application/json" reset="true" />
		<cfreturn application.fapi.getContentType("solrProContentType").getSolrFieldTypes() />
	</cffunction>
	
</cfcomponent>