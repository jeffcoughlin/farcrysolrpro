<cfsetting enablecfoutputonly="true" />

<!--- @@displayname: Solr Pro Document Boost Admin --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<admin:header title="Solr Pro Document Boost Admin" />

<ft:objectadmin 
	typename="solrProDocumentBoost"
	columnList="documentId,boostValue,datetimecreated" 
	sortableColumns="datetimecreated"
	lFilterFields=""
	sqlorderby="datetimecreated"
	plugin="farcrysolrpro" />

<admin:footer />

<cfsetting enablecfoutputonly="false" />