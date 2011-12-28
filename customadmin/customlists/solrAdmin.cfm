<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Admin  --->
<!--- @@author: Sean Coyne (sean@n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset host = application.fapi.getConfig(key = 'solrserver', name = 'host') />
<cfset port = application.fapi.getConfig(key = 'solrserver', name = 'port') />
<cfset path = application.fapi.getConfig(key = 'solrserver', name = 'path') /> 
<cfset uri = "http://" & host & ":" & port & path & "/admin/" />

<!--- TODO: add info --->

<cfoutput>
	<iframe src="#uri#" width="100%" height="600" />
</cfoutput>

<cfsetting enablecfoutputonly="false" />