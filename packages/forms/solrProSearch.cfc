<cfcomponent output="false" extends="farcry.core.packages.forms.forms" displayname="Solr Pro Search" hint="Handles searching Solr collections">
	<cfproperty ftSeq="110" ftFieldset="General" name="q" type="string" default="" hint="The search text criteria" ftLabel="Search" ftClass="solr-search-criteria" />
	<cfproperty ftSeq="120" ftFieldset="General" name="operator" type="string" default="" hint="The operator used for the search" ftLabel="Search Operator" ftType="list" ftList="any:Any of these words,all:All of these words,phrase:These words as a phrase" />
	<cfproperty ftSeq="130" ftFieldset="General" name="lContentTypes" type="string" default="" hint="The content types to be searched" ftLabel="Content Types" ftType="list" ftListData="getContentTypeList" />
	<cfproperty ftSeq="140" ftFieldset="General" name="orderBy" type="string" default="rank" hint="The sort order of the results" ftLabel="Sort Order" ftType="list" ftList="rank:Relevance,date:Date" />
	
	<cfproperty name="bSearchPerformed" type="boolean" default="false" hint="Will be true if any search has been performed" />
	
	<cffunction name="getContentTypeList" access="public" output="false" returntype="string" hint="Returns a list used to populate the lCollections field dropdown selection">
		<cfargument name="objectid" required="true" hint="The objectid of this object" />
		
		<cfset var oContentType = application.fapi.getContentType("solrProContentType") />
		<cfset var qContentTypes = oContentType.getAllContentTypes() />
		<cfset var lResult = ":All" />
		
		<cfloop query="qContentTypes">
			<cfset lResult = listAppend(lResult, "#qContentTypes.contentType[qContentTypes.currentRow]#:#qContentTypes.title[qContentTypes.currentRow]#") />
		</cfloop>
		
		<cfreturn lResult />
	</cffunction>
	
	<cffunction name="getSearchResults" access="public" output="false" returntype="struct" hint="Returns a structure containing extensive information of the search results">
		<cfargument name="objectid" required="true" hint="The objectid of the farsolrSearch object containing the details of the search" />
		<cfargument name="typename" required="false" default="solrProSearch" hint="The solr search form type used to control the search." />
		<cfargument name="bSpellcheck" required="false" default="true" hint="enable/disable spellchecker" />
		<cfargument name="rows" required="false" default="10" />
		<cfargument name="page" required="false" default="1" />
		
		<cfset var startRow = ((arguments.page - 1) * arguments.rows) />
		<cfset var stResult = { bSearchPerformed = 0 } />
		<cfset var oSearchForm = application.fapi.getContentType(arguments.typename) />
		<cfset var stSearchForm = oSearchForm.getData(objectid = arguments.objectid) />
		<cfset var oContentType = application.fapi.getContentType("solrProContentType") />
		<cfset var params = {} />
		
		<cfif stSearchForm.bSearchPerformed eq 1>
			
			<!--- TODO: validate the form submission data --->
			
			<!--- TODO: calculate the start row and num rows --->
			
			<!--- convert search criteria into a proper solr query string (using chosen operator (any,all,phrase) and target collection, if specified) --->
			
			<!--- spellcheck --->
			<cfif arguments.bSpellcheck is true>
				<cfset params["spellcheck"] = true />
				<cfset params["spellcheck.count"] = 1 />
				<cfset params["spellcheck.q"] = stSearchForm.q />
				<cfif listLen(stSearchForm.q, " ") gt 1>
					<cfset stParams["spellcheck.dictionary"] = "phrase" />
				<cfelse>
					<cfset stParams["spellcheck.dictionary"] = "default" />
				</cfif>
				<cfset params["spellcheck.build"] = false />
				<cfset params["spellcheck.onlyMorePopular"] = true />
				<cfset params["spellcheck.collate"] = true />
			<cfelse>
				<cfset params["spellcheck"] = false />
			</cfif>

			<!--- escape lucene special chars (+ - && || ! ( ) { } [ ] ^ " ~ * ? : \) --->
			<cfset var q = reReplaceNoCase(stSearchForm.q,'([\+\-!(){}\[\]\^"~*?:\\]|&&|\|\|)',"\\\1","ALL") />
			
			<!--- remove operators from string (AND, OR, NOT) --->
			<cfset q = trim(reReplaceNoCase(q,"^AND |^OR |^NOT | AND | OR | NOT | AND$| OR$| NOT$"," ","ALL")) />
			
			<cfif stSearchForm.operator eq "all">
				<cfset q = "(" & reReplace(q,"[[:space:]]{1,}"," AND ","ALL") & ")" />
			<cfelseif stSearchForm.operator eq "any">
				<cfset q = "(" & reReplace(q,"[[:space:]]{1,}"," OR ","ALL") & ")" />
			<cfelseif stSearchForm.operator eq "phrase">
				<cfset q = '("' & q & '")' />
			</cfif>
			
			<cfif listLen(stSearchForm.lContentTypes)>
				<cfset q = q & " AND (" />
				
				<cfset var counter = 0 />
				<cfloop list="#stSearchForm.lContentTypes#" index="type">
					<cfset counter++ />
					
					<cfif counter gt 1>
						<cfset q = q & " OR " />
					</cfif>
					
					<cfset q = q & "typename:" & type />
					
				</cfloop>
			
				<cfset q = q & ")" />
			</cfif>
			
			<!--- get the field list for the content type(s) we are searching --->
			<cfif listLen(stSearchForm.lContentTypes) eq 1>
				<cfset params["qf"] = oContentType.getFieldListCacheForType(stSearchForm.lContentTypes) />
			<cfelseif listLen(stSearchForm.lContentTypes) gte 1>
				<cfset params["qf"] = oContentType.getFieldListForTypes(stSearchForm.lContentTypes) />
			</cfif>
			
			<!--- return the score --->
			<cfset params["fl"] = "*,score" />
						
			<!--- apply the sort --->
			<cfif stSearchForm.orderby eq "date">
				<cfset params["sort"] = "datetimelastupdated desc" />
			</cfif>
			
			<cfset var oSearchService = application.fapi.getContentType("solrProContentType") />
			<cfset stResult = oSearchService.search(q = trim(q), start = startRow, rows = arguments.rows, params = params) />
			<cfset stResult.bSearchPerformed = 1 />
			
			<!--- TODO: log the search and result stats --->
				
		</cfif>
		
		<cfreturn stResult />
		
	</cffunction>
	
	<cffunction name="getSuggestion" access="public" output="false" returntype="string" hint="Returns suggestion text based on results from solr">
		
		<cfargument name="spellcheck" type="array" required="true" />
		
		<cfargument name="q" type="string" required="true" />
		<cfargument name="operator" type="string" required="false" default="any" />
		<cfargument name="lContentTypes" type="string" required="false" default="" />
		<cfargument name="orderby" type="string" required="false" default="rank" />
		
		<cfargument name="startWrap" type="string" required="false" default="<strong>" />
		<cfargument name="endWrap" type="string" required="false" default="</strong>" />
		<cfargument name="linkUrl" type="string" required="false" default="#application.fapi.getLink(objectid = request.navid)#" />
		
		<!--- if we have no spell check info, just return empty string --->
		<cfif not arrayLen(arguments.spellcheck)>
			<cfreturn "" />
		</cfif>
		
		<!--- build the suggestion --->
		<cfset var suggestion = arguments.q />
		<cfset var s = "" />
		<cfloop array="#arguments.spellcheck#" index="s">
			<!--- create one w/ the wrap --->
			<cfset suggestion = trim(reReplaceNoCase(suggestion,"^#s.token# | #s.token# | #s.token#$"," " & arguments.startWrap & s.suggestions[1] & arguments.endWrap & " ","ALL")) />
			<!--- and one w/o --->
			<cfset arguments.q = trim(reReplaceNoCase(arguments.q,"^#s.token# | #s.token# | #s.token#$"," " & s.suggestions[1] & " ","ALL")) />
		</cfloop>
		
		<!--- build the url for the link --->
		<cfset var addValues = {
			"q" = arguments.q,
			"operator" = arguments.operator,
			"orderby" = arguments.orderby
		} />
		<cfif len(trim(arguments.lContentTypes))>
			<cfset addValues["lContentTypes"] = arguments.lContentTypes />
		</cfif>
		<cfset arguments.linkUrl = application.fapi.fixUrl(
			url = arguments.linkUrl, 
			addValues = addValues
		) />
		
		<!--- build the HTML and return it --->
		<cfset var str = "" />
		<cfsavecontent variable="str">
			<cfoutput>
				Did you mean <a href="#arguments.linkUrl#">#suggestion#</a>?
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn trim(str) />
		
	</cffunction>
	
</cfcomponent>