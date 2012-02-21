<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Documentation - About  --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset oManifest = application.stPlugins.farcrysolrpro.oManifest />

<cfsavecontent variable="supportedFarCryVersions">
	<cfoutput>	
		<cfloop collection="#oManifest.stSupportedCores#" item="core">
			<cfloop collection="#oManifest.stSupportedCores[core]#" item="patchversion">
				#core#-#oManifest.stSupportedCores[core][patchversion]#,
			</cfloop>
		</cfloop>
	</cfoutput> 
</cfsavecontent>
<cfset supportedFarCryVersions = trim(supportedFarCryVersions) />
<cfif len(supportedFarCryVersions)>
	<!--- Remove trailing comma --->
	<cfset supportedFarCryVersions = left(supportedFarCryVersions, len(supportedFarCryVersions)-1) />
</cfif>

<admin:header title="Solr Pro: About" />

<cfoutput>
	<h1>Plugin Info</h1>
	<ul>
		<li><strong>Name:</strong> #oManifest.name#</li>
		<li><strong>Description:</strong> #oManifest.description#</li>
		<li><strong>Version:</strong> #oManifest.version#<cfif oManifest.buildState neq ""> (#oManifest.buildState#)</cfif></li>
		<li><strong>License:</strong> <a href="#oManifest.license.link#">#oManifest.license.name#</a></li>
		<li><strong>Supported FarCry Minimum:</strong> #supportedFarCryVersions#</li>
		<li><strong>Required Plugins:</strong> <cfif oManifest.lRequiredPlugins neq "">#oManifest.lRequiredPlugins#<cfelse><em>none</em></cfif></li>
	</ul>
	<h1>What is the FarCry Solr Pro Plugin?</h1>
	<p>The FarCry Solr Pro plugin lets you use the power of Lucene (through Solr) to index and search your site.  It goes above and beyond ColdFusion's native implementation of Solr.</p>
	<p>FarCry Solr Pro was designed with FarCry's framework in mind.  It matches each record with its unique record ID and grants you the power to make your searches more relevant with things like field boosting, search term elevation, and more.</p>
	<h1>Features</h1>
	<ul class="features">
		<li>Boosting
			<ul>
				<li><strong>by field:</strong> You can give certain fields more weight than others.</li>
				<li><strong>by document:</strong> You can give certain documents more weight than others (ie. Main landing pages). No re-index required.</li>
			</ul>
		</li>
		<li>Elevation
			<ul>
				<li>To raise certain items to the top of the result list based on a certain query.
					<ul>
						<li><em>Example:</em> Every time someone searches for the search term "Round Widgets" you can tell Solr to return the following [n] documents of choice in order (n = the specific documents you've chosen). These documents will appear in order at the top of the results, then be followed with the remaining results from a standard Solr search.</li>		
					</ul>
				</li>
				<li>You can also choose to "exclude" specific documents from results based on specific search strings.</li>
				<li>This setting is instant.  No re-index is required.</li>
			</ul>
		</li>
		<li>Spellcheck
			<ul>
				<li>Relevant suggestions</li>
				<li>Phonetic search
					<ul>
						<li>Even if you spell the word completely wrong Solr will know and do a search with the correct spelling.</li>
						<li><em>Example:</em> Search for the word "phlowur" and Solr will know to search for the real word "flower".  It's smarter than using a dictionary.  Instead, it uses the existing content *already* in your index to work from.
							<ul>
								<li>Note: This example will only work, of course, if you actually have the word "flower" indexed in your content somewhere.</li>
							</ul>
						</li>
					</ul>
				</li>
			</ul>
		</li>
		<li>Performance enhancements
			<ul>
				<li>Many times faster than the previous FarCry Solr plugin which uses ColdFusion's cfsearch/cfindex tags under the hood.  The FarCry Solr Pro plugin talks directly to Solr and takes advantage of many overlooked features by ColdFusion.</li>
				<li>Complete data field indexing
					<ul>
						<li>Because we are now able to store custom fields, we don't have to do complicated content lookups on each item in the search results.  All the data you now see in the search results (title, teaser, last updated date, content type, etc) can all stored in Solr (provided you use the plugin correctly).  This feature alone makes searches much faster.</li>
					</ul>
				</li>
			</ul>
		</li>
		<li>Index on-save
			<ul>
				<li>No more having to wait for nightly indexes to see your content in search results. The second you save a published document it is instantly available to site searches.</li>
			</ul>
		</li>
		<li>Rule content indexing
			<ul>
				<li>Now, static content in rules can be related directly to the parent page.
					<ul>
						<li><em>Example:</em> If you have a rule called "textarea" where you decided to have more content to appear in the right pane, you can now index that data and have it related to the page it lives on. So when someone searches for a string that matches that rule in the right pane, it will return the parent page in the search results.</li>
					</ul>
				</li>
				<li>Note: Currently we are only indexing text/string fields in the rules (not arrays, etc).</li>
			</ul>
		</li>
		<li>Search result highlighting
			<ul>
				<li>Now search result summary/teasers have the ability to highlight search terms in your search results exactly where they were found.</li>
				<li>Plus, if the term(s) were found in multiple spots, we show them together in the same search result summary/teaser separated by ellipses.</li>
			</ul>
		</li>
		<li>Custom search forms
			<ul>
				<li>Having a general site search is great, but what about another search form on the site that searches something like products? Because we can index and store as many fields as we like now, we can also search by those fields just like you would any other database. So, if you have a product search page and you wanted your visitors to search by 15 different filter options, you can now create a custom search form and use Solr to search all of those fields. The end result: A fast user experience even on some of the most complicated search requests.</li>
			</ul>
		</li>
		<li>Filters
			<ul>
				<li><strong>Synonyms:</strong> Matches strings of tokens and replaces them with other strings of tokens.
					<ul>
						<li><em>Example 1:</em> matching similar terms for ipod, i-pod, i pod => ipod</li>
						<li><em>Example 2:</em> heart attack => myocardial infarction
							<ul>
								<li>So, if someone searches for the term "heart attack", the results will also include any documents with the text "myocardial infarction".</li>
							</ul>
						</li>
					</ul>
				</li>
				<li><strong>Stop Words:</strong> These are words that Solr will ignore when searching. Some default English examples are "and, or, the" because they are words that are commonly used and can affect search result scoring.</li>
				<li><strong>Protected Words:</strong> A list of words that should be protected and passed through unchanged. This protects the words from being "stemmed" (reducing two unrelated words to the same base word).
					<ul>
						<li><em>Example:</em> Solr is smart enough to know that when someone searches for the word "nursing" to also search for the word "nurse".  This is called stemming.  However, perhaps you don't want it to stem the word "nursing".  You can use this setting to protect the word "nursing" from ever being stemmed by the search engine so that if the word "nursing" would only be found if someone searched for it specifically.</li>
					</ul>
				</li>
				<li><strong>Spellings (dictionary):</strong> By default, this never needs to be changed.  We've implemented Solr's automatic spell checker, which uses the data already in the index to spell check against.  However, if you wanted to override this, you could use the settings in Solr to create a custom dictionary.</li>
			</ul>
		</li>
		<li>Reports &amp; Stats
			<ul>
				<li><strong>Search log:</strong> </li>
				<li><strong>Searches without results:</strong> Shows what people were searching for when they received no results.  This is helpful to see if people are searching for things on your site that do exist, but for some reason they're not finding what they want (maybe they are searching for terms that don't exist on your site, but refer to the same content).  Using things like "synonyms" can help here, as well as adding the actual terms to your content itself.</li>
			</ul>
		</li>
	</ul>

	<h1>Credits</h1>
	<h2>
		Development Team
		<img src="#application.fapi.getConfig(key = 'solrserver', name = 'pluginWebRoot')#/css/images/logo-farcrySolrPro-75.png" style="float: right; margin: 0 0 30px 10px; clear: left;" />
		<img src="#application.fapi.getConfig(key = 'solrserver', name = 'pluginWebRoot')#/css/images/logo-apacheSolr-75.png" style="float: right; margin: 0 0 10px 10px; clear: right;" />
	</h2>
	<p>Many hours went into creating this plugin and there are many people to thank.  If you'd like to show your appreciation, see the list of people below.  Maybe say thanks by visiting their Amazon wishlist :).</p>
	<ul class="credits">
		<li><strong>Jeff Coughlin</strong>
			<ul>
				<li>Email: <a href="jeff@jeffcoughlin.com">jeff@jeffcoughlin.com</a></li>
				<li>Website: <a href="http://jeffcoughlin.com/blog">http://jeffcoughlin.com/blog</a></li>
				<li>Amazon Wishlist: <a href="http://amzn.to/zrvloy">http://amzn.to/zrvloy</a></li>
			</ul>
		</li>
		<li><strong>Sean Coyne</strong>
			<ul>
				<li>Email: <a href="sean@n42designs.com">sean@n42designs.com</a></li>
				<li>Website: <a href="http://n42designs.com">http://n42designs.com</a></li>
				<li>Amazon wishlist: <a href="http://amzn.to/ztFQsj">http://amzn.to/ztFQsj</a></li>
			</ul>
		</li>
	</ul>
	<h2>Devoted Testers</h2>
	<ul>
		<li>None yet :)</li>
	</ul>
	<br />
</cfoutput>

<admin:footer />

<!--- Styling and javascript --->
<skin:htmlhead id="solrProDocumentation-HowTo">
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
		ul, ol {
			margin: .5em 0 .5em 1em;
		}
		ul ul,
		ol ol {
			margin-left: 0;
		}
		ul li {
			margin-left: 1em;
			list-style: disc outside none;
		}
		ol li {
			margin-left: 1em;
			list-style: decimal outside none;
		}
		ul li li {
			list-style: square outside none;
		}
		ul.features li {
			font-weight: bold;
		}
		ul.features li li {
			font-weight: normal;
		}
		li.nolistyle {
			margin-left: 0;
			list-style: none;
		}
	</style>
	</cfoutput>
</skin:htmlhead>

<cfsetting enablecfoutputonly="false" />