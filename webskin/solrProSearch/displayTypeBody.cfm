<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Search Result --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="url.q" default="" />

<cfif trim(url.q) eq "">
	<cfif isDefined("request.stObj.title")>
		<cfset newPageTitle = application.stPlugins.farcrysolrpro.oCustomFunctions.xmlSafeText(request.stObj.title) />
	<cfelse>
		<cfset newPageTitle = "Search" />
	</cfif>
<cfelse>
	<cfset newPageTitle = application.stPlugins.farcrysolrpro.oCustomFunctions.xmlSafeText('Search Results for "#trim(url.q)#"') />
</cfif>

<cfoutput><h1>#newPageTitle#</h1></cfoutput>

<skin:view typename="#stobj.name#" key="SearchForm" webskin="displaySearch" />

<cfsetting enablecfoutputonly="false" />