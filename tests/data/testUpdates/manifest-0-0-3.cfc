<cfcomponent extends="farcry.core.webtop.install.manifest" name="manifest">

	<cfset this.name = "FarCry Solr Pro" />
	<cfset this.description = "An advanced Solr search implementation" />
	<cfset this.lRequiredPlugins = "" />
	<cfset this.version = "0.0.3" />
	<cfset this.buildState = "private beta" />
	<cfset this.license = {
		name = "Apache License 2.0",
		link = "http://www.apache.org/licenses/LICENSE-2.0"
	} />
	<cfset addSupportedCore(majorVersion="6", minorVersion="0", patchVersion="18") />
	<cfset addSupportedCore(majorVersion="6", minorVersion="1", patchVersion="3") />
	<cfset addSupportedCore(majorVersion="6", minorVersion="2", patchVersion="0") />
  <cfset this.aVersions = [
  {
    "version"="0.0.3",
    "releasedate"="2012-04-03",
    "description"="<p>This is a sample description for the the 0.0.3 release.</p>",
    "changelog"="<ul><li>New features</li><li>Tika was upgraded from v1.0 to v1.1</li><li>bug fixes</li></ul>",
    "downloads"=[
      {
        "url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/0.0.3",
        "shortdesc"="w/ Solr 3.5",
        "size"="41MB"
      },
      {
        "url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/0.0.3",
        "shortdesc"="<em>(plugin only)</em>",
        "size"="28MB"
      }
    ],
    "requirements"={
      "cfml"=["ColdFusion 9","Railo 3.3"],
      "farcry"=["6.2","6.1.4","6.1.19"],
      "solr"=["3.5"]
    },
    "repository"={
      "url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/0.0.3"
    }
  },
  {
    "version"="0.0.2",
    "releasedate"="2012-03-28",
    "description"="<p>This is a sample description for the the 0.0.2 release.</p>",
    "changelog"="<ul><li>bug fixes</li></ul>",
    "downloads"=[
      {
        "url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/0.0.2",
        "shortdesc"="w/ Solr 3.5",
        "size"="41MB"
      },
      {
        "url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/0.0.2",
        "shortdesc"="<em>(plugin only)</em>",
        "size"="28MB"
      }
    ],
    "requirements"={
      "cfml"=["ColdFusion 9","Railo 3.3"],
      "farcry"=["6.2","6.1.3","6.1.18"],
      "solr"=["3.5"]
    },
    "repository"={
      "url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/0.0.2"
    }
  },
  {
    "version"="0.0.1",
    "releasedate"="2012-02-25",
    "description"="<p>This is a sample description for the the 0.0.1 release.</p>",
    "changelog"="<ul><li>bug fixes</li></ul>",
    "downloads"=[
      {
        "url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/0.0.1",
        "shortdesc"="w/ Solr 3.5",
        "size"="41MB"
      },
      {
        "url"="https://github.com/jeffcoughlin/farcrysolrpro/zipball/0.0.1",
        "shortdesc"="<em>(plugin only)</em>",
        "size"="28MB"
      }
    ],
    "requirements"={
      "cfml"=["ColdFusion 9","Railo 3.3"],
      "farcry"=["6.2","6.1.3","6.1.18"],
      "solr"=["3.5"]
    },
    "repository"={
      "url"="https://github.com/jeffcoughlin/farcrysolrpro/tree/0.0.1"
    }
  }
] />
</cfcomponent>