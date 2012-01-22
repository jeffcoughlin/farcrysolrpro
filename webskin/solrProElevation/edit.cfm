<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit --->
<!--- @@author: Sean Coyne (sean@n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />

<ft:processform action="Cancel" exit="true" />

<cfset bContinueSave = true />

<ft:processform action="Save">
	
	<!--- do some validation first --->
	
	<ft:processFormObjects typename="solrProElevation" bSessionOnly="true" r_stObject="stObj">
		
		<cfparam name="stProperties.searchstring" default="" />
		<cfparam name="stProperties.aDocumentsToInclude" default="#arrayNew(1)#" />
		<cfparam name="stProperties.aDocumentsToExclude" default="#arrayNew(1)#" />
		
		<!--- ensure we have no duplicates --->
		<cfset stSearchStringValidationResult = ftValidateSearchString(
			objectid = stProperties.objectid, 
			typename = "solrProElevation", 
			stFieldPost = { value = stProperties.searchString }, 
			stMetadata = {}
		) />
		
		<cfif stSearchStringValidationResult.bSuccess eq false>
			<ft:advice 
				objectid="#stProperties.objectid#" 
				field="searchString" 
				message="#stSearchStringValidationResult.stError.message#" 
				value="#stSearchStringValidationResult.value#" />
			<cfset bContinueSave = false />
		</cfif>
		
		<!--- ensure at least one document selected --->
		<cfif not arrayLen(stProperties.aDocumentsToInclude) and not arrayLen(stProperties.aDocumentsToExclude)>
			<ft:advice 
				objectid="#stProperties.objectid#" 
				field="aDocumentsToInclude" 
				message="You must select at least one document to elevate or exclude" 
				value="#stProperties.aDocumentsToInclude#" />
			<ft:advice 
				objectid="#stProperties.objectid#" 
				field="aDocumentsToExclude" 
				message="You must select at least one document to elevate or exclude" 
				value="#stProperties.aDocumentsToExclude#" />
			<cfset bContinueSave = false />
		</cfif>
		
	</ft:processFormObjects>
		
</ft:processform>

<cfif bContinueSave>
<ft:processform action="Save" exit="true">
	
	<ft:processFormObjects typename="solrProElevation" />
		
</ft:processform>
</cfif>

<ft:form>
	<ft:fieldset>
		<cfoutput><h1><skin:icon icon="#application.stCOAPI[stobj.typename].icon#" default="farcrycore" size="32" />#stobj.label#</h1></cfoutput>
	</ft:fieldset>
	<ft:object objectid="#stobj.objectid#" lFields="searchString,aDocumentsToInclude,aDocumentsToExclude" />
	<ft:farcryButtonPanel>
		<ft:farcryButton type="submit" text="Complete" value="save" validate="true" />
		<ft:farcryButton type="submit" text="Cancel" value="cancel" validate="false" confirmText="Are you sure you wish to discard your changes?" />
	</ft:farcryButtonPanel>
</ft:form>


<cfsetting enablecfoutputonly="false" />