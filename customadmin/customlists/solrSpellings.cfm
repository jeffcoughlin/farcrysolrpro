<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Spellings --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset filePath = application.fapi.getConfig(key = 'solrserver', name = 'instanceDir') & "/conf/spellings.txt" />

<admin:header title="Spellings" />

<cfif fileExists(filePath)>

<ft:processForm action="Save">
	<cfset fileWrite(filePath,trim(form.contents)) />
	<cfset application.fapi.getContentType("solrProContentType").reload() />
	<skin:bubble title="Spellings" message="Updated spellings.txt" />
</ft:processForm>

<cfset contents = fileRead(filePath) />

<cfoutput>
	<h1>Spellings (dictionary)</h1> 
	<p>By default, this never needs to be changed (and is disabled by default).  We've implemented Solr's automatic spell checker, which uses the data already in the index to spell check against.  However, if you wanted to override this, you could use the settings in Solr to create a custom dictionary.</p>
	<p>To Enable: You need to set spellchecker.dictionary = 'file' when doing a query.  The file spell checker will be used and the spellings.txt file will be used as the dictionary.</p>
</cfoutput>

<ft:form>
	
	<ft:fieldset legend="Spellings">
		
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

	<cfset linkConfig = application.url.webtop & "/index.cfm?sec=admin&sub=general&menu=settings&listfarconfig" />
	<cfoutput><p>Unable to locate #filepath#.  Please be sure your <a target="_top" href="#linkConfig#">Solr configuration</a> is correct.</p></cfoutput>

</cfif>

<admin:footer />

<!--- Load Custom Webtop Styling (load after admin:header) --->
<skin:loadCSS id="solrPro-customWebtopStyles" />

<cfsetting enablecfoutputonly="false" />