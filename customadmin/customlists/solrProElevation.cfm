<cfsetting enablecfoutputonly="true" />

<!--- @@displayname: Solr Pro Elevation Admin --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<admin:header title="Solr Pro Elevation Admin" />

<ft:objectadmin 
	typename="solrProElevation"
	columnList="searchString,datetimecreated" 
	sortableColumns="searchString,datetimecreated"
	lFilterFields="searchString"
	sqlorderby="datetimecreated"
	plugin="farcrysolrpro" />

<admin:footer />

<cfsetting enablecfoutputonly="false" />