<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="stParam.threshold" default="10" />
<cfparam name="stParam.totalResults" default="0" />
<cfparam name="stParam.spellcheck" default="" />
<cfparam name="stParam.q" default="" />
<cfparam name="stParam.operator" default="any" />
<cfparam name="stParam.lContentTypes" default="" />
<cfparam name="stParam.orderby" default="rank" />

<cfif structKeyExists(stParam,"spellcheck") and stParam.totalResults lte stParam.threshold>
	
	<cfoutput>
		<div class="searchSuggest">
			<p>#getSuggestion(
					linkURL = application.fapi.getLink(objectid = request.navid), 
					spellcheck = stParam.spellcheck, 
					q = stParam.q,
					operator = stParam.operator,
					lContentTypes = stParam.lContentTypes,
					orderby = stParam.orderby,
					startWrap = '<strong>', 
					endWrap = '</strong>'
				)#</p>
		</div>	
	</cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="false" />