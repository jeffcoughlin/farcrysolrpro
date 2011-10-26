<cfsetting enablecfoutputonly="true" />

<cfset solrConfig = {
	host = application.fapi.getConfig(key = "solrserver", name = "host", default = "localhost"),
	port = application.fapi.getConfig(key = "solrserver", name = "port", default = "8983"),
	path = application.fapi.getConfig(key = "solrserver", name = "path", default = "/solr"),
	queueSize = application.fapi.getConfig(key = "solrserver", name = "queueSize", default = 100),
	threadCount = application.fapi.getConfig(key = "solrserver", name = "threadCount", default = 5),
	binaryEnabled = application.fapi.getConfig(key = "solrserver", name = "binaryEnabled", default = true)
} />

<cfset oSolrServerConfig = createObject("component", "farcry.plugins.farcrysolrpro.packages.forms.configSolrServer").process(fields = solrConfig) />

<cfsetting enablecfoutputonly="false" />