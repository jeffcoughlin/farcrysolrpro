<cfsetting enablecfoutputonly="true" />

<!--- required includes --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<ft:form>
	<ft:object objectid="#stobj.objectid#" typename="solrProSearch" lExcludeFields="label,bSearchPerformed" IncludeFieldSet="false"  />
	<ft:buttonPanel>
		<ft:button type="submit" value="Search" />
	</ft:buttonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />