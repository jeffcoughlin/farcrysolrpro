<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Check for Updates --->
<!--- @@author: Sean Coyne (sean@n42designs.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<admin:header title="Check for Updates" />

<cfscript>
	updateUrl = "http://jeffcoughlin.github.com/farcrysolrpro/update.xml";
	updater = createObject("component","farcry.plugins.farcrysolrpro.packages.custom.updates").init(
		updateUrl = updateUrl,
		installManifest = application.stPlugins["farcrysolrpro"].oManifest
	);
</cfscript>

<cfif updater.updateAvailable()>

	<cfif updater.getMostRecentVersion() eq "UNKNOWN">

		<cfoutput><p>There was a problem accessing the update site.  Please try again later.</p></cfoutput>

	<cfelse>

		<cfset versions = updater.getAvailableVersions() />

		<cfoutput>
			<p>You are currently running version #updater.getCurrentVersion()#.  The latest version available is <strong>#updater.getMostRecentVersion()#</strong>.</p>
			<hr />
			<p>The following version<cfif arrayLen(versions) gt 1>s are<cfelse> is</cfif> available for download:</p>
		</cfoutput>

		<cfset countVersion = 0 />
		<cfloop array="#versions#" index="version">
			<cfset countVersion++ />
			<cfoutput>
				<div class="version">
					<h2>#dateFormat(version.releasedate,"yyyy-mm-dd")# v#version.version#</h2>
          <div class="versioninfo">
					  <div class="versiondesc">#version.description#</div>
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
			<cfif countVersion lt arrayLen(versions)>
				<cfoutput>
					<hr />
				</cfoutput>
			</cfif>
		</cfloop>

	</cfif>

<cfelse>

	<cfoutput><p>You are currently running version #updater.getCurrentVersion()#.  This is the most recent version.</p></cfoutput>

</cfif>

<cfoutput>
	<hr />
	<p>Note: See <a href="http://jeffcoughlin.github.com/farcrysolrpro/downloads.html">plugin website</a> for information on all versions and changelogs.</p>
</cfoutput>

<admin:footer />

<!--- Load Custom Webtop Styling (load after admin:header) --->
<skin:loadCss id="solrPro-customWebtopStyles" />
<cfsetting enablecfoutputonly="false" />