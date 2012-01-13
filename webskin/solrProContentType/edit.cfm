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
		
		<!--- ensure this is not a duplicate content type --->
		<cfset stValidationResult = ftValidateContentType(
			objectid = stProperties.objectid, 
			typename = "solrProContentType", 
			stFieldPost = { value = stProperties.contentType }, 
			stMetadata = {}
		) />
		<cfif stValidationResult.bSuccess eq false>
			<ft:advice 
				objectid="#stProperties.objectid#" 
				field="contentType" 
				message="#stValidationResult.stError.message#" 
				value="#stValidationResult.value#" />
			<cfset bContinueSave = false />
		</cfif>
		
		<!--- assure all core field boost values are numeric --->
		<cfparam name="form.indexedProperties" type="string" default="" />
		<cfloop collection="#form#" item="f">
			<cfif left(f, len('coreFieldBoost_')) eq 'coreFieldBoost_'>
				<cfif not isNumeric(form[f])>
					<ft:advice 
						objectid="#stProperties.objectid#" 
						field="aIndexedProperties" 
						message="Field boost values must be numeric. Boost value for #right(f,len(f)-len('coreFieldBoost_'))# is ""#form[f]#""" 
						value="#form[f]#" />
					<cfset bContinueSave = false />
				</cfif>
			</cfif>
		</cfloop>
		
		<!--- validate custom field boost values --->
		<cfloop collection="#form#" item="f">
			<cfif left(f, len('lFieldTypes_')) eq 'lFieldTypes_'>
				<cfset aFieldTypes = listToArray(form[f]) />
				<cfloop array="#aFieldTypes#" index="ft">
					<cfif listlen(ft,":") neq 3>
						<ft:advice 
							objectid="#stProperties.objectid#" 
							field="aIndexedProperties" 
							message="There is an error in your field type definition for #right(f,len(f)-len('lFieldTypes_'))#" 
							value="#form[f]#" />
						<cfset bContinueSave = false />
					<cfelse>
						<cfif not isNumeric(listGetAt(ft,3,":"))>
							<ft:advice 
								objectid="#stProperties.objectid#" 
								field="aIndexedProperties" 
								message="Field boost values must be numeric.  Boost value for #right(f,len(f)-len('lFieldTypes_'))# is ""#listGetAt(ft,3,":")#""" 
								value="#form[f]#" />
							<cfset bContinueSave = false />
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<!--- validate the result summary fields --->
		<cfparam name="form.resultSummaryField" type="string" default="" />
		<cfset stProperties["resultSummaryField"] = form.resultSummaryField  />
		<cfif len(trim(stProperties["resultSummaryField"])) eq 0>
			<!--- if no specific result summary field, require at least one field to build the highlight field in solr --->
			<cfparam name="form.lSummaryFields" type="string" default="" />
			<cfset stProperties["lSummaryFields"] = form.lSummaryFields />
			<cfif listLen(stProperties["lSummaryFields"]) eq 0>
				<ft:advice 
					objectid="#stProperties.objectid#" 
					field="lSummaryFields" 
					message="Since you have not chosen a field to serve as the search result summary, you must choose at least one field to use to have Solr generate a summary" 
					value="#form.lSummaryFields#" />
				<cfset bContinueSave = false />
			</cfif>
		</cfif>
		
		<!--- TODO: ensure that 2 records for the same content type are not created (dupe check "contentType" field) --->
		
	</ft:processFormObjects>
		
</ft:processform>

