<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Documentation  --->
<!--- @@author: Sean Coyne (sean@n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<admin:header title="Solr Pro How-To" />

<cfset linkConfig = application.url.webroot & "/webtop/admin/customadmin.cfm?module=customlists/farConfig.cfm" />

<cfoutput>
	<!--- TODO: Finish these docs --->
	<h1>Requirements</h1>
	<ul>
		<li>Although Solr can run from a separate server, FarCry needs directory access to the conf files (schema.xml, solrconfig.cml, etc).  So if you plan to run Solr on a separate server you'll need to setup a mapped network drive for FarCry to use (and then set those settings in the <a href="linkConfig">Solr Pro Config</a>).
			<ul>
				<li>Note: Running Solr on a separate machine can result in slower response times if the network is not properly configured.  Please keep in mind that Solr uses HTTP requests to send and recieve JSON/XML (we use JSON in our plugin) strings of data back and forth.  In most cases, it is faster to run Solr on the same box.  Reasons for runn ing it on a separate box are usually due to HDD space limiation, and/or CPU and RAM limitation.  If it is only HDD limitation that is the issue, you can still configure Solr to store the files on another mapped drive while running Solr on the same box as CF (to configure where the Solr configuration and data file live, see the <a href="linkConfig">Solr Pro Config</a>.)</li>
			</ul>
		</li>
	</ul>
	<h1>Setup</h1>
	<h2>First Time Setup</h2>
	<p>If you've just installed this plugin, below is a checklist of things you'll need to do to get yourself on your way</p>
	<ol>
		<li>Deploy new types in the FarCry <abbr title="Conent Object API">COAPI</abbr>.</li>
		<li>Run the FarCry Solr config at least once.  Even if you don't plan to change any of the defaults, running it once will copy over the necessary configuration files into your project's Solr conf folder (that folder's destination is set in that config folder.  By default it is set to [project]/solr - with conf and data subfolders)</li>
	</ol>
	
	<h1>Performance Tips</h1>
	<h2>64-bit and More RAM for Solr</h2>
	<p>By default Jetty is 32-bit and 32-bit java has a RAM limitation of about 1.5GB.  If you have a lot of data to index and search or are running into heap stack errors when searching or indexing, it is suggested to give Solr more RAM which requires a 64-bit JVM.  Setting this up is not difficult, but differs by operating system and setup.  Explaining how to do that goes beyond the documentation provided in this plugin, however finding steps on how to set that up on the web are pretty easy to find.</p>
	<h2>Storing Data</h2>
	<p>Some larger companies prefer to store "every" field in Solr (Assuming they have the HDD space and RAM for indexing).  They find this to be better performace than relying on a CMS's caching system or extra database hits (we're talking extreme cases though - like millions of objects).  In these types of cases though, it is suggested to know how to performance-tune Solr and run it on a 64-bit JVM with more RAM dedicated to Solr.</p>
	<h2>Result Summary</h2>
	<p>You can always configure your displaySearchResult.cfm file to allow FarCry to lookup the content object and get a field, however storing the data in Solr often results in faster response times (depending on how you setup your object broker, this statement could be argued).</p>
</cfoutput>

<admin:footer />

<!--- Styling and javascript --->
<skin:htmlhead id="solrProDocumentation-HowTo">
	<cfoutput>
	<style type="text/css" media="all">
		strong {
			font-weight: bold;
		}
		em {
			font-style: italic;
		}
		h1 {
			margin: 1.2em 0 0;
		}
		div.indent {
			margin-left: 1.2em;
		}
		code,
		.code {
			color: ##555;
			font: 1.1em monospace;
			background-color: ##eee;
			padding: 0.3em 0.5em;
		}
		ul {
			margin-left: 1em;
		}
		ul ul {
			margin-left: 0;
		}
		li {
			margin-left: 1em;
			list-style: disc outside none;
		}
		li.nolistyle {
			margin-left: 0;
			list-style: none;
		}
	</style>
	</cfoutput>
</skin:htmlhead>

<cfsetting enablecfoutputonly="false" />