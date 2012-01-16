<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Search Log --->
<!--- @@author: Sean Coyne (sean@n42designs.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<skin:loadJs id="jquery" />
<skin:loadJs id="jquery-ui" />
<skin:loadCss id="jquery-ui" />

<skin:onReady>
<cfoutput>
$j('input.datefield').datepicker();
</cfoutput>
</skin:onReady>

<admin:header title="Searches Without Results" />

<cfparam name="form.queryString" default="" />
<cfparam name="form.startDate" default="#dateAdd('m',-1,now())#" />
<cfparam name="form.endDate" default="#now()#" />

<!---<cfset dateMask = "mm/dd/yyyy" />
<cfset timeMask = "h:mm ss" />--->
<cfset dateMask = "yyyy-mm-dd" />
<cfset timeMask = "short" />

<!--- this is here so the pagination will work --->
<cfset form.farcryFormSubmitButtonClickedSearchLog = "Submit" />

<ft:processForm action="Submit">
	
	<cfset oLog = application.fapi.getContentType("solrProSearchLog") />
	<cfset qResults = oLog.getSearchesWithoutResults(startDate = form.startDate, endDate = form.endDate, queryString = form.queryString) />
	
</ft:processForm>

<!--- TODO: style this --->
<cfif application.fapi.getConfig(key = 'solrserver', name = 'bLogSearches', default = true) eq false>
	<cfoutput><p>NOTE: Search logging is currently turned OFF.</p></cfoutput>
</cfif>

<ft:form name="SearchLog">
	
	<ft:fieldset legend="Filter">
		
		<ft:field for="startDate" label="Start Date" hint="mm/dd/yyyy">
			<cfoutput>
			<input type="text" class="textInput datefield" name="startDate" id="endDate" value="#dateFormat(form.startDate,'mm/dd/yyyy')#" />
			</cfoutput>
		</ft:field>
		
		<ft:field for="endDate" label="End Date" hint="mm/dd/yyyy">
			<cfoutput>
			<input type="text" class="textInput datefield" name="endDate" id="endDate" value="#dateFormat(form.endDate,'mm/dd/yyyy')#" />
			</cfoutput>
		</ft:field>
		
		<ft:field for="queryString" label="Query String">
			<cfoutput>
			<input type="text" class="textInput" name="queryString" id="queryString" value="#form.queryString#" />
			</cfoutput>
		</ft:field>
		
		<ft:buttonPanel>
			<ft:button value="Submit" />
		</ft:buttonPanel>
		
	</ft:fieldset>

<cfif structKeyExists(variables,"qResults")>
	
	<skin:pagination submissionType="form" bDisplayTotalRecords="true" paginationId="" query="qResults" pageLinks="5">
	
	<cfif stObject.bFirst>
	<cfoutput>
	<table class="ui-widget ui-widget-content" width="100%"><!--- class="objectadmin" --->
		<thead>
			<tr class="ui-widget-header">
				<th>Query String</th>
				<th>Content Types</th>
				<th>Operator</th>
				<th>Order By</th>
				<th>Suggestion</th>
				<th>Date</th>
			</tr>
		</thead>
		<tbody>
	</cfoutput>
	</cfif>
			
			<cfoutput>
			<tr>
				<td>#qResults.q[stObject.recordsetRow]#</td>
				<td>#qResults.lContentTypes[stObject.recordsetRow]#</td>
				<td>#qResults.operator[stObject.recordsetRow]#</td>
				<td>#qResults.orderby[stObject.recordsetRow]#</td>
				<td>#qResults.suggestion[stObject.recordsetRow]#</td>
				<td><span title="#dateFormat(qResults.datetimecreated[stObject.recordsetRow],dateMask)# #timeFormat(qResults.datetimecreated[stObject.recordsetRow],timeMask)#">#application.fapi.prettyDate(qResults.datetimecreated[stObject.recordsetRow])#</span></td>
			</tr>
			</cfoutput>
			
	<cfif stObject.bLast>
	<cfoutput>		
		</tbody>
	</table>
	</cfoutput>
	</cfif>
	
	</skin:pagination>
	
</cfif>

	<skin:htmlhead id="solrProSearchLog">
		<cfoutput>
		<style type="text/css" media="all">
			strong {
				font-weight: bold;
			}
			em {
				font-style: italic;
			}
			table {
				margin: .85em 0;
				border-collapse: collapse;
				font-size: 1em;
			}
			table caption {
				font: bold 145% arial;
				padding: 5px 10px;
				text-align: left;
			}
			table td,
			table th {
				border: 1px solid ##eee;
				padding: .6em 10px;
				text-align: left;
				vertical-align: top;
			}
			table tr:nth-child(even) {
				background: none repeat scroll 0 0 ##F1F1F1;
			}
		</style>
		</cfoutput>
	</skin:htmlhead>

</ft:form>

<admin:footer />

<cfsetting enablecfoutputonly="false" />