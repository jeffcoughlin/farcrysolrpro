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
			<cfif qContentTypes.bEnableSearch eq 1>
				<cfset lResult = listAppend(lResult, "#qContentTypes.contentType[qContentTypes.currentRow]#:#qContentTypes.title[qContentTypes.currentRow]#") />
			</cfif>
		</cfloop>
		
		<cfreturn lResult />
	</cffunction>
	
	<cffunction name="getSearchResults" access="public" output="false" returntype="struct" hint="Returns a structure containing extensive information of the search results">
		<cfargument name="objectid" required="true" hint="The objectid of the farsolrSearch object containing the details of the search" />
		<cfargument name="typename" required="false" default="solrProSearch" hint="The solr search form type used to control the search." />
		<cfargument name="bSpellcheck" required="false" default="true" hint="enable/disable spellchecker" />
		<cfargument name="rows" required="false" default="10" />
		<cfargument name="page" required="false" default="1" />
		<cfargument name="bHighlight" required="false" type="boolean" default="true" hint="enable/disable highlighting" />
		<cfargument name="hlFragSize" required="false" type="numeric" default="200" hint="The length in characters of each highlight snippet" />
		<cfargument name="hlSnippets" required="false" type="numeric" default="3" hint="The number of highlighting snippets to return" />
		<cfargument name="hlPre" required="false" type="string" default="<strong>" hint="HTML to use to wrap instances of search terms" />
		<cfargument name="hlPost" required="false" type="string" default="</strong>" hint="HTML to use to wrap instances of search terms" />
		<cfargument name="bLogSearch" required="false" type="boolean" default="#application.fapi.getConfig(key = 'solrserver', name = 'bLogSearches', default = true)#" hint="Log the search criteria and number of results?" />
		<cfargument name="bCleanString" required="false" type="boolean" default="true" />
		<cfargument name="bFilterBySite" required="false" type="boolean" default="true" hint="If using a single Solr core for multiple sites, do you want to filter results for only this site (true) or for all sites (false)?" />
		
		<!--- calculate the start row --->
		<cfset var startRow = ((arguments.page - 1) * arguments.rows) />
		<cfset var stResult = { bSearchPerformed = 0 } />
		<cfset var oSearchForm = application.fapi.getContentType(arguments.typename) />
		<cfset var stSearchForm = oSearchForm.getData(objectid = arguments.objectid) />
		<cfset var oContentType = application.fapi.getContentType("solrProContentType") />
		<cfset var params = {} />
		
		<cfif stSearchForm.bSearchPerformed eq 1>
			
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
			
			<cfset var q = oContentType.buildQueryString(searchString = stSearchForm.q, operator = stSearchForm.operator, lContentTypes = stSearchForm.lContentTypes, bCleanString = arguments.bCleanString, bFilterBySite = arguments.bFilterBySite) />
			
			<!--- get the field list for the content type(s) we are searching --->
			<!--- if doing a "PHRASE" search, remove all PHONETIC fields. to match Google and other search engine functionality --->
			<!--- <cfif listLen(stSearchForm.lContentTypes) eq 1>
				<cfset params["qf"] = oContentType.getFieldListCacheForType(typename = stSearchForm.lContentTypes, bIncludePhonetic = (stSearchForm.operator neq "phrase")) />
			<cfelseif listLen(stSearchForm.lContentTypes) gte 1>
				<cfset params["qf"] = oContentType.getFieldListForTypes(lContentTypes = stSearchForm.lContentTypes, bIncludePhonetic = (stSearchForm.operator neq "phrase")) />
			<cfelse>
				<cfset params["qf"] = oContentType.getFieldListForTypes(bIncludePhonetic = (stSearchForm.operator neq "phrase")) />
			</cfif> --->
			<!--- TODO: there is a bug in the field list methods.  some field types are not returned when bIncludePhonetic is false --->
			<cfif listLen(stSearchForm.lContentTypes) eq 1>
				<cfset params["qf"] = oContentType.getFieldListCacheForType(typename = stSearchForm.lContentTypes, bIncludePhonetic = true) />
			<cfelseif listLen(stSearchForm.lContentTypes) gte 1>
				<cfset params["qf"] = oContentType.getFieldListForTypes(lContentTypes = stSearchForm.lContentTypes, bIncludePhonetic = true) />
			<cfelse>
				<cfset params["qf"] = oContentType.getFieldListForTypes(bIncludePhonetic = true) />
			</cfif>
			
			<!--- return the score --->
			<cfset params["fl"] = "*,score" />
			
			<!--- apply the sort --->
			<cfif stSearchForm.orderby eq "date">
				<cfset params["sort"] = "datetimelastupdated desc" />
			</cfif>
			
			<!--- get highlighting --->
			<cfif arguments.bHighlight>
				<cfset params["hl"] = true />
				<cfset params["hl.fragsize"] = arguments.hlFragSize />
				<cfset params["hl.snippets"] = arguments.hlSnippets />
				<cfset params["hl.fl"] = "fcsp_highlight" />
				<cfset params["hl.simple.pre"] = arguments.hlPre />
				<cfset params["hl.simple.post"] = arguments.hlPost />
			</cfif>
			
			<cfset var oSearchService = application.fapi.getContentType("solrProContentType") />
			<cfset stResult = oSearchService.search(q = trim(q), start = startRow, rows = arguments.rows, params = params) />
			<cfset stResult.bSearchPerformed = 1 />
			
			<cfif arguments.bSpellcheck>
				<cfset stResult.suggestion = getSuggestion(
					linkURL = application.fapi.getLink(objectid = request.navid), 
					spellcheck = stResult.spellcheck, 
					q = stSearchForm.q,
					operator = stSearchForm.operator,
					lContentTypes = stSearchForm.lContentTypes,
					orderby = stSearchForm.orderby,
					startWrap = '<strong>', 
					endWrap = '</strong>'
				) />
			<cfelse>
				<cfset stResult.suggestion = "" />
			</cfif>
			
			<!--- ensure log is enabled, only log search for page 1 --->
			<cfif arguments.bLogSearch and arguments.page eq 1>
				<!--- log the search and result stats --->
				<cfset oLog = application.fapi.getContentType("solrProSearchLog") />
				<cfset stLog = {
					numResults = stResult.totalResults,
					q = stSearchForm.q,
					lContentTypes = stSearchForm.lContentTypes,
					operator = stSearchForm.operator,
					orderBy = stSearchForm.orderBy,
					suggestion = stResult.suggestion
				} />
				<cfset oLog.createData(stLog) />
			</cfif>
			
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
			<cfset suggestion = trim(reReplaceNoCase(suggestion,"^#s.token# | #s.token# | #s.token#$|^#s.token#$"," " & arguments.startWrap & s.suggestions[1] & arguments.endWrap & " ","ALL")) />
			<!--- and one w/o --->
			<cfset arguments.q = trim(reReplaceNoCase(arguments.q,"^#s.token# | #s.token# | #s.token#$|^#s.token#$"," " & s.suggestions[1] & " ","ALL")) />
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
			<cfoutput>Did you mean <a href="#arguments.linkUrl#">#suggestion#</a>?</cfoutput>
		</cfsavecontent>
		
		<cfreturn trim(str) />
		
	</cffunction>
	
</cfcomponent>