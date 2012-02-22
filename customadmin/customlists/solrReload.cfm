<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Reload --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<admin:header title="Solr Reload" />

<cfset application.fapi.getContentType("solrProContentType").reload() />

<!--- TODO: Are we sure these are the only files reloaded? (ie. what about stopwords).  The only info I can find in solr docs is that it reloads the Solr core --->

<cfoutput>
	<h1>Complete!</h1>
	<p>Solr has been reloaded.  Changes to the following files have been reloaded:</p>
	<ul>
		<li>solrconfig.xml</li>
		<li>schema.xml</li>
		<li>protwords.txt</li>
		<li>spellings.txt</li>
		<li>synonyms.txt</li>
		<li>elevate.xml</li>
	</ul>
</cfoutput>

<admin:footer />

<!--- Load Custom Webtop Styling (load after admin:header) --->
<skin:loadCss id="solrPro-customWebtopStyles" />

<cfsetting enablecfoutputonly="false" />