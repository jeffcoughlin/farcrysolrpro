<cfcomponent extends="farcry.core.webtop.install.manifest" name="manifest">

	<cfset this.name = "FarCry Solr Pro" />
	<cfset this.description = "An advanced Solr search implementation" />
	<cfset this.lRequiredPlugins = "" />
	<cfset addSupportedCore(majorVersion="6", minorVersion="0", patchVersion="18") />
	<cfset addSupportedCore(majorVersion="6", minorVersion="1", patchVersion="3") />
	
</cfcomponent>