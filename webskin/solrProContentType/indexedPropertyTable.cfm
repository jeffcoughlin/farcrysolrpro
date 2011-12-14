<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Indexed Property Table --->
<!--- @@author: Sean Coyne (sean@n42designs.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset request.fc.bShowTray = false />

<cfparam name="url.typename" default="" />

<cfset lProps = getPropertiesByType(typename = url.typename) />
<cfset aFieldTypes = getSolrFieldTypes() />

<!--- load the fields that are defined in the schema.xml --->
<cfset aFields = getSolrFields() />

<!--- TODO: break up custom fields and default fields --->

<cfoutput>
<table id="tblCustomProperties" class="objectAdmin">
	<caption>Custom Properties</caption>
	<thead>
		<tr>
			<th>&nbsp;</th>
			<th>Field Name</th>
			<th>Solr Field Type</th>
			<th>Field Boosting</th>
		</tr>
	</thead>
	<tbody>
</cfoutput>

<cfset counter = 0 />

<cfloop list="#lProps#" index="prop">
	<cfif not arrayFindNoCase(aFields,prop)>
		
		<cfset counter++ />
		
		<cfoutput>
			<tr<cfif counter mod 2 eq 0> class="alt"</cfif>>
				<td><input type="checkbox" name="fieldNames" id="fieldNames_#prop#" value="#prop#" /></td>
				<td>#prop#</td>
				<td>
					<select id="fieldType_#prop#">
						<cfloop array="#aFieldTypes#" index="fieldType">
						<option value="#fieldType#">#fieldType#</option>
						</cfloop>
					</select>
					
					<button type="button" class="btnAddFieldType" rel="#prop#">Add</button>
					
					<!--- this will hold the field types created for this field --->
					<div id="displayFieldTypes_#prop#"></div>
					
					<!--- TODO: change to hidden field --->
					<textarea name="lFieldTypes_#prop#" id="lFieldTypes_#prop#"></textarea>
				</td>
				<td>
					<select class="fieldBoost" name="fieldBoost_#prop#" id="fieldBoost_#prop#">
						<option value="1">1</option>
						<option value="2">2</option>
						<option value="3">3</option>
						<option value="5" selected="selected">5</option>
						<option value="10">10</option>
						<option value="15">15</option>
						<option value="20">20</option>
						<option value="50">50</option>
					</select>
				</td>
			</tr>
		</cfoutput>
	</cfif>
</cfloop>

<cfoutput>
	</tbody>
</table>
</cfoutput>

<cfoutput>
<table id="tblCoreProperties" class="objectAdmin">
	<caption>Core Properties</caption>
	<thead>
		<tr>
			<th>&nbsp;</th>
			<th>Field Name</th>
			<th>Solr Field Type</th>
			<th>Field Boosting</th>
		</tr>
	</thead>
	<tbody>
</cfoutput>

<cfset counter = 0 />

<cfloop list="#lProps#" index="prop">
	<cfif arrayFindNoCase(aFields,prop)>
		
		<cfset counter++ />
		
		<cfoutput>
			<tr<cfif counter mod 2 eq 0> class="alt"</cfif>>
				<td><input type="checkbox" checked="checked" onclick="this.checked = true;" name="fieldNames" id="fieldNames_#prop#" value="#prop#" /></td>
				<td>#prop#</td>
				<td>
					#getSolrFieldTypeForProperty(prop)#
				</td>
				<td>
					<select class="fieldBoost" name="fieldBoost_#prop#" id="fieldBoost_#prop#">
						<option value="1">1</option>
						<option value="2">2</option>
						<option value="3">3</option>
						<option value="5" selected="selected">5</option>
						<option value="10">10</option>
						<option value="15">15</option>
						<option value="20">20</option>
						<option value="50">50</option>
					</select>
				</td>
			</tr>
		</cfoutput>
	</cfif>
</cfloop>

<cfoutput>
	</tbody>
</table>
</cfoutput>

<cfsetting enablecfoutputonly="false" />