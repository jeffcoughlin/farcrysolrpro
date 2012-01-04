<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
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
	
<cfoutput><p>Your search <cfif len(stParam.searchCriteria)>for "#stParam.searchCriteria#" </cfif>produced <span id="vp-resultsfound">#stParam.qResults.recordCount#</span> results.</p></cfoutput>

<cfsetting enablecfoutputonly="false">