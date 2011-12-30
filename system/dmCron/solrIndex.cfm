<cfsetting enablecfoutputonly="true" requestTimeOut="9999" />
<!--- @@displayname: Solr Index --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<!--- Start timer --->
<cfset tickBegin = GetTickCount() />

<!---<cfoutput><p>Running. . .</p></cfoutput>
<cfflush />--->

<cfset request.fc.bShowTray = false />

<!--- TODO: remove this for production --->
<cfset application.stplugins["farcrysolrpro"].cfsolrlib.resetIndex() />

<!--- has optimization been disabled? --->
<cfparam name="url.optimize" default="true" />
<cfif not isBoolean(url.optimize)>
	<cfset url.optimize = true />
</cfif>

<cfset oContentType = application.fapi.getContentType("solrProContentType") />
<cfset oIndexedProperty = application.fapi.getContentType("solrProIndexedProperty") />
<cfset oDocumentBoost = application.fapi.getContentType("solrProDocumentBoost") />

<!--- get all the content types that are being indexed --->
<cfset qContentTypes = oContentType.getAllContentTypes() />

<cfset aStats = [] />

<cfloop query="qContentTypes">
	
	<cfset stContentType = oContentType.getData(qContentTypes.objectid[qContentTypes.currentRow]) />
	
	<cfset oType = application.fapi.getContentType(stContentType.contentType) />
	
	<!--- get all the records that should be indexed --->
	<cfif structKeyExists(oType, "contentToIndex")>
		<!--- run the contentToIndex method for this content type --->
		<cfset qContentToIndex = oType.contentToIndex() />
	<cfelse>
		<!--- no contentToIndex method, just grab all the records --->
		<cfquery name="qContentToIndex" datasource="#application.dsn#">
		SELECT objectID
		FROM #oType.getTablename()#
		<cfif structkeyexists(application.stcoapi[oType.getTablename()].stprops, "status")>
		where status = 'approved'
		</cfif>
		</cfquery>
	</cfif>
	<cfset stStats = {} />
	<cfset stStats["typeName"] = qContentTypes.contentType[qContentTypes.currentRow] />
	<cfset stStats["indexRecordCount"] =  qContentToIndex.recordCount />
	<cfset arrayAppend(aStats, stStats) />
	
	<!--- parse core property boosts --->
	<cfset aCorePropBoosts = listToArray(stContentType.lCorePropertyBoost) />
	<cfset stPropBoosts = {} />
	<cfloop array="#aCorePropBoosts#" index="i">
		<cfset stPropBoosts[listFirst(i,":")] = listLast(i,":") /> 
	</cfloop>
	
	<!--- get a list of FarCry properties for this type --->
	<cfset lFarCryProps = oContentType.getPropertiesByType(typename = stContentType.contentType) /> 
	
	<cfloop query="qContentToIndex">
		
		<!--- build an object for each record --->
		<cfset stRecord = application.fapi.getContentObject(typename = oType.getTablename(), objectid = qContentToIndex.objectid[qContentToIndex.currentRow]) />
		
		<cfset doc = [] />
		
		<cfset aCoreFields = oContentType.getSolrFields(lOmitFields = "rulecontent") />
		
		<cfloop collection="#stRecord#" item="field">
			<!--- only add field if its a core property or an indexed field --->
			<cfif oContentType.hasIndexedProperty(stContentType.objectid, field) or arrayFindNoCase(aCoreFields, field)>
				
				<cfif arrayFindNoCase(aCoreFields, field)>
					
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
						
					<cfset stSolrPropData = oIndexedProperty.getByContentTypeAndFieldname(contentTypeId = stContentType.objectid, fieldName = field) />
					
					<cfset aFieldTypes = listToArray(stSolrPropData.lFieldTypes,",") />
					
					<cfloop array="#aFieldTypes#" index="ft">
						
						<cfset typeSetup = {
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
						
					</cfloop>
					
				</cfif>
							
				<!--- TODO: if field is a "file" field, then add the file and map the file's content to the target field in the schema --->
				
			</cfif>
		</cfloop>
		
		<!--- grab any related rule records and index those as well --->
		<cfset ruleContent = oContentType.getRuleContent(objectid = qContentToIndex.objectid[qContentToIndex.currentRow], lRuleTypes = stContentType.lIndexedRules) />
		<cfset arrayAppend(doc, {
		 	name = "rulecontent", 
		 	value = ruleContent,
		 	farcryField = ""
		}) />
		<cfset arrayAppend(doc, {
		 	name = "rulecontent_phonetic", 
		 	value = ruleContent,
		 	farcryField = "" 
		}) />
		
		<!--- add core boost values to document --->
		<cfloop array="#doc#" index="i">
			<cfif structKeyExists(stPropBoosts, i.name) and not structKeyExists(i,"boost")>
				<cfset i.boost = stPropBoosts[i.name] />
			<cfelse>
				<cfset i.boost = 5 />
			</cfif>
		</cfloop>
		
		<!--- check if this record has a document level boost --->
		<cfset docBoost = oDocumentBoost.getBoostValueForDocument(documentId = stRecord.objectid) />
		
		<!--- add it to solr --->
		<!--- TODO: adding files is slightly different, address this in future --->
		<cfset args = { doc = doc, typename = stRecord.typename } />
		<cfif isNumeric(docBoost)>
			<cfset args.docBoost = docBoost />
		</cfif>
		<cfset oContentType.add(argumentCollection = args) />
		
		<!--- If there were no errors, update indexRecordCount --->
		<cfset stContentType.indexRecordCount = qContentToIndex.recordCount />
		<cfset stResult_indexType = oContentType.setData(stProperties=stContentType) />

	</cfloop>
	
	<!--- TODO: delete any records in the index that are no longer in the database (use a solr "delete by query" to delete all items for this content type that are not in the qContentToIndex results) --->
</cfloop>

<!--- commit --->
<cfset oContentType.commit() />

<!--- optimize (if necessary --->
<cfif url.optimize>
	<cfset oContentType.optimize() />
</cfif>

<!--- TODO: batch the records and update the buildtodate to the last record processed --->
<!--- update the build to date for this content type --->
<cfset stContentType.buildtodate = now() />
<cfset oContentType.setData(stProperties = stContentType) />

<cffunction name="millisecondsToDate" access="public" output="false" returnType="date">
  <cfargument name="strMilliseconds" type="string" required="true" />
  <!---
  Converts epoch milleseconds to a date timestamp.
  @param strMilliseconds      The number of milliseconds. (Required)
  @return Returns a date.
  @author Steve Parks (steve@adeptdeveloper.com)
  @version 1, May 20, 2005
  --->  
  <cfreturn dateAdd("s", strMilliseconds/1000, "january 1 1970 00:00:00") />
</cffunction>

<cfset processTime = GetTickCount() - tickBegin />

<cfoutput>
<p>Process complete</p>
<h3>Stats</h3>
<p>Process took <strong>#timeFormat(millisecondsToDate(processTime), "HH:mm:ss")#</strong> to complete <span style="color: ##333333;">(hours:min:sec)</span></p>
<h4>Content Types Indexed</h4>
	<ul>
		<cfloop array="#aStats#" index="statResult">
			<li><strong>Type:</strong> [#statResult.typeName#]&nbsp;&nbsp;&mdash;&nbsp;&nbsp;<strong>Record Count:</strong> [#statResult.indexRecordCount#]</li>
		</cfloop>
	</ul>
</cfoutput>

<cfsetting enablecfoutputonly="false" />