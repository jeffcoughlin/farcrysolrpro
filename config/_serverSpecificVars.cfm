<cfsetting enablecfoutputonly="true" />

<cfscript>
	paths = arrayNew(1);
	arrayAppend(paths,expandPath("/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solrj-lib/commons-io-1.4.jar"));
	arrayAppend(paths,expandPath("/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solrj-lib/commons-codec-1.4.jar"));
	arrayAppend(paths,expandPath("/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solrj-lib/slf4j-api-1.5.5.jar"));
	arrayAppend(paths,expandPath("/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solrj-lib/slf4j-jdk14-1.5.5.jar"));
	arrayAppend(paths,expandPath("/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solrj-lib/commons-httpclient-3.1.jar"));
	arrayAppend(paths,expandPath("/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solrj-lib/apache-solr-solrj-3.2.0.jar"));
	arrayAppend(paths,expandPath("/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solrj-lib/geronimo-stax-api_1.0_spec-1.0.1.jar"));
	arrayAppend(paths,expandPath("/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solrj-lib/wstx-asl-3.2.7.jar"));
	arrayAppend(paths,expandPath("/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solrj-lib/jcl-over-slf4j-1.5.5.jar"));
</cfscript>

<cfset javaloader = createObject("component","farcry.plugins.farcrysolrpro.packages.custom.cfsolrlib.javaloader.JavaLoader").init(paths) />

<cfset application.stPlugins["farcrysolrpro"] = {} />
<cfset application.stPlugins["farcrysolrpro"].cfsolrlib = createObject("component", "farcry.plugins.farcrysolrpro.packages.custom.cfsolrlib.components.cfsolrlib").init(
	javaloaderInstance = javaloader,
	host = application.fapi.getConfig(key = "solrserver", name = "host", default = "localhost"),
	port = application.fapi.getConfig(key = "solrserver", name = "port", default = "8983"),
	path = application.fapi.getConfig(key = "solrserver", name = "path", default = "/solr"),
	queueSize = application.fapi.getConfig(key = "solrserver", name = "queueSize", default = 100),
	threadCount = application.fapi.getConfig(key = "solrserver", name = "threadCount", default = 5),
	binaryEnabled = application.fapi.getConfig(key = "solrserver", name = "binaryEnabled", default = true)
) />

<cfsetting enablecfoutputonly="false" />