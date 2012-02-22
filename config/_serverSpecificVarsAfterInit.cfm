<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="application.stPlugins.farcrysolrpro" default="#structNew()#" />

<!--- if Solr has been configured, check that the collection and solr.xml has been set up --->
<cfif application.fapi.getConfig(key = "solrserver", name = "bConfigured", default = 0)>
	
	<cfset oConfigSolrServer = application.fapi.getContentType("configSolrServer") />

	<cfset oConfigSolrServer.setupSolrLibrary() />
	
</cfif>

<cfset application.stPlugins.farcrysolrpro.oCustomFunctions = createObject("component","farcry.plugins.farcrysolrpro.packages.custom.customFunctions") />
<cfset application.stPlugins.farcrysolrpro.oManifest = createObject("component","farcry.plugins.farcrysolrpro.install.manifest") />

<skin:registerCss id="solrPro-customWebtopStyles" media="all" baseHref="#application.fapi.getConfig(key = 'solrserver', name = 'pluginWebRoot')#/css" lFiles="customWebtopStyles.css" />

<cfsetting enablecfoutputonly="false" />