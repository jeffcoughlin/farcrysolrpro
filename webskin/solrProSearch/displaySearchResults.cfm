<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2009, http://www.daemon.com.au --->
<!--- @@License:  --->
<!--- @@displayname: Displays results found --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfparam name="stParam.qResults" default="#queryNew('blah')#" />
<cfparam name="stParam.searchCriteria" default="" />

<!------------------ 
START WEBSKIN
 ------------------>

<!--- display search results --->
<skin:pagination 
	paginationID="#stobj.objectid#"
	qRecordSet="#stParam.qResults#"
	pageLinks="5"
	recordsPerPage="25" 
	submissionType="form"
	r_stobject="st"
	>
		<skin:view 
			typename="#st.custom1#" 
			objectid="#st.objectid#" 
			webskin="displaySearchResult"
			searchCriteria="#stParam.searchCriteria#"
			rank="#st.rank#"	
			score="#st.score#"		
			title="#st.title#"	
			key="#st.key#"
			summary="#st.summary#"		
			 >

</skin:pagination>
			
<cfsetting enablecfoutputonly="false" />