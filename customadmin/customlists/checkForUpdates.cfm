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

		<cfoutput><p>You are currently running version #updater.getCurrentVersion()#.  Version #updater.getMostRecentVersion()# is available.</p></cfoutput>

		<cfloop array="#versions#" index="version">
			<cfoutput>
				<div class="version">
					<h2>#version.version#</h2>
					<div>#version.description#</div>
					<p><a href="#version.downloadUrl#">Download</a></p>
					<p>Released: #dateFormat(version.releasedate,"mm/dd/yyyy")#</p>
				</div>
			</cfoutput>
		</cfloop>

	</cfif>

<cfelse>

	<cfoutput><p>You are currently running version #updater.getCurrentVersion()#.  This is the most recent version.</p></cfoutput>

</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />