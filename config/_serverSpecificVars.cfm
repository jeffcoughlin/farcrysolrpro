<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:registerCss id="solrPro-customWebtopStyles" media="all" baseHref="/farcry/plugins/farcrysolrpro/www/css" lFiles="customWebtopStyles.cfm" />
<skin:registerCss id="siteSearch-css" media="all" baseHref="/farcry/plugins/farcrysolrpro/www/css" lFiles="search.cfm" />

<cfscript>
	// on FarCry 6, alias the jquery & jquery-ui JS/CSS assets to match FarCry 7 (so we only have one version check, rather than conditionals all over the place)
	oSysInfo = createObject("component", application.fc.utils.getPath(package = "farcry", component = "sysinfo"));
	if (oSysInfo.getMajorVersion() eq 6) {
		param name = "application.fc.stJSLibraries" default = {};
		if (structKeyExists(application.fc.stJSLibraries, "jquery")) {
			stJquery = duplicate(application.fc.stJSLibraries["jquery"]);
			stJQuery.id = "fc-jquery";
			application.fapi.registerJs(argumentCollection = stJQuery);	
		}
		if (structKeyExists(application.fc.stJSLibraries, "jquery-ui")) {
			stJQueryUI = duplicate(application.fc.stJSLibraries["jquery-ui"]);
			stJQueryUI.id = "fc-jquery-ui";
			application.fapi.registerJs(argumentCollection = stJQueryUI);	
		}
	}
</cfscript>

<cfsetting enablecfoutputonly="false" />