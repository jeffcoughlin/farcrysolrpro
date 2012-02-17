<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Reload --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<admin:header title="Solr Reload" />

<cfset application.fapi.getContentType("solrProContentType").reload() />

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

<cfsetting enablecfoutputonly="false" />