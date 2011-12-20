<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit --->
<!--- @@author: Sean Coyne (www.n42designs.com) --->
<!--- @@cacheStatus: -1 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<skin:loadJs id="jquery" />
<skin:loadJs id="jquery-ui" />
<skin:loadCss id="jquery-ui" />

<!---<ft:processform action="Save">
	
	<!--- do some validation first --->
	<ft:processFormObjects typename="solrProContentType" bSessionOnly="true" r_stObject="stObj">
		
		<!--- assume success --->
		<cfset bContinueSave = true />
		
	</ft:processFormObjects>
		
</ft:processform>

<cfif bContinueSave>
	
	<ft:processform action="Save" exit="true">
		
		<ft:processFormObjects typename="solrProContentType">
			
			<!--- build the property list --->
			
			
			<!--- build the list of indexed rules --->
			<cfparam name="form.lIndexedRules" type="string" default="" />
			<cfset stProperties["lIndexedRules"] = form.lIndexedRules />
			
		</ft:processFormObjects>
		
	</ft:processform>

</cfif>--->

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
		<ft:object stObject="#stobj#" lFields="bEnableSearch,builtToDate" />
	</ft:fieldset>
	
	<ft:fieldset legend="Indexed Properties" helpSection="The properties for this content type that will be indexed.">
		
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
			
			function setupTableInteraction() {
				
				// activate the "add" buttons
				$j("button.btnAddFieldType").click(function(event){
					
					var thisFieldName = $j(this).attr("rel");
					var thisFieldType = $j("##fieldType_" + thisFieldName);
					
					var displayFieldTypesDiv = $j("##displayFieldTypes_" + thisFieldName);
					var lFieldTypes = $j("##lFieldTypes_" + thisFieldName);
					
					if (lFieldTypes.val().length) {
						var aFieldTypes = lFieldTypes.val().split(",");	
					} else {
						var aFieldTypes = [];
					}
					
					if (aFieldTypes.indexOf(thisFieldType.val() + ":0") == -1 && aFieldTypes.indexOf(thisFieldType.val() + ":1") == -1) {
						aFieldTypes.push(thisFieldType.val() + ":0");
					}
					
					lFieldTypes.val(aFieldTypes.join(","));
					
					displayFieldTypesDiv.empty();
					for (var x = 0; x < aFieldTypes.length; x++) {
						
						var fieldType = aFieldTypes[x].split(":")[0];
						var bStored = aFieldTypes[x].split(":")[1];
						
						displayFieldTypesDiv.append('<div class="fieldType" id="fieldType_' + thisFieldName + '_' + fieldType + '"><button class="btnRemoveFieldType" type="button" rel="' + thisFieldName + '.' + fieldType + '">Remove</button><label for="chkStore_' + thisFieldName + '_' + fieldType + '">' + fieldType + '</label> <input class="chkStore" ' + ((bStored == 1) ? 'checked="checked"' : '') + '" type="checkbox" id="chkStore_' + thisFieldName + '_' + fieldType + '" name="chkStore.' + thisFieldName + '.' + fieldType + '" /></div>');
						
					}
					
					$j("button.btnRemoveFieldType").click(function(event){
						
						var rel = $j(this).attr("rel").split(".");
						var fieldTypeToRemove = rel[1];
						var fieldName = rel[0];
						
						if (lFieldTypes.val().length) {
						
							var aFieldTypes = lFieldTypes.val().split(",");
							
							// remove it from the string
							
							for (x = 0; x < aFieldTypes.length; x++) {
								console.log(aFieldTypes[x].split(":")[0]);
								console.log(fieldTypeToRemove);
								if (aFieldTypes[x].split(":")[0] == fieldTypeToRemove) {
									aFieldTypes.splice(x,1);
									break;
								}
								
							}
							
							lFieldTypes.val(aFieldTypes.join(","));
							
						}
						
						// remove it from the div
						$j("##fieldType_" + fieldName + '_' + fieldTypeToRemove).remove();
						
					});
					
					$j("input.chkStore").click(function(event){
						
						var parsed = $j(this).attr("name").split(".");
						var fieldName = parsed[1];
						var fieldType = parsed[2];
						
						// find the field in the string and set stored property 
						if (lFieldTypes.val().length) {
							
							var aFieldTypes = lFieldTypes.val().split(",");
							
							for (var i = 0; i < aFieldTypes.length; i++) {
								console.log(aFieldTypes[i].split(":")[0]);
								console.log(fieldType);
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
					
				});
				
				// setup the boost "dropdown"
				activateBoostDropdowns();
				
			}
			
			function activateBoostDropdowns() {
				
				$j('.combobox input').autocomplete({
					source: [ "1", "2", "3", "5", "10", "15", "20", "50" ],
					minLength: 0
				}).addClass( "ui-widget ui-widget-content ui-corner-left" );
				
				// create and activate the button
				$j(".combobox").each(function(i){
					
					var input = $(this).find("input");
					var button = $('<button type="button">Open</button>');
					
					button.button({
						text: false,
						icons: {
							primary: "ui-icon-triangle-1-s"
						}
					}).removeClass( "ui-corner-all" ).addClass( "ui-corner-right ui-button-icon" ).click(function (event) {
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
					url: "#application.fapi.getwebroot()#/?typename=" + typename + "&view=indexedPropertyTable&objectid=" + objectid,
					datatype: "html",
					success: function(data, status, req) {
						
						$j("##indexedProperties").append(data);
						
						setupTableInteraction();
						
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