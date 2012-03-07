<cfsetting enablecfoutputonly="true" />

<cfparam name="application.stPlugins.farcrysolrpro" default="#structNew()#" />

<!--- if Solr has been configured, check that the collection and solr.xml has been set up --->
<cfif application.fapi.getConfig(key = "solrserver", name = "bConfigured", default = 0)>
	
	<cfset oConfigSolrServer = application.fapi.getContentType("configSolrServer") />

	<cfset oConfigSolrServer.setupSolrLibrary() />
	
</cfif>

<cfset application.stPlugins.farcrysolrpro.oCustomFunctions = createObject("component","farcry.plugins.farcrysolrpro.packages.custom.customFunctions") />
<cfset application.stPlugins.farcrysolrpro.oManifest = createObject("component","farcry.plugins.farcrysolrpro.install.manifest") />

<!--- clear all field name list caches --->
<cftry>
	<cfset application.fapi.getContentType("solrProContentType").clearAllFieldListCaches() />
	<cfcatch>
		<!--- most likely the content type has not been deployed yet, so there is nothing to do here --->
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="false" />