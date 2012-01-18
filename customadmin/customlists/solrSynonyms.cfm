<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Synonyms --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset filePath = application.fapi.getConfig(key = 'solrserver', name = 'instanceDir') & "/conf/synonyms.txt" />

<admin:header title="Synonyms" />

<cfif fileExists(filePath)>

<ft:processForm action="Save">
	<cfset fileWrite(filePath,trim(form.contents)) />
	<skin:bubble title="Synonyms" message="Updated synonyms.txt" />
</ft:processForm>

<cfset contents = fileRead(filePath) />

<ft:form>
	
	<ft:fieldset legend="Synonyms">
		
		<ft:field for="contents" label="File Contents:" hint="No reindex is required. This file is read by Solr at query time.">
			<cfoutput>
			<textarea class="textareaInput" name="contents" id="contents" style="min-height: 400px;">#contents#</textarea>
			</cfoutput>
		</ft:field>
		
		<ft:buttonPanel>
			<ft:button value="Save" />
		</ft:buttonPanel>
	
	</ft:fieldset>
	
</ft:form>


<cfelse>

	<cfset linkConfig = application.url.webroot & "/webtop/admin/customadmin.cfm?module=customlists/farConfig.cfm" />
	<cfoutput><p>Unable to locate #filepath#.  Please be sure your <a href="#linkConfig#">Solr configuration</a> is correct.</p></cfoutput>

</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />