<cfsetting enablecfoutputonly="true" />

<cfparam name="stParam.searchNavId" default="#application.fapi.getNavId('search','home')#" />

<cfoutput>
	<form action="#application.fapi.getLink(objectid = stParam.searchNavId)#" method="get">
		<fieldset>
			<label for="q">Search</label>
			<input type="text" name="q" id="q" value="" />
			<input name="operator" id="operator" type="hidden" value="any" />
			<input name="lContentTypes" id="lContentTypes" type="hidden" value="" />
			<input name="orderby" id="orderby" type="hidden" value="rank" />
			<button type="submit">Search</button>
		</fieldset>
	</form>
</cfoutput>

<cfsetting enablecfoutputonly="false" />