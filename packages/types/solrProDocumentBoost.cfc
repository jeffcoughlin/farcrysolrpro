<cfcomponent output="false" extends="farcry.core.packages.types.types" displayname="Solr Pro Document Boost" hint="Manages document boosting for the Solr Pro Plugin" bFriendly="false" bObjectBroker="false">
	
	<cfproperty ftSeq="110" ftFieldset="Document Boosting" ftLabel="Document" ftType="uuid" type="uuid" name="documentId" ftJoinMethod="getContentTypes" ftAllowCreate="false" ftAllowEdit="false" ftHint="Choose a document from your indexed content types." />
	<cfproperty ftSeq="120" ftFieldset="Document Boosting" ftLabel="Boost Value" ftType="list" type="string" name="boostValue" ftListData="getBoostOptions" ftListDataTypename="solrProDocumentBoost" ftHint="Choose a boost value.<br />  These are configurable in the Solr configuration." hint="Stored as string because the FarCry compare fails when there are decimals." />
	
	<cffunction name="ftValidateDocumentId" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset var oField = createObject("component", "farcry.core.packages.formtools.field") />
		<cfset var qDupeCheck = "" />		
		
		<!--- assume it passes --->
		<cfset stResult = oField.passed(value=arguments.stFieldPost.Value) />
			
		<cfif NOT len(stFieldPost.Value)>
			<cfset stResult = oField.failed(value=arguments.stFieldPost.value, message="This is a required field.") />
		</cfif>
		
		<!--- check for duplicates --->
		<cfquery name="qDupeCheck" datasource="#application.dsn#">
			select objectid from solrProDocumentBoost where documentId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.stFieldPost.value)#" /> and objectid <> <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />; 
		</cfquery>
		
		<cfif qDupeCheck.recordCount gt 0>
			<cfset stResult = oField.failed(value=arguments.stFieldPost.value, message="That document has already been boosted.  You cannot create duplicate boosts for the same document.") />
		</cfif>

		<cfreturn stResult />
		
	</cffunction>
	
	<cffunction name="getBoostValueForDocument" access="public" output="false" returntype="string">
		<cfargument name="documentId" required="true" type="uuid" />
		
		<cfset var q = "" />
		<cfquery name="q" datasource="#application.dsn#">
			select boostValue from solrProDocumentBoost where documentId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.documentId#" />;
		</cfquery>
		
		<cfif q.recordCount>
			<cfreturn q.boostValue[1] />
		<cfelse>
			<cfreturn "" />
		</cfif>
	</cffunction>
	
	<cffunction name="getContentTypes" access="public" output="false" returntype="string">
		<cfset var oType = application.fapi.getcontenttype("solrProContentType") />
		<cfset var q = oType.getAllContentTypes(bIncludeNonSearchable = true) />
		<cfreturn valueList(q.contentType) />
	</cffunction>
	
	<cffunction name="getBoostOptions" access="public" output="false" returntype="string">
		<cfargument name="objectid" required="true" type="uuid" />
		
		<!--- check config for the list of boost options, also check the current record for the value, and if not in the list from config, add it as an option --->
		<cfset var stDocBoost = getData(arguments.objectid) />
		<cfset var defaultValue = application.fapi.getConfig(key = 'solrserver', name = 'defaultDocBoost', default = 50) />
		<cfset var l = application.fapi.getConfig(key = 'solrserver', name = 'lDocumentBoostValues') /> 
		<cfset var i = "" />
		<cfset var counter = 0 />
		<cfset var finalList = "" />
		
		<cfloop list="#l#" index="i">
			<cfset counter++ />
			<cfset var a = listToArray(i,":") />
			<cfif a[1] eq defaultValue>
				<cfset finalList = listAppend(finalList,a[1] & ":" & a[2] & " &mdash; Default") />
			<cfelse>
				<cfset finalList = listAppend(finalList,i) />
			</cfif>
		</cfloop>
		
		<cfif structKeyExists(stDocBoost, "boostValue") and not listContainsNoCase(finalList, stDocBoost.boostValue)>
			<cfset finalList = listAppend(finalList, stDocBoost.boostValue) />
		</cfif>
		
		<cfreturn finalList />
		
	</cffunction>
	
	<cffunction name="AfterSave" access="public" output="false" returntype="struct" hint="Called from setData and createData and run after the object has been saved.">
		<cfargument name="stProperties" required="yes" type="struct" hint="A structure containing the contents of the properties that were saved to the object.">
		
		<!--- index the record being boosted --->
		<cfset var oContentType = application.fapi.getContentType("solrProContentType") />
		<cfset oContentType.addRecordToIndex(objectid = stProperties.documentId) />
		
		<cfreturn super.afterSave(argumentCollection = arguments) />
	</cffunction>
	
	<cffunction name="onDelete" returntype="void" access="public" output="false" hint="Is called after the object has been removed from the database">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />
		
		<!--- re-index the record since it is no longer being boosted --->
		<cfset var oContentType = application.fapi.getContentType("solrProContentType") />
		<cfset oContentType.addRecordToIndex(objectid = stObject.documentId) />
		
		<cfset super.onDelete(argumentCollection = arguments) />
		
	</cffunction>
	
</cfcomponent>