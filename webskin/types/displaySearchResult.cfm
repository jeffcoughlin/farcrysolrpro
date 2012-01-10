<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Search Result --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset oCustomFunctions = application.stPlugins.farcrysolrpro.oCustomFunctions />

<!---<cfdump var="#stobj#" />--->

<!--- TODO: trim all stObj fields --->

<!--- TODO: Get title and teaser fields --->
<!--- For the moment, assume we have teaser_text_stored, and title_text_stored --->

<!--- Get result title --->
<cfif structKeyExists(stObj, "title")>
	<cfset variables.resultTitle = oCustomFunctions.xmlSafeText(stObj.title) />
<cfelse>
	<cfset variables.resultTitle = oCustomFunctions.xmlSafeText(stObj.label) />
</cfif>

<!--- Get result teaser --->
<cfif structKeyExists(stObj, "teaser_text_stored") and stObj.teaser_text_stored neq "">
	<cfset variables.teaser = oCustomFunctions.tagStripped(stObj.teaser_text_stored) />
<cfelseif 	structKeyExists(stObj, "body_text_stored") and stObj.body_text_stored neq "">
	<cfset variables.teaser = oCustomFunctions.tagStripped(stObj.body_text_stored) />
<cfelse>
	<cfset variables.teaser = "" />
</cfif>

<!--- Get result image teaser --->
<cfif structKeyExists(stObj, "teaserimage_string_stored") and stObj.teaserimage_string_stored neq "">
	<cfset variables.teaserImage = stObj.teaserimage_string_stored />
<cfelse>
	<cfset variables.teaserImage = "" />
</cfif>

<!--- Highlight search string where found --->
<!---<cfset oSearchService = createobject("component", "farcry.plugins.farcrysolr.packages.custom.solrService").init() />
<cfset variables.teaser = oSearchService.highlightSummary(searchCriteria="#stParam.searchCriteria#", summary="#teaser#") />--->

<!--- Get result date --->
<cfif structKeyExists(stObj, "publishDate")>
	<cfset variables.resultDate = stObj.publishDate />
<cfelse>
	<cfset variables.resultDate = stObj.dateTimeLastUpdated />
</cfif>

<!--- abbreviate teaser --->
<cfset teaser = oCustomFunctions.abbreviate(teaser, 450) />

<!--- Get Abbreviated Link --->
<!---
<cfsavecontent variable="abbrLink">
  <cfoutput>http://middlesexhospital.org</cfoutput><skin:buildLink objectid="#stObj.objectId#" urlOnly="true" />
</cfsavecontent>
<cfif len(abbrLink) gt 83>
  <cfsavecontent variable="abbrLink">
    <cfoutput>http://middlesexhospital...#right(abbrLink, 60)#</cfoutput>
  </cfsavecontent>
</cfif>
--->

<!--- Get result link --->
<skin:buildlink objectid="#stObj.objectID#" r_url="itemUri" />

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
          <p>#oCustomFunctions.XHTMLParagraphFormat(variables.teaser)#<cfif right(variables.teaser,3) EQ "..."> <a href="#itemUri#" title="#variables.resultTitle#">more</a></cfif></p>
        </div>
        <div class="searchResultMeta">
          <!---<cfif myNavId neq ""><div class="searchResultBreadCrumbs"><myskin:breadcrumb startLevel="#request.stSettings.startLevel#" objectid="#myNavId#" ulClass="breadcrumbs" here="#variables.resultTitle#" separator=" / " bShowHome="0" bShowTextOnly="true" /></div></cfif>--->
          <!--- <div class="searchResultLocation"><skin:buildLink objectid="#stObj.objectId#" linkText="#abbrLink#" /></div> --->
          <div class="searchResultFileType">#application.stCoapi[stobj.typename].displayName#</div>
          <div class="searchResultDate divider">#dateFormat(variables.resultDate, "mmm d, yyyy")#<!---  #timeFormat(variables.resultDate, "h:mm tt")# EST ---></div>
        </div>
      </div>
    </cfoutput>



<cfsetting enablecfoutputonly="false" />