<cfif bContinueSave>
	
	<ft:processform action="Save" exit="true">
		
		<ft:processFormObjects typename="solrProContentType">
			
			<cfparam name="form.resultTitleField" type="string" default="label" />
			<cfparam name="form.resultSummaryField" type="string" default="" />
			<cfparam name="form.resultImageField" type="string" default="" />
			<cfset stProperties["resultTitleField"] = form.resultTitleField />
			<cfset stProperties["resultSummaryField"] = form.resultSummaryField  />
			<cfset stProperties["resultImageField"] = form.resultImageField  />

			<cfif len(trim(stProperties["resultSummaryField"]))>
				<!--- if we have a specific summary field, then set the lSummaryFields value as an empty string.  This will prevent population of the "highlight" field.  Since its not being used, we can save disk space. --->
				<cfset stProperties["lSummaryFields"] = "" />
			<cfelse>
				<!--- if no specific summary field was chosen, then we use the checkboxes to indicate how to build the "highlight" field which will be used to generate a teaser for the search results --->
				<cfparam name="form.lSummaryFields" type="string" default="" />
				<cfset stProperties["lSummaryFields"] = form.lSummaryFields />
			</cfif>
			
			<!--- clear the array of indexed properties --->
			<cfparam name="stProperties.aIndexedProperties" type="array" default="#arrayNew(1)#" />
			<cfset oldIndexedProperties = duplicate(stProperties.aIndexedProperties) />
			<cfset stProperties.aIndexedProperties = [] />
			
			<!--- build the property list --->
			<cfparam name="form.indexedProperties" type="string" default="" />
			<cfloop list="#form.indexedProperties#" index="prop">
				
				<cfset stIndexedProperty = {
					fieldName = prop,
					lFieldTypes = form['lFieldTypes_' & prop]
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
	
	<ft:fieldset legend="Indexed Properties" helpSection="The properties for this content type that will be indexed.">
		<cfparam name="request.stFarcryFormValidation" default="#structNew()#" />
		<cfif structKeyExists(request.stFarcryFormValidation,stobj.objectid) and structKeyExists(request.stFarcryFormValidation[stobj.objectid],"aIndexedProperties")>
			<ft:field label="" class="error">
				<cfoutput>
				<p class="errorField" htmlfor="aIndexedProperties" for="aIndexedProperties">#request.stFarcryFormValidation[stobj.objectid]['aIndexedProperties'].stError.message#</p>
				</cfoutput>
			</ft:field>
		</cfif>
		<cfoutput><div id="indexedProperties"></div></cfoutput>		
	</ft:fieldset>
	
	<ft:fieldset legend="Search Result Defaults">
		
		<ft:field label="Result Title <em>*</em>" hint="The field that will be used for the search result title.  It is suggested to use a ""string"" field. You must store this value in Solr's index.">
			<cfoutput>
				<select name="resultTitleField" id="resultTitleField"></select>
			</cfoutput>
		</ft:field>

		<cfparam name="request.stFarcryFormValidation" default="#structNew()#" />
		<cfif structKeyExists(request.stFarcryFormValidation,stobj.objectid) and structKeyExists(request.stFarcryFormValidation[stobj.objectid],"lSummaryFields")>
			<cfset className = "error" />
		<cfelse>
			<cfset className = "" />
		</cfif>
		<ft:field label="Result Summary" bMultiField="true" class="#className#" hint="The field that will be used for the search result summary.<br />Options are:<br />1. Solr Generated Summary: Select any desired FarCry field(s) and Solr will use it's highlighting engine to return areas of the field(s) that match the search term.<br />2. Use a manually selected field.">
			<cfoutput>
				<cfif structKeyExists(request.stFarcryFormValidation,stobj.objectid) and structKeyExists(request.stFarcryFormValidation[stobj.objectid],"lSummaryFields")>
				<p class="errorField" htmlfor="lSummaryFields" for="lSummaryFields">#request.stFarcryFormValidation[stobj.objectid]['lSummaryFields'].stError.message#</p>
				</cfif>
				<select name="resultSummaryField" id="resultSummaryField"></select>
				<div id="lSummaryFields"></div>
			</cfoutput>
		</ft:field>
		
		<ft:field label="Result Image" hint="The field that will be used for the search result teaser image.  If you have an image you would like to display in the search results choose the Solr field that will contain the image's path.  It is recommended you use a ""string"" field type.  You must store this value in Solr's index.">
			<cfoutput>
				<select name="resultImageField" id="resultImageField"></select>
			</cfoutput>
		</ft:field>
		
	</ft:fieldset>
	
	<ft:fieldset legend="Related Rules" helpSection="The FarCry Solr Pro plugin can index the contents of rules that have text data.">
		
		<ft:object stObject="#stobj#" lFields="bIndexRuleData" r_stPrefix="rulePrefix" />
		
		<ft:field label="Indexed Rules" bMultiField="true" hint="Choose the rules you would like to index for this content type.  The rule fields that will be indexed are listed below each rule name.  Only text fields can be indexed.">
			
			<cfset aRules = application.fapi.getContentType("solrProContentType").getRules() />
			
			<cfloop array="#aRules#" index="rule">
				<cfoutput>
				<div class="rule">
					<input type="checkbox" name="lIndexedRules" id="lIndexedRules_#rule.typename#" value="#rule.typename#" <cfif listFindNoCase(stobj.lIndexedRules, rule.typename)>checked="checked"</cfif> />
					<label for="lIndexedRules_#rule.typename#">#rule.displayname#<br /><div class="indexableFields"><span>(#replace(rule.indexableFields, ",", ", ", "all")#)</span></div></label>
				</div>
				</cfoutput>
			</cfloop>
			
		</ft:field>
		
	</ft:fieldset>
	
	<ft:fieldset legend="Advanced Options">
		<ft:object stObject="#stobj#" lFields="bEnableSearch,builtToDate,bIndexOnSave" />
	</ft:fieldset>
	
	<ft:farcryButtonPanel>
		<ft:farcryButton type="submit" text="Complete" value="save" validate="true" />
		<ft:farcryButton type="submit" text="Cancel" value="cancel" validate="false" confirmText="Are you sure you wish to discard your changes?" />
	</ft:farcryButtonPanel>
	
	<cfoutput>
		<div id="helpInfo" class="ui-widget-content ui-corner-all">
			<h3 class="ui-widget-header ui-corner-all">Information &amp; Tips</h3>
			<ul id="helpInfoUl">
				<li class="ui-icon ui-icon-circle-check">
					<p>Etiam libero neque, luctus a, eleifend nec, semper at, lorem. Sed pede. Nulla lorem metus, adipiscing ut, luctus sed, hendrerit vitae, mi.</p>
					<p>Etiam libero neque, luctus a, eleifend nec, semper at, lorem. Sed pede. Nulla lorem metus, adipiscing ut, luctus sed, hendrerit vitae, mi.</p>
				</li>
				<li>
					<h4>Search Result Defaults</h4>
					<h5>Search Summary</h5>
					<p>Using Solr's generated summary takes advantage of Solr's highlighting engine.  It's not the fact that it just highlights search terms (thats simple enough to do in CF).  What makes it unique is that the summary will be snippets of text where your search term(s) were found (similar to Google).</p>
					<p>Using a custom field selection is suggested for times when you want, say, a specified teaser field to always be used no matter where the search terms were found. Example: Say you have a product with a very specified teaser that you want to always be shown in your search results (not a snippet of the search term)</p>
					<p>Performance tip: If using option 2, it is suggested to "Store" the field in Solr.  This way Solr can just output the result rather than requiring FarCry to do a record lookup.</p>
				</li>
				<li style="float: none;">
					<p>Etiam libero neque, luctus a, eleifend nec, semper at, lorem. Sed pede. Nulla lorem metus, adipiscing ut, luctus sed, hendrerit vitae, mi.</p>
					<p>Etiam libero neque, luctus a, eleifend nec, semper at, lorem. Sed pede. Nulla lorem metus, adipiscing ut, luctus sed, hendrerit vitae, mi.</p>
				</li>
			</ul>
			<!---
			<h4 class="ui-icon ui-icon-circle-check" style="float:left; margin: .2em 7px 50px 0;">
				<!---<span class="ui-icon ui-icon-circle-check" style="float:left; margin: .2em 7px 50px 0;"></span>--->
				Etiam libero neque, luctus a, eleifend nec, semper at, lorem. Sed pede. Nulla lorem metus, adipiscing ut, luctus sed, hendrerit vitae, mi.
			</h4>
			<p>Etiam libero neque, luctus a, eleifend nec, semper at, lorem. Sed pede. Nulla lorem metus, adipiscing ut, luctus sed, hendrerit vitae, mi.</p>
			<p>Etiam libero neque, luctus a, eleifend nec, semper at, lorem. Sed pede. Nulla lorem metus, adipiscing ut, luctus sed, hendrerit vitae, mi.</p>
			<p>Etiam libero neque, luctus a, eleifend nec, semper at, lorem. Sed pede. Nulla lorem metus, adipiscing ut, luctus sed, hendrerit vitae, mi.</p>
			--->
		</div>
	</cfoutput>
	
	<skin:htmlhead id="solrProContentType-edit">
		<cfoutput>
		<style type="text/css" media="all">
			.combobox a {
				text-decoration: none;
				vertical-align: middle;
				padding-right: 0.4em;
			}
			.combobox a:hover {
				background: transparent;
			}
			.combobox input {
				width: 4em;
			}
			.fieldTypeDropdown {
				vertical-align: middle;
			}
			.fieldType {
				padding: 0.25em 0 0.25em 0.5em;
			}
			.fieldType span {
				margin-left: 0.25em;
				margin-right: 0.25em;
			}
			.fieldType div.fieldTypeAttributesLeft {
				min-width: 35em;
			}
			.fieldType div.fieldTypeAttributesLeft span {
				vertical-align: middle;
			}
			.fieldType div.fieldTypeAttributesRight {
				float: right;
			}
			.fieldType div.fieldTypeAttributesRight div {
				display: inline;
				padding-left: 0.5em;
				vertical-align: middle;
			}
			.fieldType div.fieldTypeAttributesRight div input {
				vertical-align: middle;
			}
			.fieldType div.buttonset label:not(.ui-state-active) span {
				color: ##888 !important;
			}
			.fieldType div.buttonset label span {
				font-size: 0.8em;
				padding: 0.1em 0.4em;
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
				max-width: 900px;
				min-width: 500px;
			}
			##tblCustomProperties {
				width: 100%;
			}
			##tblCustomProperties tbody tr td:nth-child(1) {
				padding-top: .8em;
			}
			##tblCustomProperties thead tr th:nth-child(4) {
				width: 55%;
				white-space: nowrap;
			}
			div.rule div.indexableFields {
				padding-left: 1.2em;
			}
			##lSummaryFields {
				margin: 10px 0;
				min-height: 100px;
				height: auto;
			}
			##lSummaryFields label {
				float: left;
				width: 185px;
				margin: 2px 0;
			}
			##lSummaryFields label input {
				margin-right: 5px;
			}
			##helpInfo {
				padding: 0.4em;
				position: relative;
				margin: 1em 0;
				min-width: 500px;
				max-width: 800px;
			}
			##helpInfo h3 {
				margin: 0 0 1em 0;
				padding: 0.4em;
				text-align: center;
			}
			##helpInfoUl li {
				float: left;
			}
			##helpInfoUl li h4,
			##helpInfoUl li p {
				margin-left: 25px;
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
					// load the HTML for the table of indexed properties
					loadIndexedPropertyHTML("#stobj.objectid#",$j('###generalPrefix#contentType').val());
					// load the FarCry fields for the lSummaryFields list box
					loadContentTypeFields($j('###generalPrefix#contentType').val());
				}
				
				$j('###generalPrefix#contentType').change(function(event){
					// load the HTML for the table of indexed properties
					loadIndexedPropertyHTML("#stobj.objectid#",$j('###generalPrefix#contentType').val());
					// load the FarCry fields for the lSummaryFields list box
					loadContentTypeFields($j('###generalPrefix#contentType').val());
				});
				
				<!--- hide the "summary fields" checkboxes if we have a specific summary field --->
				<cfif len(trim(stobj.resultSummaryField))>
					$j("##lSummaryFields").hide();
				</cfif>
				
				$j('##resultSummaryField').change(function(event){
					// hide/show summary field checkboxes
					if ($j.trim($j(this).val()) == '') {
						$j('##lSummaryFields').slideDown("slow");						
					} else {
						$j('##lSummaryFields').slideUp("slow");						
					}
				});
				
			});
			
			function createOptionTag(value, label, selected) {
				var html = '<option value="' + value + '"';
				if (selected) {
					html = html + ' selected="selected"';
				}
				html = html + ">" + label + "</option>";
				return html;
			}
			
			function addOptionsToDropdown(dropdown, options) {
				dropdown.empty();
				for (var i = 0; i < options.length; i++) {
					dropdown.append(options[i]);
				}
			}
			
			function loadResultFieldDropdowns() {
				buildResultTitleDropdownOptions();
				buildResultSummaryDropdownOptions();
				buildResultImageDropdownOptions();
			}
			
			function buildResultTitleDropdownOptions() {
				
				var selectedValue = '#stobj.resultTitleField#';
				if (selectedValue == '') {
					selectedValue = 'label';
				}
				var dropdown = $j("##resultTitleField");
				var options = buildResultFieldOptions(selectedValue);
				
				addOptionsToDropdown(dropdown, options);
				
				// set the selected one
				if (selectedValue.length > 0) {
					// if we have that option in the drop down, select it
					dropdown.find('option[value="' + selectedValue + '"]').attr("selected",true);
				} else {
					// if there is a title field, select it
					dropdown.find('option[value*="title_"]').attr('selected',true);
				}
				
			}
			
			function buildResultSummaryDropdownOptions() {
				
				var selectedValue = '#stobj.resultSummaryField#';
				var dropdown = $j("##resultSummaryField");
				var options = buildResultFieldOptions(selectedValue);
				
				// add the "none" option
				options.push(createOptionTag("","-- Use Solr Generated Summary --",false));
				options.sort();
				
				addOptionsToDropdown(dropdown, options);

			}
			
			function buildResultImageDropdownOptions() {
				
				var selectedValue = '#stobj.resultImageField#';
				var dropdown = $j("##resultImageField");
				var options = buildResultFieldOptions(selectedValue);
				
				// add the "none" option
				options.push(createOptionTag("","-- No Teaser Image --",false));
				options.sort();
				
				addOptionsToDropdown(dropdown, options);
				
			}
			
			function buildResultFieldOptions(selectedValue) {
				
				// builds an array of HTML option tags for the result fields
				
				var fields = loadResultFieldsForDropdowns();
				var options = [];
				
				for (var i = 0; i < fields.length; i++) {
					options.push(createOptionTag(fields[i].fieldName, fields[i].label, (selectedValue == fields[i].fieldName)));
				}
				
				return options;
				
			}
			
			function loadResultFieldsForDropdowns() {
				
				// loads candidates for the result title, summary and image fields
				
				// get all of the created fields from the custom properties table and all core properties
				var fields = [];
				
				// get custom properties
				$j('input.lFieldTypes').each(function(i){
					
					// we are only interested in the ones that have defined field types
					if ($j(this).val().length > 0) {
					
						// grab the base field name
						var baseFieldName = $j(this).attr('rel').toLowerCase();
						
						// for each defined field type, build the full field name and add it to the array
						
						// step 1: the value of the text box is a comma delimited list of defined field types
						var types = $j(this).val().split(",");
						
						// step 2: each of the field type definitions is a colon delimited list of values in type:storedFlag:boostValue format
						for (var i = 0; i < types.length; i++) {
							types[i] = types[i].split(":");
						}
						
						// step 3: build full field name and add it to the array
						for (var y = 0; y < types.length; y++) {
							// only include stored fields
							if (types[y][1] == 1) {
								var type = types[y][0];
								var fullFieldName = baseFieldName + "_" + type + "_stored";
								fields.push({fieldName: fullFieldName, label: baseFieldName + " (" + type + ")"});
							}
						}
						
					}
						
				});
				
				// get core properties
				$j("##tblCoreProperties tbody tr").each(function(i){
					// include only stored fields
					var stored = $j.trim($j(this).find("td:nth-child(4)").text().toLowerCase());
					if (stored == "yes") {
						// column 1 is field name
						fields.push({ fieldName: $j(this).find("td:first-child").text(), label: $j(this).find("td:first-child").text()});
					}
				});
				
				// sort 'em alphabetically
				fields.sort();
				
				return fields;
				
			}
			
			function updateFieldTypeSelectionDisplay() {
				// for each property
				$j('input[name="indexedProperties"]').each(function(i){
					
					var thisFieldName = $j(this).val();
					var displayFieldTypesDiv = $j("##displayFieldTypes_" + thisFieldName);
					var lFieldTypes = $j("##lFieldTypes_" + thisFieldName);
					
					if (!$j(this).is(":checked")) {
						// remove all
						$j("##displayFieldTypes_" + thisFieldName).hide();
						$j("##fieldType_" + thisFieldName).attr("disabled", true);
						$j("button[rel='" + thisFieldName + "'].btnAddFieldType").attr("disabled", true);
						$j("##customField_" + thisFieldName).addClass("ui-state-disabled");
						$j("##fcFieldType_" + thisFieldName).addClass("ui-state-disabled");
					} else {
						// grab the lFieldTypes value and add the items to the display div
						if (lFieldTypes.val().length > 0) {
							displayFieldTypesDiv.empty();
							var aFieldTypes = lFieldTypes.val().split(",");
							for (var x = 0; x < aFieldTypes.length; x++) {
								var parsed = aFieldTypes[x].split(":");
								var fieldType = parsed[0];
								var bStored = parsed[1];
								var boostValue = parsed[2];
								
								   var html = '<div class="fieldType" id="fieldType_' + thisFieldName + '_' + fieldType + '"> ';
								html = html + '<div class="fieldTypeAttributesRight">';
								html = html + '<div class="buttonset">';
								html = html + '<input value="1" class="chkStore" ' + ((bStored == 1) ? 'checked="checked"' : '') + ' type="radio" id="chkStore_' + thisFieldName + '_' + fieldType + '_on" name="chkStore.' + thisFieldName + '.' + fieldType + '" /><label for="chkStore_' + thisFieldName + '_' + fieldType + '_on">Stored</label>';
								html = html + '<input class="chkStore" ' + ((bStored == 0) ? 'checked="checked"' : '') + '  name="chkStore.' + thisFieldName + '.' + fieldType + '" type="radio" value="0" id="chkStore_' + thisFieldName + '_' + fieldType + '_off" /><label for="chkStore_' + thisFieldName + '_' + fieldType + '_off">Not Stored</label>';
								html = html + '</div>';
								html = html + '<div class="combobox">';
								// combobox id uses underscores instead of period because of an issue with jquery selectors and periods
								html = html + '<label for="fieldBoost_' + thisFieldName + '_' + fieldType + '">Boost:</label>';
								html = html + '<input type="text" rel="' + thisFieldName + '.' + fieldType + '" class="fieldBoost" name="fieldBoost_' + thisFieldName + '.' + fieldType + '" id="fieldBoost_' + thisFieldName + '_' + fieldType + '" value="' + boostValue + '" />';
								html = html + '</div>';
								html = html + '</div>';
								html = html + '<div class="fieldTypeAttributesLeft">';
								html = html + '<button class="btnRemoveFieldType" type="button" rel="' + thisFieldName + '.' + fieldType + '">Remove</button>';
								html = html + '<span>' + $j("##fieldType_" + thisFieldName + " option[value='" + fieldType + "']").text() + '</span>';
								html = html + '</div>';
								html = html + '</div>';
								
								displayFieldTypesDiv.append(html);
								$j("##fieldType_" + thisFieldName + " option[value='" + fieldType + "']").attr("disabled",true);
							}
						}
						$j("##displayFieldTypes_" + thisFieldName).show();
						$j("##fieldType_" + thisFieldName).attr("disabled", false);
						$j("button[rel='" + thisFieldName + "'].btnAddFieldType").attr("disabled", false);
						$j("##customField_" + thisFieldName).removeClass("ui-state-disabled").attr("disabled", false);
						$j("##fcFieldType_" + thisFieldName).removeClass("ui-state-disabled").attr("disabled", false);			
					}
					
				});
				
				activateFieldTypeRemoveButtons();
				activateStoreCheckboxes();
				activateBoostDropdowns();
				
				// setup stored/not stored toggle
				$j( ".fieldType div.buttonset" ).buttonset();
				
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
					
					loadResultFieldDropdowns();
					
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
								aFieldTypes[i] = fieldType + ":" + $j(this).val() + ":" + aFieldTypes[i].split(":")[2];
								break;
							}
						}
						
						lFieldTypes.val(aFieldTypes.join(","));
							
					}
					
					loadResultFieldDropdowns();
					
				});
			}
			
			function setupTableInteraction() {
				
				// activate the checkboxes
				$j('input[name="indexedProperties"]').change(function(event){
					updateFieldTypeSelectionDisplay();
					loadResultFieldDropdowns();
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
						
						// make sure this type has not already been added
						bAlreadyExists = false;
						for (var i = 0; i < aFieldTypes.length; i++) {
							if (aFieldTypes[i].split(":")[0] == thisFieldType.val()) {
								bAlreadyExists = true;
								break;
							}
						}
						// if not add with default "stored" value, and boost value
						if (bAlreadyExists == false) {
							aFieldTypes.push(thisFieldType.val() + ":0:#application.fapi.getConfig(key = 'solrserver', name = 'defaultBoostValue', default = 5)#");
						}
						
						lFieldTypes.val(aFieldTypes.join(","));
						
						updateFieldTypeSelectionDisplay();
						
						thisFieldType.find("option:selected").removeAttr("selected");
						
					}
					
					loadResultFieldDropdowns();
					
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
			}
			
			function handleBoostChange(target) {
				
				// grab the hidden field for this field/fieldtype
				var fieldName = $j(target).attr("rel").split(".")[0];
				var fieldType = $j(target).attr("rel").split(".")[1];
				var hidden = $j("##lFieldTypes_" + fieldName);
				
				// grab the current value of the hidden field
				var aFieldTypes = hidden.val().split(',');
				
				// loop over the list until you find the field type we are changing
				for (var i = 0; i < aFieldTypes.length; i++) {
					if (aFieldTypes[i].split(":")[0].toLowerCase() == fieldType.toLowerCase()) {
						// update the boost value
						aFieldTypes[i] = fieldType.toLowerCase() + ":"  + aFieldTypes[i].split(":")[1] + ":" + $j(target).val();
						break;
					}
				}
				// write the new string to the hidden field's value
				hidden.val(aFieldTypes.join(","));
				
			}
						
			function activateBoostDropdowns() {
				
				<cfset counter = 0 />
				<cfset lFieldBoostValues = application.fapi.getConfig(key = 'solrserver', name = 'lFieldBoostValues') />
				
				$j('.combobox input').each(function(i){
					
					var options = [ <cfloop list="#lFieldBoostValues#" index="i"><cfset counter++ />"#i#"<cfif counter lt listLen(lFieldBoostValues)>,</cfif></cfloop> ];
					
					if (options.indexOf($j(this).val()) == -1) {
						options.push($j(this).val());
					}
					
					options.sort(function (a,b) {
						return a - b;
					});
					
					$j(this).autocomplete({
						source: options,
						minLength: 0,
						change: function (event) {
							handleBoostChange(this);
						},
					}).addClass( "ui-widget ui-widget-content ui-corner-left" ).css({
						"vertical-align": "middle"
					});
					
				});
				
				// activate the label
				$j('.combobox label').each(function(i){
					var labelText = $j(this).text();
					var target = $j(this).attr("for");
					$j(this).html("<a>" + labelText + "</a>");
					$j(this).find("a").click(function(event){
						event.preventDefault();
						openCombobox($j("##" + target));
					});
				});
				
				// create and activate the button
				$j(".combobox").each(function(i){
					
					if ($j(this).find("button").length > 0) {
						return false;
					}
					
					var input = $j(this).find("input");
					var button = $j('<button type="button">Open</button>');
					
					// add a change handler for the input
					input.change(function(event){
						handleBoostChange(this);
					});
					
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
				$j(this).blur();
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
						
						loadResultFieldDropdowns();
						
					},
					error: function(req, status, err) {
						
						var contentType = $j('###generalPrefix#contentType');
						var message = '<p class="errorField">There was an error loading the indexed fields for that content type.  Make sure you have created an web server mapping for /farcrysolrpro. See documentation for more information.</p>';
						contentType.closest(".ctrlHolder").addClass("error").prepend(message);
						
					}
				});
				
			}
			function loadContentTypeFields(contentType) {
				
				var lSummaryFields = $j("##lSummaryFields");
				
				lSummaryFields.empty();
				
				$j.ajax({
					url: "#application.fapi.getwebroot()#/farcrysolrpro/facade/remote.cfc?method=getTextPropertiesByType&returnformat=json&typename=" + contentType,
					type: "GET",
					datatype: "json",
					success: function(data,status,req){
						
						var currentValueArray = ("#lcase(stobj.lSummaryFields)#").split(",");
						
						for (var x = 0; x < data.length; x++) {
							
							var html = '<label><input type="checkbox" name="lSummaryFields" value="' + data[x].toLowerCase() + '"';
							
							if (currentValueArray.indexOf(data[x].toLowerCase()) > -1) {
								html = html + ' checked="checked"';
							}
							
							html = html + ' />' + data[x] + '</label>';
							
							lSummaryFields.append(html);
						}
						
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