<cfcomponent extends="farcry.core.webtop.install.manifest" name="manifest">

	<cfset this.name = "FarCry Solr Pro" />
	<cfset this.description = "An advanced Solr search implementation" />
	<cfset this.lRequiredPlugins = "" />
	<cfset this.version = "1.2.6" />
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
		"version"="1.2.6",
		"releasedate"="2013-05-15",
		"description"="",
		"changelog"="<ul><li>Fixes a bug related to indexed date fields.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.2.6",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.2.6.zip",
				"shortdesc"="<em>(plugin only)</em>",
				"size"="24MB"
			}
		],
		"requirements"={
			"cfml"=["ColdFusion 9","Railo 3.3"],
			"farcry"=["6.2","6.1.4","6.0.19"],
			"solr"=["3.5"]
		},
		"repository"={
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.2.6"
		}
	},
	{
		"version"="1.2.5",
		"releasedate"="2012-12-12",
		"description"="",
		"changelog"="<ul><li>Indexing performance enhacements for large datasets.</li><li>Increase max query size to 1 billion records.</li><li>Added bRemoveOldDataFromSolr boolean to indexRecords() for the option to do faster mass batch indexing.<ul><li>Be sure to update any custom contentToIndex() methods in your types to account for new arguments/filters. See online documentation for filtering examples).</li></ul></li><li>Added GET/POST method options for Solr queries.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.2.5",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.2.5.zip",
				"shortdesc"="<em>(plugin only)</em>",
				"size"="24MB"
			}
		],
		"requirements"={
			"cfml"=["ColdFusion 9","Railo 3.3"],
			"farcry"=["6.2","6.1.4","6.0.19"],
			"solr"=["3.5"]
		},
		"repository"={
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.2.5"
		}
	},
	{
		"version"="1.2.4",
		"releasedate"="2012-11-26",
		"description"="",
		"changelog"="<ul><li>Fixes a elevation bug (be sure to update your project's schema.xml from the version in the templates directory).</li><li>Documentation fix</li><li>Better error logging for Tika file parsing.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.2.4",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.2.4.zip",
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
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.2.4"
		}
	},
	{
		"version"="1.2.3",
		"releasedate"="2012-11-07",
		"description"="",
		"changelog"="<ul><li>Fixes a bug that prevented Tika parsed content from being searched.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.2.3",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.2.3.zip",
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
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.2.3"
		}
	},
	{
		"version"="1.2.2",
		"releasedate"="2012-10-24",
		"description"="",
		"changelog"="<ul><li>Upgrade Tika to 1.2.</li><li>Bug fixes.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.2.2",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.2.2.zip",
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
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.2.2"
		}
	},
	{
		"version"="1.2.1",
		"releasedate"="2012-08-16",
		"description"="",
		"changelog"="<ul><li>Add support for descending date order.</li><li>Allow for custom query parameters.</li><li>Query builder is more robust.</li><li>Bug fixes.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.2.1",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.2.1.zip",
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
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.2.1"
		}
	},
	{
		"version"="1.2.0",
		"releasedate"="2012-06-20",
		"description"="",
		"changelog"="<ul><li>Allows for custom indexing logic.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.2.0",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.2.0.zip",
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
			"url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/1.2.0"
		}
	},
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
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.1.1.zip",
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
		"changelog"="<ul><li>Several bug fixes.</li><li>Introduces fcsp_id as the uniqueKey field instead of objectid.  Be sure to update your project's schema.xml from the version in the templates directory.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.1.0",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.1.0.zip",
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
		"changelog"="<ul><li>Fixes a bug related to content type specific searches.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.0.2",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.0.2.zip",
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
		"changelog"="<ul><li>Documentation updates.</li><li>Ant build update.</li><li>Config defaults updated.</li><li>Added purge logs cron job.</li><li>Bug fixes.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.0.1",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.0.1.zip",
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
		"changelog"="<ul><li>Initial release.</li></ul>",
		"downloads"=[
			{
				"url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/1.0.0",
				"shortdesc"="w/ Solr 3.5",
				"size"="38MB"
			},
			{
				"url"="http://www.n42designs.com/farcrysolrpro/farcrysolrpro-nosolr-1.0.0.zip",
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