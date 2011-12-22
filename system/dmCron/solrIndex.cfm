<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Index --->
<!--- @@author: Sean Coyne (www.n42designs.com) --->

<!--- has optimization been disabled? --->
<cfparam name="url.optimize" default="true" />
<cfif not isBoolean(url.optimize)>
	<cfset url.optimize = true />
</cfif>

<cfset oContentType = application.fapi.getContentType("solrProContentType") />
<cfset oIndexedProperty = application.fapi.getContentType("solrProIndexedProperty") />

<!--- get all the content types that are being indexed --->
<cfset qContentTypes = oContentType.getAllContentTypes() />
<cfloop query="qContentTypes">
	
	<cfset stContentType = oContentType.getData(qContentTypes.objectid[qContentTypes.currentRow]) />
	
	<cfset oType = application.fapi.getContentType(stContentType.contentType) />
	
	<!--- get all the records that should be indexed --->
	<cfif structKeyExists(oType, "contentToIndex")>
		<!--- run the contentToIndex method for this content type --->
		<cfset qContentToIndex = oType.contentToIndex() />
	<cfelse>
		<!--- no contentToIndex method, just grab all the records --->
		<cfquery name="qContentToIndex" datasource="#application.dsn#">
		SELECT objectID
		FROM #oType.getTablename()#
		<cfif structkeyexists(application.stcoapi[oType.getTablename()].stprops, "status")>
		where status = 'approved'
		</cfif>
		</cfquery>
	</cfif>
	
	<!--- parse core property boosts --->
	<cfset aCorePropBoosts = listToArray(stContentType.lCorePropertyBoost) />
	<cfset stPropBoosts = {} />
	<cfloop array="#aCorePropBoosts#" index="i">
		<cfset stPropBoosts[listFirst(i,":")] = listLast(aCorePropBoosts[i],":") /> 
	</cfloop>
	
	<!--- parse custom property boosts --->
	<cfloop array="#stContentType.aIndexedProperties#" index="i">
		<cfset stIndexedProp = oIndexedProperty.getData(i) />
		<cfset stPropBoosts[stIndexedProp.fieldName] = stPropBoosts[stIndexedProp.fieldBoost] />
	</cfloop>
	
	<!--- build an object for each record --->
	<cfset stRecord = application.fapi.getContentObject(typename = oType.getTablename(), objectid = qContentToIndex.objectid[qContentToIndex.currentRow]) />
	
	<cfset doc = [] />
	
	<cfset aCoreFields = oContentType.getSolrFields(lOmitFields = "rulecontent") />
	
	<cfloop collection="#stRecord#" item="field">
		<!--- only add field if its a core property or an indexed field --->
		<cfif oContentType.hasIndexedProperty(stContentType.objectid, field) or arrayFindNoCase(aCoreFields, field)>
			
			<!--- TODO: if not a core field, map to the dynamic fields (field type, stored vs not stored, etc) --->
			
			<cfset arrayAppend(doc, {
				name = field,
				value = stRecord[field]
			}) />
			
		</cfif>
	</cfloop>
	
	<!--- grab any related rule records and index those as well --->
	<cfset arrayAppend(doc, {
	 	name = "rulecontent", 
	 	value = oType.getRuleContent(objectid = qContentToIndex.objectid[qContentToIndex.currentRow], lRuleTypes = stContentType.lIndexedRules) 
	}) />
	
	<cfloop array="#doc#" index="i">
		<cfif structKeyExists(stPropBoosts, i.name)>
			<cfset i.boost = stPropBoosts[i.name] />
		</cfif>
	</cfloop>
	
	<!--- TODO: document level boosting --->
	
	<!--- TODO: add it to solr --->
	
	<!--- TODO: delete any records in the index that are no longer in the database (use a solr "delete by query" to delete all items for this content type that are not in the qContentToIndex results) --->

</cfloop>

<!--- commit --->
<cfset oContentType.commit() />

<!--- optimize (if necessary --->
<cfif url.optimize>
	<cfset oContentType.optimize() />
</cfif>

<!--- TODO: batch the records and update the buildtodate to the last record processed --->
<!--- update the build to date for this content type --->
<cfset stContentType.buildtodate = now() />
<cfset oContentType.setData(stProperties = stContentType) />

<cfsetting enablecfoutputonly="false" />