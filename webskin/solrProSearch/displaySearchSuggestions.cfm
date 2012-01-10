<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="stParam.threshold" default="10" />
<cfparam name="stParam.totalResults" default="0" />
<cfparam name="stParam.spellcheck" default="" />

<cfif structKeyExists(stParam,"spellcheck") and stParam.totalResults lte stParam.threshold>
	
	<cfoutput>
		<div class="searchSuggest">
			<p>#getSuggestion(
					linkURL = application.fapi.getLink(objectid = request.navid), 
					spellcheck = stParam.spellcheck, 
					q = stobj.q,
					operator = stobj.operator,
					lContentTypes = stobj.lContentTypes,
					orderby = stobj.orderby,
					startWrap = '<strong>', 
					endWrap = '</strong>'
				)#</p>
		</div>	
	</cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="false" />