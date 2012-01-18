<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Admin  --->
<!--- @@author: Sean Coyne (sean@n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset host = application.fapi.getConfig(key = 'solrserver', name = 'host') />
<cfset port = application.fapi.getConfig(key = 'solrserver', name = 'port') />
<cfset path = application.fapi.getConfig(key = 'solrserver', name = 'path') /> 
<cfset uri = "http://" & host & ":" & port & path & "/admin/" />

<admin:header title="Solr Admin" />

<cfoutput>
	<h1>Solr Admin Screen</h1>
	<p>The screen below is pulled from Solr itself and is not managed by FarCry.  Generally you shouldn't need this tool for any of your Solr management, however we've provided this screen here for your convenience for testing and troubleshooting should you desire it.</p>
	<br />
	<iframe src="#uri#" width="100%" height="600" />
</cfoutput>

<admin:footer />

<cfsetting enablecfoutputonly="false" />