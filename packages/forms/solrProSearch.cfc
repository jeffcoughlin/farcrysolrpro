<cfcomponent output="false" extends="farcry.core.packages.forms.forms" displayname="Solr Pro Search" hint="Handles searching Solr collections">
	<cfproperty ftSeq="110" ftFieldset="General" name="q" type="string" default="" hint="The search text criteria" ftLabel="Search" ftClass="solr-search-criteria" />
	<cfproperty ftSeq="120" ftFieldset="General" name="operator" type="string" default="" hint="The operator used for the search" ftLabel="Search Operator" ftType="list" ftList="any:Any of these words,all:All of these words,phrase:These words as a phrase" />
	<cfproperty ftSeq="130" ftFieldset="General" name="lContentTypes" type="string" default="" hint="The content types to be searched" ftLabel="Content Types" ftType="list" ftListData="getContentTypeList" />
	<cfproperty ftSeq="140" ftFieldset="General" name="orderBy" type="string" default="rank" hint="The sort order of the results" ftLabel="Sort Order" ftType="list" ftList="rank:Relevance,date:Date" />
	
	<!---<cfproperty name="page" type="integer" default="1" hint="The page of results to return.  Use either page or start to determine which records to display." />
	<cfproperty name="start" type="integer" default="0" hint="The start row of results.  Use either page or start to determine which records to display." />
	<cfproperty name="rows" type="integer" default="10" hint="The number of items to display per page" />--->
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
			<cfset var q = trim(reReplaceNoCase(q,"^AND |^OR |^NOT | AND | OR | NOT | AND$| OR$| NOT$"," ","ALL")) />
			
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
			<cfelse>
				<cfset params["qf"] = oContentType.getFieldListForTypes(stSearchForm.lContentTypes) />
			</cfif>
			
			<!--- return the score --->
			<cfset params["fl"] = "*,score" />
						
			<!--- apply the sort --->
			<cfif stSearchForm.orderby eq "date">
				<cfset params["sort"] = "datetimelastupdated desc" />
			</cfif>
			
			<cfset var oSearchService = application.fapi.getContentType("solrProContentType") />
			<cfset stResult = oSearchService.search(q = trim(q), start = 0, rows = 10, params = params) />
			<cfset stResult.bSearchPerformed = 1 />
			
			<!--- TODO: log the search and result stats --->
				
		</cfif>
		
		<cfreturn stResult />
		
	</cffunction>
	
</cfcomponent>