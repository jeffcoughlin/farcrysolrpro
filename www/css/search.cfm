<cfsetting enablecfoutputonly="true" />
<cfoutput>
/***********************************************************/
/**                     Search Results                    **/
/***********************************************************/
##searchPage div.searchResultInfo {
  float: right;
  text-align: right;
  width: 36%;
  color: ##6B6B6B;
}
##searchPage div.searchCount {
}
##searchPage div.searchSuggest {
}
##searchPage div.searchResult {
  padding: 15px 0;
  clear: both;
}
##searchPage div.searchResultTitle h2 {
  font-size: 1.3em;
  font-weight: normal;
  text-transform: none;
  letter-spacing: 0;
  padding: 0; 
  margin: 0;
  border-bottom: none;
}
##searchPage div.searchResultTitle h2 a,
##searchPage div.searchResultTitle h2 a:visited {
  font-size: 1.15em;
  font-weight: bold;
  text-decoration: none;
}
##searchPage img.searchResultTeaserImage {
  float: left;
  margin: 10px 10px 10px 0;
}
##searchPage div.searchResultMeta {
  clear: both;
  margin-bottom: 10px;
}
##searchPage div.searchResult div.searchResultLocation,
##searchPage div.searchResult div.searchResultLocation a {
  color: ##767727;
  font-size: 1em;
  font-weight: normal;
  text-decoration: none;
}
##searchPage div.searchResult div.searchResultBreadCrumbs {
  margin: 10px 0 5px;
}
##searchPage div.searchResult div.searchResultBreadCrumbs ul.breadcrumbs {
  margin: 0;
}
##searchPage div.searchResult div.searchResultBreadCrumbs ul.breadcrumbs li {
  color: ##767727;
  display: inline;
  list-style-type: none;
}
##searchPage div.searchResult div.searchResultFileType,
##searchPage div.searchResult div.searchResultDate {
  display: block;
  font-size: 1.1em;
  padding: 0;
  margin: 0;
  color: ##666666;
}
##searchPage div.searchResult div.searchResultFileType {
  float: left;
  margin-right: 10px;
}
##searchPage div.searchResult div.divider {
  float: left;
  background: transparent url(#application.fapi.getConfig(key = 'solrserver',name = 'pluginWebRoot',default='/farcrysolrpro')#/css/images/listDivider.png) no-repeat scroll 0 0;
  padding-left: 10px; 
}
##searchPage div.searchResultContent {
  margin-top: -10px;
}
##searchPage div.searchResultContent p {
  padding: 0;
  margin: 16px 0 5px;
}
##searchPage div.searchResultContent span.search-highlight {
  font-weight: bold;
}
</cfoutput>
<cfsetting enablecfoutputonly="false" />