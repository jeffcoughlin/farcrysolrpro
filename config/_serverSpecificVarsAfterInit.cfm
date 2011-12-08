<cfsetting enablecfoutputonly="true" />

<!--- if Solr has been configured, check that the collection and solr.xml has been set up --->
<cfif application.fapi.getConfig(key = "solrserver", name = "bConfigured", default = 0)>
	
	<cfset oConfigSolrServer = application.fapi.getContentType("configSolrServer") />

	<cfset oConfigSolrServer.setupSolrLibrary() />
	
</cfif>

<cfsetting enablecfoutputonly="false" />