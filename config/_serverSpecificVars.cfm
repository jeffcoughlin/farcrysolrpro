<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:registerCss id="solrPro-customWebtopStyles" media="all" baseHref="/farcry/plugins/farcrysolrpro/www/css" lFiles="customWebtopStyles.cfm" />
<skin:registerCss id="siteSearch-css" media="all" baseHref="/farcry/plugins/farcrysolrpro/www/css" lFiles="search.cfm" />

<cfscript>
	// on FarCry 6, alias the jquery & jquery-ui JS/CSS assets to match FarCry 7 (so we only have one version check, rather than conditionals all over the place)
	oSysInfo = createObject("component", application.fc.utils.getPath(package = "farcry", component = "sysinfo"));
	if (oSysInfo.getMajorVersion() lt 7) {
		application.fapi.registerJs(id = "fc-jquery", lCombineIDs = "jquery", append = "$.noConflict(); $j = jQuery.noConflict();");
		application.fapi.registerJs(id = "fc-jquery-ui", lCombineIDs = "jquery-ui");
		application.fapi.registerCss(id = "fc-jquery-ui", lCombineIDs = "jquery-ui");
	}
</cfscript>

<cfsetting enablecfoutputonly="false" />