<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Reload --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<admin:header title="Solr Reload" />

<cfif application.fapi.getConfig(key = 'solrserver', name = 'bConfigured', default = false) eq true>

	<cfset application.fapi.getContentType("solrProContentType").reload() />
	
	<cfoutput>
		<h1>Complete!</h1>
		<p>Solr has been reloaded.  Changes to the following files have been reloaded:</p>
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
	
	<cfset linkConfig = application.url.webtop & "/admin/customadmin.cfm?module=customlists/farConfig.cfm" />
	<cfoutput><p>You must <a href="#linkConfig#">configure the Solr settings</a> before you can test search.</p></cfoutput>
	
</cfif>

<admin:footer />

<!--- Load Custom Webtop Styling (load after admin:header) --->
<skin:loadCss id="solrPro-customWebtopStyles" />

<cfsetting enablecfoutputonly="false" />