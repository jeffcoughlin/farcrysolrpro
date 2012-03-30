<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Documentation - How To  --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<admin:header title="Solr Pro: How To" />

<cfset linkConfig = application.url.webtop & "/admin/customadmin.cfm?module=customlists/farConfig.cfm" />
<cfset linkPluginHome = "http://jeffcoughlin.github.com/farcrysolrpro/" />
<cfset linkPluginInstall = "http://jeffcoughlin.github.com/farcrysolrpro/documentation.html" />

<cfoutput>
	<img src="#application.fapi.getConfig(key = 'solrserver', name = 'pluginWebRoot')#/css/images/logo-farcrySolrPro-75.png" style="margin-top: 30px;" />
	<img src="#application.fapi.getConfig(key = 'solrserver', name = 'pluginWebRoot')#/css/images/logo-apacheSolr-75.png" style="float: right;" />
	<h1>Detailed Installation and Setup Help</h1>
	<p>For detailed installation and configuration assistance, please see the <a href="#linkPluginInstall#">plugin's website</a>.</p>
	<h1>Minimum Requirements</h1>
	<ul>
		<li>ColdFusion 9</li>
		<li>FarCry 6.2, 6.1.4, 6.0.19</li>
		<li>Solr 3.5
			<ul>
				<li>Solr 3.5 is optionally included in this plugin.</li>
				<li>To date, we have only tested this on Solr 3.5</li>
			</ul>
		</li>
		<li>Although Solr can run from a separate server, FarCry needs directory access to the conf files (schema.xml, solrconfig.cml, etc) as well as the solr.xml file found in the root of the Solr server engine.  So if you plan to run Solr on a separate server you'll need to setup a mapped network drive for FarCry to use (and then set those settings in the <a href="#linkConfig#">Solr Pro Config</a>).
			<ul>
				<li>Note: Running Solr on a separate machine can result in slower response times if the network is not properly configured.  Please keep in mind that Solr uses HTTP requests to send and recieve JSON/XML (we use JSON in our plugin) strings of data back and forth.  In most cases, it is faster to run Solr on the same box.  Reasons for running it on a separate box are usually due to HDD space limiation, and/or CPU and RAM limitation.  If it is only HDD limitation that is the issue, you can still configure Solr to store the files on another mapped drive while running Solr on the same box as CF (to configure where the Solr configuration and data file live, see the <a href="#linkConfig#">Solr Pro Config</a>.)</li>
			</ul>
		</li>
	</ul>
	<h1>Setup</h1>
	<h2>First Time Setup</h2>
	<p>If you've just installed this plugin, below is a checklist of things you'll need to do to get yourself on your way</p>
	<ol>
		<li>Deploy new types in the FarCry <abbr title="Conent Object API">COAPI</abbr>.</li>
		<li>Start Solr.  We've provided sample Solr startup scripts found in the plugin's copy of <var>solr-server</var> (assuming you've downloaded our copy of Solr server). Tips for auto-starting Solr as a service can be found at the <a href="#linkPluginInstall#">plugin's website</a>.</li>
		<li>Run the FarCry Solr config at least once.  Even if you don't plan to change any of the defaults, running it once will copy over the necessary configuration files into your project's Solr conf folder (that folder's destination is set in that config folder.  By default it is set to [project]/solr - with conf and data subfolders).</li>
		<li>Confirm that you've setup the web mapping correctly in your web server (needed for some ajax facade calls in the webtop) and that it matches whatever web map setting you've configured in your <a href="#linkConfig#">config</a>.  A simple way to do this is to look at the top of this very page and verify that you see the logos for Apache Solr and the FarCry Solr Pro plugin.</li>
	</ol>
	
	<h1>Performance Tips</h1>
	<h2>Configure RAM</h2>
	<p>Although fine-tuning and tweaking the JVM (especially for RAM) can get very detailed, most servers are fine with just setting a min/max for Solr's RAM.  For production use it is usually suggested to set both the min and max memory settings to the same values.  If you plan to use the sample startup scripts provided with the plugin, you'll see variables at the top of the file(s) for setting the min/max memory for Solr.  The default settings are 256/512 respectively.  For sites with a lot of content, you'll likely want to increase those values.  Please note that if you are using a 32-bit JVM then you will be limited to about 1.5GB of RAM as a cap (a limitation of 32-bit java) and will want to consider moving to a 64-bit JVM (see the next section for more info).</p>
	<p>If you're getting heap stack errors when searching or indexing, this likely means that Solr doesn't have enough memory to work with your data.  Increasing the RAM and restarting Solr will fix this error in most cases.  If you're only getting the error while indexing large datasets, you may need to set your <var>index batch size</var> too a lower number in the <a href="#linkConfig#">plugin configuration</a>.  Reducing the batch size will likely get you on you way (note: Even though you received the heap stack errors during the indexing process, your data is safe.  Solr will still need to commit the information before it becomes available, but the next commit or index will take care of that).</p>
	<h2>64-bit Support</h2>
	<p>32-bit JVMs have a RAM limitation of about 1.5GB.  If you want to use more than this limitation you will want to load Solr using a 64-bit JVM (requires 64-bit hardware and a 64-bit OS).</p>
	<p>Although setting this up goes beyond our documentation, it is not difficult.  In fact, your server may already have a 64-bit JVM in place.  For instructions on how to set this up, search the web on how to configure your JAVA_HOME environment variable for your server's operating system and where to download a 64-bit JVM (since ColdFusion requires an SDK version, we personally use an SDK instead of a JRE).  You can also start a discussion in the <a href="https://groups.google.com/forum/##!forum/farcry-dev">FarCry developer mailing list</a> for any tips/questions on this plugin or FarCry questions in general.</p>
	<h2>Storing Data</h2>
	<p>Some larger companies prefer to store "every" field in Solr (Assuming they have the HDD space and RAM for indexing).  They find this to be better performace than relying on a CMS's caching system or extra database hits (we're talking extreme cases though - like millions of objects).  In these types of cases though, it is suggested to know how to performance-tune Solr and run it on a 64-bit JVM with more RAM dedicated to Solr.</p>
	<h2>Result Summary</h2>
	<p>You can always configure your displaySearchResult.cfm file to allow FarCry to lookup the content object and get a field, however storing the data in Solr that you plan to display in your search results will return faster response times for your end-users (depending on how you setup your object broker and query your data, this statement could be argued).</p>
	<br />
</cfoutput>

<admin:footer />

<!--- Load Custom Webtop Styling (load after admin:header) --->
<skin:loadCss id="solrPro-customWebtopStyles" />

<cfsetting enablecfoutputonly="false" />