<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Documentation - Menu Legend  --->
<!--- @@author: Sean Coyne (sean@n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<admin:header title="Solr Pro: Menu Legend" />

<cfset linkHowTo = application.url.webroot & "/webtop/admin/customadmin.cfm?module=documentation/solrHowTo.cfm&plugin=farcrysolrpro" />
<cfset linkConfig = application.url.webroot & "/webtop/admin/customadmin.cfm?module=customlists/farConfig.cfm" />

<cfoutput>	
	<!--- Setup --->
	<h1 id="a">Setup</h1>
	<p>Setting up your Solr Plugin to work with your content is the first step.  Don't forget to edit the <a href="#linkConfig#">Solr configuration</a> first.  More details on all of this are explained in the detailed <a href="#linkHowTo#">How-To</a> documentation.</p>
	<h2 id="a1">Content Types</h2>
	<p>This is where you setup your content types for Solr to index.  Each of the options for setting this up are exaplined at the bottom of the screen when you add/edit a content type to Solr.</p>
	<!---<p><a href="#linkHowTo###contenttypes">Full docs</a></p>--->
	<h2 id="a2">Solr Admin</h2>
	<p>This is a link to Solr's existing Admininistration area. It is only here for your convenience if you prefer to use it's provided admin tools.</p>

	<!--- Influence Search --->
	<h1 id="b">Influence Search</h1>
	<p>Solr has several ways to allow you to persuade and influence its search results.  This is helpful when you have specific pages or documents that you have determined are more important than others.  You know your content better than anyone, so why not help your users find the data they're looking for?</p>
	<h2 id="b1">Elevation</h2>
	<p>Elevation is Solr's way to override specific search terms (similar to Google's AdWords).  This feature matches the user query text to a configured Map of top results.  This is sometimes called "sponsored search", "editorial boosting" or "best bets".</p>
	<h2 id="b2">Document Boosting</h2>
	<p>Give specific pages and documents more weight when people are searching for items.  Example: Out of your hundreds of web pages on your site lets say you have maybe 10 specific landing pages that hold a lot of importance (and are maybe parents to the majority of other pages on the site).  Giving these landing pages more weight in searching means that they are more likely to turn up in the search results when matching terms are used.</p>

	<!--- Filters --->
	<h1 id="c">Filters</h1>
	<h2 id="c1">Stop Words</h2>
	<p>Words that Solr will ignore when searching.  Some default english examples are "and, or, the" because they are words that are commonly used and can affect search result scoring.</p>
	<h2 id="c1">Protected Words</h2>
	<p>A list of words that should be protected and passed through unchanged.  This protects the words from being "stemmed" (reducing two unrelated words to the same base word).</p>
	<h2 id="c2">Spellings</h2>
	<!--- TODO: Finish these docs --->
	<p><em>More info soon...</em></p>
	<h2 id="c1">Synonyms</h2>
	<p>Matches strings of tokens and replaces them with other strings of tokens.</p>
	<p>One example provided is matching similar terms for iPod: <span class="code">ipod, i-pod, i pod => ipod</span></p>

	<!--- Test Setup --->
	<h1 id="d">Test Setup </h1>
	<h2 id="d1">Search</h2>
	<!--- TODO: Finish these docs --->
	<p><em>More info soon...</em></p>

	<!--- Influence Search --->
	<h1 id="b">Reports &amp; Stats</h1>
	<h2 id="b1">Search Log</h2>
	<!--- TODO: Finish these docs --->
	<p><em>More info soon...</em></p>
	<h2 id="b2">Searches without Results</h2>
	<!--- TODO: Finish these docs --->
	<p><em>More info soon...</em></p>
</cfoutput>

<admin:footer />

<!--- Styling and javascript --->
<skin:htmlhead id="solrProDocumentation-MenuLegend">
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

<cfsetting enablecfoutputonly="false" />