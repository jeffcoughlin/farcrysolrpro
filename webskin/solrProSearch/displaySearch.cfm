<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2009, http://www.daemon.com.au --->
<!--- @@License:  --->
<!--- @@displayname: Display Search Results --->
<!--- @@description: Runs the cfsearch and displays the search results  --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- 
	Display Search
---------------------------------------------------------------------->

<!--- default local vars --->
<cfparam name="stQueryStatus" default="#structNew()#" type="struct" />

<!--- Save hard coded criteria values --->
<cfif structKeyExists(url, "criteria") and len(url.criteria)>
	<cfset form.criteria = url.criteria />
</cfif>

<cfif structKeyExists(url, "lContentTypes") and len(url.lContentTypes)>
	<cfset form.lContentTypes = url.lContentTypes />
</cfif>

<cfif structKeyExists(form, "criteria") and len(form.criteria)>
	<cfset stProperties = structNew() />
	<cfset stProperties.objectid = stObj.objectid />
	<cfset stProperties.criteria = form.criteria />
	<cfset stproperties.bSearchPerformed = 1 />
	<cfif structKeyExists(form, "operator")>
		<cfset stProperties.operator = form.operator />
	</cfif>
	<cfif structKeyExists(form, "lContentTypes")>
		<cfset stProperties.lContentTypes = form.lContentTypes />
	</cfif>
	<cfset stResult = setData(stProperties="#stProperties#") />
</cfif>


<ft:processForm action="Search">
	<ft:processFormObjects objectid="#stobj.objectid#" typename="#stobj.typename#" bSessionOnly="true">
	 <cfset stproperties.bSearchPerformed = 1 />
	</ft:processFormObjects>
</ft:processForm>

<cfset actionURL = application.fapi.getLink(
	objectid=stobj.objectid,
	view="displaySearch",
	includeDomain=true
) />

<!--- Render the search form and results #application.url.webroot#/index.cfm?objectid=#stobj.objectid#&view=displaySearch --->
<ft:form name="#stobj.typename#SearchForm" bAjaxSubmission="true" ajaxMaskMsg="Searching..." 
	action="#actionURL#">

	<!--- Get the search Results --->
	<cfset oSearchService = application.fapi.getContentType("solrProSearch") />
	<cfset stSearchResult = oSearchService.getSearchResults(objectid="#stobj.objectid#", typename="#stobj.typename#") />
	
	<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchForm" />

	<cfif stSearchResult.bSearchPerformed>

		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchCount" stParam="#stSearchResult#" />
		
		<cfif len(stSearchResult.searchCriteria)>
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchSuggestions" stParam="#stSearchResult#" />
		</cfif>
		
		<cfif stSearchResult.qResults.recordCount GT 0>
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchResults" stParam="#stSearchResult#" />
		</cfif>
	<cfelse>
		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchNoCriteria" stParam="#stSearchResult#" />
	</cfif>
</ft:form>


<cfsetting enablecfoutputonly="false">