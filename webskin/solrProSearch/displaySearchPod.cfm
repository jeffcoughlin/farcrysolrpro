<cfsetting enablecfoutputonly="true" />

<!--- required includes --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- SETUP THE URL OF THE SEARCH PAGE --->
<cfif structKeyExists(application.navid, "search")>
	<cfset actionURL = "#application.url.conjurer#?objectID=#application.navID.search#" />
<cfelse>
	<cfset actionURL = "#application.url.conjurer#?type=#stobj.typename#&bodyView=displayTypeBody" />
</cfif>

<ft:form action="#actionURL#">

	<!--- We want to clear the value in this search field when displaying and let the search form handle it once submitted --->
	<cfset stPropMetadata = structNew() />
	<cfset stPropMetadata.criteria = structNew() />
	<cfset stPropMetadata.criteria.value = "" />
	<ft:object objectid="#stobj.objectid#" lFields="criteria" stPropMetadata="#stPropMetadata#" r_stFields="stFields" />
	
	<cfoutput>
		<div id="search">
			<table id="tab-search" class="layout">
			<tr>
				<td valign="middle">#stFields.criteria.label#</td>
				<td valign="middle">#stFields.criteria.html#</td>
				<td valign="middle"><ft:button value="Search" size="small" /></td>
			</tr>
			</table>
		</div>
	</cfoutput>

</ft:form>

<cfsetting enablecfoutputonly="false" />