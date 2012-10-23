<cfcomponent output="false" extends="farcry.core.packages.forms.forms" displayname="Solr Pro Plugin" key="solrserver" hint="Configures Solr Server settings">
	
	<cfproperty ftSeq="105" ftFieldset="Server Setting" name="collectionName" type="nstring" default="" required="true" ftDefault="application.applicationName" ftDefaultType="evaluate" ftValidation="required" ftLabel="Collection Name" ftHint="For most installations the application name will suffice.  If you want a single collection used with multiple sites, you can use a custom collection name here. (default: applicationName)" />
	
	<cfproperty ftSeq="110" ftFieldset="Server Settings" name="host" type="nstring" default="" required="true" ftDefault="cgi.server_name" ftDefaultType="evaluate" ftType="string" ftValidation="required" ftLabel="Host" ftHint="The hostname of the server (default: current domain name)" />
	<cfproperty ftSeq="120" ftFieldset="Server Settings" name="port" type="nstring" default="8983" required="true" ftDefault="8983" ftType="string" ftValidation="required,digits" ftLabel="Port" ftHint="The port number of the server (default: 8983)" />
	<cfproperty ftSeq="130" ftFieldset="Server Settings" name="path" type="nstring" default="/solr" ftDefault="'/solr/' & application.applicationName" ftDefaultType="evaluate" required="true" ftType="string" ftValidation="required" ftLabel="Path" ftHint="The path to the solr instance & collection.  If you specified a collection name above, you should provide that here as well. (default: /solr/[application name], ex: /solr/mycollectionname)" />
	<cfproperty ftSeq="140" ftFieldset="Server Settings" name="queueSize" type="integer" default="100" required="true" ftDefault="100" ftType="integer" ftValidation="required,digits" ftLabel="Queue Size" ftHint="The buffer size before the documents are sent to the server (default: 100)" />
	<cfproperty ftSeq="150" ftFieldset="Server Settings" name="threadCount" type="integer" default="5" required="true" ftDefault="5" ftType="integer" ftValidation="required,digits" ftLabel="Thread Count" ftHint="The number of background threads used to empty the queue (default: 5)" />
	<cfproperty ftSeq="160" ftFieldset="Server Settings" name="binaryEnabled" type="boolean" default="1" required="true" ftDefault="1" ftType="boolean" ftLabel="Binary Enabled?" ftHint="Should we use the faster binary data transfer format? (default: true)" /> 
	<cfproperty ftSeq="170" ftFieldset="Server Settings" name="instanceDir" type="nstring" default="" ftDefault="expandPath('/farcry/projects/' & application.applicationName & '/solr')" ftDefaultType="evaluate" ftType="string" required="true" ftLabel="Solr Collection Instance Dir." ftHint="Choose a location with sufficient disk space for the collection." />
	
	<cfproperty ftSeq="210" ftFieldset="Performace Settings" name="batchSize" type="integer" default="5000" required="true" ftDefault="5000" ftType="integer" ftValidation="required" ftLabel="Index Batch Size" ftHint="The number of records that will be processed for each content type during the scheduled task. Default: 5000" />
	<cfproperty ftSeq="220" ftFieldset="Performace Settings" name="bLogSearches" type="boolean" default="1" required="true" ftDefault="1" ftType="boolean" ftLabel="Log Searches?" ftHint="Should searches be logged? Default: true" />
	
	<cfproperty ftSeq="310" ftFieldset="Boost Settings" name="lFieldBoostValues" ftLabel="Field Boost Values" type="longchar" ftType="longchar" default="1,2,3,5,10,15,20,50" ftDefault="1,2,3,5,10,15,20,50" required="true" ftHint="A comma separated list of numeric values to use for field boost dropdowns. Default: 1,2,3,5,10,15,20,50" />
	<cfproperty ftSeq="320" ftFieldset="Boost Settings" name="defaultBoostValue" type="numeric" ftType="numeric" default="5" ftDefault="5" ftLabel="Default Field Boost Value" required="true" ftHint="The default field boost value. Default: 5" />
	<cfproperty ftSeq="330" ftFieldset="Boost Settings" name="lDocumentBoostValues" type="longchar" ftType="longchar" default="0:Very Low (0),10:Low (10),25:Medium (25),40:High (40),50:Very High (50)" ftDefault="0:Very Low (0),10:Low (10),25:Medium (25),40:High (40),50:Very High (50)" ftLabel="Document Boost Values" required="true" ftHint="A comma separated list of values for the document boosts.  Should be in the format value:label. Example: 10:Low would have a value of 10 and a label of Low. Default: 0:Very Low (0),10:Low (10),25:Medium (25),40:High (40),50:Very High (50)" />
	<cfproperty ftSeq="335" ftFieldset="Boost Settings" name="defaultDocBoost" type="numeric" ftType="numeric" default="25" ftDefault="25" ftLabel="Default Document Boost Value" required="true" ftHint="The default document boost value.  Default: 25" />
	
	<cfproperty ftSeq="410" ftFieldset="Plugin Settings" name="pluginWebRoot" ftLabel="Plugin Web Root" type="nstring" ftType="string" default="/farcrysolrpro" ftDefault="application.fapi.getwebroot() & '/farcrysolrpro'" ftDefaultType="evaluate" required="true" ftValidation="required" ftHint="The url path to the plugin's www directory.  You should create a webserver alias to this directory, or copy the www directory to a 'farcrysolrpro' directory in the webroot." />
	
	<cfproperty name="bConfigured" type="boolean" ftType="hidden" default="0" required="true" hint="Flag to indicate that the user has configured the Solr server, this avoids creating folders and files using the default settings when FarCry is initialized." />
		
	<cffunction name="setupCollectionConfig" access="public" output="false" returntype="void" hint="Copies the collection configuration default templates to the collection conf directory.  Optionally, overwrites existing files.">
		<cfargument name="instanceDir" type="string" default="#application.fapi.getConfig(key = 'solrserver', name = 'instanceDir', default = expandPath('/farcry/projects/' & application.applicationName & '/solr'))#" />
		<cfargument name="bOverwrite" type="boolean" required="false" default="false" />
		
		<cfset var templateDir = expandPath("/farcry/plugins/farcrysolrpro/templates/") />
		<cfset var tempPath = "" />
		<cfset var subdir = "" />
		<cfset var sourcedir = "" />
		<cfset var destdir = "" />
		<cfset var qTemplateFiles = "" />
		
		<cfdirectory action="list" directory="#templateDir#" recurse="true" name="qTemplateFiles" type="file" />
		
		<cfloop query="qTemplateFiles">
			
			<cfset subdir = replace(qTemplateFiles.directory[qTemplateFiles.currentRow], templateDir, "", "one") />
			
			<cfif subdir eq qTemplateFiles.directory[qTemplateFiles.currentRow]>
				<cfset subdir = "" />
			</cfif>
		
			<cfset sourcedir = templateDir & "/" & subdir />
			<cfset destdir = arguments.instanceDir & "/" & subdir />
			
			<!--- create the dest directory if it doesn't exist --->
			<cfif not directoryExists(destdir)>
				<cfdirectory action="create" directory="#destdir#" mode="777" />
			</cfif>
			
			<!--- Copy the config file if applicable --->
			<cfif arguments.bOverwrite or not fileExists("#destdir#/#qTemplateFiles.name[qTemplateFiles.currentRow]#")>
				<cffile action="copy" source="#qTemplateFiles.directory[qTemplateFiles.currentRow]#/#qTemplateFiles.name[qTemplateFiles.currentRow]#" destination="#destdir#/#qTemplateFiles.name[qTemplateFiles.currentRow]#" mode="777" />
			</cfif>
		
		</cfloop>

	</cffunction>
	
	<cffunction name="setupInstanceDir" access="public" output="false" returntype="void" hint="Creates the instance directory">
		<cfargument name="instanceDir" type="string" default="#application.fapi.getConfig(key = 'solrserver', name = 'instanceDir', default = expandPath('/farcry/projects/' & application.applicationName & '/solr'))#" />
		<cfargument name="bReset" type="boolean" required="false" default="false" />
		
		<cfif arguments.bReset and directoryExists(arguments.instanceDir)>
			<cfset directoryDelete(arguments.instanceDir, true) />
		</cfif>
		
		<!--- ensure instanceDir exists --->
		<cfif not directoryExists(arguments.instanceDir)>
			<cfdirectory action="create" directory="#arguments.instanceDir#" mode="777" />
		</cfif>
		
		<!--- ensure collection directories exist --->
		<cfif not directoryExists(arguments.instanceDir & "/conf")>
			<cfdirectory action="create" directory="#arguments.instanceDir#/conf" mode="777" />
		</cfif>
		<cfif not directoryExists(arguments.instanceDir & "/data")>
			<cfdirectory action="create" directory="#arguments.instanceDir#/data" mode="777" />
		</cfif>

	</cffunction>
	
	<cffunction name="createCore" access="private" returntype="void" output="false">
		<cfargument name="config" required="false" type="struct" default="#application.fapi.getContentType('farConfig').getConfig(key = 'solrserver')#" />
		<cfset var host = arguments.config.host />
		<cfset var port = arguments.config.port />
		<cfset var collectionName = arguments.config.collectionName />
		<cfset var instanceDir = arguments.config.instanceDir />
		<cfset var uri = "http://" & host & ":" & port & "/solr/admin/cores?action=CREATE&name=" & collectionName & "&instanceDir=" & instanceDir & "&persist=true" />
		<cfhttp url="#uri#" method="get" />
	</cffunction>
	
	<cffunction name="coreExists" access="private" returntype="boolean" output="false">
		<cfargument name="config" required="false" type="struct" default="#application.fapi.getContentType('farConfig').getConfig(key = 'solrserver')#" />
		<cfset var host = arguments.config.host />
		<cfset var port = arguments.config.port />
		<cfset var collectionName = arguments.config.collectionName />
		<cfset var instanceDir = arguments.config.instanceDir />
		<cfset var uri = "http://" & host & ":" & port & "/solr/admin/cores?action=STATUS&core=" & collectionName />
		<cfset var httpResult = "" />
		<cfhttp url="#uri#" method="get" result="httpResult" timeout="10" />
		<cfif httpResult.statusCode contains "200">
			<cfset var xml = xmlParse(httpResult.fileContent) />
			<cfset var matches = xmlSearch(xml,"/response/lst[@name='status']/lst[@name='#collectionName#']/str[@name='name']") />
			<cfreturn arrayLen(matches) />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="setupSolrDefaults" access="public" output="false" returntype="void" hint="Resets the Solr.xml file, instance directory and collection configuration">
		<cfargument name="config" required="false" type="struct" default="#application.fapi.getContentType('farConfig').getConfig(key = 'solrserver')#" />
		
		<cfset var instanceDir = arguments.config.instanceDir />

		<!--- ensure instanceDir exists --->
		<cfset setupInstanceDir(directory = instanceDir) />
		
		<!--- copy template config files if necessary --->
		<cfset setupCollectionConfig(directory = instanceDir) />
		
		<!--- create/update the core --->
		<cfif application.fapi.getContentType("solrProContentType").isSolrRunning(config = arguments.config)>
			<cfif coreExists(config = arguments.config)>
				<cfset application.fapi.getContentType("solrProContentType").reload(config = arguments.config) />
			<cfelse>
				<cfset createCore(config = arguments.config) />
			</cfif>
		<cfelse>
			<!--- warn the user that the Solr server is not responding. --->
			<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
			<skin:bubble title='Solr Server not responding' sticky='true' message='http://#arguments.config.host#:#arguments.config.port# #arguments.config.path#<br />Be sure that Solr is running and you have specified the configuration correctly.  You will need to update the configuration again.' />
		</cfif>
		
	</cffunction>
	
	<cffunction name="setupSolrLibrary" access="public" output="false" returntype="void" hint="Sets up CFSolrLib">
		<cfargument name="fields" type="struct" required="false" default="#structNew()#" />
		
		<cfif structCount(arguments.fields) eq 0>
			<cfset arguments.fields = application.fapi.getContentType("farConfig").getConfig(key = 'solrserver') />
		</cfif>
		
		<cfparam name="application.stPlugins.farcrysolrpro" default="#structNew()#" />
		
		<cfscript>
			
			// setup javaloader
			var solrjLibPath = "/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solrj-lib/";
			application.stPlugins["farcrysolrpro"].javaloader = createObject("component","farcry.plugins.farcrysolrpro.packages.custom.cfsolrlib.javaloader.JavaLoader").init(
				loadPaths = [	
					expandPath(solrjLibPath & "apache-solr-solrj-3.5.0.jar"),
					expandPath("/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/lib/tika-app-1.2.jar")
				],
				loadColdFusionClassPath = true
			);	
			// setup tika (note do not use this copy of tika for OpenXML files (http://en.wikipedia.org/wiki/Office_Open_XML), you must switch out the class loader, see https://github.com/markmandel/JavaLoader/wiki/Switching-the-ThreadContextClassLoader)
			application.stPlugins["farcrysolrpro"].tika = application.stPlugins["farcrysolrpro"].javaloader.create("org.apache.tika.Tika").init();
			
    		// setup cfsolrlib
    		application.stPlugins["farcrysolrpro"].cfsolrlib = createObject("component", "farcry.plugins.farcrysolrpro.packages.custom.cfsolrlib.components.cfsolrlib").init(
				javaloaderInstance = application.stPlugins["farcrysolrpro"].javaloader,
				host = arguments.fields["host"],
				port = arguments.fields["port"],
				path = arguments.fields["path"],
				queueSize = arguments.fields["queueSize"],
				threadCount = arguments.fields["threadCount"],
				binaryEnabled = arguments.fields["binaryEnabled"]
			);
			
		</cfscript>
		
	</cffunction> 
	
	<cffunction name="process" access="public" output="false" returntype="struct">
		<cfargument name="fields" type="struct" required="true" />
		
		<!--- only run if the config has been set at least once, manually --->
		<cfif arguments.fields.bConfigured eq 1>
			
			<!--- set up javaloader and cfsolrlib --->	
			<cfset setupSolrLibrary(fields = arguments.fields) />
			
			<!--- ensure solr is properly set up --->
			<cfset setupSolrDefaults(config = arguments.fields) />
			
		</cfif>
		
		<cfreturn super.process(argumentCollection = arguments) />
	</cffunction>

</cfcomponent>