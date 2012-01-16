<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Documentation  --->
<!--- @@author: Sean Coyne (sean@n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<admin:header title="Solr Pro How-To" />

<cfoutput>
	<!--- TODO: Finish these docs --->
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
	</style>
	</cfoutput>
</skin:htmlhead>

<cfsetting enablecfoutputonly="false" />