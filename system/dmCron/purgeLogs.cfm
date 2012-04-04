<cfsetting enablecfoutputonly="true"/>
<!--- @@displayname: Purge Solr Search Logs --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeffcoughlin.com) --->

<cfparam name="url.days" default="90" />

<cfscript>
	purgeDate = dateAdd('d',-url.days,now());
	application.fapi.getContentType("solrProSearchLog").purgeLog(purgeDate = purgeDate);
</cfscript>

<cfoutput><h1>Purge Complete!</h1></cfoutput>

<cfsetting enablecfoutputonly="false"/>