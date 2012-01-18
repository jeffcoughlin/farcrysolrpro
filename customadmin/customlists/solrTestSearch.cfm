<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Test Search --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfparam name="form.contentType" default="" />
<cfparam name="form.searchcriteria" default="" />

<admin:header title="Test Search" />

<cfif application.fapi.getConfig(key = 'solrserver', name = 'bConfigured', default = false) eq true>

<cfset oContentType = application.fapi.getContentType("solrProContentType") />
<cfset qContentTypes = oContentType.getAllContentTypes() />

<!--- this is here so the pagination will work --->
<cfset form.farcryFormSubmitButtonClickedTestSearch = "Search" />

<ft:processForm action="Search">	
	
	<!--- ensure we have actually submitted a search --->
	<cfset bContinue = false />
	<cfif len(trim(form.searchcriteria))>
		<cfset bContinue = true />
	<cfelse>
		<cfloop collection="#form#" item="f">
			<cfif left(f,len('searchField_')) eq 'searchField_'>
				<cfif len(trim(form[f]))>
					<cfset bContinue = true />
					<cfbreak />
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfif bContinue>
		
		<!--- pagination --->
		<cfparam name="form.paginationpage" default="1" />
		<cfif not isNumeric(form.paginationpage)>
			<cfset form.paginationpage = 1 />
		</cfif>
		<cfset rows = 10 />
		<cfset startRow = ((form.paginationpage - 1) * rows) />
		
		<cfset q = "" />
		<cfset params = {} />
		
		<cfif len(trim(form.searchcriteria)) or len(trim(form.contentType)) eq 0>
			<!--- search against all fields in the content type (or all content types) --->
			<cfset params["qf"] = oContentType.getFieldListForTypes(lContentTypes = form.contentType) />
			<cfset q = form.searchcriteria />
		<cfelse>
			<!--- build qf based on the fields being searched --->
			<cfset params["qf"] = "" />
			<cfloop collection="#form#" item="f">
				<cfif left(f,len('searchField_')) eq 'searchField_'>
					<cfif len(trim(form[f]))>
						<cfset fieldName = lcase(right(f,len(f) - len('searchField_'))) />
						<cfset params["qf"] = listAppend(params["qf"], fieldName, " ") />
						<cfset q = q & " " & fieldName & ":(" & form[f] & ")" />
					</cfif>
				</cfif>
			</cfloop>
			<cfset q = trim(q) />
		</cfif>
		
		<cfif len(trim(form.contentType))>
			<cfset q = "(" & q & ") AND typename:" & form.contentType />
		</cfif>
		
		<cfset params["fl"] = "*,score" />
	
		<cfset results = oContentType.search(q = q, start = startRow, rows = rows, params = params) />
		
	</cfif>
	
</ft:processForm>

<ft:form name="testSearch">
	
	<ft:fieldset legend="Test Search">
		
		<ft:field label="Type:" for="contentType" hint="Choose which type (or all types) to search against">
			
			<cfoutput>
			<select name="contentType" id="contentType" class="selectInput" onchange="$j('.textInput').each(function(i){ $(this).val(''); }); $j('##testSearch').submit();">
				<option value="">-- All Content Types --</option>
				<cfloop query="qContentTypes">
				<option value="#qContentTypes.contentType[qContentTypes.currentRow]#"<cfif form.contentType eq qContentTypes.contentType[qContentTypes.currentRow]> selected="selected"</cfif>>#qContentTypes.title[qContentTypes.currentRow]#</option>
				</cfloop>
			</select>
			</cfoutput>
			
		</ft:field>
		
		<ft:field label="Keyword Search:" for="searchcriteria" hint="Search against all fields">
			
			<cfoutput>
			<input type="text" class="textInput" name="searchcriteria" id="searchcriteria" value="#form.searchcriteria#" />
			</cfoutput>
			
		</ft:field>
		
	</ft:fieldset>
	
	<cfif len(trim(form.contentType))>
	<ft:fieldset legend="Search by Field">

		<cfset aFields = listToArray(oContentType.getFieldListForType(form.contentType)," ") />
		<cfset aCoreFields = oContentType.getSchemaFieldMetadata(lOmitFields = "random,typename") />
		<cfloop array="#aCoreFields#" index="coreField">
			<cfif coreField.indexed eq true>
				<cfset arrayAppend(aFields,coreField.name) />
			</cfif>
		</cfloop>
		<cfset arraySort(aFields,"text") />
		
		<cfloop array="#aFields#" index="f">
		<ft:field label="#f#:" for="searchField_#f#">
			<cfparam name="form.searchField_#f#" default="" />
			<cfoutput>
			<input type="text" class="textInput" name="searchField_#f#" id="searchField_#f#" value="#form['searchField_' & f]#" />
			</cfoutput>
		</ft:field>
		</cfloop>
		
	</ft:fieldset>
	</cfif>
	
	<ft:buttonPanel>
		<ft:button value="Search" />
	</ft:buttonPanel>
	
	<cfif structKeyExists(variables,"results")>	

		<skin:pagination paginationId="" pageLinks="5" bDisplayTotalRecords="true" submissionType="form" array="#variables.results.results#" totalRecords="#variables.results.totalResults#" recordsPerPage="#rows#">
			
			<!--- only dump the results the first time through the loop --->
			<cfif stObject.bFirst>
				<cfdump var="#variables.results.results#" label="Search Results" />	
			</cfif>
		
		</skin:pagination>

	</cfif>
	
</ft:form>

<cfelse>
	<cfset linkConfig = application.url.webroot & "/webtop/admin/customadmin.cfm?module=customlists/farConfig.cfm" />
	<cfoutput><p>You must <a href="#linkConfig#">configure the Solr settings</a> before you can test search.</p></cfoutput>
</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />