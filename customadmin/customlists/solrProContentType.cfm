<cfsetting enablecfoutputonly="true" />

<!--- @@displayname: Solr Pro Content Type Admin --->
<!--- @@author: Sean Coyne (www.n42designs.com)--->

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<admin:header title="Solr Pro Content Type Admin" />

<ft:objectadmin 
	typename="solrProContentType"
	columnList="title,contentType,indexRecordCount,datetimecreated" 
	sortableColumns="title,contentType,indexRecordCount,datetimelastUpdated"
	lFilterFields="title,contentType"
	sqlorderby="title"
	plugin="farcrysolrpro" />

<admin:footer />

<cfsetting enablecfoutputonly="false" />