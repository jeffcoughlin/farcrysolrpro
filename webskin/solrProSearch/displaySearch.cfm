<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Load Search CSS --->
<skin:loadCss id="siteSearch-css" media="all" baseHref="#application.fapi.getWebroot()#/farcrysolrpro/css" lFiles="search.css" />

<!--- default local vars --->
<cfparam name="stQueryStatus" default="#structNew()#" type="struct" />

<cfparam name="url.q" default="" />
<cfparam name="form.q" default="#url.q#" />
<cfparam name="url.lContentTypes" default="" />
<cfparam name="form.lContentTypes" default="#url.lContentTypes#" />
<cfparam name="url.operator" default="" />
<cfparam name="form.operator" default="#url.operator#" />
<cfparam name="url.orderby" default="" />
<cfparam name="form.orderby" default="#url.orderby#" />
<!---
<cfparam name="url.page" default="1" />
<cfparam name="form.page" default="#url.page#" />
<cfparam name="url.start" default="0" />
<cfparam name="form.start" default="#url.start#" />
<cfparam name="url.rows" default="10" />
<cfparam name="form.rows" default="#url.rows#" />
--->

<!--- this will handle a traditional form post or url variable submission --->
<cfif len(trim(form.q))>
	<cfset stProperties = structNew() />
	<cfset stProperties.objectid = stObj.objectid />
	<cfset stProperties.q = form.q />
	<cfset stProperties.orderby = form.orderby />
	<cfset stProperties.operator = form.operator />
	<cfset stProperties.lContentTypes = form.lContentTypes />
	<!---
	<cfset stProperties.page = form.page />
	<cfset stProperties.start = form.start />
	<cfset stProperties.rows = url.rows />
	--->
	<cfset stproperties.bSearchPerformed = 1 />
	<cfset stResult = setData(stProperties = stProperties) />
</cfif>

<!--- this will handle a formtools form submission --->
<ft:processForm action="Search">
	<ft:processFormObjects objectid="#stobj.objectid#" typename="#stobj.typename#" bSessionOnly="true">
		<!--- TODO: determine page, start, rows values --->
	 <cfset stproperties.bSearchPerformed = 1 />
	</ft:processFormObjects>
</ft:processForm>

<cfset actionURL = application.fapi.getLink(
	objectid=stobj.objectid,
	view="displaySearch",
	includeDomain=true
) />

<cfoutput>
	<div id="searchPage"></cfoutput>

<!--- Render the search form and results #application.url.webroot#/index.cfm?objectid=#stobj.objectid#&view=displaySearch --->
<ft:form name="#stobj.typename#SearchForm"><!--- action="#actionURL#" --->

	<!--- Get the search Results --->
	<cfset oSearchService = application.fapi.getContentType("solrProSearch") />
	<cfset stSearchResult = oSearchService.getSearchResults(objectid = stobj.objectid, typename = stobj.typename) />

	<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchForm" />
	
	<cfif stSearchResult.bSearchPerformed>

<!--- TODO: Display total results
Total results: #stSearchResult.totalResults#
--->

<!---
		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchCount" stParam="#stSearchResult#" />--->
		
		<cfif structKeyExists(stSearchResult,"spellcheck")>
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchSuggestions" spellcheck="#stSearchResult.spellcheck#" />
		</cfif>
		
		<cfif arraylen(stSearchResult.results) GT 0>
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchResults" stParam="#stSearchResult#" />
		</cfif>
	<!---<cfelse>
		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchNoCriteria" stParam="#stSearchResult#" />--->
	</cfif>
	
</ft:form>

<cfoutput>
	</div></cfoutput>

<cfsetting enablecfoutputonly="false">