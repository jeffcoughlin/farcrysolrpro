<cfsetting enablecfoutputonly="true" requestTimeOut="9999" />
<!--- @@displayname: Solr Index --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfset request.fc.bShowTray = false />

<!--- Start timer --->
<cfset tickBegin = GetTickCount() />

<!--- has optimization been disabled? --->
<cfparam name="url.optimize" default="true" />
<cfif not isBoolean(url.optimize)>
	<cfset url.optimize = true />
</cfif>

<!--- set the batch size --->
<cfparam name="url.batchSize" default="#application.fapi.getConfig(key = "solrserver", name = "batchSize", default = 1000)#" />
<cfif not isNumeric(url.batchSize)>
	<cfset url.batchSize = 1000 />
</cfif>

<!--- instantiate the content types we will need --->
<cfset oContentType = application.fapi.getContentType("solrProContentType") />
<cfset oIndexedProperty = application.fapi.getContentType("solrProIndexedProperty") />
<cfset oDocumentBoost = application.fapi.getContentType("solrProDocumentBoost") />

<!--- get all the content types that are being indexed --->
<cfset qContentTypes = oContentType.getAllContentTypes() />

<!--- delete any records that have a typename value that is not in the list of indexed typenames --->
<cfset lValidTypenames = valueList(qContentTypes.contentType) />
<cfset deleteQueryString = "q={!lucene q.op=AND}" />
<cfloop list="#lValidTypenames#" index="t">
	<cfset deleteQueryString = deleteQueryString & " -typename:" & t />
</cfloop>
<cfset oContentType.deleteByQuery(q = deleteQueryString) />
<cfset oContentType.commit() />

<cfset aStats = [] />
<cfloop query="qContentTypes">
	
	<cfset typeTickBegin = getTickCount() />
	
	<!--- load this content type's index settings --->
	<cfset stContentType = oContentType.getData(qContentTypes.objectid[qContentTypes.currentRow]) />
	
	<!--- get the records to index --->
	<cfset stResult = oContentType.getRecordsToIndex(typename = stContentType.contentType, batchSize = url.batchSize, builtToDate = stContentType.builtToDate) />
	<cfset qContentToIndex = stResult.qContentToIndex />
	<cfset lItemsInDb = stResult.lItemsInDb />
	
	<!--- load all records for this type from solr for comparison later --->
	<cfset existingRecords = oContentType.search(q = "typename:" & stContentType.contentType, rows = 999999) />
	<cfset lExistingRecords = "" />
	<cfloop array="#existingRecords.results#" index="r">
		<cfset lExistingRecords = listAppend(lExistingRecords, r.objectid[1]) />
	</cfloop>
	
	<cfloop query="qContentToIndex">
		
		<!--- add each record to the index --->
		<cfset oContentType.addRecordToIndex(
			objectid = qContentToIndex.objectid[qContentToIndex.currentRow],
			typename = stContentType.contentType,
			stContentType = stContentType,
			oIndexedProperty = oIndexedProperty,
			oDocumentBoost = oDocumentBoost,
			bCommit = false
		) />
		
	</cfloop>
	
	<!--- delete any records in the index that are no longer in the database. (use a solr "delete by query" to delete all items for this content type that are not in the qContentToIndex results) --->
	<cfset lItemsToDelete = listCompare(lExistingRecords, lItemsInDB) />
	<cfif listLen(lItemsToDelete)>
		<cfset oContentType.deleteByTypename(typename = stContentType.contentType, lObjectIds = lItemsToDelete, bCommit = false) />
	</cfif>
	
	<!--- update metadata for this content type --->
	<cfset stContentType.indexRecordCount = listLen(lExistingRecords) + qContentToIndex.recordCount - listLen(lItemsToDelete) />
	<cfset stContentType.builtToDate = qContentToIndex.datetimelastupdated[qContentToIndex.recordCount] />
	<cfset oContentType.setData(stProperties = stContentType) />
	
	<cfset typeTickEnd = getTickCount() />
	
	<!--- If there were no errors, update stats --->	
	<cfset stStats = {} />
	<cfset stStats["typeName"] = qContentTypes.contentType[qContentTypes.currentRow] />
	<cfset stStats["processtime"] = typeTickEnd - typeTickBegin />
	<cfset stStats["indexRecordCount"] =  qContentToIndex.recordCount />
	<cfset stStats["totalRecordCount"] = stContentType.indexRecordCount />
	<cfset stStats["builtToDate"] = stContentType.builtToDate />
	<cfset arrayAppend(aStats, stStats) />
	
</cfloop>

<!--- commit --->
<cfset oContentType.commit() />

<!--- optionally, optimize --->
<cfif url.optimize>
	<cfset oContentType.optimize() />
</cfif>

<cfset processTime = GetTickCount() - tickBegin />

<cfoutput>
<p>Process complete</p>
<h3>Stats</h3>
<p>Process took <strong>#timeFormat(millisecondsToDate(processTime), "HH:mm:ss")#</strong> to complete <span style="color: ##333333;">(hours:min:sec)</span></p>
<h4>Content Types Indexed</h4>
	<ul>
		<cfloop array="#aStats#" index="statResult">
			<li><strong>Type:</strong> [#statResult.typeName#]&nbsp;&nbsp;&mdash;&nbsp;&nbsp;<strong>Batch Record Count:</strong> [#statResult.indexRecordCount#] <strong>Total Index Count:</strong> #statResult.totalRecordCount# <strong>Build To Date:</strong> #dateFormat(statResult.builtToDate,"mm/dd/yyyy")# #timeFormat(statResult.builtToDate,"h:mm tt")# - #timeFormat(millisecondsToDate(statResult.processtime),"HH:mm:ss")#</li>
		</cfloop>
	</ul>
</cfoutput>

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

<cfsetting enablecfoutputonly="false" />