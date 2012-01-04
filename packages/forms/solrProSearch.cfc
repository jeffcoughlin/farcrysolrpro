<cfcomponent output="false" extends="farcry.core.packages.forms.forms" displayname="Solr Pro Search" hint="Handles searching Solr collections">
	<cfproperty ftSeq="1" ftFieldset="General" name="criteria" type="string" default="" hint="The search text criteria" ftLabel="Search" ftClass="solr-search-criteria" />
	<cfproperty ftSeq="2" ftFieldset="General" name="operator" type="string" default="" hint="The operator used for the search" ftLabel="Search Operator" ftType="list" ftList="any:Any of these words,all:All of these words,phrase:These words as a phrase" />
	<cfproperty ftSeq="3" ftFieldset="General" name="lContentTypes" type="string" default="" hint="The content types to be searched" ftLabel="Content Types" ftType="list" ftListData="getContentTypeList" />
	<cfproperty ftSeq="4" ftFieldset="General" name="orderBy" type="string" default="rank" hint="The sort order of the results" ftLabel="Sort Order" ftType="list" ftList="rank:Relevance,date DESC:Date" />
	<cfproperty name="bSearchPerformed" type="boolean" default="false" hint="Will be true if any search has been performed" />
	
	<cffunction name="getContentTypeList" access="public" output="false" returntype="string" hint="Returns a list used to populate the lCollections field dropdown selection">
		<cfargument name="objectid" required="true" hint="The objectid of this object" />
		
		<cfset var oContentType = application.fapi.getContentType("solrProContentType") />
		<cfset var qContentTypes = oContentType.getAllContentTypes() />
		<cfset var lResult = "" />
		
		<cfloop query="qContentTypes">
			<cfset lResult = listAppend(lResult, "#qContentTypes.objectid[qContentTypes.currentRow]#:#qContentTypes.title[qContentTypes.currentRow]#") />
		</cfloop>
		
		<cfreturn lResult />
	</cffunction>
	
	<cffunction name="getSearchResults">
		
		<!--- TODO: make this work --->
			
		<cfreturn { bSearchPerformed = false } />
		
	</cffunction>
	
</cfcomponent>