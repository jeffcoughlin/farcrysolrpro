<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Reload --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<admin:header title="Solr Reload" />

<cfif application.fapi.getConfig(key = 'solrserver', name = 'bConfigured', default = false) eq true>

	<cfscript>
		oContentType = application.fapi.getContentType("solrProContentType");
		oContentType.reload();
		oContentType.optimize();
	</cfscript>
	
	<cfoutput>
		<h1>Complete!</h1>
		<p>Solr has been reloaded and the collection has been optimized.  Changes to the following files have been reloaded:</p>
		<ul>
			<li>solrconfig.xml</li>
			<li>schema.xml</li>
			<li>protwords.txt</li>
			<li>spellings.txt</li>
			<li>stopwords.txt</li>
			<li>synonyms.txt</li>
			<li>elevate.xml</li>
		</ul>
	</cfoutput>

<cfelse>
	
	<cfset linkConfig = application.url.webtop & "/index.cfm?sec=admin&sub=general&menu=settings&listfarconfig" />
	<cfoutput><p>You must <a target="_top" href="#linkConfig#">configure the Solr settings</a> before you can test search.</p></cfoutput>
	
</cfif>

<admin:footer />

<!--- Load Custom Webtop Styling (load after admin:header) --->
<skin:loadCss id="solrPro-customWebtopStyles" />

<cfsetting enablecfoutputonly="false" />