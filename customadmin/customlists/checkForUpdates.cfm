<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Check for Updates --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<admin:header title="Check for Updates" />

<cfscript>
	updateUrl = "http://jeffcoughlin.github.io/farcrysolrpro/update.json";
	oUpdater = createObject("component","farcry.plugins.farcrysolrpro.packages.custom.updates").init(
		updateUrl = updateUrl,
		installManifest = application.stPlugins["farcrysolrpro"].oManifest
	);
</cfscript>

<cfif oUpdater.updateAvailable()>

	<cfif oUpdater.getMostRecentVersion() eq "UNKNOWN">

		<cfoutput><p>There was a problem accessing the update site.  Please try again later.</p></cfoutput>

	<cfelse>

		<cfset aVersions = oUpdater.getDataFromJson() />

		<cfoutput>
			<p>You are currently running version #oUpdater.getCurrentVersion()#.  The latest version available is <strong>#oUpdater.getMostRecentVersion()#</strong>.</p>
			<hr />
			<p>The following version<cfif arrayLen(aVersions) gt 1>s are<cfelse> is</cfif> available for download:</p>
		</cfoutput>

		<cfset countVersion = 0 />
		<cfloop array="#aVersions#" index="version">
			<cfset countVersion++ />
			<cfoutput>
				<div class="version">
					<h2>#dateFormat(version.releasedate,"yyyy-mm-dd")# v#version.version#</h2>
          <div class="versioninfo">
					  <cfif trim(version.description) neq ""><div class="versiondesc">#version.description#</div></cfif>
					  <cfif trim(version.changelog) neq ""><div class="versionchangelog"><h3>Changelog</h3>#version.changelog#</div></cfif>
					  <div class="versiondownload">
              <h3>Downloads</h3>
              <ul>
              <cfloop array="#version.downloads#" index="download">
              <li><a href="#download.url#">Download v#version.version# #download.shortdesc#<cfif download.size neq ""> [#download.size#]</cfif></a></li>
              </cfloop>
              </ul>
            </div>
          </div>
				</div>
			</cfoutput>
			<cfif countVersion lt arrayLen(aVersions)>
				<cfoutput>
					<hr />
				</cfoutput>
			</cfif>
		</cfloop>

	</cfif>

<cfelse>

	<cfoutput><p>You are currently running version #oUpdater.getCurrentVersion()#.  This is the most recent version.</p></cfoutput>

</cfif>

<cfoutput>
	<hr />
	<p>Note: See <a href="http://jeffcoughlin.github.io/farcrysolrpro/downloads.html">plugin website</a> for information on all versions and changelogs.</p>
</cfoutput>

<admin:footer />

<!--- Load Custom Webtop Styling (load after admin:header) --->
<skin:loadCSS id="solrPro-customWebtopStyles" />
<cfsetting enablecfoutputonly="false" />