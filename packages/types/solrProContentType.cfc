<cfcomponent output="false" extends="farcry.core.packages.types.types" displayname="Solr Pro Content Type" hint="Manages content type index information" bFriendly="false" bObjectBroker="false">
	
	<cfproperty ftSeq="110" ftFieldset="Solr Content Type" ftLabel="Title" name="title" bLabel="true" ftType="string" type="nstring" required="true" ftValidation="required" ftHint="The name of this content type.  This will appear on the search form and will allow users to search a specific content type." />
	<cfproperty ftSeq="120" ftFieldset="Solr Content Type" ftLabel="Content Type" name="contentType" ftType="list" type="nstring" ftListData="getContentTypes" ftRenderType="dropdown" required="true" ftValidation="required" ftHint="The content type being indexed." />
	
	<!--- TODO: for resultTitleField and resultSummaryField we need to load the available values based on the value of contentType.  We could use an ftWatch or write custom jQuery on the edit.cfm --->
	<cfproperty ftSeq="130" ftFieldset="Solr Content Type" ftLabel="Result Title" name="resultTitleField" ftType="list" type="nstring" required="true" ftValidation="required" ftHint="The field that will be used for the search result title." />
	<cfproperty ftSeq="140" ftFieldset="Solr Content Type" ftLabel="Result Summary" name="resultSummaryField" ftType="list" type="nstring" required="true" ftValidation="required" ftHint="The field that will be used for the search result summary." />
	
	<cfproperty ftSeq="150" ftFieldset="Solr Content Type" ftLabel="Enable Search?" name="bEnableSearch" ftType="boolean" type="boolean" required="true" default="1" ftDefault="1" ftHint="Should this content type be included in the global, site-wide search?" />
	<cfproperty ftSeq="160" ftFieldset="Solr Content Type" ftLabel="Built to Date" name="builtToDate" ftType="datetime" type="date" required="false" ftHint="The date of the last indexed item.  Used for batching when indexing items." />
	
	<cfproperty ftSeq="170" ftFieldset="Solr Content Type" ftLabel="Indexed Properties" name="aIndexedProperties" ftType="array" type="array" ftJoin="solrProIndexedProperty" ftHint="The properties for this content type that will be indexed." />
	
	<!--- TODO: override delete method to delete child array objects when a parent record is deleted --->
	
	<cffunction name="getContentTypes" access="public" hint="Get list of all searchable content types." output="false" returntype="string">
		<cfset var listdata = "" />
		<cfset var qListData = queryNew("typename,displayname,lowerdisplayname") />
		
		<cfloop collection="#application.types#" item="type">
			<cfset queryAddRow(qListData) />
			<cfset querySetCell(qListData, "typename", type) />
			<cfset querySetCell(qListData, "displayname", "#application.stcoapi[type].displayname# (#type#)") />
			<cfset querySetCell(qListData, "lowerdisplayname", "#lcase(application.stcoapi[type].displayname)#") />
		</cfloop>
		
		<cfquery dbtype="query" name="qListData">
		SELECT typename,displayname FROM qListData
		ORDER BY lowerdisplayname
		</cfquery>
		
		<cfloop query="qListData">
			<cfset listdata = listAppend(listdata, "#qlistdata.typename#:#qlistdata.displayname#") />
		</cfloop>
		
		<cfreturn listData />
	</cffunction>
		
	<cffunction name="getPropertiesByType" access="public" output="false" returntype="string">
		<cfargument name="typename" required="true" type="string" />
		
		<cfset var properties = application.fapi.getContentTypeMetadata(typename = arguments.typename, md = "stProps", default = "") />
		
		<cfif isStruct(properties)>
			<cfreturn listSort(structKeyList(properties),"textnocase") />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getTextPropertiesByType" access="public" output="false" returntype="string">
		<cfargument name="typename" required="true" type="string" />
		
		<cfset var l = "" />
		<cfset var properties = application.fapi.getContentTypeMetadata(typename = arguments.typename, md = "stProps", default = "") />
		<cfset var prop = "" />
		
		<cfif isStruct(properties)>
			<cfloop collection="#properties#" item="prop">
				<cfif listFindNoCase("nstring,string,longchar",properties[prop].metadata.type)>
					<cfset l = listAppend(l, prop) />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn listSort(l,"textnocase") />
		
	</cffunction>
	
	<cffunction name="getSolrFieldTypes" access="public" output="false" returntype="array" hint="Parses the field types from the schema.xml file">
		
		<cfset var a = [] />
		<cfset var schemaXmlFile = application.fapi.getConfig(key = "solrserver", name = "instanceDir") & "/conf/schema.xml" />
		<cfset var fieldTypes = xmlSearch(schemaXmlFile, "//schema/types/fieldType | //schema/types/fieldtype") />
		<cfset var fieldType = "" />
		
		<cfloop array="#fieldTypes#" index="fieldType">
			<cfset arrayAppend(a,fieldType.xmlAttributes["name"]) />
		</cfloop>
		
		<cfreturn a />
		
	</cffunction>
	
	<cffunction name="getSolrFields" access="public" output="false" returntype="array" hint="Gets the fields defined in the schema.xml file">
		
		<cfset var a = [] />
		<cfset var schemaXmlFile = application.fapi.getConfig(key = "solrserver", name = "instanceDir") & "/conf/schema.xml" />
		<cfset var fields = xmlSearch(schemaXmlFile, "//schema/fields/field") />
		<cfset var field = "" />
		
		<cfloop array="#fields#" index="field">
			<cfset arrayAppend(a, field.xmlAttributes["name"]) />
		</cfloop>
		
		<cfreturn a />
		
	</cffunction>
	
	<cffunction name="getSolrFieldTypeForProperty" access="public" output="false" returntype="string" hint="Returns the field type specified for a given field as declared in the schema.xml file.">
		<cfargument name="fieldName" type="string" required="true" />
		
		<cfset var schemaXmlFile = application.fapi.getConfig(key = "solrserver", name = "instanceDir") & "/conf/schema.xml" />
		<cfset var field = xmlSearch(schemaXmlFile, "//schema/fields/field[@name='#lcase(arguments.fieldName)#']") />
		
		<cfif arrayLen(field)>
			<cfreturn field[1].xmlAttributes["type"] />
		<cfelse>
			<cfreturn "" />
		</cfif>
		
	</cffunction>
	
</cfcomponent>