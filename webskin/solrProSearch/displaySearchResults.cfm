<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display Search Results --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="stParam.results" default="#arrayNew(1)#" />

<cfloop array="#stParam.results#" index="result">

	<skin:view webskin="displaySearchResult" typename="#result.typename#" stObject="#result#" />
	
</cfloop>
			
<cfsetting enablecfoutputonly="false" />