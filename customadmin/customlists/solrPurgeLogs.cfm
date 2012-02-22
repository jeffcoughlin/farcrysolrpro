<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Purge Logs --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<admin:header title="Purge Logs" />

<cfif application.fapi.getConfig(key = 'solrserver', name = 'bConfigured', default = false) eq true>

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

<cfelse>
	
	<cfset linkConfig = application.url.webtop & "/admin/customadmin.cfm?module=customlists/farConfig.cfm" />
	<cfoutput><p>You must <a href="#linkConfig#">configure the Solr settings</a> before you can test search.</p></cfoutput>
	
</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />