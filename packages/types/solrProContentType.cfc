<cfcomponent output="false" extends="farcry.core.packages.types.types" displayname="Solr Pro Content Type" hint="Manages content type index information" bFriendly="false" bObjectBroker="false">
	
	<cfproperty ftSeq="110" ftFieldset="Solr Content Type" ftLabel="Title" name="title" bLabel="true" ftType="string" type="nstring" required="true" ftValidation="required" ftHint="The name of this content type.  This will appear on the search form and will allow users to search a specific content type." />
	<cfproperty ftSeq="120" ftFieldset="Solr Content Type" ftLabel="Content Type" name="contentType" ftType="list" type="nstring" ftListData="getContentTypes" ftRenderType="dropdown" required="true" ftValidation="required" ftHint="The content type being indexed." />
	
	<cfproperty ftSeq="130" ftFieldset="Solr Content Type" ftLabel="Result Title" name="resultTitleField" ftType="list" type="nstring" required="true" ftValidation="required" ftHint="The field that will be used for the search result title." />
	<cfproperty ftSeq="140" ftFieldset="Solr Content Type" ftLabel="Result Summary" name="resultSummaryField" ftType="list" type="nstring" required="true" ftValidation="required" ftHint="The field that will be used for the search result summary." />
	
	<cfproperty ftSeq="150" ftFieldset="Solr Content Type" ftLabel="Enable Search?" name="bEnableSearch" ftType="boolean" type="boolean" required="true" default="1" ftDefault="1" ftHint="Should this content type be included in the global, site-wide search?" />
	<cfproperty ftSeq="160" ftFieldset="Solr Content Type" ftLabel="Built to Date" name="builtToDate" ftType="datetime" type="date" required="false" ftHint="The date of the last indexed item.  Used for batching when indexing items." />
	
	<cfproperty ftSeq="170" ftFieldset="Solr Content Type" ftLabel="Indexed Properties" name="aIndexedProperties" ftType="array" type="array" ftJoin="solrProIndexedProperty" ftHint="The properties for this content type that will be indexed." />
	
	<cfproperty ftSeq="180" ftFieldset="Solr Content Type" ftLabel="Index Rule Data?" name="bIndexRuleData" ftType="boolean" type="boolean" default="0" ftDefault="0" ftHint="You can choose to disable this feature and still preserve your settings below." />
	<cfproperty ftSeq="185" ftFieldset="Solr Content Type" ftLabel="Indexed Rules" name="lIndexedRules" ftType="longchar" type="longchar" default="" hint="Using longchar in case there are many rules in the list and FarCry 6.0.x does not support precision." />
	
	<cfproperty ftSeq="190" ftFieldset="Solr Content Type" ftLabel="Core Property Boost Values" name="lCorePropertyBoost" ftType="longchar" type="longchar" default="" hint="A list of boost values in field:boostvalue format.  Ex: label:5,datetimecreated:10 would indicate a boost value of 5 for label and 10 for datetimecreated." />
	
	<cfproperty ftSeq="210" ftFieldset="Solr Content Type" ftLabel="Index on Save?" name="bIndexOnSave" ftType="boolean" type="boolean" ftHint="Should this content type be indexed whenever a record is saved? If not, the content type will only be indexed by a separate scheduled task." />
	
	<cfproperty ftSeq="310" ftFieldset="Solr Content Type Stats" ftLabel="Current Index Count" name="indexRecordCount" ftType="integer" type="integer" ftDefault="0" default="0" ftDisplayOnly="true" hint="Solr record count for this type. Updated when content item is indexed" />

	<cffunction name="onDelete" returntype="void" access="public" output="false" hint="Is called after the object has been removed from the database">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />
		
		<cfif structKeyExists(arguments.stObject, "contentType") and len(trim(arguments.stObject.contentType))>
			
			<!--- on delete, remove all indexed records for this typename from solr --->	
			<cfset deleteByQuery(q = "typename:" & arguments.stObject.contentType) />
			<cfset commit() />
			
			<!--- delete any indexed properties for this content type --->
			<cfset var oProperty = application.fapi.getContentType("solrProIndexedProperty") />
			<cfset var id = "" />
			<cfloop array="#stObject.aIndexedProperties#" index="id">
				<cftry>
					<cfset oProperty.delete(id) />
					<cfcatch>
						<!--- do nothing --->
					</cfcatch>
				</cftry>
			</cfloop>
			
		</cfif>
		
		<cfset super.onDelete(argumentCollection = arguments) />
		
	</cffunction>
	
	<cffunction name="getRuleContent" access="public" output="false" returntype="array">
		<cfargument name="objectid" required="true" type="uuid" hint="The objectid of the object to get rule content for" />
		<cfargument name="lRuleTypes" required="true" type="string" hint="A list of rule typenames to check" />
		
		<cfset var a = [] />
		<cfset var qRulesToIndex = "" />
		
		<cfquery name="qRulesToIndex" datasource="#application.dsn#">
			select 
				cxr.data, 
				cxr.typename 
			from 
				container c 
				join container_aRules cxr on c.objectID = cxr.parentid
			where 
				cxr.typename in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.lRuleTypes#" />) 
				and c.label like <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#%" />
		</cfquery>
		
		<cfloop query="qRulesToIndex">
		
			<cfset var qData = "" />
			
			<cfset var rule = getRules(ruleTypename = qRulesToIndex.typename[qRulesToIndex.currentRow]) />
			
			<cfif arrayLen(rule)>
				
				<cfquery name="qData" datasource="#application.dsn#">
					select #rule[1].indexableFields# from #qRulesToIndex.typename[qRulesToIndex.currentRow]# where objectID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qRulesToIndex.data[qRulesToIndex.currentRow]#" />
				</cfquery>
				
				<cfloop query="qData">
					<cfset var col = "" />
					<cfloop list="#qData.columnList#" index="col">
						<cfset arrayAppend(a, qData[col][qData.currentRow]) />
					</cfloop>
				</cfloop>
				
			</cfif>
		
		</cfloop>
		
		<cfreturn a />

	</cffunction>
	
	<cffunction name="hasIndexedProperty" access="public" hint="Checks if a content type is indexing a single property" output="false" returntype="boolean">
		<cfargument name="objectid" type="uuid" required="true" hint="The objectid of the content type" />
		<cfargument name="fieldName" type="string" required="true" />
		<cfset var q = "" />
		<cfquery name="q" datasource="#application.dsn#">
			select p.objectid 
			from solrProIndexedProperty p 
			join solrProContentType_aIndexedProperties cxp on p.objectid = cxp.data 
			where p.fieldName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fieldName#" />
			and cxp.parentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
		</cfquery>
		<cfreturn q.recordCount />
	</cffunction>
	
	<cffunction name="getRules" access="public" hint="Get list of all indexable rules (rules with at least one string field)" output="false" returntype="array">
		
		<cfargument name="ruleTypename" required="false" type="string" />
		
		<cfset var aRules = [] />
		<cfset var q = queryNew("typename,displayname,indexableFields,lowerdisplayname") />
		<cfset var rule = "" />
		<cfset var lIndexedTypes = "nstring,string,longchar,richtext,country,state,hidden,category" />
		
		<cfloop collection="#application.rules#" item="rule">
			<cfif (not structKeyExists(arguments,"ruleTypename")) or (structKeyExists(arguments,"ruleTypename") and arguments.ruleTypename eq rule)>
				<cfif rule neq "container">
					
					<!--- build a list of indexable fields --->
					<cfset var props = application.fapi.getContentTypeMetadata(typename = rule, md = "stProps", default = "") />
					<cfset var prop = "" />
					<cfset var lIndexableFields = "" />
					
					<cfloop collection="#props#" item="prop">
						<cfif (listFindNoCase(lIndexedTypes, props[prop].metadata.type) or listFindNoCase(lIndexedTypes, props[prop].metadata.ftType))>
							<cfset lIndexableFields = listAppend(lIndexableFields, prop) />
						</cfif>
					</cfloop>
				
					<cfset queryAddRow(q) />
					<cfset querySetCell(q, "typename", rule) />
					<cfset querySetCell(q, "displayname", application.stcoapi[rule].displayname & " (" & rule & ")") />
					<cfset querySetCell(q, "indexableFields", lIndexableFields) />
					<cfset querySetCell(q, "lowerdisplayname", lcase(application.stcoapi[rule].displayname)) />
					
				</cfif>
			</cfif>
		</cfloop>
		
		<cfquery dbtype="query" name="q">
		SELECT typename,displayname,indexableFields FROM q ORDER BY lowerdisplayname
		</cfquery>
		
		<cfloop query="q">
			<cfset arrayAppend(aRules, {
				typename = q.typename[q.currentRow],
				displayname = q.displayName[q.currentRow],
				indexableFields = q.indexableFields[q.currentRow]
			}) />
		</cfloop>
		
		<cfreturn aRules />
		
	</cffunction> 
	
	<cffunction name="getContentTypes" access="public" hint="Get list of all searchable content types." output="false" returntype="string">
		<cfset var listdata = "" />
		<cfset var qListData = queryNew("typename,displayname,lowerdisplayname") />
		<cfset var type = "" />
		<cfloop collection="#application.types#" item="type">
			<cfset queryAddRow(qListData) />
			<cfset querySetCell(qListData, "typename", type) />
			<cfset querySetCell(qListData, "displayname", "#application.stcoapi[type].displayname# (#type#)") />
			<cfset querySetCell(qListData, "lowerdisplayname", "#lcase(application.stcoapi[type].displayname)#") />
		</cfloop>
		
		<cfquery dbtype="query" name="qListData">
		SELECT typename,displayname FROM qListData ORDER BY lowerdisplayname
		</cfquery>
		
		<cfloop query="qListData">
			<cfset listdata = listAppend(listdata, "#qlistdata.typename[qlistdata.currentrow]#:#qlistdata.displayname[qlistdata.currentrow]#") />
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
	
	<cffunction name="getFTTypeForProperty" access="public" output="false" returntype="string">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="propertyName" required="true" type="string" />
		<cfset var properties = application.fapi.getContentTypeMetadata(typename = arguments.typename, md = "stProps", default = "") />
		<cfreturn properties[arguments.propertyName].metadata.ftType />
	</cffunction>
	
	<cffunction name="getFarCryDataTypeForProperty" access="public" output="false" returntype="string">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="propertyName" required="true" type="string" />
		<cfset var properties = application.fapi.getContentTypeMetadata(typename = arguments.typename, md = "stProps", default = "") />
		<cfreturn properties[arguments.propertyName].metadata.type />
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
		
		<cfargument name="fcDataType" type="string" required="false" default="" hint="A FarCry data type to use to filter" />
		
		<cfset var a = [] />
		<cfset var schemaXmlFile = application.fapi.getConfig(key = "solrserver", name = "instanceDir") & "/conf/schema.xml" />
		<cfif not fileExists(schemaXmlFile)>
			<!--- TODO: XML file doesn't exist. Need a solution or message to user --->
		</cfif>
		<cfset var fieldTypes = xmlSearch(schemaXmlFile, "//schema/fields/dynamicField | //schema/fields/dynamicfield") />
		<cfset var fieldType = "" />
		
		<cfloop array="#fieldTypes#" index="fieldType">
			<cfparam name="fieldType.xmlAttributes.fcDataTypes" default="" />
			<cfif len(trim(fcDataType)) eq 0 or (listFindNoCase(fieldType.xmlAttributes['fcDataTypes'], arguments.fcDataType))>
				<cfif structKeyExists(fieldType.xmlAttributes,"fcId") and not arrayFindNoCase(a, fieldType.xmlAttributes["fcId"] & ":" & fieldType.xmlAttributes["fcDisplayName"] & ":" & fieldType.xmlAttributes["fcDataTypes"])>
					<cfset arrayAppend(a, fieldType.xmlAttributes["fcId"] & ":" & fieldType.xmlAttributes["fcDisplayName"] & ":" & fieldType.xmlAttributes["fcDataTypes"]) />
				</cfif>
			</cfif>	
		</cfloop>
		
		<cfreturn a />
		
	</cffunction>
	
	<cffunction name="getSolrFields" access="public" output="false" returntype="array" hint="Gets the fields defined in the schema.xml file">
		<cfargument name="lOmitFields" type="string" required="false" default="" hint="A list of fields to omit" />
		<cfset var a = [] />
		<cfset var schemaXmlFile = application.fapi.getConfig(key = "solrserver", name = "instanceDir") & "/conf/schema.xml" />
		<cfset var fields = xmlSearch(schemaXmlFile, "//schema/fields/field") />
		<cfset var field = "" />
		
		<cfloop array="#fields#" index="field">
			<cfif not listFindNoCase(arguments.lOmitFields, field.xmlAttributes["name"])>
				<cfset arrayAppend(a, field.xmlAttributes["name"]) />
			</cfif>
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
	
	<cffunction name="getAllContentTypes" access="public" output="false" returntype="query">
		<cfset var q = "" />
		<cfquery name="q" datasource="#application.dsn#">
			select objectid, contentType from solrProContentType;
		</cfquery>
		<cfreturn q />
	</cffunction>
	
	<cffunction name="commit" access="public" output="false" returntype="void">
		<cfset application.stplugins["farcrysolrpro"].cfsolrlib.commit() />
	</cffunction>
	
	<cffunction name="optimize" access="public" output="false" returntype="void">
		<cfset application.stplugins["farcrysolrpro"].cfsolrlib.optimize() />
	</cffunction>
	
	<cffunction name="add" access="public" output="false" returntype="void">
		<cfargument name="doc" type="array" required="true" hint="An array of field objects, with name, value, and an optional boost attribute. {name:""Some Name"",value:""Some Value""[,boost:5]}" />
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="docBoost" type="numeric" required="false" hint="Value of boost for this document." />
		
		<cfset var prop = "" />
		<cfset var httpresult = "" />
		<cfset var ftType = "" />
		<cfset var filePath = "" />
		<cfset var xml = "" />
		<cfset var tika = application.stPlugins["farcrysolrpro"].tika />
		<cfset var solrUrl = "http://" & application.fapi.getConfig(key = 'solrserver', name = 'host') & ":" & application.fapi.getConfig(key = 'solrserver', name = 'port') & application.fapi.getConfig(key = 'solrserver', name = 'path') & "/update/extract" />
		
		<cfloop array="#doc#" index="prop">
			
			<!--- determine if this property is a "file" or "image" field, if so, send to Tika for extraction --->
			<cfif len(prop.farcryField)>
				
				<cfset ftType = getFTTypeForProperty(arguments.typename,prop.farcryField) />
				
				<cfif listFindNoCase("image,file", ftType)>
					
					<cfif ftType eq "image">
						<!--- due to a bug in farcry, check to see if the image path in the database had the image webroot, if not add that --->
						<cfif application.fapi.getImageWebroot() eq left(prop.value,len(application.fapi.getImageWebroot()))>
							<cfset filePath = prop.value />
						<cfelse>
							<cfset filePath = application.fapi.getImageWebroot() & prop.value />
						</cfif>
					<cfelse>
						<cfset filePath = application.fapi.getFileWebroot() & prop.value />
					</cfif>
					
					<cfset filePath = expandPath(filePath) />
					
					<cfif fileExists(filePath)>

						<!--- TODO: make sure we have a supported file type before passing it to Tika --->
						
						<!--- TODO: determine why Tika is throwing an error for Open XML files --->
						<cfif not listFindNoCase(".docx,.xlsx,.pptx",right(filePath,5))>
							
							<cfset prop.value = tika.parseToString(createObject("java","java.io.File").init(filePath)) />
						
						<cfelse>
							
							<cflog application="true" file="farcrysolrpro" type="warning" text="Skipping DOCX file: #filePath#" />
						
						</cfif>
						
					<cfelse>
						<cfset prop.value = "" />
					</cfif>
					
				</cfif>
				
			</cfif>
			
			<!--- remove farcryField key from all structs in the doc array --->
			<cfset structDelete(prop,"farcryField") />
			
		</cfloop>
		
		<cfset application.stPlugins["farcrysolrpro"].cfsolrlib.add(argumentCollection = arguments) />
		
	</cffunction>
	
	<cffunction name="search" access="public" output="false" returntype="any">
		<cfargument name="q" type="string" required="true" hint="Your query string" />
		<cfargument name="start" type="numeric" required="false" default="0" hint="Offset for results, starting with 0" />
		<cfargument name="rows" type="numeric" required="false" default="20" hint="Number of rows you want returned" />
		<cfargument name="params" type="struct" required="false" default="#structNew()#" hint="A struct of data to add as params. The struct key will be used as the param name, and the value as the param's value. If you need to pass in multiple values, make the value an array of values." />
		<cfreturn application.stPlugins["farcrysolrpro"].cfsolrlib.search(argumentCollection = arguments) />
	</cffunction>
	
	<cffunction name="deleteByQuery" access="public" output="false" returntype="void">
		<cfargument name="q" type="string" required="true" />
		<cfset application.stPlugins["farcrysolrpro"].cfsolrlib.deleteByQuery(q = arguments.q) />
	</cffunction>
	
</cfcomponent>