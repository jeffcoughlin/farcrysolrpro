<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: FarCry Solr Pro Website Reference  --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<admin:header title="Solr Admin" />

<cfset linkPlugin = "http://jeffcoughlin.github.io/farcrysolrpro" />

<cfoutput>
	<h1>FarCry Solr Pro Website Reference</h1>
	<p>More details on the plugin and installation help can be found on the plugin's website: <a href="#linkPlugin#">#linkPlugin#</a>.</p>
	<p>For your convenience the plugin website has been iFrame'd below (assuming you currently have web access to the site from your location).</p>
	<br />
	<iframe src="#linkPlugin#" width="100%" height="500"></iframe>
</cfoutput>

<admin:footer />

<cfsetting enablecfoutputonly="false" />