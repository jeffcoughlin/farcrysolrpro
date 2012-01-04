<cfsetting enablecfoutputonly="true" requestTimeOut="9999" />
<!--- @@displayname: Solr Optimize --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfset request.fc.bShowTray = false />

<cfset application.fapi.getContentType("solrProContentType").optimize() />

<cfoutput><h1>Optimization Complete!</h1></cfoutput>

<cfsetting enablecfoutputonly="false" />