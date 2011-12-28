<cfcomponent output="false" extends="farcry.core.packages.types.types" displayname="Document Boost" hint="Manages document boosting for the Solr Pro Plugin" bFriendly="false" bObjectBroker="false">
	
	<cfproperty ftSeq="110" ftFieldset="Document Boosting" ftLabel="Document" ftType="uuid" type="uuid" name="documentId" ftJoinMethod="getContentTypes" ftAllowCreate="false" ftAllowEdit="false" />
	<cfproperty ftSeq="120" ftFieldset="Document Boosting" ftLabel="Boost Value" ftType="list" type="string" name="boostValue" ftListData="getBoostOptions" ftListDataTypename="solrProDocumentBoost" hint="Stored as string because the FarCry compare fails when there are decimals." />
	
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
	
	<!--- TODO: trigger index on save --->
	
</cfcomponent>