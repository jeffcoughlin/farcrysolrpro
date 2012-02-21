<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Admin  --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset host = application.fapi.getConfig(key = 'solrserver', name = 'host') />
<cfset port = application.fapi.getConfig(key = 'solrserver', name = 'port') />
<cfset path = application.fapi.getConfig(key = 'solrserver', name = 'path') /> 
<cfset uri = "http://" & host & ":" & port & path & "/admin/" />

<!--- check that Solr is responding --->
<cfset bContinue = application.fapi.getContentType("solrProContentType").isSolrRunning() />

<admin:header title="Solr Admin" />

<cfoutput>
	<h1>Solr Admin Screen</h1>
	<p>The screen below is pulled from Solr itself and is not managed by FarCry.  Generally you shouldn't need this tool for any of your Solr management, however we've provided this screen here for your convenience for testing and troubleshooting should you desire it (ref: <a href="#uri#">Solr Admin</a>).</p>
	<br />
	<cfif bContinue>
	<iframe src="#uri#" width="100%" height="600" />
	<cfelse>
		<cfset linkConfig = application.url.webtop & "/admin/customadmin.cfm?module=customlists/farConfig.cfm" />
		<p>Solr is not responding.  Please be sure your <a href="#linkConfig#">Solr configuration</a> is correct, and that the Solr service is running.</p>
	</cfif>
</cfoutput>

<admin:footer />

<cfsetting enablecfoutputonly="false" />