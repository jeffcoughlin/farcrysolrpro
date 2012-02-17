<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display Search Results --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="stParam.currentPage" default="1" />
<cfparam name="stParam.rows" default="10" />
<cfparam name="stParam.pageLinks" default="5" />
<cfparam name="stParam.results" default="#arrayNew(1)#" />
<cfparam name="stParam.highlighting" default="#structNew()#" />
<cfparam name="stParam.totalResults" default="0" />

<cfset aObjectIds = [] />
<cfloop array="#stParam.results#" index="i">
	<cfset arrayAppend(aObjectIds, i.objectid) />
</cfloop>

<cfset addValues = { 'q' = stobj.q, 'operator' = stobj.operator, 'orderby' = stobj.orderby } />
<cfif len(trim(stobj.lContentTypes))>
	<cfset addvalues["lContentTypes"] = stobj.lContentTypes />
</cfif>
<cfset actionUrl = application.fapi.getLink(objectid = request.navid, stParameters = addValues) />

<cfset oContentType = application.fapi.getContentType("solrProContentType") />

<skin:pagination 
	paginationId="" 
	array="#aObjectIds#" 
	totalRecords="#stParam.totalResults#" 
	actionUrl="#actionUrl#" 
	submissionType="url" 
	currentPage="#stParam.currentPage#" 
	recordsPerPage="#stParam.rows#" 
	pageLinks="#stParam.pageLinks#">
	
	<cfif structKeyExists(stParam.highlighting, stParam.results[stObject.currentRow].objectid)>
		<cfset highlighting = stParam.highlighting[stParam.results[stObject.currentRow].objectid] />
	<cfelse>
		<cfset highlighting = {} />
	</cfif>
	
	<skin:view webskin="displaySolrSearchResult" stObject="#stParam.results[stObject.currentRow]#" oContentType="#oContentType#" highlighting="#highlighting#" />

</skin:pagination>
			
<cfsetting enablecfoutputonly="false" />