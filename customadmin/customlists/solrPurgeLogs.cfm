<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Purge Logs --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<admin:header title="Purge Logs" />

<skin:loadJs id="jquery" />
<skin:loadJs id="jquery-ui" />
<skin:loadCss id="jquery-ui" />

<cfparam name="form.purgeDate" default="" />

<cfif isDate(form.purgeDate)>
	<cfset form.purgeDate = dateFormat(form.purgeDate,"mm/dd/yyyy") />
<cfelse>
	<cfset form.purgeDate = "" />
</cfif>

<skin:loadJs id="purgeLogs">
<cfoutput>
$j(document).ready(function(){
	$j(".datepicker").datepicker();
});
</cfoutput>
</skin:loadJs>

<ft:processForm action="Purge">

	<cfset application.fapi.getContentType("solrProSearchLog").purgeLog(purgeDate = form.purgeDate) />
	
	<skin:bubble title="Purge" message="Purge complete!" />
	
</ft:processForm>

<ft:form>
	
	<ft:fieldset legend="Purge Logs">
		
		<ft:field label="Purge Logs Older Than:" for="purgeDate" hint="Specify a date.  The system will purge all search log records older than midnight on the date provided.  Leave blank to purge all records.">
			
			<cfoutput>
			<input type="text" class="datepicker" id="purgeDate" name="purgeDate" value="#form.purgeDate#" />
			</cfoutput>
			
		</ft:field>
		
	</ft:fieldset>
	
	<ft:buttonPanel>
		<ft:button value="Purge" />
	</ft:buttonPanel>
	
</ft:form>


<!--- Styling and javascript --->
<skin:htmlhead id="solrPro-purgeLogs">
	<cfoutput>
	<style type="text/css" media="all">
		strong {
			font-weight: bold;
		}
		em {
			font-style: italic;
		}
		h1 {
			margin: 1.2em 0 0;
		}
		p {
			margin: .5em 0;
		}
		code,
		.code {
			color: ##555;
			font: 1.1em monospace;
			background-color: ##eee;
			padding: 0.3em 0.5em;
		}
	</style>
	</cfoutput>
</skin:htmlhead>

<admin:footer />

<cfsetting enablecfoutputonly="false" />