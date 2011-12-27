<cfcomponent output="false" extends="farcry.core.packages.types.types" displayname="Solr Pro Indexed Property" hint="Manages indexed properties for a content type" bFriendly="false" bObjectBroker="false">
	
	<cfproperty ftSeq="110" ftFieldset="Indexed Property" name="fieldName" bLabel="true" type="nstring" required="true" ftValidation="required" ftType="string" ftHint="The name of the field being indexed." />
	<cfproperty ftSeq="120" ftFieldset="Indexed Property" name="lFieldTypes" type="longchar" ftType="longchar" required="true" ftHint="A list of field types to use for this field." />
	
	<cffunction name="getByContentTypeAndFieldname" access="public" output="false" returntype="struct">
		<cfargument name="contentTypeId" required="true" type="uuid" hint="The ObjectID of the solrProContentType record" />
		<cfargument name="fieldName" required="true" type="string" />
		
		<cfset var q = "" />
		
		<cfquery name="q" datasource="#application.dsn#">
			select p.objectid from solrProIndexedProperty p join solrProContentType_aIndexedProperties cxp on p.objectid = cxp.data
			where cxp.parentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentTypeId#" />
			and p.fieldName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fieldName#" />
		</cfquery>
		
		<cfif q.recordCount>
			<cfreturn getData(q.objectid[1]) />
		<cfelse>
			<cfreturn {} />
		</cfif>
		
	</cffunction>
	
</cfcomponent>