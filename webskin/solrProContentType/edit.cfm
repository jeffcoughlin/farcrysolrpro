<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->
<!--- @@cacheStatus: -1 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<skin:loadJs id="jquery" />
<skin:loadJs id="jquery-ui" />
<skin:loadCss id="jquery-ui" />

<cfset oIndexedProperty = application.fapi.getContentType("solrProIndexedProperty") />

<!--- assume success --->
<cfset bContinueSave = true />

<ft:processform action="Save">
	
	<!--- do some validation first --->
	<ft:processFormObjects typename="solrProContentType" bSessionOnly="true" r_stObject="stObj">
		
		<!--- assure all fieldBoost values are numeric --->
		<cfparam name="form.indexedProperties" type="string" default="" />
		<cfloop collection="#form#" item="f">
			<cfif left(f, len('fieldBoost_')) eq 'fieldBoost_' or left(f, len('coreFieldBoost_')) eq 'coreFieldBoost_'>
				<cfif not isNumeric(form[f]) and listFindNoCase(form.indexedProperties, listlast(f,"_"))>
					<ft:advice 
						objectid="#stProperties.objectid#" 
						field="#f#" 
						message="Field boost values must be numeric." 
						value="#form[f]#" />
					<cfset bContinueSave = false />
				</cfif>
			</cfif>
		</cfloop>
		
	</ft:processFormObjects>
		
</ft:processform>

<cfif bContinueSave>
	
	<ft:processform action="Save" exit="true">
		
		<ft:processFormObjects typename="solrProContentType">
			
			<cfparam name="form.resultTitleField" type="string" default="label" />
			<cfparam name="form.resultSummaryField" type="string" default="" />
			<cfset stProperties["resultTitleField"] = form.resultTitleField />
			<cfset stProperties["resultSummaryField"] = form.resultSummaryField  />
			
			<!--- clear the array of indexed properties --->
			<cfparam name="stProperties.aIndexedProperties" type="array" default="#arrayNew(1)#" />
			<cfset oldIndexedProperties = duplicate(stProperties.aIndexedProperties) />
			<cfset stProperties.aIndexedProperties = [] />
			
			<!--- build the property list --->
			<cfparam name="form.indexedProperties" type="string" default="" />
			<cfloop list="#form.indexedProperties#" index="prop">
				
				<cfset stIndexedProperty = {
					fieldName = prop,
					lFieldTypes = form['lFieldTypes_' & prop],
					fieldBoost = form['fieldBoost_' & prop]
				} />
				
				<cfif structKeyExists(stProperties,"objectid") and hasIndexedProperty(stproperties.objectid, prop)>
					<!--- already exists, update it --->
					<cfset stCurrent = oIndexedProperty.getByContentTypeAndFieldname(stproperties.objectid, prop) />
					<cfset structAppend(stCurrent, stIndexedProperty, true) />
					<cfset oIndexedProperty.setData(stProperties = stCurrent) />
					<cfset stIndexedProperty.objectid = stCurrent.objectid />
				<cfelse>
					<!--- new indexed property, create it --->
					<cfset stResult = oIndexedProperty.createData(stProperties = stIndexedProperty) />
					<cfset stIndexedProperty.objectid = stResult.objectid />
				</cfif>
				
				<!--- add it to the array --->
				<cfset arrayAppend(stProperties.aIndexedProperties, stIndexedProperty.objectId) />
								
			</cfloop>
			
			<!--- delete any properties that are no longer being indexed for this content type --->
			<!--- loop over the properties that used to be indexed and check that they still are, if not mark for deletion --->
			<cfloop array="#oldIndexedProperties#" index="prop">
				<cfif not arrayFindNoCase(stProperties.aIndexedProperties, prop)>
					<cfset oIndexedProperty.delete(prop) />
				</cfif>
			</cfloop>
			
			<!--- build the list of indexed rules --->
			<cfparam name="form.lIndexedRules" type="string" default="" />
			<cfset stProperties["lIndexedRules"] = form.lIndexedRules />
			
			<!--- build the list of core property boost values --->
			<cfset stProperties.lCorePropertyBoost = "" />
			<cfloop collection="#form#" item="f">
				<cfif left(f,len('coreFieldBoost_')) eq 'coreFieldBoost_' and isNumeric(form[f])>
					<cfset stProperties.lCorePropertyBoost = listAppend(stProperties.lCorePropertyBoost, listLast(f,"_") & ":" & form[f]) />
				</cfif>
			</cfloop> 
			
		</ft:processFormObjects>
		
	</ft:processform>

