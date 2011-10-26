<cfcomponent output="false" extends="farcry.core.packages.forms.forms" displayname="Solr Server" key="solrserver" hint="Configures Solr Server settings">
	
	<cfproperty ftSeq="110" ftFieldset="Solr Server" name="host" type="nstring" default="localhost" required="true" ftDefault="localhost" ftType="string" ftValidation="required" ftLabel="Host" ftHint="The hostname of the server (default: localhost)" />
	<cfproperty ftSeq="120" ftFieldset="Solr Server" name="port" type="nstring" default="8983" required="true" ftDefault="8983" ftType="string" ftValidation="required,digits" ftLabel="Port" ftHint="The port number of the server (default: 8983)" />
	<cfproperty ftSeq="130" ftFieldset="Solr Server" name="path" type="nstring" default="/solr" required="true" ftDefault="/solr" ftType="string" ftValidation="required" ftLabel="Path" ftHint="The path to the solr instance (default: /solr)" />
	<cfproperty ftSeq="140" ftFieldset="Solr Server" name="queueSize" type="integer" default="100" required="true" ftDefault="100" ftType="integer" ftValidation="required,digits" ftLabel="Queue Size" ftHint="The buffer size before the documents are sent to the server (default: 100)" />
	<cfproperty ftSeq="150" ftFieldset="Solr Server" name="threadCount" type="integer" default="5" required="true" ftDefault="5" ftType="integer" ftValidation="required,digits" ftLabel="Thread Count" ftHint="The number of background threads used to empty the queue (default: 5)" />
	<cfproperty ftSeq="160" ftFieldset="Solr Server" name="binaryEnabled" type="boolean" default="1" required="true" ftDefault="1" ftType="boolean" ftLabel="Binary Enabled?" ftHint="Should we use the faster binary data transfer format? (default: true)" /> 
	
	<cffunction name="process" access="public" output="false" returntype="struct">
		<cfargument name="fields" type="struct" required="true" />
		
		<cfscript>
			var paths = [];
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

		<cfset var javaloader = createObject("component","farcry.plugins.farcrysolrpro.packages.custom.cfsolrlib.javaloader.JavaLoader").init(paths) />

		<cfset application.stPlugins["farcrysolrpro"] = {} />
		<cfset application.stPlugins["farcrysolrpro"].cfsolrlib = createObject("component", "farcry.plugins.farcrysolrpro.packages.custom.cfsolrlib.components.cfsolrlib").init(
			javaloaderInstance = javaloader,
			host = arguments.fields["host"],
			port = arguments.fields["port"],
			path = arguments.fields["path"],
			queueSize = arguments.fields["queueSize"],
			threadCount = arguments.fields["threadCount"],
			binaryEnabled = arguments.fields["binaryEnabled"]
		) />
		
		<cfreturn super.process(argumentCollection = arguments) />
	</cffunction>
	
</cfcomponent>