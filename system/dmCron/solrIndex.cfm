<cfsetting enablecfoutputonly="true" requestTimeOut="9999" />
<!--- @@displayname: Solr Index --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<!---
	URL variable options are
	optimize: true/false (default: true)
	batchSize: integer (default: [set in main config. default: 1000])
--->

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
	<style>
	body {
		line-height: 1.6em;
		font-size: 15px;
	}
	.statsTbl {
		font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
		font-size: 1em;
		margin: 20px;
		text-align: left;
		border-collapse: collapse;
	}
	.statsTbl th {
		padding: 8px;
		font-weight: normal;
		font-size: 1.1em;
		color: ##039;
		background: ##b9c9fe;
	}
	.statsTbl th span {
		display: block;
		font-size: 0.8em;
	}
	.statsTbl td {
		padding: 8px;
		background: ##e8edff;
		border-top: 1px solid ##fff;
		color: ##669;
		text-align: center;
	}
	.statsTbl td:nth-child(1) {
		text-align: left;
		color: ##039;
		background: ##b9c9fe;
	}
	.statsTbl thead th:nth-child(1) {
		-moz-border-radius: 10px 0 0 0;
		border-radius: 10px 0 0 0;
	}
	.statsTbl thead th:nth-child(5) {
		-moz-border-radius: 0 10px 0 0;
		border-radius: 0 10px 0 0;
	}
	.statsTbl tfoot td:nth-child(1) {
		-moz-border-radius: 0 0 0 10px;
		border-radius: 0 0 0 10px;
		text-align: right;
		font-weight: bold;
	}
	.statsTbl tfoot td:nth-child(2) {
		text-align: right;
		font-weight: bold;
	}
	.statsTbl tfoot td:nth-child(3) {
		-moz-border-radius: 0 0 10px 0;
		border-radius: 0 0 10px 0;
	}
	.statsTbl tbody tr:hover td {
		background: ##d0dafd;
	}
	</style>

	<table class="statsTbl" summary="Solr Index Stats">
		<thead>
			<tr>
				<th scope="col">FC Type</th>
				<th scope="col">Batch Count</th>
				<th scope="col">Total Index Count</th>
				<th scope="col">Built to Date</th>
				<th scope="col">Process Time<span>(hours:min:sec)</span></th>
			</tr>
		</thead>
		<tfoot>
			<tr>
				<td></td>
				<td colspan="3">Total Page Processing Time:</td>
				<td>#timeFormat(millisecondsToDate(processTime), "HH:mm:ss")#</strong></td>
			</tr>
		</tfoot>
		<tbody>
		<cfloop array="#aStats#" index="statResult">
			<tr>
				<td>#statResult.typeName#</td>
				<td>#statResult.indexRecordCount#</td>
				<td>#statResult.totalRecordCount#</td>
				<td>#dateFormat(statResult.builtToDate,"mm/dd/yyyy")# #timeFormat(statResult.builtToDate,"h:mm tt")#</td>
				<td>#timeFormat(millisecondsToDate(statResult.processtime),"HH:mm:ss")#</td>
			</tr>
		</cfloop>
		</tbody>
	</table>
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