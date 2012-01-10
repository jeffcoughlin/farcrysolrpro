<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display Search Results --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="stParam.currentPage" default="1" />
<cfparam name="stParam.rows" default="10" />
<cfparam name="stParam.pageLinks" default="5" />
<cfparam name="stParam.results" default="#arrayNew(1)#" />
<cfparam name="stParam.totalResults" default="0" />

<cfset aObjectIds = [] />
<cfloop array="#stParam.results#" index="i">
	<cfset arrayAppend(aObjectIds, i.objectid) />
</cfloop>

<skin:pagination paginationId="" array="#aObjectIds#" totalRecords="#stParam.totalResults#" submissionType="form" currentPage="#stParam.currentPage#" recordsPerPage="#stParam.rows#" pageLinks="#stParam.pageLinks#">

	<skin:view webskin="displaySearchResult" typename="#stParam.results[stObject.currentRow].typename#" stObject="#stParam.results[stObject.currentRow]#" />

</skin:pagination>
			
<cfsetting enablecfoutputonly="false" />