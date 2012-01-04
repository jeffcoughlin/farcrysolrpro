<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Current Index Count --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cftry>
	<cfoutput>#getRecordCountForType(typename = stobj.contentType)#</cfoutput>
	<cfcatch>
		<cfoutput>Solr Unavailable</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="false" />