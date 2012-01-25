<cfsetting enablecfoutputonly="true" />

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

<cfif structKeyExists(form,"paginationpage")>
	<cfset form.page = form.paginationpage />
</cfif>

<cfparam name="url.page" default="1" />
<cfparam name="form.page" default="#url.page#" />

<cfif not isNumeric(form.page)>
	<cfset form.page = 1 />
</cfif>

<!--- number of records to display per page --->
<cfset rows = 10 />

<!--- number of page links to display --->
<cfset pageLinks = 5 />

<!--- suggestion threshold --->
<cfset suggestionThreshold = rows />

<!--- this will handle a traditional form post or url variable submission --->
<cfif len(trim(form.q))>
	<cfset stProperties = structNew() />
	<cfset stProperties.objectid = stObj.objectid />
	<cfset stProperties.q = form.q />
	<cfset stProperties.orderby = form.orderby />
	<cfset stProperties.operator = form.operator />
	<cfset stProperties.lContentTypes = form.lContentTypes />
	<cfset stproperties.bSearchPerformed = 1 />
	<cfset stResult = setData(stProperties = stProperties) />
	<!--- update the stobj to reflect the most recent info --->
	<cfset stobj = getData(stProperties.objectid) />
</cfif>

<cfoutput>
	<div id="searchPage"></cfoutput>

	<!--- Render the search form --->
	<skin:view stObject="#stobj#" webskin="displaySearchForm" />
		
	<!--- Get the search Results --->
	<cfset oSearchService = application.fapi.getContentType("solrProSearch") />
	<cfif form.operator eq "nofilter">
		<cfset bCleanString = false />
	<cfelse>
		<cfset bCleanString = true />
	</cfif>
	<cfset stSearchResult = oSearchService.getSearchResults(objectid = stobj.objectid, typename = stobj.typename, page = form.page, rows = rows, bCleanString = bCleanString) />

	<cfif stSearchResult.bSearchPerformed>
		
		<!--- display results --->
		
		<skin:view 
			stobject="#stobj#" 
			webskin="displaySearchCount" 
			totalResults="#stSearchResult.totalResults#"
			qTime="#stSearchResult.qTime#" />
		
		<cfif structKeyExists(stSearchResult,"spellcheck") and arrayLen(stSearchResult.spellcheck)>
			<skin:view  
				stObject="#stobj#" 
				webskin="displaySearchSuggestions" 
				suggestion="#stSearchResult.suggestion#" />
		</cfif>
		
		<cfif arraylen(stSearchResult.results) GT 0>
			<cfparam name="stSearchResult.highlighting" default="#structnew()#" />
			<skin:view 
				stObject="#stobj#" 
				webskin="displaySearchResults" 
				results="#stSearchResult.results#"
				highlighting="#stSearchResult.highlighting#" 
				totalResults="#stSearchResult.totalResults#" 
				pageLinks="#pageLinks#" 
				currentPage="#form.page#" 
				rows="#rows#" />
		</cfif>

	</cfif>
	
<cfoutput>
	</div></cfoutput>

<cfsetting enablecfoutputonly="false">