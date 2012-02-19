<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: FarCry Solr Pro Wiki Reference  --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<admin:header title="Solr Admin" />

<cfset linkWiki = "https://bitbucket.org/jeffcoughlin/farcrysolrpro/wiki" />

<cfoutput>
	<h1>FarCry Solr Pro Wiki Reference</h1>
	<p>More details on the plugin and installation help can be found in the online wiki: <a href="#linkWiki#">#linkWiki#</a>.</p>
	<p>For your convenience the wiki has been iFrame'd below (assuming you currently have web access to the site).</p>
	<br />
	<iframe src="#linkWiki#" width="100%" height="100%" />
</cfoutput>

<admin:footer />

<cfsetting enablecfoutputonly="false" />