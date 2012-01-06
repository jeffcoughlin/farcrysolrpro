<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfparam name="stParam.spellcheck" default="" />

<cfif structKeyExists(stParam,"spellcheck")>
	<cfdump var="#stParam.spellcheck#" />
</cfif>


<cfsetting enablecfoutputonly="false">