</cfif>

<ft:processform action="Cancel" exit="true" />

<ft:form>

	<ft:fieldset>
		<cfoutput><h1><skin:icon icon="#application.stCOAPI[stobj.typename].icon#" default="farcrycore" size="32" />#stobj.label#</h1></cfoutput>
	</ft:fieldset>
	
	<ft:fieldset legend="General">
		<ft:object stObject="#stobj#" lFields="title,contentType" r_stPrefix="generalPrefix" />
	</ft:fieldset>
	
	<ft:fieldset legend="Search Result Data">
		
		<ft:field label="Result Title" hint="The field that will be used for the search result title.">
			<cfoutput>
				<select name="resultTitleField" id="resultTitleField"></select>
			</cfoutput>
		</ft:field>
		
		<ft:field label="Result Summary" hint="The field that will be used for the search result summary.  It is suggested to use a teaser field here.">
			<cfoutput>
				<select name="resultSummaryField" id="resultSummaryField"></select>
			</cfoutput>
		</ft:field>
		
	</ft:fieldset>
	
	<ft:fieldset legend="Advanced Options">
		<ft:object stObject="#stobj#" lFields="bEnableSearch,builtToDate,bIndexOnSave" />
	</ft:fieldset>
	
	<ft:fieldset legend="Indexed Properties" helpSection="The properties for this content type that will be indexed.">
		
		<!--- TODO: add a note telling users that all Text (General) fields will be copied to a phonetic field to allow phonetic searching. 
		No need to add a separate phonetic field as well for those fields --->
		
		<cfoutput><div id="indexedProperties"></div></cfoutput>
		
	</ft:fieldset>
	
	<ft:fieldset legend="Related Rules" helpSection="TODO: MORE TO COME">
		
		<ft:object stObject="#stobj#" lFields="bIndexRuleData" r_stPrefix="rulePrefix" />
		
		<ft:field label="Indexed Rules" bMultiField="true">
			
			<cfset aRules = application.fapi.getContentType("solrProContentType").getRules() />
			
			<cfloop array="#aRules#" index="rule">
				<cfoutput>
				<div class="rule">
					<input type="checkbox" name="lIndexedRules" id="lIndexedRules_#rule.typename#" value="#rule.typename#" <cfif listFindNoCase(stobj.lIndexedRules, rule.typename)>checked="checked"</cfif> />
					<label for="lIndexedRules_#rule.typename#">#rule.displayname#<br /><span class="indexableFields">(#rule.indexableFields#)</span></label>
				</div>
				</cfoutput>
			</cfloop>
			
		</ft:field>
		
	</ft:fieldset>
	
	<ft:farcryButtonPanel>
		<ft:farcryButton type="submit" text="Complete" value="save" validate="true" />
		<ft:farcryButton type="submit" text="Cancel" value="cancel" validate="false" confirmText="Are you sure you wish to discard your changes?" />
	</ft:farcryButtonPanel>
	
	<skin:htmlhead id="solrProContentType-edit">
		<cfoutput>
		<style type="text/css" media="all">
			.fieldType {
				padding: 0.25em 0 0.25em 0.5em;
			}
			.fieldType label {
				margin-left: 0.25em;
				margin-right: 0.25em;
			}
			table.fcproperties {
				margin: .85em 0;
				border-collapse: collapse;
				font-size: 1em;
			}
			table.fcproperties caption {
				font: bold 145% arial;
				padding: 5px 10px;
				text-align: left;
			}
			table.fcproperties td,
			table.fcproperties th {
				border: 1px solid ##eee;
				padding: .6em 10px;
				text-align: left;
				vertical-align: top;
			}
			table.fcproperties tr.alt {
				background: none repeat scroll 0 0 ##F1F1F1;
			}
			##indexedProperties {
				max-width: 650px;
				min-width: 500px;
			}
			##tblCustomProperties {
				width: 100%;
			}
			##tblCustomProperties thead tr th:nth-child(3) {
				min-width: 30%;
				width: 50%;
			}
			##tblCustomProperties tbody tr td:nth-child(3), ##tblCustomProperties tbody tr td:nth-child(4) {
				white-space: nowrap;
			}
		</style>
		<script type="text/javascript">
			
			var fieldTypes = [];
			
			$j(document).ready(function(){
				
				<cfif stobj.bIndexRuleData eq 0>
				$j(".rule").closest(".ctrlHolder").hide();
				</cfif>
				
				$j('###rulePrefix#bIndexRuleData').change(function(event){
					if ($j(this).is(':checked')) {
						$j(".rule").closest(".ctrlHolder").show();
					} else {
						$j(".rule").closest(".ctrlHolder").hide();
					}
				});
				
				if ($j('###generalPrefix#contentType').val().length > 0) {
					
					// load the data for the resultTitleField and resultSummaryField dropdowns
					loadContentTypeFields($j('###generalPrefix#contentType').val());
					
					// load the HTML for the table of indexed properties
					loadIndexedPropertyHTML("#stobj.objectid#",$j('###generalPrefix#contentType').val());
					
				}
				
				$j('###generalPrefix#contentType').change(function(event){
					
					// load the data for the resultTitleField and resultSummaryField dropdowns
					loadContentTypeFields($j('###generalPrefix#contentType').val());
					
					// load the HTML for the table of indexed properties
					loadIndexedPropertyHTML("#stobj.objectid#",$j('###generalPrefix#contentType').val());
					
				});
				
			});
			
			function updateFieldTypeSelectionDisplay() {
				// for each property
				$j('input[name="indexedProperties"]').each(function(i){
					
					var thisFieldName = $j(this).val();
					var displayFieldTypesDiv = $j("##displayFieldTypes_" + thisFieldName);
					var lFieldTypes = $j("##lFieldTypes_" + thisFieldName);
					
					if (!$(this).is(":checked")) {
						// remove all
						$j("##displayFieldTypes_" + thisFieldName).hide();
						$j("##fieldType_" + thisFieldName).attr("disabled", true);
						$j("button[rel='" + thisFieldName + "'].btnAddFieldType").attr("disabled", true);
						$j("##customField_" + thisFieldName).addClass("ui-state-disabled");
						$j("##fieldBoost_" + thisFieldName).addClass("ui-state-disabled").attr("disabled", true);
						$j("##fieldBoost_" + thisFieldName).next("button").addClass("ui-state-disabled").attr("disabled", true);
					} else {
						// grab the lFieldTypes value and add the items to the display div
						if (lFieldTypes.val().length > 0) {
							displayFieldTypesDiv.empty();
							var aFieldTypes = lFieldTypes.val().split(",");
							for (var x = 0; x < aFieldTypes.length; x++) {
								var fieldType = aFieldTypes[x].split(":")[0];
								var bStored = aFieldTypes[x].split(":")[1];
								displayFieldTypesDiv.append('<div class="fieldType" id="fieldType_' + thisFieldName + '_' + fieldType + '"><button class="btnRemoveFieldType" type="button" rel="' + thisFieldName + '.' + fieldType + '">Remove</button><label for="chkStore_' + thisFieldName + '_' + fieldType + '">' + $j("##fieldType_" + thisFieldName + " option[value='" + fieldType + "']").text() + '</label> <input title="Store this field in Solr?" class="chkStore" ' + ((bStored == 1) ? 'checked="checked"' : '') + '" type="checkbox" id="chkStore_' + thisFieldName + '_' + fieldType + '" name="chkStore.' + thisFieldName + '.' + fieldType + '" /></div>');
								$j("##fieldType_" + thisFieldName + " option[value='" + fieldType + "']").attr("disabled",true);
							}
						}
						$j("##displayFieldTypes_" + thisFieldName).show();
						$j("##fieldType_" + thisFieldName).attr("disabled", false);
						$j("button[rel='" + thisFieldName + "'].btnAddFieldType").attr("disabled", false);
						$j("##customField_" + thisFieldName).removeClass("ui-state-disabled").attr("disabled", false);
						$j("##fieldBoost_" + thisFieldName).removeClass("ui-state-disabled").attr("disabled", false);
						$j("##fieldBoost_" + thisFieldName).next("button").removeClass("ui-state-disabled").attr("disabled", false);
												
					}
					activateFieldTypeRemoveButtons();
					activateStoreCheckboxes();
				});
				
			}
			
			function activateFieldTypeRemoveButtons() {
				
				$j("button.btnRemoveFieldType").button({
					text: false,
					icons: { 
						primary: "ui-icon-close" 
					}
				}).css({
					"width": "1.4em",
					"height": "1.4em",
					"vertical-align": "middle"
				});
				
				$j("button.btnRemoveFieldType").click(function(event){
					
					var rel = $j(this).attr("rel").split(".");
					var fieldTypeToRemove = rel[1];
					var fieldName = rel[0];
					var lFieldTypes = $j("##lFieldTypes_" + fieldName);
					
					if (lFieldTypes.val().length) {
					
						var aFieldTypes = lFieldTypes.val().split(",");
						
						// remove it from the string
						
						for (x = 0; x < aFieldTypes.length; x++) {
							if (aFieldTypes[x].split(":")[0] == fieldTypeToRemove) {
								aFieldTypes.splice(x,1);
								break;
							}
							
						}
						
						lFieldTypes.val(aFieldTypes.join(","));
						
					}
					
					// remove it from the div
					$j("##fieldType_" + fieldName + '_' + fieldTypeToRemove).remove();
					
					$j("##fieldType_" + fieldName + " option[value='" + fieldTypeToRemove + "']").removeAttr("disabled");
					
				});
			}
			
			function activateStoreCheckboxes() {
				$j("input.chkStore").click(function(event){
					
					var parsed = $j(this).attr("name").split(".");
					var fieldName = parsed[1];
					var fieldType = parsed[2];
					var lFieldTypes = $j("##lFieldTypes_" + fieldName);
					
					// find the field in the string and set stored property 
					if (lFieldTypes.val().length) {
						
						var aFieldTypes = lFieldTypes.val().split(",");
						
						for (var i = 0; i < aFieldTypes.length; i++) {
							if (aFieldTypes[i].split(":")[0] == fieldType) {
								if (aFieldTypes[i].split(":")[1] == 1) {
									aFieldTypes[i] = fieldType + ":0";
								} else {
									aFieldTypes[i] = fieldType + ":1";
								}
								break;
							}
						}
						
						lFieldTypes.val(aFieldTypes.join(","));
							
					}
					
				});
			}
			
			function setupTableInteraction() {
				
				// activate the checkboxes
				$j('input[name="indexedProperties"]').change(function(event){
					updateFieldTypeSelectionDisplay();
				});
				
				// activate the "add" buttons
				$j("button.btnAddFieldType").click(function(event){
					
					
					var thisFieldName = $j(this).attr("rel");
					var thisFieldType = $j("##fieldType_" + thisFieldName);
					
					if (thisFieldType.val() != "") {
					
						var displayFieldTypesDiv = $j("##displayFieldTypes_" + thisFieldName);
						var lFieldTypes = $j("##lFieldTypes_" + thisFieldName);
						
						if (lFieldTypes.val().length) {
							var aFieldTypes = lFieldTypes.val().split(",");
						}
						else {
							var aFieldTypes = [];
						}
						
						if (aFieldTypes.indexOf(thisFieldType.val() + ":0") == -1 && aFieldTypes.indexOf(thisFieldType.val() + ":1") == -1) {
							aFieldTypes.push(thisFieldType.val() + ":0");
						}
						
						lFieldTypes.val(aFieldTypes.join(","));
						
						updateFieldTypeSelectionDisplay();
						
						thisFieldType.find("option:selected").removeAttr("selected");
						
					}
					
				});
				
				$j("button.btnAddFieldType").button({
					text: false,
					icons: { 
						primary: "ui-icon-plus" 
					}
				}).css({
					"width": "1.4em",
					"height": "1.4em",
					"vertical-align": "middle"
				});
				
				// setup the boost "dropdown"
				activateBoostDropdowns();
				
			}
			
			function activateBoostDropdowns() {
				
				$j('.combobox input').autocomplete({
					source: [ "1", "2", "3", "5", "10", "15", "20", "50" ],
					minLength: 0
				}).addClass( "ui-widget ui-widget-content ui-corner-left" ).css({
					"vertical-align": "middle"
				});
				
				// create and activate the button
				$j(".combobox").each(function(i){
					
					var input = $(this).find("input");
					var button = $('<button type="button">Open</button>');
					
					button.button({
						text: false,
						icons: {
							primary: "ui-icon-triangle-1-s"
						}
					}).removeClass( "ui-corner-all" ).addClass( "ui-corner-right ui-button-icon" ).css({
						"width": "1.4em",
						"height": "1.4em",
						"vertical-align": "middle"
					}).click(function (event) {
							openCombobox(input);
					});
					
					input.after(button);
					
				});
				
			}
			
			function openCombobox(target) {
				
				// if its open, close it
				if (target.autocomplete("widget").is(":visible")) {
					target.autocomplete("close");
					return;
				}

				// open the combobox
				$(this).blur();
				target.autocomplete("search","");
				target.focus();
				
			}
			
			function loadIndexedPropertyHTML(objectid,typename) {
				
				$j("##indexedProperties").empty();
				
				// do an ajax call to the webskin to grab the HTML to build the table
				$j.ajax({
					cache: false,
					type: "GET",
					url: "#application.fapi.getwebroot()#/?contentType=" + typename + "&view=indexedPropertyTable&objectid=" + objectid,
					datatype: "html",
					success: function(data, status, req) {
						
						$j("##indexedProperties").append(data);
						
						setupTableInteraction();
						
						updateFieldTypeSelectionDisplay();
						
					},
					error: function(req, status, err) {
						
						var contentType = $j('###generalPrefix#contentType');
						var message = '<p class="errorField">There was an error loading the indexed fields for that content type.  Make sure you have created an web server mapping for /farcrysolrpro. See documentation for more information.</p>';
						contentType.closest(".ctrlHolder").addClass("error").prepend(message);
						
					}
				});
				
			}
			
			function loadContentTypeFields(contentType) {
		
				$j('###generalPrefix#contentType').closest(".ctrlHolder").removeClass("error").find("p.errorField").remove();
				
				var title = $j("##resultTitleField");
				var summary = $j("##resultSummaryField");
				
				title.empty();
				summary.empty();
				
				$j.ajax({
					url: "#application.fapi.getwebroot()#/farcrysolrpro/facade/remote.cfc?method=getTextPropertiesByType&returnformat=json&typename=" + contentType,
					type: "GET",
					datatype: "json",
					success: function(data,status,req){
						
						summary.append('<option value="">-- Solr Default --</option>');
						
						var currentTitle = "#lcase(stobj.resultTitleField)#";
						var currentSummary = "#lcase(stobj.resultSummaryField)#";
							
						for (var x = 0; x < data.length; x++) {
							
							var titleHtml = "";
							var summaryHtml = "";
							
							if (data[x].toLowerCase() == currentTitle) {
								var titleHtml = '<option value="' + data[x] + '" selected="selected">' + data[x] + '</option>';
							} else if (currentTitle.length == 0 && data[x].toLowerCase() == "label") {
								var titleHtml = '<option value="' + data[x] + '" selected="selected">' + data[x] + '</option>';
							} else {
								var titleHtml = '<option value="' + data[x] + '">' + data[x] + '</option>';
							}
							
							if (data[x].toLowerCase() == currentSummary) {
								var summaryHtml = '<option value="' + data[x] + '" selected="selected">' + data[x] + '</option>';
							} else if (currentTitle.length == 0 && data[x].toLowerCase() == "teaser") {
								var summaryHtml = '<option value="' + data[x] + '" selected="selected">' + data[x] + '</option>';
							} else {
								var summaryHtml = '<option value="' + data[x] + '">' + data[x] + '</option>';
							}
							
							title.append(titleHtml);
							summary.append(summaryHtml);
							
						}
						
						// mark the selected value based on stobj
						title.find("option[value='#stobj.resultTitleField#']").attr("selected","selected");
						summary.find("option[value='#stobj.resultSummaryField#']").attr("selected","selected");
						 
					},
					error: function(req,status,err){
						
						var contentType = $j('###generalPrefix#contentType');
						var message = '<p class="errorField">There was an error loading the fields for that content type.  Make sure you have created an web server mapping for /farcrysolrpro. See documentation for more information.</p>';
						
						contentType.closest(".ctrlHolder").addClass("error").prepend(message);
						
					},
					cache: false
				});
			}
			
		</script>
		</cfoutput>
	</skin:htmlhead>
	
</ft:form>

<cfsetting enablecfoutputonly="false" />