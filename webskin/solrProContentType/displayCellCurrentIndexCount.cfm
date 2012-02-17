<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Current Index Count --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif application.fapi.getContentType("solrProContentType").isSolrRunning()>
	<cfoutput>#getRecordCountForType(typename = stobj.contentType)#</cfoutput>
<cfelse>
	<cfoutput>[Solr Unavailable]</cfoutput>
</cfif>
	
<cfsetting enablecfoutputonly="false" />