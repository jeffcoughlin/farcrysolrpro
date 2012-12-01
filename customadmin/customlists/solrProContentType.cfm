<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Pro Content Type Admin --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com)--->

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<admin:header title="Solr Pro Content Type Admin" />

<cfif application.ApplicationName neq application.fapi.getConfig(key = 'solrserver', name = 'collectionName')>
	
	<ft:processForm action="Reset This Site">
		<cfset oContentType = application.fapi.getContentType("solrProContentType") />
		<cfset oContentType.deleteBySitename(sitename = application.ApplicationName) />
		<cfset qContentTypes = oContentType.getAllContentTypes(bIncludeNonSearchable = true) />
		<cfloop query="qContentTypes">
			<cfset stContentType = oContentType.getData(qContentTypes.objectid[qContentTypes.currentRow]) />
			<cfset stContentType.builtToDate = "" />
			<cfset oContentType.setData(stContentType) />
		</cfloop>
		<skin:bubble title="Reset This Site" message="All records for site #application.applicationName# have been reset." />
	</ft:processForm>
	
	<ft:processForm action="resetContentTypeBySite">
		<cfset oContentType = application.fapi.getContentType("solrProContentType") />
		<cfset stContentType = oContentType.getData(form.selectedObjectId) />
		<cfset oContentType.deleteByTypename(typename = stContentType.contentType, sitename = application.applicationName, bCommit = true) />
		<cfset stContentType.builtToDate = "" />
		<cfset oContentType.setData(stContentType) />
		<skin:bubble title='Reset Conect Type' message='"#stContentType.title#" has been reset for site #application.applicationName#' />
	</ft:processForm>	
	
	<ft:processForm action="resetAndReindexBySite">
		<cfsetting requesttimeout="9999" />
		<cfset oContentType = application.fapi.getContentType("solrProContentType") />
		<cfset stContentType = oContentType.getData(form.selectedObjectId) />
		<!--- Reset index --->
		<cfset oContentType.deleteByTypename(typename = stContentType.contentType, sitename = application.applicationName, bCommit = true) />
		<cfset stContentType.builtToDate = "" />
		<cfset oContentType.setData(stContentType) />
		<!--- Index records without comparing old data - since there is nothing to compare --->
		<cfset stResult = oContentType.indexRecords(lContentTypeIds = stContentType.objectid, bRemoveOldDataFromSolr = false) />
		<skin:bubble title='Index Content Type' message='"#stContentType.title#" has been reset and re-indexed for site #application.applicationName#. #stResult.aStats[1].indexRecordCount# items were indexed in #timeFormat(application.stPlugins.farcrysolrpro.oCustomFunctions.millisecondsToDate(stResult.processTime),'HH:mm:ss')#' />
	</ft:processForm>
</cfif>

<ft:processForm action="resetContentType">
	<cfset oContentType = application.fapi.getContentType("solrProContentType") />
	<cfset stContentType = oContentType.getData(form.selectedObjectId) />
	<cfset oContentType.deleteByTypename(typename = stContentType.contentType, sitename = "", bCommit = true) />
	<cfset stContentType.builtToDate = "" />
	<cfset oContentType.setData(stContentType) />
	<skin:bubble title='Reset Content Type' message='"#stContentType.title#" has been reset' />
</ft:processForm>

<ft:processForm action="Optimize All">
	<cfset oContentType = application.fapi.getContentType("solrProContentType") />
	<cfset oContentType.optimize() />
	<skin:bubble title="Optimize" message="The Solr collection has been optimized." />
</ft:processForm>

<ft:processForm action="Reset All">
	<cfset oContentType = application.fapi.getContentType("solrProContentType") />
	<cfset oContentType.resetIndex() />
	<cfset qContentTypes = oContentType.getAllContentTypes(bIncludeNonSearchable = true) />
	<cfloop query="qContentTypes">
		<cfset stContentType = oContentType.getData(qContentTypes.objectid[qContentTypes.currentRow]) />
		<cfset stContentType.builtToDate = "" />
		<cfset oContentType.setData(stContentType) />
	</cfloop>
	<skin:bubble title="Reset All" message="Solr has been reset." />
</ft:processForm>

