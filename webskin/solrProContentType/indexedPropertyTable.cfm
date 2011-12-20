<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Indexed Property Table --->
<!--- @@author: Sean Coyne (sean@n42designs.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset request.fc.bShowTray = false />
<cfset oIndexedProperty = application.fapi.getContentType("solrProIndexedProperty") />

<cfparam name="url.contentType" default="#stobj.contentType#" />

<!--- get the properties for this content type --->
<cfset lProps = getPropertiesByType(typename = url.contentType) />
<cfset aFieldTypes = getSolrFieldTypes() />

<!--- load the fields that are defined in the schema.xml --->
<cfset aCoreFields = getSolrFields() />

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
	<cfif not arrayFindNoCase(aCoreFields,prop)>
		
		<cfset counter++ />
		
		<cfset stIndexedProperty = oIndexedProperty.getByContentTypeAndFieldname(contentTypeId = stobj.objectid, fieldname = prop) />
		
		<cfoutput>
			<tr<cfif counter mod 2 eq 0> class="alt"</cfif>>
				<td><input type="checkbox" name="indexedProperties" id="fieldNames_#prop#" value="#prop#" <cfif structCount(stIndexedProperty)>checked="checked"</cfif> /></td>
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
					
					<!--- TODO: change to hidden field for go live --->
					<input type="hidden" name="lFieldTypes_#prop#" id="lFieldTypes_#prop#" <cfif structKeyExists(stIndexedProperty, "lFieldTypes")>value="#stIndexedProperty.lFieldTypes#"</cfif> />
					<!---<textarea name="lFieldTypes_#prop#" id="lFieldTypes_#prop#"><cfif structKeyExists(stIndexedProperty, "lFieldTypes")>#stIndexedProperty.lFieldTypes#</cfif></textarea>--->
				</td>
				<td>
					<div class="combobox">
						<input type="text" class="fieldBoost" name="fieldBoost_#prop#" id="fieldBoost_#prop#" value="<cfif structKeyExists(stIndexedProperty, 'fieldBoost')>#stIndexedProperty.fieldBoost#<cfelse>5</cfif>" />
					</div>
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
			<th>Field Name</th>
			<th>Solr Field Type</th>
			<th>Field Boosting</th>
		</tr>
	</thead>
	<tbody>
</cfoutput>

<cfset counter = 0 />

<cfloop list="#lProps#" index="prop">
	<cfif arrayFindNoCase(aCoreFields,prop)>
		
		<cfset counter++ />
		
		<cfoutput>
			<tr<cfif counter mod 2 eq 0> class="alt"</cfif>>
				<td>#prop#</td>
				<td>
					#getSolrFieldTypeForProperty(prop)#
				</td>
				<td>
					<div class="combobox">
						<input type="text" class="fieldBoost" name="fieldBoost_#prop#" id="fieldBoost_#prop#" />
					</div>
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