<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="stParam.suggestion" default="" />

<cfif len(trim(stParam.suggestion))>
	
	<cfoutput>
		<div class="searchSuggest">
			<p>#stParam.suggestion#</p>
		</div>	
	</cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="false" />