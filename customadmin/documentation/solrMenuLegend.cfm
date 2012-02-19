<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Documentation - Menu Legend  --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<admin:header title="Solr Pro: Menu Legend" />

<cfset linkConfig = application.url.webtop & "/admin/customadmin.cfm?module=customlists/farConfig.cfm" />
<cfset linkHowTo = application.url.webtop & "/admin/customadmin.cfm?module=documentation/solrHowTo.cfm&plugin=farcrysolrpro" />
<cfset linkAbout = application.url.webtop & "/admin/customadmin.cfm?module=documentation/solrProAbout.cfm&amp;plugin=farcrysolrpro" />

<cfoutput>	
	<h1>Solr Menu Legend</h1>
	<p>We've taken advantage of many of Solr's functions and features and tried to make them as user-friendly as possible.  Below is a simple breakdown to help explain the main menu seen on the left.</p>
	<!--- Setup --->
	<h1>Setup</h1>
	<p>Setting up your Solr Plugin to work with your content is the first step.  Don't forget to edit the <a href="#linkConfig#">Solr configuration</a> first.  More details on all of this are explained in the <a href="#linkHowTo#">How-To</a> documentation.</p>
	<h2>Content Types</h2>
	<p>This is where you setup your content types for Solr to index.  Each of the options for setting this up are exaplined at the bottom of the screen when you add/edit a content type to Solr.</p>
	<h2>Solr Admin</h2>
	<p>This is a link to Solr's existing Admininistration area. It is only here for your convenience if you prefer to use it's provided admin tools.</p>

	<!--- Influence Search --->
	<h1>Influence Search</h1>
	<p>Solr has several ways to allow you to persuade and influence its search results.  This is helpful when you have specific pages or documents that you have determined are more important than others.  You know your content better than anyone, so why not help your users find the data they're looking for?</p>
	<h2>Elevation</h2>
	<p>Elevation is Solr's way to override specific search terms (similar to Google's AdWords).  This feature matches the user query text to a configured Map of top results.  This is sometimes called "sponsored search", "editorial boosting" or "best bets".</p>
	<h2>Document Boosting</h2>
	<p>Give specific pages and documents more weight when people are searching for items.  Example: Out of your hundreds of web pages on your site lets say you have maybe 10 specific landing pages that hold a lot of importance (and are maybe parents to the majority of other pages on the site).  Giving these landing pages more weight in searching means that they are more likely to turn up in the search results when matching terms are used.</p>

	<!--- Filters --->
	<h1>Filters <span style="font-size: .6em; font-weight: normal;">(see <a href="#linkAbout#">features list</a> for more details.)</span></h1>
	<h2>Synonyms</h2>
	<p>Matches strings of tokens and replaces them with other strings of tokens.</p>
	<p>One example provided is matching similar terms for iPod: <span class="code">ipod, i-pod, i pod => ipod</span></p>
	<h2>Stop Words</h2>
	<p>Words that Solr will ignore when searching.  Some default english examples are "and, or, the" because they are words that are commonly used and can affect search result scoring.</p>
	<h2>Protected Words</h2>
	<p>A list of words that should be protected and passed through unchanged.  This protects the words from being "stemmed" (reducing two unrelated words to the same base word).</p>
	<h2>Spellings (dictionary)</h2>
	<p>Override the default dictionary.  By default, this never needs to be changed.</p>

	<!--- Test Setup --->
	<h1>Test Setup </h1>
	<h2>Search</h2>
	<p>Once you have some data indexed, you can do test searches against it here.  You can search all types or a specific type.  When searching a specific type, all of the Solr fields will be available to you (except typename which is already filtered in the type dropdown).</p>
	<p>A few important things to note:</p>
	<ul>
		<li>The site search checkbox (configured in the type) is ignored in this test search.  All FarCry types are searchable.</li>
		<li>The results are in cfdump format.  Because Solr can store your data in both simple and complex data (like arrays), it's easier for us to just use cfdump for the result.</li>
		<li>The results are paginated (10 items per page).</li>
		<li>Doing a type search here can be very useful when you're trying to do a specific search page on your site and need somewhere to test your searches again.  Example: a product page search with multiple filter options.</li>
	</ul>
	<h2>Reload Solr</h2>
	<p>The <tt>RELOAD</tt> action loads a new core from the configuration of an existing, registered Solr core. While the new core is initializing, the existing one will continue to handle requests. When the new Solr core is ready, it takes over and the old core is unloaded.</p>
	<p>This is useful when you've made changes to a Solr core's configuration on disk, such as adding new field definitions. Calling the <tt>RELOAD</tt> action lets you apply the new configuration without having to restart the Web container.</p>

	<!--- Influence Search --->
	<h1>Reports &amp; Stats</h1>
	<h2>Search Log</h2>
	<p>Shows what people are searching for, how many results they received, and the suggestion they were given (if relevant).  You can optionally set date ranges to search within.</p>
	<h2>Searches without Results</h2>
	<p>Shows what people were searching for when they received no results.  This is helpful to see if people are searching for things on your site that do exist, but for some reason they're not finding what they want (maybe they are searching for terms that don't exist on your site, but refer to the same content).  Using things like "synonyms" can help here, as well as adding the actual terms to your content itself.</p>
	<h2>Purge Logs</h2>
	<p>If your search logs are getting too long, you can purge them here.  You can optionally purge them before a chosen date or purge all.</p>
	<br />
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