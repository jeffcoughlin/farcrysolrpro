<cfsetting enablecfoutputonly="true" />

<cfset actionUrl = application.fapi.getLink(objectid = request.navid) />

<cfoutput>
	<form action="#actionUrl#" method="get">
		
		<fieldset>
			
			<label for="q">Search</label>
			<input type="text" name="q" id="q" value="#htmlEditFormat(stobj.q)#" />
			
			<label for="operator">Search Operator</label>
			<select name="operator" id="operator">
				<option value="any"<cfif stobj.operator eq 'any'> selected="selected"</cfif>>Any of these words</option>
				<option value="all"<cfif stobj.operator eq 'all'> selected="selected"</cfif>>All of these words</option>
				<option value="phrase"<cfif stobj.operator eq 'phrase'> selected="selected"</cfif>>These words as a phrase</option>
				<cfif application.fapi.checkPermission("Developer")>
				<option value="nofilter"<cfif stobj.operator eq 'nofilter'> selected="selected"</cfif>>No Filter</option>
				</cfif>
			</select>
			
			<label for="lContentTypes">Content Types</label>
			<select name="lContentTypes" id="lContentTypes">
				<cfloop list="#getContentTypeList(stobj.objectid)#" index="i">
					<cfif listLen(i,":") neq 2>
						<option value="">#listLast(i,':')#</option>
					<cfelse>
						<option value="#listFirst(i,':')#"<cfif listFindNoCase(stobj.lContentTypes,listFirst(i,':'))> selected="selected"</cfif>>#listLast(i,':')#</option>
					</cfif>
				</cfloop>
			</select>
			
			<label for="orderby">Sort Order</label>
			<select name="orderby" id="orderby">
				<option value="rank"<cfif stobj.orderby eq 'rank'> selected="selected"</cfif>>Relevance</option>
				<option value="date"<cfif stobj.orderby eq 'date'> selected="selected"</cfif>>Date</option>
			</select>
			
			<!--- handle non friendly urls --->
			<cfif actionUrl contains "?">
				<cfset queryString = listLast(actionUrl,"?") />
				<cfset queryString = listToArray(queryString,"&") />
				<cfloop array="#queryString#" index="param">
				<cfif listLen(param,"=") eq 2>
				<input type="hidden" name="#listFirst(param,'=')#" value="#listLast(param,'=')#" />
				</cfif>
				</cfloop>
			</cfif>
			
			<button type="submit">Search</button>
			
		</fieldset>
		
	</form>
</cfoutput>

<cfsetting enablecfoutputonly="false" />