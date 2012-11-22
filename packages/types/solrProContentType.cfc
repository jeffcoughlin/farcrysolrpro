<cfcomponent output="false" extends="farcry.core.packages.types.types" displayname="Solr Pro Content Type" hint="Manages content type index information" bFriendly="false" bObjectBroker="true">
	
	<cfproperty ftSeq="110" ftFieldset="Solr Content Type" ftLabel="Title" name="title" bLabel="true" ftType="string" type="nstring" required="true" ftValidation="required" ftHint="The name of this content type.  This will appear on the search form and will allow users to search a specific content type." />
	<cfproperty ftSeq="120" ftFieldset="Solr Content Type" ftLabel="Content Type" name="contentType" ftType="list" type="nstring" ftListData="getContentTypes" ftRenderType="dropdown" required="true" ftValidation="required" ftHint="The content type being indexed." />
	
	<cfproperty ftSeq="130" ftFieldset="Solr Content Type" ftLabel="Result Title" name="resultTitleField" ftType="list" type="nstring" required="true" default="label" ftDefault="label" ftValidation="required" ftHint="The field that will be used for the search result title." />
	<cfproperty ftSeq="140" ftFieldset="Solr Content Type" ftLabel="Result Summary" name="resultSummaryField" ftType="list" type="nstring" required="false" default="" ftDefault="" ftHint="The field that will be used for the search result summary." />
	<cfproperty ftSeq="142" ftFieldset="Solr Content Type" ftLabel="Summary Fields" name="lSummaryFields" ftType="list" ftAllowMultiple="true" type="longchar" required="false" default="" ftHint="The fields to use to build the summary" />
	<cfproperty ftSeq="150" ftFieldset="Solr Content Type" ftLabel="Result Image" name="resultImageField" ftType="list" type="nstring" required="false" default="" ftDefault="" ftHint="The field that will be used for the search result teaser image." />
	<cfproperty ftSeq="160" ftFieldset="Solr Content Type" ftLabel="Document Size Fields" name="lDocumentSizeFields" ftType="list" ftAllowMultiple="true" type="longchar" required="false" default="" ftHint="The fields to use to calculate the document size" />
	
	<cfproperty ftSeq="150" ftFieldset="Solr Content Type" ftLabel="Enable Site Search?" name="bEnableSearch" ftType="boolean" type="boolean" required="true" default="1" ftDefault="1" ftHint="Should this content type be included in the global, site-wide search?" />
	<cfproperty ftSeq="160" ftFieldset="Solr Content Type" ftLabel="Built to Date" name="builtToDate" ftType="datetime" type="date" required="false" ftHint="For system use.  Updated by the system.  Used as a reference date of the last indexed item.  Used for batching when indexing items.  Default is blank (no date)." />
	<cfproperty ftSeq="165" ftFieldset="Solr Content Type" ftLabel="Default Document Boost" name="defaultDocBoost" ftType="list" ftListData="getBoostOptions" ftListDataTypename="solrProDocumentBoost" type="numeric" required="true" ftHint="The default document boost for all documents of this content type.  Use this to boost (or lower) all documents of a specific type." />
	
	<cfproperty ftSeq="170" ftFieldset="Solr Content Type" ftLabel="Indexed Properties" name="aIndexedProperties" ftType="array" type="array" ftJoin="solrProIndexedProperty" ftHint="The properties for this content type that will be indexed." />
	
	<cfproperty ftSeq="180" ftFieldset="Solr Content Type" ftLabel="Index Rule Data?" name="bIndexRuleData" ftType="boolean" type="boolean" default="0" ftDefault="0" ftHint="You can choose to disable this feature and still preserve your settings below." />
	<cfproperty ftSeq="185" ftFieldset="Solr Content Type" ftLabel="Indexed Rules" name="lIndexedRules" ftType="longchar" type="longchar" default="" hint="Using longchar in case there are many rules in the list and FarCry 6.0.x does not support precision." />
	
	<cfproperty ftSeq="190" ftFieldset="Solr Content Type" ftLabel="Core Property Boost Values" name="lCorePropertyBoost" ftType="longchar" type="longchar" default="" hint="A list of boost values in field:boostvalue format.  Ex: label:5,datetimecreated:10 would indicate a boost value of 5 for label and 10 for datetimecreated." />
	
	<cfproperty ftSeq="210" ftFieldset="Solr Content Type" ftLabel="Index on Save?" name="bIndexOnSave" ftType="boolean" type="boolean" default="1" ftDefault="1" ftHint="Should this content type be indexed whenever a record is saved? If not, the content type will only be indexed by a separate scheduled task." />
	
	<cffunction name="AfterSave" access="public" output="false" returntype="struct" hint="Called from setData and createData and run after the object has been saved.">
		<cfargument name="stProperties" required="yes" type="struct" hint="A structure containing the contents of the properties that were saved to the object.">
		
		<cfparam name="application.stPlugins.farcrysolrpro.corePropertyBoosts" type="struct" default="#structNew()#" />
		<cfset structDelete(application.stPlugins.farcrysolrpro.corePropertyBoosts,stProperties.objectid) />
		
		<!--- reset the cache for the field list for this type (both phonetic and non-phonetic) --->
		<cfset setFieldListCacheForType(typename = stProperties.contentType, bIncludePhonetic = true) />
		<cfset setFieldListCacheForType(typename = stProperties.contentType, bIncludePhonetic = false) />
		
		<cfreturn super.aftersave(argumentCollection = arguments) />
		
	</cffunction>
	
	<cffunction name="onDelete" returntype="void" access="public" output="false" hint="Is called after the object has been removed from the database">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />
		
		<cfif structKeyExists(arguments.stObject, "contentType") and len(trim(arguments.stObject.contentType))>
			
			<!--- on delete, remove all indexed records for this typename from solr --->	
			<cfset deleteByTypename(typename = arguments.stObject.contentType, sitename = application.applicationName, bCommit = true) />
			
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
	
	<cffunction name="ftValidateContentType" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
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
			select objectid from solrProContentType where lower(contentType) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(lcase(arguments.stFieldPost.value))#" /> and objectid <> <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />; 
		</cfquery>
		
		<cfif qDupeCheck.recordCount gt 0>
			<cfset stResult = oField.failed(value=arguments.stFieldPost.value, message="There is already a configuration created for this content type.") />
		</cfif>

		<cfreturn stResult />
		
	</cffunction>
	
	<cffunction name="indexRecords" returntype="struct" access="public" output="false" hint="Indexes records for all or selected content types.">
		<cfargument name="bOptimize" type="boolean" required="false" default="true" />
		<cfargument name="batchSize" type="numeric" required="false" default="#application.fapi.getConfig(key = 'solrserver', name = 'batchSize', default = 1000)#" />
		<cfargument name="lContentTypeIds" type="string" required="false" default="" hint="A list of SolrProContentType ObjectIDs.  If empty string, all preconfigured content types will be indexed." />
		
		<!--- Start timer --->
		<cfset var tickBegin = GetTickCount() />
		
		<!--- instantiate the content types we will need --->
		<cfset var oIndexedProperty = application.fapi.getContentType("solrProIndexedProperty") />
		<cfset var oDocumentBoost = application.fapi.getContentType("solrProDocumentBoost") />
		
		<!--- get all the content types that are being indexed --->
		<cfset var qContentTypes = getAllContentTypes(bIncludeNonSearchable = true) />

		<!--- delete any records that have a typename value that is not in the list of indexed typenames --->
		<cfset var lValidTypenames = valueList(qContentTypes.contentType) />
		<cfset var deleteQueryString = "q={!lucene q.op=AND} fcsp_sitename:" & application.applicationName />
		<cfset var t = "" />
		<cfloop list="#lValidTypenames#" index="t">
			<cfset deleteQueryString = deleteQueryString & " -typename:" & t />
		</cfloop>
		<cfset deleteByQuery(q = deleteQueryString) />
		<cfset commit() />
		
		<!--- only index the specified content types --->
		<cfif listLen(arguments.lContentTypeIds)>
			<cfquery name="qContentTypes" dbtype="query">
				select objectid, contentType from qContentTypes where objectid in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.lContentTypeIds#" /> )
			</cfquery>
		</cfif>

		<cfset var aStats = [] />
		<cfloop query="qContentTypes">
			
			<cfset var typeTickBegin = getTickCount() />
			
			<!--- load this content type's index settings --->
			<cfset var stContentType = getData(objectid = qContentTypes.objectid[qContentTypes.currentRow]) />
			
			<!--- get the records to index --->
			<cfset var stResult = getRecordsToIndex(typename = stContentType.contentType, batchSize = arguments.batchSize, builtToDate = stContentType.builtToDate) />
			<cfset var qContentToIndex = stResult.qContentToIndex />
			<cfset var lItemsInDb = stResult.lItemsInDb />
			
			<!--- load all records for this type from solr for comparison later --->
			<cfset var existingRecords = search(q = "typename:" & stContentType.contentType & " AND fcsp_sitename:" & application.applicationName, rows = 999999) />
			<cfset var lExistingRecords = "" />
			<cfset var r = "" />
			<cfloop array="#existingRecords.results#" index="r">
				<cfif isArray(r["objectid"])>
					<cfset lExistingRecords = listAppend(lExistingRecords, r["objectid"][1]) />
				<cfelse>	
					<cfset lExistingRecords = listAppend(lExistingRecords, r["objectid"]) />
				</cfif>
			</cfloop>
			
			<cfloop query="qContentToIndex">
				
				<!--- add each record to the index --->
				<cfset addRecordToIndex(
					objectid = qContentToIndex.objectid[qContentToIndex.currentRow],
					typename = stContentType.contentType,
					stContentType = stContentType,
					oIndexedProperty = oIndexedProperty,
					oDocumentBoost = oDocumentBoost,
					bCommit = false
				) />
				
			</cfloop>
			
			<!--- delete any records in the index that are no longer in the database. (use a solr "delete by query" to delete all items for this content type that are not in the qContentToIndex results) --->
			<cfset var lItemsToDelete = listCompare(lExistingRecords, lItemsInDB) />
			<cfif listLen(lItemsToDelete)>
				<cfset deleteByTypename(typename = stContentType.contentType, sitename = application.applicationName, lObjectIds = lItemsToDelete, bCommit = false) />
			</cfif>
			
			<!--- update metadata for this content type --->
			<cfif qContentToIndex.recordCount gt 0>
				<cfset stContentType.builtToDate = qContentToIndex.datetimelastupdated[qContentToIndex.recordCount] />
				<cfset setData(stProperties = stContentType) />
			</cfif>
			
			<cfset var typeTickEnd = getTickCount() />
			
			<!--- If there were no errors, update stats --->	
			<cfset var stStats = {} />
			<cfset stStats["typeName"] = qContentTypes.contentType[qContentTypes.currentRow] />
			<cfset stStats["processtime"] = typeTickEnd - typeTickBegin />
			<cfset stStats["indexRecordCount"] =  qContentToIndex.recordCount />
			<cfset stStats["totalRecordCount"] = listLen(lExistingRecords) + qContentToIndex.recordCount - listLen(lItemsToDelete) />
			<cfset stStats["builtToDate"] = stContentType.builtToDate />
			<cfset arrayAppend(aStats, stStats) />
			
		</cfloop>
		
		<!--- commit --->
		<cfset commit() />
		
		<!--- optionally, optimize --->
		<cfif arguments.bOptimize>
			<cfset optimize() />
		</cfif>
		
		<cfset var processTime = GetTickCount() - tickBegin />
		
		<cfreturn {
			aStats = aStats,
			processTime = processTime
		} />
		
	</cffunction>
	
	<cffunction name="clearAllFieldListCaches" returntype="void" access="public" output="false">
		<cfset application.stPlugins["farcrysolrpro"].fieldLists = {} />
	</cffunction>
	
	<cffunction name="setFieldListCacheForType" returntype="void" access="public" output="false">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="bIncludePhonetic" type="boolean" required="false" default="true" />
		<cfargument name="fieldList" type="string" required="false" default="#getFieldListForType(typename = arguments.typename, bIncludePhonetic = arguments.bIncludePhonetic)#" />
		<cfparam name="application.stPlugins['farcrysolrpro'].fieldLists" default="#structNew()#" />
		<cfset application.stPlugins["farcrysolrpro"].fieldLists[arguments.typename & "-" & arguments.bIncludePhonetic] = arguments.fieldList />
	</cffunction>
	
	<cffunction name="getFieldListCacheForType" returntype="string" access="public" output="false">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="bIncludePhonetic" type="boolean" required="false" default="true" />
		<cfargument name="bFlushCache" type="boolean" required="false" default="false" />
		
		<!--- try to load the cached value --->
		<cfparam name="application.stPlugins['farcrysolrpro'].fieldLists" default="#structNew()#" />
		<cfif structKeyExists(application.stPlugins["farcrysolrpro"].fieldLists, arguments.typename & "-" & arguments.bIncludePhonetic)>
			<cfset var cachedValue = application.stPlugins["farcrysolrpro"].fieldLists[arguments.typename & "-" & arguments.bIncludePhonetic] />
		<cfelse>
			<cfset var cachedValue = "" />	
		</cfif>
		
		<cfif len(trim(cachedValue)) eq 0 or arguments.bFlushCache eq true>
			
			<!--- no cached version, generate the field list --->
			<cfset var fieldList = getFieldListForType(arguments.typename,arguments.bIncludePhonetic) />
			
			<!--- cache it for later use --->
			<cfset setFieldListCacheForType(typename = arguments.typename,bIncludePhonetic = arguments.bIncludePhonetic,fieldList = fieldList) />
			
			<!--- return the field list --->
			<cfreturn fieldList />
			
		<cfelse>
			
			<!--- we have a cached version, just return that --->
			<cfreturn cachedValue />
			
		</cfif>
		
	</cffunction>
	
	<cffunction name="getFieldListForTypes" returntype="string" access="public" output="false" hint="Returns a list of fields (space delimited) for a all specified indexed content types.  Used for the qf (query fields) Solr parameter">
		<cfargument name="lContentTypes" type="string" default="" />
		<cfargument name="bIncludePhonetic" type="boolean" required="false" default="true" />
		<cfargument name="bUseCache" type="boolean" required="false" default="true" />
		<cfargument name="bFlushCache" type="boolean" required="false" default="false" />
		<cfset var q = getAllContentTypes(lContentTypes) />
		<cfset var qf = "" />
		
		<!--- for each indexed content type, get the field list --->
		<cfloop query="q">
			<cfif arguments.bUseCache>
				<cfset qf = qf & " " & getFieldListCacheForType(typename = q.contentType,bIncludePhonetic = arguments.bIncludePhonetic, bFlushCache = arguments.bFlushCache) />
			<cfelse>
				<cfset qf = qf & " " & getFieldListForType(typename = q.contentType,bIncludePhonetic = arguments.bIncludePhonetic) />
			</cfif>		
		</cfloop> 
		
		<!--- dedupe list --->
		<cfset var st = {} />
		<cfset var i = "" />
		<cfloop list="#qf#" index="i" delimiters=" ">
			<cfset st[i] = "" />
		</cfloop>
		<cfset qf = structKeyList(st," ") />
		
		<cfreturn trim(qf) />
		
	</cffunction>
	
	<cffunction name="getFieldListForType" returntype="string" access="public" output="false" hint="Returns a list of fields (space delimited) for a given content type.  Used for the qf (query fields) Solr parameter">
		<cfargument name="typename" required="true" />
		<cfargument name="bIncludePhonetic" type="boolean" required="false" default="true" />
		<cfargument name="qf" type="array" required="false" default="#['fcsp_rulecontent','fcsp_rulecontent_phonetic','objectid']#" hint="The starting list for the query fields" />
		<cfset var st = getByContentType(arguments.typename) />
		<cfset var oIndexedProperty = application.fapi.getContentType("solrProIndexedProperty") />
		<cfset var prop = "" />
		<cfset var propId = "" />
		<cfset var ft = "" />
		<cfset var fieldType = [] />
		
		<cfloop array="#st.aIndexedProperties#" index="propId">
			<cfset prop = oIndexedProperty.getData(propId) />
			<cfloop list="#prop.lFieldTypes#" index="ft">
				<!--- for each field type for this farcry field, build the solr dynamic field name --->
				<cfset fieldType = listToArray(ft,":") />
				<cfif fieldType[2] eq 0>
					<cfset fieldType[2] = "notstored" />
				<cfelse>
					<cfset fieldType[2] = "stored" />
				</cfif>
				<cfif arguments.bIncludePhonetic or (fieldType[1] neq 'phonetic' and arguments.bIncludePhonetic eq false)>
					<cfset arrayAppend(arguments.qf, lcase(prop.fieldName) & "_" & fieldType[1] & "_" & fieldType[2]) />
					<cfif getFTTypeForProperty(typename = arguments.typename, propertyName = prop.fieldName) eq "file">
						<cfset arrayAppend(arguments.qf, lcase(prop.fieldName) & "_contents_" & fieldType[1] & "_" & fieldType[2]) />
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		<cfreturn arrayToList(arguments.qf, " ") />
	</cffunction>
	
	<cffunction name="getCorePropertyBoosts" returntype="struct" access="public" output="false" hint="Returns a struct of core property boost values for a given content type">
		<cfargument name="stContentType" required="true" type="struct" />
		<cfparam name="application.stPlugins.farcrysolrpro.corePropertyBoosts" default="#structNew()#" />
		<cfif structKeyExists(application.stPlugins.farcrysolrpro.corePropertyBoosts,arguments.stContentType.objectid)>
			<cfreturn application.stPlugins.farcrysolrpro.corePropertyBoosts[stContentType.objectid] />
		</cfif>
		<cfset var aCorePropBoosts = listToArray(stContentType.lCorePropertyBoost) />
		<cfset var stPropBoosts = {} />
		<cfset var i = "" />
		<cfloop array="#aCorePropBoosts#" index="i">
			<cfset stPropBoosts[listFirst(i,":")] = listLast(i,":") /> 
		</cfloop>
		<cfset application.stPlugins.farcrysolrpro.corePropertyBoosts[stContentType.objectid] = stPropBoosts />
		<cfreturn stPropBoosts />
	</cffunction>
	
	<cffunction name="getRecordCountForType" returntype="numeric" access="public" output="false">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="sitename" required="false" type="string" default="#application.applicationName#" />
		<cfreturn arrayLen(search(q = "typename:" & arguments.typename & " AND fcsp_sitename:" & arguments.sitename, params = { "fl" = "fcsp_id" }, rows = 9999999).results) />
	</cffunction>
	
	<cffunction name="addRecordToIndex" returntype="void" access="public" output="false">
		<cfargument name="objectid" required="true" type="uuid" hint="The objectID of the record to be indexed." />
		<cfargument name="typename" required="false" type="string" default="#application.fapi.findType(arguments.objectid)#" hint="The FarCry typename of the record being indexed.  If not provided, it will be loaded from the FarCry database.  This should be provided for performance reasons." />
		<cfargument name="stContentType" required="false" type="struct" default="#structNew()#" hint="The SolrProContentType object that defines how to index this record.  If not provided, it will be loaded based on the type of the record being indexed." />
		<cfargument name="oIndexedProperty" required="false" type="any" default="#application.fapi.getContentType('solrProIndexedProperty')#" hint="An instance of the solrProIndexedProperty content type CFC.  If not provided, an instance will be created.  If you are looping and calling this method multiple times, it will be much more performant if you create an instance of this CFC once and provide it here." />
		<cfargument name="oDocumentBoost" required="false" type="any" default="#application.fapi.getContentType('solrProDocumentBoost')#" hint="An instance of the solrProDocumentBoost content type CFC.  If not provided, an instance will be created.  If you are looping and calling this method multiple times, it will be much more performant if you create an instance of this CFC once and provide it here." />
		<cfargument name="bCommit" required="false" type="boolean" default="true" hint="Should Solr's commit method be called after adding this record?  Do not specify true here if adding multiple records. Commit after all records have been added." />
		
		<!--- if the content type record was not provided, look it up --->
		<cfif not structCount(arguments.stContentType)>
			<cfset arguments.stContentType = getByContentType(arguments.typename) />
			<!--- if we got an empty struct back then an invalid content type was specified (the type isn't set up for indexing) --->
			<cfif not structCount(arguments.stContentType)>
				<cfthrow type="InvalidContentType" message="You have attempted to index a record that is of a content type (#arguments.typename#) that is not being indexed by the FarCry Solr Pro plugin.  Please setup that content type in the administration area." />
			</cfif>
		</cfif>
		
		<!--- note: these results are cached so it is safe to loop and call this method --->
		<cfset var stPropBoosts = getCorePropertyBoosts(stContentType = arguments.stContentType) />
		<cfset var lFarCryProps = getPropertiesByType(typename = arguments.typename) />
		<cfset var aCoreFields = getSolrFields(lOmitFields = "fcsp_rulecontent") />
		
		<!--- load the record from the database --->
		<cfset var stRecord = application.fapi.getContentObject(typename = arguments.typename, objectid = arguments.objectid) />
		
		<!--- each record in Solr should track the application name --->
		<cfset stRecord["fcsp_sitename"] = application.applicationName />

		<!--- set a unique id --->
		<cfset stRecord["fcsp_id"] = application.applicationName & "_" & stRecord.objectid />
		
		<!--- create a solr object for this record --->
		<cfset var doc = [] />
		<cfset var field = "" />
		<cfloop collection="#stRecord#" item="field">
			
			<!--- only add field if its a core property or an indexed field --->
			<cfif hasIndexedProperty(arguments.stContentType.objectid, field) or arrayFindNoCase(aCoreFields, field)>
				
				<cfif arrayFindNoCase(aCoreFields, field)>
					
					<!--- core property --->
				
					<!--- if this is a legit FC property then set the farcryField, otherwise leave it blank --->
					<cfif listFindNoCase(lFarCryProps, field)>
						
						<cfset arrayAppend(doc, {
							name = lcase(field),
							value = stRecord[field],
							farcryField = field
						}) />
						
					<cfelse>
						
						<cfset arrayAppend(doc, {
							name = lcase(field),
							value = stRecord[field],
							farcryField = ""
						}) />
						
					</cfif>
					
				<cfelse>
					
					<!--- custom property --->
					
					<!--- load the indexing metadata for this property --->
					<cfset var stSolrPropData = arguments.oIndexedProperty.getByContentTypeAndFieldname(contentTypeId = arguments.stContentType.objectid, fieldName = field) />
					<cfset var aFieldTypes = listToArray(stSolrPropData.lFieldTypes,",") />
					<cfset var ft = "" />
					<cfloop array="#aFieldTypes#" index="ft">
						
						<cfset var typeSetup = {
							fieldType = listGetAt(ft,1,":"),
							bStored = listGetAt(ft,2,":"),
							boostValue = listGetAt(ft,3,":")
						} />
						
						<cfset arrayAppend(doc, {
							name = lcase(field) & "_" & typeSetup.fieldType & "_" & ((typeSetup.bStored eq 1) ? "stored" : "notstored"),
							value = stRecord[field],
							boost = typeSetup.boostValue,
							farcryField = field
						}) />
						
						<cfscript>
							// if this field is an image or file field, parse the contents
							var ftType = getFTTypeForProperty(arguments.typename,field);
							if (listFindNoCase("image,file",ftType) && len(trim(stRecord[field]))) {
							
								if (ftType eq "image") {
									var filePath = expandPath(application.fapi.getImageWebroot() & stRecord[field]);
								} else {
									var filePath = getFilePathForProperty(stRecord, field);
								}

								if (fileExists(filePath)) {
								
									// parse and save the value
									var parsedValue = parseFile(filePath = filePath);
									arrayAppend(doc, {
										"name" = lcase(field) & "_contents_" & typeSetup.fieldType & "_" & ((typeSetup.bStored eq 1) ? "stored" : "notstored"),
										"value" = parsedValue,
										"boost" = typeSetup.boostValue,
										"farcryField" = field
									});
									
									// save parsed value to stRecord so we can use it to build the "highlight" summary
									stRecord[field & "_contents"] = parsedValue;

								}
								
							}
						</cfscript>
						
					</cfloop>
					
				</cfif>
					
			</cfif>
			
		</cfloop>

		<!--- grab any related rule records and index those as well (if we are indexing rules for this content type) --->
		<cfif listLen(arguments.stContentType.lIndexedRules)>
			<cfset var ruleContent = getRuleContent(objectid = arguments.objectid, lRuleTypes = arguments.stContentType.lIndexedRules) />
			<cfset arrayAppend(doc, {
			 	name = "fcsp_rulecontent", 
			 	value = ruleContent,
			 	farcryField = ""
			}) />
			<cfset arrayAppend(doc, {
			 	name = "fcsp_rulecontent_phonetic", 
			 	value = ruleContent,
			 	farcryField = "" 
			}) />
		</cfif>
		
		<!--- if we are building a summary field, grab that data as well --->
		<cfset var lSummaryFields = arguments.stContentType.lSummaryFields />
		<cfset var f = "" />
		<cfloop list="#lSummaryFields#" index="f">
			<cfif structKeyExists(stRecord, f)>
				<cfset arrayAppend(doc, {
					name = "fcsp_highlight",
					value = application.stPlugins.farcrysolrpro.oCustomFunctions.tagStripper(stRecord[f]),
					farcryField = ""
				}) />
			</cfif>
			<cfif structKeyExists(stRecord, f & "_contents")>
				<!--- we have file contents for this field, index it as well --->
				<cfset arrayAppend(doc, {
					name = "fcsp_highlight",
					value = application.stPlugins.farcrysolrpro.oCustomFunctions.tagStripper(stRecord[f & "_contents"]),
					farcryField = ""
				}) />
			</cfif>
		</cfloop>
		
		<!--- note whether or not this record should be included in the site-wide search --->
		<cfset arrayAppend(doc, {
			name = "fcsp_benablesearch",
			value = javacast("boolean",stContentType.bEnableSearch),
			farcryField = ""
		}) />

		<!--- calculate the document size (fcsp_documentsize) --->
		<cfset var docSize = 0 />
		<cfif len(trim(arguments.stContentType.lDocumentSizeFields))>
			<cfset var docSizeField = "" />
			<cfloop list="#arguments.stContentType.lDocumentSizeFields#" index="docSizeField">
				<cfif len(trim(stRecord[docSizeField]))>
					<cfset var docSizeFtType = getFtTypeForProperty(typename = stRecord.typename, propertyName = docSizeField) />
					<cfswitch expression="#docSizeFtType#">
						<cfcase value="file,image">
							<!--- get the size of the file --->
							<cfif docSizeFtType eq "file">
								<cfset var fp = getFilePathForProperty(stRecord, docSizeField) />
							<cfelse>
								<cfset var fp = expandPath(application.fapi.getImageWebroot() & stRecord[docSizeField]) />
							</cfif>
							<cfif fileExists(fp)>
								<cfset docSize+= createObject("java","java.io.File").init(fp).length() />
							</cfif>
						</cfcase>
						<cfdefaultcase>
							<cfset docSize+= len(stRecord[docSizeField]) />
						</cfdefaultcase>
					</cfswitch>
				</cfif>
			</cfloop>
		</cfif>
		<cfset arrayAppend(doc, {
			name = "fcsp_documentsize",
			value = javacast("int",docSize),
			farcryField = ""
		}) />

		<cfscript>
			// handle any custom field mapping for this type
			var oType = application.fapi.getContentType(arguments.typename);
			if (structKeyExists(oType,"mapSolrFields")) {
				doc = oType.mapSolrFields(stObject = stRecord, fields = doc);
			}
		</cfscript>
		
		<!--- add core boost values to document --->
		<cfset var i = "" />
		<cfloop array="#doc#" index="i">
			<cfif structKeyExists(stPropBoosts, i.name) and not structKeyExists(i,"boost")>
				<cfset i.boost = stPropBoosts[i.name] />
			<cfelseif not structKeyExists(i,"boost")>
				<cfset i.boost = application.fapi.getConfig(key = 'solrserver', name = 'defaultBoost', default = 5) />
			</cfif>
		</cfloop>
		
		<!--- check if this record has a document level boost --->
		<cfset var docBoost = arguments.oDocumentBoost.getBoostValueForDocument(documentId = stRecord.objectid) />
		
		<!--- if there was no boost for the specific document, grab the default specified for the content type --->
		<cfif not isNumeric(docBoost)>
			<cfset docBoost = arguments.stContentType.defaultDocBoost />
		</cfif>
		
		<!--- add it to solr --->
		<cfset var args = { doc = doc, typename = stRecord.typename } />
		<cfif isNumeric(docBoost)>
			<cfset args.docBoost = docBoost />
		</cfif>
		<cfset add(argumentCollection = args) />
		
		<!--- optionally, commit --->
		<cfif arguments.bCommit>
			<cfset commit() />
		</cfif>
		
	</cffunction>
	
	<cffunction name="getRecordsToIndex" returntype="struct" access="public" output="false" hint="Get the records to index for a given content type">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="batchSize" required="true" type="numeric" />
		<cfargument name="builtToDate" required="false" type="any" />
		
		<cfset var oType = application.fapi.getContentType(arguments.typename) />
		<cfset var stResult = {} />
		
		<cfif structKeyExists(oType,"getTablename")>
			<cfset var tablename = oType.getTablename() />
		<cfelse>
			<cfset var tablename = oType.getTypename() />
		</cfif>
					
		<cfif structKeyExists(oType, "contentToIndex")>
			<!--- run the contentToIndex method for this content type --->
			<cfset stResult.qContentToIndex = oType.contentToIndex() />
		<cfelse>
			<!--- no contentToIndex method, just grab all the records --->
			<cfquery name="stResult.qContentToIndex" datasource="#application.dsn#">
			SELECT objectID, datetimelastupdated
			FROM #tablename#
			<cfif structkeyexists(application.stcoapi[tablename].stprops, "status")>
			where status = 'approved'
			</cfif>
			</cfquery>
		</cfif>
		
		<cfset stResult.lItemsInDb = valueList(stResult.qContentToIndex.objectid) />
		
		<cfquery name="stResult.qContentToIndex" dbtype="query" maxrows="#batchSize#">
			select objectid, datetimelastupdated from stResult.qContentToIndex 
			<cfif structKeyExists(arguments,"builtToDate") and isDate(arguments.builtToDate)>
			where datetimelastupdated > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.builtToDate#" />
			</cfif>
			order by datetimelastupdated
		</cfquery>
		
		<cfreturn stResult />
		
	</cffunction>
	
	<cffunction name="deleteByTypename" returntype="void" access="public" output="false">
		<cfargument name="typename" required="true" type="string" />
		<cfargument name="sitename" required="false" type="string" default="#application.applicationName#" />
		<cfargument name="lObjectIds" required="false" type="string" default="" hint="optional list of objectIds to delete from the solr index" />
		<cfargument name="bCommit" required="false" type="boolean" default="true" />
		<cfset var deleteQuery = "typename:" & arguments.typename />
		<cfif len(trim(arguments.sitename))>
			<cfset deleteQuery = deleteQuery & " AND fcsp_sitename:" & arguments.sitename />
		</cfif>

		<cfset var i = "" />

		<!--- max clause count is 1024 --->
		<cfset var batchSize = 1000 />
		<cfif listLen(arguments.lObjectIds) gt batchSize>
			<!--- run in batches --->
			<cfset var numBatches = ceiling(listLen(arguments.lObjectIds) / batchSize) />
			<cfset var batchIdx = "" />
			<cfset var batchStart = 1 />
			<cfloop from="1" to="#numBatches#" index="batchIdx">
				<cfset batchQuery = deleteQuery & " AND (" />
				<cfset var batchEnd = min(listLen(arguments.lObjectIds), (batchStart + batchSize - 1)) />
				<cfloop from="#batchStart#" to="#batchEnd#" index="i">
					<cfset batchQuery = batchQuery & " fcsp_id:#arguments.sitename#_#listGetAt(arguments.lObjectIds,i)#" />
				</cfloop>
				<cfset batchQuery = batchQuery & " )" />
				<cfset deleteByQuery(q = batchQuery) />
				<cfset batchStart+= batchSize />
			</cfloop>
		<cfelseif listLen(arguments.lObjectIds)>
			<cfset deleteQuery = deleteQuery & " AND (" />
			<cfloop list="#arguments.lObjectIds#" index="i">
				<cfset deleteQuery = deleteQuery & " fcsp_id:#arguments.sitename#_#i#" />
			</cfloop>
			<cfset deleteQuery = deleteQuery & " )" />
			<cfset deleteByQuery(q = deleteQuery) />
		<cfelse>
			<cfset deleteByQuery(q = deleteQuery) />
		</cfif>

		<cfif arguments.bCommit>
			<cfset commit() />
		</cfif>
	</cffunction>
	
	<cffunction name="deleteBySitename" returntype="void" access="public" output="false">
		<cfargument name="sitename" required="false" type="string" default="#application.applicationName#" />
		<cfargument name="bCommit" required="false" type="boolean" default="true" />
		<cfset var deleteQuery = "fcsp_sitename:" & arguments.sitename />
		<cfset deleteByQuery(q = deleteQuery) />
		<cfif arguments.bCommit>
			<cfset commit() />
		</cfif>
	</cffunction>
	
	<cffunction name="getByContentType" access="public" output="false" returntype="struct">
		<cfargument name="contentType" type="string" required="true" />
		<cfset var q = "" />
		<cfquery name="q" datasource="#application.dsn#" cachedwithin="#createTimeSpan(0,0,0,60)#">
			select objectid from solrProContentType where lower(contenttype) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.contentType)#" /> 
		</cfquery>
		<cfif q.recordCount>
			<cfreturn getData(q.objectid[1]) />
		<cfelse>
			<cfreturn {} />
		</cfif>
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
				lower(cxr.typename) in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#lcase(arguments.lRuleTypes)#" />) 
				and lower(c.label) like <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.objectid)#%" />
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
			where lower(p.fieldName) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.fieldName)#" />
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
		
		<cfif structKeyExists(application.stPlugins["farcrysolrpro"],"typeProperties-" & arguments.typename)>
			<cfreturn application.stPlugins["farcrysolrpro"]["typeProperties-" & arguments.typename] />
		</cfif>
		
		<cfset var properties = application.fapi.getContentTypeMetadata(typename = arguments.typename, md = "stProps", default = "") />
		
		<cfif isStruct(properties)>
			<cfset application.stPlugins["farcrysolrpro"]["typeProperties-" & arguments.typename] = listSort(structKeyList(properties),"textnocase") />
			<cfreturn application.stPlugins["farcrysolrpro"]["typeProperties-" & arguments.typename]  />
		</cfif>
		
	</cffunction>

	<cffunction name="getFilePathForProperty" access="public" output="false" returntype="string">
		<cfargument name="stObject" required="true" type="struct" />
		<cfargument name="propertyName" required="true" type="string" />
		<cfscript>
			var pathInfo = application.fapi.getFormtool("file").getFileLocation(
				stObject = arguments.stObject,
				stMetadata = application.fapi.getPropertyMetadata(typename = arguments.stObject.typename, property = arguments.propertyName)
			);
			if (structKeyExists(pathInfo,"fullPath")) {
				return pathInfo.fullPath;
			} else {
				// it wasn't found, try and cobble something together
				return application.path.defaultfilepath & arguments.stObject[arguments.propertyName];
			}
		</cfscript>
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
				<cfif listFindNoCase("string,nstring,varchar,longchar,text,variablename,color,email",properties[prop].metadata.type)>
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
		
		<cfif structKeyExists(application.stPlugins["farcrysolrpro"],"schemaFields-#arguments.lOmitFields#")>
			<cfreturn application.stPlugins["farcrysolrpro"]["schemaFields-" & arguments.lOmitFields] />
		</cfif>
		
		<cfset var a = [] />
		<cfset var schemaXmlFile = application.fapi.getConfig(key = "solrserver", name = "instanceDir") & "/conf/schema.xml" />
		<cfset var fields = xmlSearch(schemaXmlFile, "//schema/fields/field") />
		<cfset var field = "" />
		
		<cfloop array="#fields#" index="field">
			<cfif not listFindNoCase(arguments.lOmitFields, field.xmlAttributes["name"])>
				<cfset arrayAppend(a, field.xmlAttributes["name"]) />
			</cfif>
		</cfloop>
		
		<cfset application.stPlugins["farcrysolrpro"]["schemaFields-" & arguments.lOmitFields] = a />
		
		<cfreturn a />
		
	</cffunction>
	
	<cffunction name="getSchemaFieldMetadata" access="public" output="false" returntype="array" hint="Returns field metadata from the schema.xml file">
		<cfargument name="lFieldNames" type="string" required="false" default="" hint="List of fields to return metadata.  If not specified, all fields will be returned." />
		<cfargument name="lOmitFields" type="string" required="false" default="fcsp_random" />
		<cfargument name="bIncludeIgnored" type="boolean" required="false" default="false" /> 
		<cfset var a = [] />
		<cfset var schemaXmlFile = application.fapi.getConfig(key = "solrserver", name = "instanceDir") & "/conf/schema.xml" />
		<cfset var fields = xmlSearch(schemaXmlFile, "//schema/fields/field") />
		<cfset var field = "" />
		<cfloop array="#fields#" index="field">
			<cfif (listLen(arguments.lFieldNames) eq 0 or listFindNoCase(arguments.lFieldNames, field.xmlAttributes["name"])) and not listFindNoCase(arguments.lOmitFields, field.xmlAttributes["name"])>
				<cfif field.xmlAttributes.type neq "ignored" or arguments.bIncludeIgnored eq true>
					<cfset arrayAppend(a, field.xmlAttributes) />
				</cfif>
			</cfif>
		</cfloop>
		<cfreturn a />
	</cffunction>
	
	<cffunction name="getSchemaDynamicFieldMetadata" access="public" output="false" returntype="array" hint="Returns dynamic field metadata from the schema.xml file">
		<cfargument name="bIncludeIgnored" type="boolean" required="false" default="false" /> 
		<cfset var a = [] />
		<cfset var schemaXmlFile = application.fapi.getConfig(key = "solrserver", name = "instanceDir") & "/conf/schema.xml" />
		<cfset var fields = xmlSearch(schemaXmlFile, "//schema/fields/dynamicField | //schema/fields/dynamicfield") />
		<cfset var field = "" />
		<cfloop array="#fields#" index="field">
			<cfif field.xmlAttributes.type neq "ignored" or arguments.bIncludeIgnored eq true>
				<cfset arrayAppend(a, field.xmlAttributes) />
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
		<cfargument name="lObjectIds" type="string" required="false" default="" />
		<cfargument name="bIncludeNonSearchable" type="boolean" required="false" default="false" />
		<cfset var q = "" />
		<cfquery name="q" datasource="#application.dsn#">
			select objectid, contentType, title, bEnableSearch from solrProContentType
			where 1=1
			<cfif listLen(arguments.lObjectIds)>
			and objectid in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#arguments.lObjectIds#" />)
			</cfif>
			<cfif bIncludeNonSearchable eq false>
			and bEnableSearch = 1
			</cfif>
			order by lower(title);
		</cfquery>
		<cfreturn q />
	</cffunction>
	
	<cffunction name="buildQueryString" access="public" output="false" returntype="string">
		<cfargument name="searchString" required="true" type="string" />
		<cfargument name="operator" required="false" type="string" default="ANY" hint="ANY,ALL,PHRASE" />
		<cfargument name="lContentTypes" required="false" type="string" default="" />
		<cfargument name="bCleanString" required="false" type="boolean" default="true" />
		<cfargument name="bFilterBySite" required="false" type="boolean" default="true" />
		
		<cfset var type = "" />
		<cfset var q = arguments.searchString />
		
		<cfif arguments.bCleanString>
			<cfset q = cleanQueryString(arguments.searchString,arguments.operator) />
		</cfif>
		<cfset q = '(' & q & ')' />
		
		<!--- add a typename filter --->
		<cfif listLen(arguments.lContentTypes)>
			<cfset q = q & " AND +(" />
			
			<cfset var counter = 0 />
			<cfloop list="#arguments.lContentTypes#" index="type">
				<cfset counter++ />
				
				<cfif counter gt 1>
					<cfset q = q & " OR " />
				</cfif>
				
				<cfset q = q & "typename:" & type />
				
			</cfloop>
		
			<cfset q = q & ")" />
		</cfif>
		
		<cfif arguments.bFilterBySite>
			<cfset q = q & " AND +(fcsp_sitename:" & application.applicationName & ")" />
		</cfif>
		
		<cfset q = q & " AND +fcsp_benablesearch:true" />
		
		<cfreturn q />
		
	</cffunction>

	<cffunction name="cleanQueryString" access="public" output="false" returntype="string">
		<cfargument name="searchString" required="true" type="string" />
		<cfargument name="operator" required="false" type="string" default="ANY" hint="ANY,ALL,PHRASE" />
		
		<cfset var type = "" />
		
		<!--- escape lucene special chars (+ - && || ! ( ) { } [ ] ^ " ~ * ? : \) --->
		<cfset var q = trim(reReplaceNoCase(arguments.searchString,'([\+\-!(){}\[\]\^"~*?:\\]|&&|\|\|)',"\\\1","ALL")) />
		
		<cfif arguments.operator eq "phrase">
			<!--- Operators in phrases don't need to be removed --->
			<cfset q = '"' & q & '"' />
		<cfelse>
			<!--- remove any terms that are operators (AND, OR, NOT) --->
			<cfset q = trim(reReplaceNoCase(q,"\b(AND|OR|NOT)\b"," ","ALL")) />
			
			<!--- If there are multiple terms, connect them with AND or OR operators --->
			<cfif reFind("[[:space:]]",q) gt 0>
				<cfif arguments.operator eq "all">
					<cfset q = reReplace(q,"[[:space:]]+"," AND ","ALL") />
				<cfelse>
					<!--- Default operator is ANY --->
					<cfset q = reReplace(q,"[[:space:]]+"," OR ","ALL") />
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn q />
		
	</cffunction>
	
	<!--- cfsolrlib abstractions --->
	
	<cffunction name="resetIndex" access="public" output="false" returntype="void">
		<cfset application.stplugins["farcrysolrpro"].cfsolrlib.resetIndex() />
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
		
		<cfloop array="#doc#" index="prop">

			<cfscript>
			// remove farcryField key from all structs in the doc array
			structDelete(prop,"farcryField");
			</cfscript>
			
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
	
	<cffunction name="deleteByID" access="public" output="false" hint="Delete a document from the index by ID">
		<cfargument name="id" type="string" required="true" hint="ID of object to delete.">
		<cfargument name="bCommit" type="boolean" required="false" default="false" />
		<cfset application.stPlugins["farcrysolrpro"].cfsolrlib.deleteById(id = arguments.id, idFieldName = "fcsp_id") />
		<cfif arguments.bCommit>
			<cfset commit() />
		</cfif>
	</cffunction>
	
	<cffunction name="deleteByQuery" access="public" output="false" returntype="void">
		<cfargument name="q" type="string" required="true" />
		<cfset application.stPlugins["farcrysolrpro"].cfsolrlib.deleteByQuery(q = arguments.q) />
	</cffunction>
	
	<!--- helper --->

	<cffunction name="parseOpenXmlFile" access="private" output="false" returntype="string">
		<cfargument name="filePath" required="true" type="string" />
		
		<!--- 
			Note this method must be run within the context of Javaloader having switched out the context class loader 
			(see https://github.com/markmandel/JavaLoader/wiki/Switching-the-ThreadContextClassLoader) 
			
			call it as follows:
				javaloader.switchThreadContextClassLoader(parseOpenXmlFile, { filePath = '/path/to/file.txt' })
		--->
		
		<cfscript>	
		// grab a new instance of tika
		var tika = application.stPlugins["farcrysolrpro"].javaloader.create("org.apache.tika.Tika").init();
		
		// parse the file
		var returnValue = tika.parseToString(createObject("java","java.io.File").init(arguments.filePath));
		
		// return the parsed string
		return returnValue;
		</cfscript>
		
	</cffunction>
	
	<cffunction name="parseFile" access="public" output="false" returntype="string" hint="Parses a file using Tika and returns the file contents as a string">
		<cfargument name="filePath" required="true" type="string" />
		
		<cfset var returnValue = '' />

		<cfscript>
			try {
				if (listFindNoCase(".docx,.xlsx,.pptx,.docm,.xlsm,.pptm",right(arguments.filePath,5))) {
					// parsing OpenXML files must be done using a different context class loader
					returnValue = application.stPlugins["farcrysolrpro"].javaloader.switchThreadContextClassLoader(parseOpenXmlFile, { filePath = arguments.filePath });
				} else {
					// use our cached copy of tika and parse the file
					returnValue = application.stPlugins["farcrysolrpro"].tika.parseToString(createObject("java","java.io.File").init(arguments.filePath));
				}
			} catch (any e) {
				WriteLog(application = true, file = 'farcrySolrPro', type = 'error', text = 'Tika failed to parse #filePath#, the error was #e.message#');
			}
		</cfscript>
		
		<cfreturn returnValue />

	</cffunction>
	
	<cffunction name="listCompare" output="false" returnType="string">
	   <cfargument name="list1" type="string" required="true" />
	   <cfargument name="list2" type="string" required="true" />
	   <cfargument name="delim1" type="string" required="false" default="," />
	   <cfargument name="delim2" type="string" required="false" default="," />
	   <cfargument name="delim3" type="string" required="false" default="," />
		<!---
		 Compares one list against another to find the elements in the first list that don't exist in the second list.
		 v2 mod by Scott Coldwell
		 
		 @param List1      Full list of delimited values. (Required)
		 @param List2      Delimited list of values you want to compare to List1. (Required)
		 @param Delim1      Delimiter used for List1.  Default is the comma. (Optional)
		 @param Delim2      Delimiter used for List2.  Default is the comma. (Optional)
		 @param Delim3      Delimiter to use for the list returned by the function.  Default is the comma. (Optional)
		 @return Returns a delimited list of values. 
		 @author Rob Brooks-Bilson (rbils@amkor.com) 
		 @version 2, June 25, 2009 
		--->
	   <cfset var list1Array = ListToArray(arguments.List1,Delim1) />
	   <cfset var list2Array = ListToArray(arguments.List2,Delim2) />
	
	   <!--- Remove the subset List2 from List1 to get the diff --->
	   <cfset list1Array.removeAll(list2Array) />
	
	   <!--- Return in list format --->
	   <cfreturn ArrayToList(list1Array, Delim3) />
	</cffunction>
	
	<cffunction name="isSolrRunning" access="public" returntype="boolean" output="false">
		<cfargument name="config" required="false" type="struct" default="#application.fapi.getContentType('farConfig').getConfig(key = 'solrserver')#" />
		<cftry>

			<cfset var uri = "http://" & arguments.config.host & ":" & arguments.config.port & "/solr/admin/cores?action=STATUS" />
			<cfset var httpResult = {} />
			
			<!--- check that Solr is responding --->
			<cfhttp url="#uri#" method="get" result="httpResult" timeout="10" />
			
			<cfif not isXml(httpResult.FileContent)>
				<cfreturn false />
			<cfelse>
				<cfif arrayLen(XmlSearch(xmlParse(httpResult.fileContent),"//response/lst[@name='status']"))>
					<cfreturn true />
				<cfelse>
					<cfreturn false />
				</cfif>
			</cfif>
			
			<cfcatch>
				<cfreturn false />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="reload" access="public" returntype="void" output="false">
		<cfargument name="config" required="false" type="struct" default="#application.fapi.getContentType('farConfig').getConfig(key = 'solrserver')#" />
		<cfset var host = arguments.config.host />
		<cfset var port = arguments.config.port />
		<cfset var collectionName = arguments.config.collectionName />
		<cfset var uri = "http://" & host & ":" & port & "/solr/admin/cores?action=RELOAD&core=" & collectionName />
		<cfhttp url="#uri#" method="get" />
	</cffunction>
	
</cfcomponent>