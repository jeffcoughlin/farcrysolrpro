<cfcomponent extends="farcry.core.webtop.install.manifest" name="manifest">

	<cfset this.name = "FarCry Solr Pro" />
	<cfset this.description = "An advanced Solr search implementation" />
	<cfset this.lRequiredPlugins = "" />
	<cfset this.version = "1.1.1" />
	<cfset this.buildState = "" />
	<cfset this.license = {
		name = "Apache License 2.0",
		link = "http://www.apache.org/licenses/LICENSE-2.0"
	} />
	<cfset addSupportedCore(majorVersion="6", minorVersion="0", patchVersion="19") />
	<cfset addSupportedCore(majorVersion="6", minorVersion="1", patchVersion="4") />
	<cfset addSupportedCore(majorVersion="6", minorVersion="2", patchVersion="0") />
	<cfset this.aVersions = [
	{
		"version"="1.1.1",
		"releasedate"="2012-05-30",
		"description"="",
		"changelog"="<ul><li>Several bug fixes & performance improvements.</li><li>Implements FarCry 6.2 new event publish/subscribe model.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.1.1",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="https://github.com/downloads/jeffcoughlin/farcrysolrpro/farcrysolrpro-nosolr-1.1.1.zip",
				"shortdesc"="<em>(plugin only)</em>",
				"size"="22MB"
			}
		],
		"requirements"={
			"cfml"=["ColdFusion 9","Railo 3.3"],
			"farcry"=["6.2","6.1.4","6.0.19"],
			"solr"=["3.5"]
		},
		"repository"={
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.1.1"
		}
	},
	{
		"version"="1.1.0",
		"releasedate"="2012-05-07",
		"description"="",
		"changelog"="<ul><li>Several bug fixes</li><li>Introduces fcsp_id as the uniqueKey field instead of objectid.  Be sure to update your project's schema.xml from the version in the templates directory.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.1.0",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="https://github.com/downloads/jeffcoughlin/farcrysolrpro/farcrysolrpro-nosolr-1.1.0.zip",
				"shortdesc"="<em>(plugin only)</em>",
				"size"="22MB"
			}
		],
		"requirements"={
			"cfml"=["ColdFusion 9","Railo 3.3"],
			"farcry"=["6.2","6.1.4","6.0.19"],
			"solr"=["3.5"]
		},
		"repository"={
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.1.0"
		}
	},
	{
		"version"="1.0.2",
		"releasedate"="2012-04-13",
		"description"="",
		"changelog"="<ul><li>Fixes a bug related to content type specific searches</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.0.2",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="https://github.com/downloads/jeffcoughlin/farcrysolrpro/farcrysolrpro-nosolr-1.0.2.zip",
				"shortdesc"="<em>(plugin only)</em>",
				"size"="22MB"
			}
		],
		"requirements"={
			"cfml"=["ColdFusion 9","Railo 3.3"],
			"farcry"=["6.2","6.1.4","6.0.19"],
			"solr"=["3.5"]
		},
		"repository"={
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.0.2"
		}
	},
	{
		"version"="1.0.1",
		"releasedate"="2012-04-05",
		"description"="",
		"changelog"="<ul><li>Documentation updates</li><li>Ant build update</li><li>Config defaults updated</li><li>Added purge logs cron job</li><li>Bug fixes</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.0.1",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="https://github.com/downloads/jeffcoughlin/farcrysolrpro/farcrysolrpro-nosolr-1.0.1.zip",
				"shortdesc"="<em>(plugin only)</em>",
				"size"="22MB"
			}
		],
		"requirements"={
			"cfml"=["ColdFusion 9","Railo 3.3"],
			"farcry"=["6.2","6.1.4","6.0.19"],
			"solr"=["3.5"]
		},
		"repository"={
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.0.1"
		}
	},
	{
		"version"="1.0.0",
		"releasedate"="2012-04-02",
		"description"="",
		"changelog"="<ul><li>Initial release</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.0.0",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="https://github.com/downloads/jeffcoughlin/farcrysolrpro/farcrysolrpro-nosolr-1.0.0.zip",
				"shortdesc"="<em>(plugin only)</em>",
				"size"="22MB"
			}
		],
		"requirements"={
			"cfml"=["ColdFusion 9","Railo 3.3"],
			"farcry"=["6.2","6.1.4","6.0.19"],
			"solr"=["3.5"]
		},
		"repository"={
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.0.0"
		}
	}
	] />
</cfcomponent>