<cfsetting enablecfoutputonly="true" />

<!--- @@displayname: Search Results Page --->
<!--- @@author: Geoff Bowers (modius@daemon.com.au) --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif isDefined("request.stObj.title")>
	<cfoutput><h1>#request.stObj.title#</h1></cfoutput>
<cfelse>
	<cfoutput><h1>Search</h1></cfoutput>
</cfif>

<skin:view typename="#stobj.name#" key="SearchForm" webskin="displaySearch" />


<cfsetting enablecfoutputonly="false" />