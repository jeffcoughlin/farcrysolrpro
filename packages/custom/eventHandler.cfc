<cfcomponent output="false">

	<cffunction name="afterSave" access="public" output="false" returntype="struct">
		<cfargument name="stProperties" type="struct" required="true" />

		<cfset var oContentType = application.fapi.getContentType("solrProContentType") />

		<!--- handle rules and types separately --->
		<cfif left(stProperties.typename,4) eq "rule">
			<!--- determine containing page --->
			<cfset var oRule = application.fapi.getContentType(stProperties.typename) />
			<cfset var containerId = oRule.getRuleContainerID(objectid = stProperties.objectid) />
			<cfif isValid("uuid",containerId)>
				<cfset var stContainer = application.fapi.getContentType("container").getData(containerId) />
				<cfset var pageId = left(stContainer.label,35) />
				<!--- determine if this page is being indexed --->
				<cfif isValid("uuid",pageId)>
					<cfset var pageType = application.fapi.findType(pageId) />
					<cfset var stContentType = oContentType.getByContentType(pageType) />
					<!--- make sure this content type is being indexed, has the index on save flag, and is indexing this rule --->
					<cfif structCount(stContentType) and stContentType.bIndexOnSave is true and listFindNoCase(stContentType.lIndexedRules,stProperties.typename)>
						<cfset oContentType.addRecordToIndex(objectid = pageId) />
					</cfif>
				</cfif>
			</cfif>
		<cfelseif stProperties.typename eq "container">
			<!--- determine the containing page --->
			<cfset var stContainer = application.fapi.getContentType("container").getData(stProperties.objectid) />
			<cfset var pageId = left(stContainer.label,35) />
			<!--- determine if this page is being indexed --->
			<cfif isValid("uuid",pageId)>
				<cfset var pageType = application.fapi.findType(pageId) />
				<cfset var stContentType = oContentType.getByContentType(pageType) />
				<!--- make sure this content type is being indexed, has the index on save flag --->
				<cfif structCount(stContentType) and stContentType.bIndexOnSave is true>
					<cfset oContentType.addRecordToIndex(objectid = pageId) />
				</cfif>
			</cfif>
		<cfelse>
			<cfset var stContentType = oContentType.getByContentType(stProperties.typename) />
			<cfif structCount(stContentType) and stContentType.bIndexOnSave is true>
				<cfif (structKeyExists(stProperties,"status") and stProperties.status eq "approved") or (not structKeyExists(stProperties,"status"))>
					<cfset oContentType.addRecordToIndex(objectid = stProperties.objectid) />
				</cfif>
			</cfif>
		</cfif>

		<cfreturn arguments.stProperties />

	</cffunction>

	<cffunction name="onDelete" access="public" output="false" returntype="void">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />
		<cfset var oContentType = application.fapi.getContentType("solrProContentType") />
		<cfset var stContentType = oContentType.getByContentType(arguments.typename) />
		<cfif structCount(stContentType) and stContentType.bIndexOnSave is true>
			<cfset oContentType.deleteById(id = arguments.stObject.objectid, bCommit = true) />
		</cfif>
	</cffunction>

</cfcomponent>