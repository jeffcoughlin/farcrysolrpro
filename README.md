![FarCry Solr Pro](http://jeffcoughlin.github.com/farcrysolrpro/assets/images/logo-farcrySolrPro-admin.png "FarCry Solr Pro")

# FarCry Solr Pro Plugin

The FarCry Solr Pro plugin lets you use the power of Lucene (through Solr) to index and search your site.  It goes above and beyond ColdFusion's native implementation of Solr.

FarCry Solr Pro was designed with FarCry's framework in mind.  It matches each record with its unique record ID and grants you the power to make your searches more relevant with things like field boosting, search term elevation, and more.

![FarCry Solr Pro Webtop](http://jeffcoughlin.github.com/farcrysolrpro/assets/images/searchExample.png "FarCry Solr Pro Webtop")

## Details and Installation

For more details and installation information, see the [documentation pages](http://jeffcoughlin.github.com/farcrysolrpro "FarCry Solr Pro").

## Authors

Jeff Coughlin [http://jeffcoughlin.com](http://jeffcoughlin.com), Sean Coyne [http://www.n42designs.com](http://www.n42designs.com)

## Features
* **Boosting**
    * **by field:** You can give certain fields more weight than others.
    * **by document:** You can give certain documents more weight than others (ie. Main landing pages). No re-index required.
* **Elevation**
    * To raise certain items to the top of the result list based on a certain query
        * *Example:* Every time someone searches for the search term "Round Widgets" you can tell Solr to return the following [n] documents of choice in order (n = the specific documents you've chosen). These documents will appear in order at the top of the results, then be followed with the remaining results from a standard Solr search.
    * You can also choose to "exclude" specific documents from results based on specific search strings.
    * This setting is instant. No re-index is required.
* **Spellcheck**
    * Relevant suggestions
    * Phonetic search
        * Even if you spell the word completely wrong Solr will know and do a search with the correct spelling.
        * *Example:* Search for the word "phlowur" and solr will know to search for the real word "flower". It's smarter than using a dictionary. Instead, it uses the existing content *already* in your index to work from.
            * Note: This example will only work, of course, if you actually have the word "flower" indexed in your content somewhere.
* **Performance enhancements**
    * Many times faster than the previous FarCry Solr plugin which uses ColdFusion's cfsearch/cfindex tags under the hood. The FarCry Solr Pro plugin talks directly to Solr and takes advantage of many overlooked features by ColdFusion.
    * Complete data field indexing
        * Because we are now able to store custom fields, we don't have to do complicated content lookups on each item in the search results. All the data you now see in the search results (title, teaser, last updated date, content type, etc) can all stored in Solr (provided you use the plugin correctly). This feature alone makes searches much faster.
* **Index on-save**
    * No more having to wait for nightly indexes to see your content in search results. The second you save a published document it is instantly available to site searches.
* **Rule content indexing**
    * Now, static content in rules can be related directly to the parent page.
        * *Example:* If you have a rule called "textarea" where you decided to have more content to appear in the right pane, you can now index that data and have it related to the page it lives on. So when someone searches for a string that matches that rule in the right pane, it will return the parent page in the search results.
    * Note: Currently we are only indexing text/string fields in the rules (not arrays, etc).
* **Search result highlighting**
    * Now search result summary/teasers have the ability to highlight search terms in your search results exactly where they were found.
    * Plus, if the term(s) were found in multiple spots, we show them together in the same search result summary/teaser separated by ellipses.
* **File Indexing**
    * File format parsing is automatically handled by the plugin using a content analysis toolkit called <a href="http://tika.apache.org/">Tika</a>.  Not only will it the parse text of documents, but it will also get metadata from documents like author and company.
    * The parser doesn't just handle PDFs and Word docs.  Below is a list of many of the <a href="http://tika.apache.org/1.1/formats.html">formats</a> that Tika supports for metadata extraction:
        * HyperText Markup Language (<abbr title="HyperText Markup Language">HTML</abbr>)
        * <abbr title="Extensible Markup Language">XML</abbr> and derived formats
        * Microsoft Office document formats
        * OpenDocument Format
        * Portable Document Format (<abbr title="Portable Document Format">PDF</abbr>)
        * Electronic Publication Format (<abbr title="Electronic Publication Format">Epub</abbr>)
        * Rich Text Format (<abbr title="Rich Text Format">RTF</abbr>)
        * Compression and packaging formats (zip, gzip, tar, etc)
        * Text formats
        * Audio formats (<abbr title="MPEG-2 Audio Layer III">MP3</abbr>, etc)
        * Image formats (simple metadata from images)
        * Video formats (<abbr title="Flash Video">FLV</abbr> parser)
        * Java class files and archives
        * The mbox format (extracting email messages from mailbox formats)
    * For more details on what formats Tika supports, see <a href="http://tika.apache.org/1.1/formats.html">Tika's Supported Document Formats</a> page.
* **Document size**
    * Optionally return the document size with each result.
        * You can choose which fields total up the size (options are text-based fields, files, and images).
            * For content pages, it is suggested to select only those fields relevant to the landing/target page itself (ie. A title and body field are likely relevant to the landing page where a teaser field is not).
            * Any file or image fields selected will get the file size of each referenced item.  Although there are plenty of uses for this option, it is likely most useful in cases where the record itself that you're indexing refers to a file (like a PDF).
* **Custom search forms**
    * Having a general site search is great, but what about another search form on the site that searches something like products? Because we can index and store as many fields as we like now, we can also search by those fields just like you would any other database. So, if you have a product search page and you wanted your visitors to search by 15 different filter options, you can now create a custom search form and use Solr to search all of those fields. The end result: A fast user experience even on some of the most complicated search requests.
* **Filters**
    * **Synonyms:** Matches strings of tokens and replaces them with other strings of tokens.
        * *Example1:* matching similar terms for ipod, i-pod, i pod => ipod
        * *Example2:* heart attack => myocardial infarction
            * So, if someone searches for the term "heart attack", the results will also include any documents with the text "myocardial infarction".
    * **Stop Words:** These are words that Solr will ignore when searching. Some default English examples are "and, or, the" because they are words that are commonly used and can affect search result scoring.
    * **Protected Words:** A list of words that should be protected and passed through unchanged. This protects the words from being "stemmed" (reducing two unrelated words to the same base word).
        * *Example:* Solr is smart enough to know that when someone searches for the word "nursing" to also search for the word "nurse".  This is called stemming.  However, perhaps you don't want it to stem the word "nursing".  You can use this setting to protect the word "nursing" from ever being stemmed by the search engine so that if the word "nursing" would only be found if someone searched for it specifically. 
    * **Spellings (dictionary):** By default, this never needs to be changed.  We've implemented Solr's automatic spell checker, which uses the data already in the index to spell check against.  However, if you wanted to override this, you could use the settings in Solr to create a custom dictionary.
* **Reports & Stats**
    * **Search log:** Shows what people are searching for, how many results they received, and the suggestion they were given (if relevant).
    * **Searches without results:** Shows what people were searching for when they received no results.  This is helpful to see if people are searching for things on your site that do exist, but for some reason they're not finding what they want (maybe they are searching for terms that don't exist on your site, but refer to the same content).  Using things like "synonyms" can help here, as well as adding the actual terms to your content itself.
    
## Minimum Requirements

* ColdFusion 9
* FarCry 6.2, 6.1.4, 6.0.19
* Solr 3.5
    * Solr 3.5 is optionally included in this plugin.
    * To date, we have only tested this on Solr 3.5