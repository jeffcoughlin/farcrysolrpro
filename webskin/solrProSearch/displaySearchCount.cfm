<cfsetting enablecfoutputonly="true" />

<cfparam name="stParam.totalReslts" default="0" />

<cfoutput><p>Your search <cfif len(stobj.q)>for "#application.stPlugins.farcrysolrpro.oCustomFunctions.xmlSafeText(stobj.q)#" </cfif>produced #stParam.totalResults# result<cfif stParam.totalResults neq 1>s</cfif>.</p></cfoutput>

<cfsetting enablecfoutputonly="false" />