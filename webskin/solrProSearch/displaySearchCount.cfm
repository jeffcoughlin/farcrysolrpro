<cfsetting enablecfoutputonly="true" />

<cfparam name="stParam.qTime" default="0" />
<cfparam name="stParam.totalResults" default="0" />

<cfoutput><p>Your search <cfif len(stobj.q)>for "#application.stPlugins.farcrysolrpro.oCustomFunctions.xmlSafeText(stobj.q)#" </cfif>produced #stParam.totalResults# result<cfif stParam.totalResults neq 1>s</cfif> and took #numberFormat(stParam.qTime/1000,'9.99')# seconds.</p></cfoutput>

<cfsetting enablecfoutputonly="false" />