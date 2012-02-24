<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Documentation - How To  --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<admin:header title="Solr Pro: How To" />

<cfset linkConfig = application.url.webtop & "/admin/customadmin.cfm?module=customlists/farConfig.cfm" />
<cfset linkWikiHome = "https://bitbucket.org/jeffcoughlin/farcrysolrpro/wiki" />
<cfset linkWikiInstall = "https://bitbucket.org/jeffcoughlin/farcrysolrpro/wiki/installation_and_configuration" />

<cfoutput>
	<!--- TODO: Finish these docs --->
	<img src="#application.fapi.getConfig(key = 'solrserver', name = 'pluginWebRoot')#/css/images/logo-farcrySolrPro-75.png" style="margin-top: 30px;" />
	<img src="#application.fapi.getConfig(key = 'solrserver', name = 'pluginWebRoot')#/css/images/logo-apacheSolr-75.png" style="float: right;" />
	<h1>Detailed Installation and Setup Help</h1>
	<p>For detailed installation and configuration assistance, please see the <a href="#linkWikiInstall#">online wiki</a>.</p>
	<h1>Minimum Requirements</h1>
	<ul>
		<li>ColdFusion 9</li>
		<li>FarCry 6.2</li>
		<li>Solr 3.5
			<ul>
				<li>Solr 3.5 is optionally included in this plugin.</li>
				<li>To date, we have only tested this on Solr 3.5</li>
			</ul>
		</li>
		<li>Although Solr can run from a separate server, FarCry needs directory access to the conf files (schema.xml, solrconfig.cml, etc).  So if you plan to run Solr on a separate server you'll need to setup a mapped network drive for FarCry to use (and then set those settings in the <a href="linkConfig">Solr Pro Config</a>).
			<ul>
				<li>Note: Running Solr on a separate machine can result in slower response times if the network is not properly configured.  Please keep in mind that Solr uses HTTP requests to send and recieve JSON/XML (we use JSON in our plugin) strings of data back and forth.  In most cases, it is faster to run Solr on the same box.  Reasons for running it on a separate box are usually due to HDD space limiation, and/or CPU and RAM limitation.  If it is only HDD limitation that is the issue, you can still configure Solr to store the files on another mapped drive while running Solr on the same box as CF (to configure where the Solr configuration and data file live, see the <a href="linkConfig">Solr Pro Config</a>.)</li>
			</ul>
		</li>
	</ul>
	<h2>Older FarCry Support</h2>
	<p>It is possible to run this plugin with a minimum of either FarCry 6.0.18 or 6.1.3, but you will not have the ability to ""commit on save" which just means that you'll have to setup a scheduled task (provided with plugin) to index your data on a regular basis.  If you'd still prefer to use one of the versions of FarCry mentioned here and add the support for "commit on save" to your copy of core manually, see the <a href="#linkWikiInstall#">wiki</a> on how to do this.</p>
	<h1>Setup</h1>
	<h2>First Time Setup</h2>
	<p>If you've just installed this plugin, below is a checklist of things you'll need to do to get yourself on your way</p>
	<ol>
		<li>Deploy new types in the FarCry <abbr title="Conent Object API">COAPI</abbr>.</li>
		<li>Run the FarCry Solr config at least once.  Even if you don't plan to change any of the defaults, running it once will copy over the necessary configuration files into your project's Solr conf folder (that folder's destination is set in that config folder.  By default it is set to [project]/solr - with conf and data subfolders).</li>
		<li>Confirm that you've setup the web mapping correctly in your web server (needed for some ajax facade calls in the webtop) and that it matches whatever web map setting you've configured in your <a href="#linkConfig#">config</a>.  A simple way to do this is to look at the top of this very page and verify that you see the logos for Apache Solr and the FarCry Solr Pro plugin.</li>
	</ol>
	
	<h1>Performance Tips</h1>
	<h2>64-bit and More RAM for Solr</h2>
	<p>By default Jetty is 32-bit and 32-bit java has a RAM limitation of about 1.5GB.  If you have a lot of data to index and search or are running into heap stack errors when searching or indexing then it is suggested to give Solr more RAM which requires a 64-bit JVM.  Setting this up is not difficult, but differs by operating system and setup.  Explaining how to do that goes beyond the documentation provided in this plugin, however finding steps on how to set that up on the web are pretty easy to find.</p>
	<h2>Storing Data</h2>
	<p>Some larger companies prefer to store "every" field in Solr (Assuming they have the HDD space and RAM for indexing).  They find this to be better performace than relying on a CMS's caching system or extra database hits (we're talking extreme cases though - like millions of objects).  In these types of cases though, it is suggested to know how to performance-tune Solr and run it on a 64-bit JVM with more RAM dedicated to Solr.</p>
	<h2>Result Summary</h2>
	<p>You can always configure your displaySearchResult.cfm file to allow FarCry to lookup the content object and get a field, however storing the data in Solr that you plan to display in your search results will return faster response times for your end-users (depending on how you setup your object broker and query your data, this statement could be argued).</p>
	<br />
</cfoutput>

<admin:footer />

<!--- Load Custom Webtop Styling (load after admin:header) --->
<skin:loadCss id="solrPro-customWebtopStyles" media="all" baseHref="#application.fapi.getConfig(key = 'solrserver', name = 'pluginWebRoot')#/css" lFiles="customWebtopStyles.css" />

<cfsetting enablecfoutputonly="false" />