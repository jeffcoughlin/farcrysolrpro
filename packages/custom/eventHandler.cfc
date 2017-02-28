<cfcomponent output="false">

	<cffunction name="getPageIdForContainer" access="private" output="false" returntype="string">
		<cfargument name="containerId" type="uuid" required="true" />
		<cfset var stContainer = application.fapi.getContentType("container").getData(arguments.containerId) />
		<cfset var pageId = left(stContainer.label,35) />
		<cfif isValid("uuid",pageId)>
			<cfreturn pageId />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>

	<cffunction name="isIndexable" access="private" output="false" returntype="boolean">
		<cfargument name="stObject" type="struct" required="false" />
		<cfset var oType = application.fapi.getContentType(arguments.stObject.typename) />
		<cfif structKeyExists(oType,"contentToIndex")>
			<!--- make sure this record is in the indexable records reported by the content type --->
			<cfset var qIndexableRecords = oType.contentToIndex(objectid = arguments.stObject.objectId) />
			<cfif qIndexableRecords.recordCount>
				<cfif listFindNoCase(valueList(qIndexableRecords.objectid),arguments.stObject.objectId)>
					<cfreturn true />
				</cfif>
			</cfif>
		<cfelse>
			<!--- make sure it is "approved" --->
			<cfif (structKeyExists(arguments.stObject,"status") and arguments.stObject.status eq "approved") or (not structKeyExists(arguments.stObject,"status"))>
				<cfreturn true />
			</cfif>
		</cfif>
		<!--- if we get this far, its not indexable --->
		<cfreturn false />
	</cffunction>

	<cffunction name="afterSave" access="public" output="false" returntype="struct">
		<cfargument name="stProperties" type="struct" required="true" />

		<cftry>

			<cfset var oContentType = application.fapi.getContentType("solrProContentType") />
			<cfset var stRecordToIndex = {} />
			<cfset var stContentType = {} />
			
			<cfif !structKeyExists(arguments.stProperties, "typename")>
				<cfset arguments.stProperties.typename = application.fapi.findType(arguments.stProperties.objectid) />
			</cfif>

			<!--- handle rules and types separately --->
			<cfif left(stProperties.typename,4) eq "rule">
				<!--- determine containing page --->
				<cfset var containerId = application.fapi.getContentType(stProperties.typename).getRuleContainerID(objectid = stProperties.objectid) />
				<cfif isValid("uuid",containerId)>
					<cfset var pageId = getPageIdForContainer(containerId) />
					<!--- determine if this page is being indexed --->
					<cfif isValid("uuid",pageId)>
						<cfset var pageType = application.fapi.findType(pageId) />
						<cfset stContentType = oContentType.getByContentType(pageType) />
						<!--- make sure this content type is being indexed, has the index on save flag, and is indexing this rule --->
						<cfif structCount(stContentType) and stContentType.bIndexOnSave is true and listFindNoCase(stContentType.lIndexedRules,stProperties.typename)>
							<!--- get the page --->
							<cfset stRecordToindex = application.fapi.getContentType(pageType).getData(pageId) />
						</cfif>
					</cfif>
				</cfif>
			<cfelseif stProperties.typename eq "container">
				<!--- determine the containing page --->
				<cfset var pageId = getPageIdForContainer(stProperties.objectId) />
				<!--- determine if this page is being indexed --->
				<cfif isValid("uuid",pageId)>
					<cfset var pageType = application.fapi.findType(pageId) />
					<cfset stContentType = oContentType.getByContentType(pageType) />
					<!--- make sure this content type is being indexed, has the index on save flag --->
					<cfif structCount(stContentType) and stContentType.bIndexOnSave is true>
						<!--- get the page --->
						<cfset stRecordToindex = application.fapi.getContentType(pageType).getData(pageId) />
					</cfif>
				</cfif>
			<cfelse>
				<cfset stContentType = oContentType.getByContentType(stProperties.typename) />
				<cfif structCount(stContentType) and stContentType.bIndexOnSave is true>
					<cfset stRecordToindex = application.fapi.getContentObject(objectid = stProperties.objectId) />
				</cfif>
			</cfif>

			<!--- if we have a record to index, check that it is "indexable" and index it --->
			<cfif structCount(stRecordToIndex) and isIndexable(stObject = stRecordToIndex)>
				<cfset oContentType.addRecordToIndex(objectid = stRecordToIndex.objectId, typename = stRecordToIndex.typename, stContentType = stContentType, bCommit = true) />
			<cfelseif structCount(stRecordToIndex)>
				<!--- this record is NOT indexable, delete it from the index --->
				<cfset oContentType.deleteById(id = application.applicationName & "_" & stRecordToIndex.objectid, bCommit = true) />
			</cfif>

			<cfcatch>
				<cflog application="true" file="farcrySolrPro" type="error" text="Index on Save was unable to index objectid: #arguments.stProperties.objectid# (#arguments.stProperties.typename#).  The error was: #cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>

		<cfreturn arguments.stProperties />

	</cffunction>

	<cffunction name="onDelete" access="public" output="false" returntype="void">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />

		<cftry>

			<cfset var oContentType = application.fapi.getContentType("solrProContentType") />
			<cfset var stContentType = oContentType.getByContentType(arguments.typename) />
			<cfif structCount(stContentType) and stContentType.bIndexOnSave is true>
				<cfset oContentType.deleteById(id = application.applicationName & "_" & arguments.stObject.objectid, bCommit = true) />
			</cfif>

			<cfcatch>
				<cflog application="true" file="farcrySolrPro" type="error" text="Index on Delete was unable to remove objectid: #arguments.stObject.objectid# (#arguments.typename#)  The error was: #cfcatch.message# #cfcatch.detail#" />
			</cfcatch>
		</cftry>

	</cffunction>

</cfcomponent>