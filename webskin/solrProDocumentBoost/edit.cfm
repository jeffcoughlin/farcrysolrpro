<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit --->
<!--- @@author: Sean Coyne (sean@n42designs.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<ft:processform action="Cancel" exit="true" />

<cfset bContinueSave = true />

<ft:processform action="Save">
	
	<!--- do some validation first --->
	
	<ft:processFormObjects typename="solrProDocumentBoost" bSessionOnly="true" r_stObject="stObj">
		
		<cfparam name="stProperties.documentId" default="" />
		<cfparam name="stProperties.boostValue" default="" />
		
		<!--- ensure we have no duplicates --->
		<cfset stValidationResult = ftValidateDocumentId(
			objectid = stProperties.objectid, 
			typename = "solrProDocumentBoost", 
			stFieldPost = { value = stProperties.documentId }, 
			stMetadata = {}
		) />
		
		<cfif stValidationResult.bSuccess eq false>
			<ft:advice 
				objectid="#stProperties.objectid#" 
				field="documentId" 
				message="#stValidationResult.stError.message#" 
				value="#stValidationResult.value#" />
			<cfset bContinueSave = false />
		</cfif>
				
	</ft:processFormObjects>
		
</ft:processform>

<cfif bContinueSave>
<ft:processform action="Save" exit="true">
	
	<ft:processFormObjects typename="solrProDocumentBoost" />
		
</ft:processform>
</cfif>

<ft:form>
	<ft:fieldset>
		<cfoutput><h1><skin:icon icon="#application.stCOAPI[stobj.typename].icon#" default="farcrycore" size="32" />#stobj.label#</h1></cfoutput>
	</ft:fieldset>
	<cfset stPropMetadata = { 
		boostValue = { 
			ftDefault = application.fapi.getConfig(key = 'solrserver', name = 'defaultDocBoost', default = 50),
			default = application.fapi.getConfig(key = 'solrserver', name = 'defaultDocBoost', default = 50)
		} 
	} />
	<cfif not isNumeric(stObj.boostValue)>
		<cfset stPropMetadata.boostValue.value = application.fapi.getConfig(key = 'solrserver', name = 'defaultDocBoost', default = 50) />
	</cfif>
	<ft:object objectid="#stobj.objectid#" lFields="documentId,boostValue" stPropMetadata="#stPropMetadata#" />
	<ft:farcryButtonPanel>
		<ft:farcryButton type="submit" text="Complete" value="save" validate="true" />
		<ft:farcryButton type="submit" text="Cancel" value="cancel" validate="false" confirmText="Are you sure you wish to discard your changes?" />
	</ft:farcryButtonPanel>
</ft:form>


<cfsetting enablecfoutputonly="false" />