<ft:processForm action="indexContentType">
	<cfsetting requesttimeout="9999" />
	<cfset oContentType = application.fapi.getContentType("solrProContentType") />
	<cfset stContentType = oContentType.getData(form.selectedObjectId) />
	<cfset stResult = oContentType.indexRecords(lContentTypeIds = stContentType.objectid) />
	<skin:bubble title='Index Content Type' message='"#stContentType.title#" has been indexed. #stResult.aStats[1].indexRecordCount# items were indexed in #timeFormat(application.stPlugins.farcrysolrpro.oCustomFunctions.millisecondsToDate(stResult.processTime),'HH:mm:ss')#' />
</ft:processForm>

<ft:processForm action="resetAndReindex">
	<cfsetting requesttimeout="9999" />
	<cfset oContentType = application.fapi.getContentType("solrProContentType") />
	<cfset stContentType = oContentType.getData(form.selectedObjectId) />
	<!--- Reset index --->
	<cfset oContentType.deleteByTypename(typename = stContentType.contentType, sitename = "", bCommit = true) />
	<cfset stContentType.builtToDate = "" />
	<cfset oContentType.setData(stContentType) />
	<!--- Index records without comparing old data - since there is nothing to compare --->
	<cfset stResult = oContentType.indexRecords(lContentTypeIds = stContentType.objectid, bRemoveOldDataFromSolr = false) />
	<skin:bubble title='Index Content Type' message='"#stContentType.title#" has been reset and re-indexed. #stResult.aStats[1].indexRecordCount# items were indexed in #timeFormat(application.stPlugins.farcrysolrpro.oCustomFunctions.millisecondsToDate(stResult.processTime),'HH:mm:ss')#' />
</ft:processForm>

<cfscript>
	aButtons = [
		{ value = "Add", permission = 1, onclick = "" },
		{ value = "Delete", permission = 1, onclick = "", confirmText = "Are you sure you wish to delete these objects?" },
		{ value = "Unlock", permission = 1, onclick = "" },
		{ value = "Optimize All", permission = 1, onclick = "" },
		{ value = "Reset All", permission = 1, onclick = "", confirmText = "This will clear all records from Solr, are you sure you wish to do this?" }
	];
</cfscript>

<cfif application.applicationName neq application.fapi.getConfig(key = 'solrserver', name = 'collectionName')>
	<cfset arrayAppend(aButtons, { 
		value = "Reset This Site", 
		permission = 1, 
		onclick = "", 
		confirmText = "This will clear all records from Solr for this site (#application.applicationName#), are you sure you wish to do this?"
	}) />
</cfif>

<cfif application.fapi.getConfig(key = 'solrserver', name = 'bConfigured', default = false) eq true>

<cftry>
	
	<cfset lCustomActions = "indexContentType:Index Content Type,resetContentType:Reset Content Type" />
	
	<cfif application.applicationName neq application.fapi.getConfig(key = 'solrserver', name = 'collectionName')>
		<cfset lCustomActions = lCustomActions & " (All Sites),resetContentTypeBySite:Reset Content Type (This Site)" />
	</cfif>
	
	<cfset lCustomActions = listAppend(lCustomActions, "resetAndReindex:Reset and Re-index") />

	<cfif application.applicationName neq application.fapi.getConfig(key = 'solrserver', name = 'collectionName')>
		<cfset lCustomActions = lCustomActions & " (All Sites),resetAndReindexBySite:Reset and Re-index (This Site)" />
	</cfif>
	
	<ft:objectadmin 
		typename="solrProContentType"
		columnList="title,contentType,datetimecreated" 
		sortableColumns="title,contentType,datetimelastUpdated"
		lCustomColumns="Current Index Count:displayCellCurrentIndexCount"
		lFilterFields="title,contentType"
		sqlorderby="title"
		aButtons="#aButtons#"
		lButtons="Add,Delete,Unlock,Optimize All,Reset This Site,Reset All"
		plugin="farcrysolrpro"
		lCustomActions="#lCustomActions#" />
		
	<cfcatch>
		
		<cfoutput><p><br />Error loading object admin, be sure you have deployed all COAPI objects.</p><cfdump var="#cfcatch#"/></cfoutput>
		
	</cfcatch>

</cftry>

<cfelse>
	<cfset linkConfig = application.url.webtop & "/admin/customadmin.cfm?module=customlists/farConfig.cfm" />
	<cfoutput><p>You must <a href="#linkConfig#">configure the Solr settings</a> before you can define any content types.</p></cfoutput>
</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />