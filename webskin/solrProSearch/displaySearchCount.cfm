<cfsetting enablecfoutputonly="true" />

<cfparam name="stParam.totalReslts" default="0" />
<cfparam name="stParam.searchCriteria" default="" />

<cfoutput><p>Your search <cfif len(stParam.searchCriteria)>for "#application.stPlugins.farcrysolrpro.oCustomFunctions.xmlSafeText(stParam.searchCriteria)#" </cfif>produced #stParam.totalResults# result<cfif stParam.totalResults neq 1>s</cfif>.</p></cfoutput>

<cfsetting enablecfoutputonly="false" />