<cfsetting enablecfoutputonly="true" requestTimeOut="9999" />
<!--- @@displayname: Solr Index --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<!---
	URL variable options are
	optimize: true/false (default: true)
	batchSize: integer (default: [set in main config. default: 1000])
	lContentTypeIds: a list of objectids for solrProContentType records to index (default: all types)
--->

<cfset request.fc.bShowTray = false />

<!--- has optimization been disabled? --->
<cfparam name="url.optimize" default="true" />
<cfif not isBoolean(url.optimize)>
	<cfset url.optimize = true />
</cfif>

<!--- set the batch size --->
<cfparam name="url.batchSize" default="#application.fapi.getConfig(key = "solrserver", name = "batchSize", default = 1000)#" />
<cfif not isNumeric(url.batchSize)>
	<cfset url.batchSize = application.fapi.getConfig(key = "solrserver", name = "batchSize", default = 1000) />
</cfif>

<!--- set the list of content types to index --->
<cfparam name="url.lContentTypeIds" default="" />

<!--- index the records --->
<cfset oContentType = application.fapi.getContentType("solrProContentType") />
<cfset stResult = oContentType.indexRecords(bOptimize = url.optimize, batchSize = url.batchSize, lContentTypeIds = url.lContentTypeIds) />

<!--- display the results --->
<cfset variables.processtime = stResult.processTime />
<cfset variables.aStats = stResult.aStats />
<cfset variables.millisecondsToDate = application.stPlugins.farcrysolrpro.oCustomFunctions.millisecondsToDate />
<cfoutput>
	<style>
	.statsTbl {
		line-height: 1.6em;
		font-size: 15px;
		font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
		font-size: 1em;
		margin: 20px;
		text-align: left;
		border-collapse: collapse;
	}
	.statsTbl th {
		padding: 8px;
		font-weight: normal;
		font-size: 1.1em;
		color: ##039;
		background: ##b9c9fe;
	}
	.statsTbl th span {
		display: block;
		font-size: 0.8em;
	}
	.statsTbl td {
		padding: 8px;
		background: ##e8edff;
		border-top: 1px solid ##fff;
		color: ##669;
		text-align: center;
	}
	.statsTbl td:nth-child(1) {
		text-align: left;
		color: ##039;
		background: ##b9c9fe;
	}
	.statsTbl thead th:nth-child(1) {
		border-radius: 10px 0 0 0;
	}
	.statsTbl thead th:nth-child(5) {
		border-radius: 0 10px 0 0;
	}
	.statsTbl tfoot td:nth-child(1) {
		border-radius: 0 0 0 10px;
		text-align: right;
		font-weight: bold;
	}
	.statsTbl tfoot td:nth-child(2) {
		text-align: right;
		font-weight: bold;
	}
	.statsTbl tfoot td:nth-child(3) {
		border-radius: 0 0 10px 0;
	}
	.statsTbl tbody tr:hover td {
		background: ##d0dafd;
	}
	</style>

	<table class="statsTbl" summary="Solr Index Stats">
		<thead>
			<tr>
				<th scope="col">FC Type</th>
				<th scope="col">Batch Count</th>
				<th scope="col">Total Index Count</th>
				<th scope="col">Built to Date</th>
				<th scope="col">Process Time<span>(hours:min:sec)</span></th>
			</tr>
		</thead>
		<tfoot>
			<tr>
				<td></td>
				<td colspan="3">Total Page Processing Time:</td>
				<td>#timeFormat(millisecondsToDate(processTime), "HH:mm:ss")#</strong></td>
			</tr>
		</tfoot>
		<tbody>
		<cfloop array="#aStats#" index="statResult">
			<tr>
				<td>#statResult.typeName#</td>
				<td>#statResult.indexRecordCount#</td>
				<td>#statResult.totalRecordCount#</td>
				<td>#dateFormat(statResult.builtToDate,"mm/dd/yyyy")# #timeFormat(statResult.builtToDate,"h:mm tt")#</td>
				<td>#timeFormat(millisecondsToDate(statResult.processtime),"HH:mm:ss")#</td>
			</tr>
		</cfloop>
		</tbody>
	</table>
</cfoutput>

<cfsetting enablecfoutputonly="false" />