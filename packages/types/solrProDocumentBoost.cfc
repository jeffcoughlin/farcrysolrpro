<cfcomponent output="false" extends="farcry.core.packages.types.types" displayname="Document Boost" hint="Manages document boosting for the Solr Pro Plugin" bFriendly="false" bObjectBroker="false">
	
	<cfproperty ftSeq="110" ftFieldset="Document Boosting" ftLabel="Document" ftType="uuid" type="uuid" name="documentId" ftJoinMethod="getContentTypes" ftAllowCreate="false" ftAllowEdit="false" ftHint="Choose a document from your indexed content types." />
	<cfproperty ftSeq="120" ftFieldset="Document Boosting" ftLabel="Boost Value" ftType="list" type="string" name="boostValue" ftListData="getBoostOptions" ftListDataTypename="solrProDocumentBoost" ftHint="Choose a boost value.<br />  These are configurable in the Solr configuration." hint="Stored as string because the FarCry compare fails when there are decimals." />
	
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
		<cfset var q = oType.getAllContentTypes() />
		<cfreturn valueList(q.contentType) />
	</cffunction>
	
	<cffunction name="getBoostOptions" access="public" output="false" returntype="string">
		<cfargument name="objectid" required="true" type="uuid" />
		
		<!--- TODO: check config for the list of boost options, also check the current record for the value, and if not in the list from config, add it as an option --->
		<cfreturn "10:Low (10),20:Medium,30:High" />
		
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