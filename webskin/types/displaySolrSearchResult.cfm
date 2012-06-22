<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Search Result --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Attributes that should be passed in by the search page --->
<cfparam name="stParam.highlighting" default="#structNew()#" />
<cfparam name="stParam.oContentType" default="#application.fapi.getContentType('solrProContentType')#" />

<!--- load the solr content type configuration information --->
<cfset stContentType = stParam.oContentType.getByContentType(contentType = stobj["typename"]) />

<!--- Variable declarations --->
<cfset oCustomFunctions = application.stPlugins.farcrysolrpro.oCustomFunctions />
<cfset variables.teaserLen = 450 />

<!--- Trim all stObj fields --->
<cfloop collection="#stObj#" item="i">
	<cfif isSimpleValue(stobj[i])>
		<cfset stObj[i] = trim(stObj[i]) />
	</cfif>
</cfloop>

<!--- Get result title --->
<cfif structKeyExists(stObj, stContentType.resultTitleField)>
	<cfif isArray(stobj[stContentType.resultTitleField]) and arrayLen(stobj[stContentType.resultTitleField]) and len(stObj[stContentType.resultTitleField][1])>
		<cfset variables.resultTitle = oCustomFunctions.xmlSafeText(stObj[stContentType.resultTitleField][1]) />
	<cfelseif isSimpleValue(stObj[stContentType.resultTitleField])>
		<cfset variables.resultTitle = oCustomFunctions.xmlSafeText(stObj[stContentType.resultTitleField]) />
	<cfelse>
		<cfset variables.resultTitle = stObj["label"] />
	</cfif>
<cfelse>
	<cfset variables.resultTitle = oCustomFunctions.xmlSafeText(stObj.label) />
</cfif>

<!--- Get result teaser --->
<cfif len(trim(stContentType.resultSummaryField)) and structKeyExists(stObj, stContentType.resultSummaryField)>
	<cfif isArray(stObj[stContentType.resultSummaryField]) and arrayLen(stObj[stContentType.resultSummaryField]) and len(stObj[stContentType.resultSummaryField][1])>
		<cfset variables.teaser = oCustomFunctions.tagStripper(stObj[stContentType.resultSummaryField][1]) />
	<cfelseif isSimpleValue(stObj[stContentType.resultSummaryField])>
		<cfset variables.teaser = oCustomFunctions.tagStripper(stObj[stContentType.resultSummaryField]) />
	<cfelse>
		<cfset vairables.teaser = "" />
	</cfif>
	<!--- abbreviate teaser --->
	<cfset variables.teaser = oCustomFunctions.abbreviate(teaser, variables.teaserLen) />
<cfelse>
	<!--- use Solr generated summary --->
	<cfset variables.teaser = "" />
	<cfif structKeyExists(stParam.highlighting, "fcsp_highlight") and isArray(stParam.highlighting["fcsp_highlight"])>
		<cfloop array="#stParam.highlighting['fcsp_highlight']#" index="hl">
			
			<!--- strip HTML (except highlighting) --->
			<cfset hl = oCustomFunctions.tagStripper(hl, "strip", "strong") />

			<!--- remove leading non-alphanumeric --->
			<cfset hl = trim(reReplaceNoCase(hl,"^[^a-z0-9<]","")) />
			
			<!--- concatenate the highlighted text strings --->
			<cfset variables.teaser = variables.teaser & "..." & hl />
			
		</cfloop>
		<cfset variables.teaser = trim(variables.teaser) & "..." />
	</cfif>
</cfif>

<!--- Get result image teaser --->
<cfif structKeyExists(stObj, stContentType.resultImageField) and len(stObj[stContentType.resultImageField])>
	<!--- if the teaser image value is a UUID, then check if it points to a dmImage object.  if it does, use the ThumbnailImage as the teaser image --->
	<cfif isArray(stObj[stContentType.resultImageField]) and isValid("uuid",stObj[stContentType.resultImageField][1])>
		<cfif application.fapi.findType(stObj[stContentType.resultImageField][1]) eq "dmImage">
			<cfset stImage = application.fapi.getContentObject(objectid = stObj[stContentType.resultImageField][1], typename = "dmImage") />
			<cfset variables.teaserImage = stImage["ThumbnailImage"] />
		</cfif>
	<cfelseif not isArray(stObj[stContentType.resultImageField]) and isValid("uuid",stObj[stContentType.resultImageField])>
		<cfif application.fapi.findType(stObj[stContentType.resultImageField]) eq "dmImage">
			<cfset stImage = application.fapi.getContentObject(objectid = stObj[stContentType.resultImageField], typename = "dmImage") />
			<cfset variables.teaserImage = stImage["ThumbnailImage"] />
		</cfif>
	<cfelse>
		<cfif isArray(stObj[stContentType.resultImageField])>
			<cfset variables.teaserImage = stObj[stContentType.resultImageField][1] />
		<cfelse>
			<cfset variables.teaserImage = stObj[stContentType.resultImageField] />
		</cfif>
	</cfif>
<cfelse>
	<cfset variables.teaserImage = "" />
</cfif>

<!--- Get result date --->
<cfif structKeyExists(stObj, "publishDate")>
	<cfset variables.resultDate = stObj.publishDate />
<cfelse>
	<cfset variables.resultDate = stObj.dateTimeLastUpdated />
</cfif>

<!--- Get result link --->
<skin:buildlink objectid="#stObj.objectID#" r_url="itemUri" />

<!--- Get Abbreviated Link --->
<cfsavecontent variable="abbrLink">
  <cfoutput>http://#cgi.server_name#<cfif cgi.server_port neq 80>:#cgi.server_port#</cfif>#itemUri#</cfoutput>
</cfsavecontent>
<cfif len(abbrLink) gt 83>
  <cfsavecontent variable="abbrLink">
    <cfoutput>http://#listFirst(cgi.server_name,'.')#<cfif listLen(cgi.server_name,'.') gte 2>.#listGetAt(cgi.server_name,2,'.')#</cfif>...#right(abbrLink, 60)#</cfoutput>
  </cfsavecontent>
</cfif>
    <cfoutput>
      <div class="searchResult">
        <div class="searchResultTitle">
          <h2><a href="#itemUri#" title="#variables.resultTitle#">#variables.resultTitle#</a></h2>
        </div></cfoutput>
        <cfif variables.teaserImage neq "" and fileExists(expandPath(variables.teaserImage))>
          <cfoutput><a href="#itemUri#" title="#variables.resultTitle#"><img src="#variables.teaserImage#" alt="#variables.resultTitle#" class="searchResultTeaserImage" /></a></cfoutput>
        </cfif>
        <cfoutput>
        <div class="searchResultContent">
          <p>#variables.teaser#<cfif right(variables.teaser,3) EQ "..."> <a href="#itemUri#" title="#variables.resultTitle#">more</a></cfif></p>
        </div>
        <div class="searchResultMeta">
          <div class="searchResultLocation"><a href="#itemUri#">#abbrLink#</a></div>
          <div class="searchResultFileType">#application.stCoapi[stObj['typename']].displayName#</div>
          <div class="searchResultDate divider">#dateFormat(variables.resultDate, "mmm d, yyyy")#<!--- #timeFormat(variables.resultDate, "h:mm tt")# ---></div>
          <cfif stObj.fcsp_documentsize gt 0><div class="searchResultSize divider">#oCustomFunctions.byteConvert(stObj.fcsp_documentsize)#</div></cfif>
        </div>
      </div>
    </cfoutput>

<cfsetting enablecfoutputonly="false" />