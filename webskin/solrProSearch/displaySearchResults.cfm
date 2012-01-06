<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="stParam.results" default="#arrayNew(1)#" />

<cfloop array="#stParam.results#" index="result">
	
	<skin:view webskin="displaySearchResult" typename="#result.typename#" stObject="#result#" />
	
</cfloop>
			
<cfsetting enablecfoutputonly="false" />