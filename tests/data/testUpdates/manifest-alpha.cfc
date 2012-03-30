<cfcomponent extends="farcry.core.webtop.install.manifest" name="manifest">

	<cfset this.name = "FarCry Solr Pro" />
	<cfset this.description = "An advanced Solr search implementation" />
	<cfset this.lRequiredPlugins = "" />
	<cfset this.version = "alpha" />
	<cfset this.buildState = "alpha" />
	<cfset this.license = {
		name = "Apache License 2.0",
		link = "http://www.apache.org/licenses/LICENSE-2.0"
	} />
	<cfset addSupportedCore(majorVersion="6", minorVersion="0", patchVersion="18") />
	<cfset addSupportedCore(majorVersion="6", minorVersion="1", patchVersion="3") />
	<cfset addSupportedCore(majorVersion="6", minorVersion="2", patchVersion="0") />
	
</cfcomponent>