<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Indexed Property Table --->
<!--- @@author: Sean Coyne (sean@n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset request.fc.bShowTray = false />
<cfset oIndexedProperty = application.fapi.getContentType("solrProIndexedProperty") />

<cfparam name="url.contentType" default="#stobj.contentType#" />

<!--- get the properties for this content type --->
<cfset lProps = getPropertiesByType(typename = url.contentType) />
<cfset aFieldTypes = getSolrFieldTypes() />

<!--- load the fields that are defined in the schema.xml --->
<cfset aCoreFields = getSolrFields(lOmitFields = "random") />

<cfoutput>
<table id="tblCustomProperties" class="ui-widget ui-widget-content fcproperties">
	<caption>Custom Properties</caption>
	<thead>
		<tr class="ui-widget-header">
			<th>&nbsp;</th>
			<th>Field Name</th>
			<th>Solr Field Type(s)</th>
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
				<td id="customField_#prop#">#prop#</td>
				<td>
					<select id="fieldType_#prop#" class="fieldTypeDropdown">
						<option value="">-- Select One --</option>
						
						<optgroup label="Suggested">
						<cfset lDisplayedTypes = "" />
						<cfloop array="#getSolrFieldTypes(fcDataType = getFarCryDataTypeForProperty(typename = url.contentType, propertyName = prop))#" index="fieldType">
							<cfset lDisplayedTypes = listAppend(lDisplayedTypes, listFirst(fieldType,':')) />
							<option value="#listFirst(fieldType,':')#">#listGetAt(fieldType,2,':')#</option>
						</cfloop>
						</optgroup>
						
						<optgroup label="Other">
							<cfloop array="#getSolrFieldTypes()#" index="fieldType">
								<cfif not listFindNoCase(lDisplayedTypes,listFirst(fieldType,':'))>
									<cfset lDisplayedTypes = listAppend(lDisplayedTypes, listFirst(fieldType,':')) />
									<option value="#listFirst(fieldType,':')#">#listGetAt(fieldType,2,':')#</option>
								</cfif>
							</cfloop>
						</optgroup>
						
						<!---
						<cfloop array="#aFieldTypes#" index="fieldType">
						<option value="#listFirst(fieldType,':')#">#listGetAt(fieldType,2,':')#</option>
						</cfloop>
						--->
					</select>
					
					<button type="button" class="btnAddFieldType" rel="#prop#">Add</button>
					
					<!--- this will hold the field types created for this field --->
					<div id="displayFieldTypes_#prop#"></div>
					
					<input type="hidden" name="lFieldTypes_#prop#" id="lFieldTypes_#prop#" <cfif structKeyExists(stIndexedProperty, "lFieldTypes")>value="#stIndexedProperty.lFieldTypes#"</cfif> />
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
<table id="tblCoreProperties" class="ui-widget ui-widget-content fcproperties">
	<caption>Core Properties</caption>
	<thead>
		<tr class="ui-widget-header">
			<th>Field Name</th>
			<th>Solr Field Type</th>
			<th>Field Boosting</th>
		</tr>
	</thead>
	<tbody>
</cfoutput>

<cfset counter = 0 />

<!--- parse the core property boosts --->
<cfset stCorePropertyBoosts = {} />
<cfloop array="#listToArray(stobj.lCorePropertyBoost)#" index="i">
	<cfset stCorePropertyBoosts[listFirst(i,":")] = listLast(i,":") />
</cfloop>

<cfloop array="#aCoreFields#" index="prop">
	
	<cfset fieldType = getSolrFieldTypeForProperty(prop) />
	
	<cfif fieldType neq "ignored">
		
		<cfset counter++ />
		
		<cfoutput>
			<tr<cfif counter mod 2 eq 0> class="alt"</cfif>>
				<td>#prop#</td>
				<td>
					#fieldType#
				</td>
				<td>
					<div class="combobox">
						<input type="text" class="fieldBoost" name="coreFieldBoost_#prop#" id="coreFieldBoost_#prop#" value="<cfif structKeyExists(stCorePropertyBoosts, prop)>#stCorePropertyBoosts[prop]#<cfelse>5</cfif>" />
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