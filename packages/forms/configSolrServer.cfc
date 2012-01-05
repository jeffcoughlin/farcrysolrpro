<cfcomponent output="false" extends="farcry.core.packages.forms.forms" displayname="Solr Pro Plugin" key="solrserver" hint="Configures Solr Server settings">
	
	<cfproperty ftSeq="110" ftFieldset="Server Settings" name="host" type="nstring" default="localhost" required="true" ftDefault="localhost" ftType="string" ftValidation="required" ftLabel="Host" ftHint="The hostname of the server (default: localhost)" />
	<cfproperty ftSeq="120" ftFieldset="Server Settings" name="port" type="nstring" default="8983" required="true" ftDefault="8983" ftType="string" ftValidation="required,digits" ftLabel="Port" ftHint="The port number of the server (default: 8983)" />
	<cfproperty ftSeq="130" ftFieldset="Server Settings" name="path" type="nstring" default="/solr" ftDefault="'/solr/' & application.applicationName" ftDefaultType="evaluate" required="true" ftType="string" ftValidation="required" ftLabel="Path" ftHint="The path to the solr instance & collection (default: /solr/[application name])" />
	<cfproperty ftSeq="140" ftFieldset="Server Settings" name="queueSize" type="integer" default="100" required="true" ftDefault="100" ftType="integer" ftValidation="required,digits" ftLabel="Queue Size" ftHint="The buffer size before the documents are sent to the server (default: 100)" />
	<cfproperty ftSeq="150" ftFieldset="Server Settings" name="threadCount" type="integer" default="5" required="true" ftDefault="5" ftType="integer" ftValidation="required,digits" ftLabel="Thread Count" ftHint="The number of background threads used to empty the queue (default: 5)" />
	<cfproperty ftSeq="160" ftFieldset="Server Settings" name="binaryEnabled" type="boolean" default="1" required="true" ftDefault="1" ftType="boolean" ftLabel="Binary Enabled?" ftHint="Should we use the faster binary data transfer format? (default: true)" /> 
	<cfproperty ftSeq="170" ftFieldset="Server Settings" name="instanceDir" type="nstring" default="" ftDefault="expandPath('/farcry/projects/' & application.applicationName & '/solr')" ftDefaultType="evaluate" ftType="string" required="true" ftLabel="Solr Collection Instance Dir." ftHint="Choose a location with sufficient disk space for the collection." />
	<cfproperty ftSeq="180" ftFieldset="Server Settings" name="solrXmlLocation" type="nstring" default="" ftDefault="expandPath('/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solr-server/multicore/solr.xml')" ftDefaultType="evaluate" required="true" ftLabel="Solr.xml File Location" ftHint="This must be in the Solr Home directory." />
	
	<cfproperty ftSeq="210" ftFieldset="Performace Settings" name="batchSize" type="integer" default="1000" required="true" ftDefault="1000" ftType="integer" ftValidation="required" ftLabel="Index Batch Size" ftHint="The number of records that will be processed for each content type during the scheduled task. Default: 1000" />
	
	<cfproperty ftSeq="310" ftFieldset="Boost Settings" name="lFieldBoostValues" ftLabel="Field Boost Values" type="longchar" ftType="longchar" default="1,2,3,5,10,15,20,50" ftDefault="1,2,3,5,10,15,20,50" required="true" ftHint="A comma separated list of numeric values to use for field boost dropdowns. Default: 1,2,3,5,10,15,20,50" />
	<cfproperty ftSeq="320" ftFieldset="Boost Settings" name="defaultBoostValue" type="numeric" ftType="numeric" default="5" ftDefault="5" ftLabel="Default Boost Value" required="true" ftHint="The default field boost value. Default: 5" />
	<cfproperty ftSeq="330" ftFieldset="Boost Settings" name="lDocumentBoostValues" type="longchar" ftType="longchar" default="10:Low (10),20:Medium (20),30:High (30)" ftDefault="10:Low (10),20:Medium (20),30:High (30)" ftLabel="Document Boost Values" required="true" ftHint="A comma separated list of values for the document boosts.  Should be in the format value:label. Example: 10:Low would have a value of 10 and a label of Low. Default: 10:Low (10),20:Medium (20),30:High (30)" />
	
	<cfproperty name="bConfigured" type="boolean" ftType="hidden" default="0" required="true" hint="Flag to indicate that the user has configured the Solr server, this avoids creating folders and files using the default settings when FarCry is initialized." />
	
	<cffunction name="setupCollectionConfig" access="public" output="false" returntype="void" hint="Copies the collection configuration default templates to the collection conf directory.  Optionally, overwrites existing files.">
		<cfargument name="bOverwrite" type="boolean" required="false" default="false" />
		
		<cfset var instanceDir = application.fapi.getConfig(key = "solrserver", name = "instanceDir") />
		<cfset var aTemplateFolders = ["conf","data"] />
		<cfset var templateFolder = "" />
		
		<cfset var templateDir = expandPath("/farcry/plugins/farcrysolrpro/templates/conf") />
		<cfset var qTemplateFiles = "" />
		<cfset var destdir = instanceDir & "/conf" />
		
		<!--- copy schema and other config files to conf directory --->
		<cfloop array="#aTemplateFolders#" index="templateFolder">
			<cfset var templateDir = expandPath("/farcry/plugins/farcrysolrpro/templates/#templateFolder#") />
			<cfset var qTemplateFiles = "" />
			<cfset var destdir = instanceDir & "/#templateFolder#" />
			
			<cfdirectory action="list" directory="#templateDir#" recurse="true" name="qTemplateFiles" type="file" />
	
			<cfloop query="qTemplateFiles">
			    <!--- get the subdir under source dir if there --->
			    <cfset var subdir = replace(directory, templateDir, "") />
			    <cfif len(subdir)>
			        <!--- create the dir in dest if not there --->
			        <cfif not directoryExists(destdir & "/" & subdir)>
			            <cfdirectory action="create" directory="#destdir#/#subdir#" mode="777" />
			        </cfif>
			    </cfif>
			    <cfif arguments.bOverwrite or not fileExists("#destdir#/#subdir#/#name#")>
					<cflog application="true" log="configSolrServer" type="information" text="copying file to #destdir#/#subdir#/#name#" />
			    	<cffile action="copy" source="#directory#/#name#" destination="#destdir#/#subdir#/#name#" mode="777" />
				<cfelse>
					<cflog application="true" log="configSolrServer" type="information" text="skipping file #destdir#/#subdir#/#name#" />
				</cfif>
			</cfloop>			
		</cfloop>
		
	</cffunction>
	
	<cffunction name="setupInstanceDir" access="public" output="false" returntype="void" hint="Creates the instance directory">
		<cfargument name="bReset" type="boolean" required="false" default="false" />
		
		<cfset var instanceDir = application.fapi.getConfig(key = "solrserver", name = "instanceDir") />
		
		<cfif arguments.bReset and directoryExists(instanceDir)>
			<cfset directoryDelete(instanceDir, true) />
		</cfif>
		
		<!--- ensure instanceDir exists --->
		<cfif not directoryExists(instanceDir)>
			<cfdirectory action="create" directory="#instanceDir#" mode="777" />
		</cfif>
		
		<!--- ensure collection directories exist --->
		<cfif not directoryExists(instanceDir & "/conf")>
			<cfdirectory action="create" directory="#instanceDir#/conf" mode="777" />
		</cfif>
		<cfif not directoryExists(instanceDir & "/data")>
			<cfdirectory action="create" directory="#instanceDir#/data" mode="777" />
		</cfif>
		
	</cffunction>
	
	<cffunction name="setupSolrDefaults" access="public" output="false" returntype="void" hint="Resets the Solr.xml file, instance directory and collection configuration">
		<cfargument name="config" required="false" type="struct" default="#application.fapi.getContentType('farConfig').getConfig(key = 'solrserver')#" />
		
		<cfset var instanceDir = arguments.config.instanceDir />
		<cfset var solrXmlLocation = arguments.config.solrXmlLocation />
		<cfset var solrXml = "" />
		
		<!--- ensure solr.xml exists --->
		<cfif not fileExists(solrXmlLocation)>
			<cfsavecontent variable="solrXml"><cfoutput><?xml version='1.0' encoding='UTF-8'?>
				<solr persistent='true'>
					<cores adminPath='/admin/cores'>
						<core name='#application.applicationName#' instanceDir='#instanceDir#'/>
					</cores>
				</solr>
				</cfoutput>
			</cfsavecontent>
			<cfset fileWrite(solrXmlLocation, trim(solrXml)) />
		<cfelse>
			
			<!--- ensure collection is defined in solr.xml --->
			<cfset var solrXml = fileRead(solrXmlLocation) />
			
			<cfset var results = xmlSearch(xmlParse(solrXml),"//core[@name='#application.applicationName#']") />
			
			<cfif arrayLen(results) eq 0>
				
				<!--- collection is NOT in solr.xml, add it --->
					
				<cfset var insertPos = findNoCase("</cores>",solrXml) - 1 />
				<cfset var startXml = left(solrXml, insertPos) />
				<cfset var newXml = "<core name='#application.applicationName#' instanceDir='#instanceDir#'/>" />
				<cfset var endXml = mid(solrXml,insertPos,len(solrXml) - len(startXml) + 1) />
				<cfset solrXml = indentXml(trim(startXml & newXml & endXml)) />
				
				<cfset fileWrite(solrXmlLocation, solrXml) />
				
			</cfif>
			
		</cfif>
		
		<!--- ensure instanceDir exists --->
		<cfset setupInstanceDir() />
		
		<!--- copy template config files if necessary --->
		<cfset setupCollectionConfig() />
		
	</cffunction>
	
	<cffunction name="setupSolrLibrary" access="public" output="false" returntype="void" hint="Sets up CFSolrLib">
		<cfargument name="fields" type="struct" required="false" default="#structNew()#" />
		
		<cfif structCount(arguments.fields) eq 0>
			<cfset arguments.fields = application.fapi.getContentType("farConfig").getConfig(key = 'solrserver') />
		</cfif>
		
		<cfscript>
			
			application.stPlugins["farcrysolrpro"] = {};
			
			// setup javaloader
			var solrjLibPath = "/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/solrj-lib/";
			application.stPlugins["farcrysolrpro"].javaloader = createObject("component","farcry.plugins.farcrysolrpro.packages.custom.cfsolrlib.javaloader.JavaLoader").init(
				loadPaths = [
					expandPath(solrjLibPath & "commons-io-1.4.jar"),
					expandPath(solrjLibPath & "commons-codec-1.5.jar"),
					expandPath(solrjLibPath & "slf4j-api-1.6.1.jar"),
					expandPath(solrjLibPath & "slf4j-jdk14-1.6.1.jar"),
					expandPath(solrjLibPath & "commons-httpclient-3.1.jar"),
					expandPath(solrjLibPath & "apache-solr-solrj-3.5.0.jar"),
					expandPath(solrjLibPath & "geronimo-stax-api_1.0_spec-1.0.1.jar"),
					expandPath(solrjLibPath & "wstx-asl-3.2.7.jar"),
					expandPath(solrjLibPath & "jcl-over-slf4j-1.6.1.jar"),
					expandPath("/farcry/plugins/farcrysolrpro/packages/custom/cfsolrlib/lib/tika-app-1.0.jar")
				],
				loadColdFusionClassPath = true
			);
			
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
		
	<!---
	 indentXml pretty-prints XML and XML-like markup without requiring valid XML.
	 
	 @param xml 	 XML string to format. (Required)
	 @param indent 	 String used for creating the indention. Defaults to a space. (Optional)
	 @return Returns a string. 
	 @author Barney Boisvert (&#98;&#98;&#111;&#105;&#115;&#118;&#101;&#114;&#116;&#64;&#103;&#109;&#97;&#105;&#108;&#46;&#99;&#111;&#109;) 
	 @version 2, July 30, 2010 
	--->
	<cffunction name="indentXml" output="false" returntype="string" access="private">
	  <cfargument name="xml" type="string" required="true" />
	  <cfargument name="indent" type="string" default="  "
	    hint="The string to use for indenting (default is two spaces)." />
	  <cfset var lines = "" />
	  <cfset var depth = "" />
	  <cfset var line = "" />
	  <cfset var isCDATAStart = "" />
	  <cfset var isCDATAEnd = "" />
	  <cfset var isEndTag = "" />
	  <cfset var isSelfClose = "" />
	  <cfset var i = "" />
	  <cfset xml = trim(REReplace(xml, "(^|>)\s*(<|$)", "\1#chr(10)#\2", "all")) />
	  <cfset lines = listToArray(xml, chr(10)) />
	  <cfset depth = 0 />
	  <cfloop from="1" to="#arrayLen(lines)#" index="i">
	    <cfset line = trim(lines[i]) />
	    <cfset isCDATAStart = left(line, 9) EQ "<![CDATA[" />
	    <cfset isCDATAEnd = right(line, 3) EQ "]]>" />
	    <cfif NOT isCDATAStart AND NOT isCDATAEnd AND left(line, 1) EQ "<" AND right(line, 1) EQ ">">
	      <cfset isEndTag = left(line, 2) EQ "</" />
	      <cfset isSelfClose = right(line, 2) EQ "/>" OR REFindNoCase("<([a-z0-9_-]*).*</\1>", line) />
	      <cfif isEndTag>
	        <!--- use max for safety against multi-line open tags --->
	        <cfset depth = max(0, depth - 1) />
	      </cfif>
	      <cfset lines[i] = repeatString(indent, depth) & line />
	      <cfif NOT isEndTag AND NOT isSelfClose>
	        <cfset depth = depth + 1 />
	      </cfif>
	    <cfelseif isCDATAStart>
	      <!---
	      we don't indent CDATA ends, because that would change the
	      content of the CDATA, which isn't desirable
	      --->
	      <cfset lines[i] = repeatString(indent, depth) & line />
	    </cfif>
	  </cfloop>
	  <cfreturn arrayToList(lines, chr(10)) />
	</cffunction>
		
</cfcomponent>