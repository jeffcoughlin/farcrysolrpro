<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Purge Logs --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<admin:header title="Purge Logs" />

<cfoutput>
	<!--- TODO: Setup option to purge logs with option "from" date --->
	<p><em>More info soon...</em></p>
</cfoutput>

<!--- Styling and javascript --->
<skin:htmlhead id="solrPro-purgeLogs">
	<cfoutput>
	<style type="text/css" media="all">
		strong {
			font-weight: bold;
		}
		em {
			font-style: italic;
		}
		h1 {
			margin: 1.2em 0 0;
		}
		p {
			margin: .5em 0;
		}
		code,
		.code {
			color: ##555;
			font: 1.1em monospace;
			background-color: ##eee;
			padding: 0.3em 0.5em;
		}
	</style>
	</cfoutput>
</skin:htmlhead>

<admin:footer />

<cfsetting enablecfoutputonly="false" />