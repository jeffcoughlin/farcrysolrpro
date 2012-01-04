<cfsetting enablecfoutputonly="true" />

<!--- @@displayname: Search Pod --->
<!--- @@author: Geoff Bowers (modius@daemon.com.au) --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />



<skin:view typename="#stobj.name#" key="SearchForm" webskin="displaySearchPod"  />


<cfsetting enablecfoutputonly="false" />