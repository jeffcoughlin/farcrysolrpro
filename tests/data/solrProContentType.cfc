<cfcomponent extends = "farcry.plugins.farcrysolrpro.packages.types.solrProContentType">
	
	<!--- disable the cached queries during testing --->
	<cffunction name="getByContentType" access="public" output="false" returntype="struct">
		<cfargument name="contentType" type="string" required="true" />
		<cfset var q = "" />
		<cfquery name="q" datasource="#application.dsn#">
			select objectid from #application.dbowner#solrProContentType where lower(contenttype) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.contentType)#" /> 
		</cfquery>
		<cfif q.recordCount>
			<cfreturn getData(q.objectid[1]) />
		<cfelse>
			<cfreturn {} />
		</cfif>
	</cffunction>
	
</cfcomponent>