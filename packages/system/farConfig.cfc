<cfcomponent extends="farcry.core.packages.types.farConfig">
	
	<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
	
	<cffunction name="Edit" access="public" output="true" returntype="void" hint="Default edit handler.">
		<cfargument name="ObjectID" required="yes" type="string" default="" />
		<cfargument name="onExitProcess" required="no" type="any" default="Refresh" />
		
		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var qMetadata = application.types[stobj.typename].qMetadata />
		<cfset var displayname = stObj.configkey />
		<cfset var thisform = "" />
		<cfset var qFields = "" />
		<cfset var configdata = "" />
		
		<cfif displayname eq "solrserver">
			<!--- show custom form (we do this here instead of a custom edit.cfm to avoid breaking code in other plugins.  If you have a custom edit.cfm for farConfig in your project or a plugin you use, you will need to modify it so that it calls this method or runs our custom form.) --->
			
			<cfloop collection="#application.stCOAPI#" item="thisform">
				<cfif left(thisform,6) eq "config" and structkeyexists(application.stCOAPI[thisform],"key") and application.stCOAPI[thisform].key eq stObj.configkey and structkeyexists(application.stCOAPI[thisform],"displayname")>
					<cfset displayname = application.stCOAPI[thisform].displayname />
				</cfif>
			</cfloop>
			
			<cfquery dbtype="query" name="qFields">
				SELECT 		propertyname
				FROM 		qMetadata
				WHERE 		ftFieldset = 'Config'
				ORDER BY 	ftSeq
			</cfquery>
		
			<!---------------------------------------
			ACTION:
			 - default form processing
			---------------------------------------->
			<ft:processForm action="Save" Exit="true">
				<ft:processFormObjects typename="#stobj.typename#">

					<!--- mark as configured, tracks if the user has updated the configuration.  This avoids creating directories on first load that may not be necessary. --->
					<cfif isWDDX(stProperties.configdata)>
						<cfwddx action="wddx2cfml" input="#stProperties.configdata#" output="configdata" />
						<cfset configdata.bConfigured = 1 />
						<cfwddx action="cfml2wddx" input="#configdata#" output="stProperties.configdata" /> 
					<cfelse>
						<cfset stConfig = deserializeJSON(stProperties.configdata)>
						<cfset stConfig.bConfigured = 1 />
						<cfset stProperties.configdata = serializeJSON(stConfig)>
					</cfif>

				</ft:processFormObjects>
			</ft:processForm>
		
			<ft:processForm action="Cancel" Exit="true" />
			
			<ft:form>
				<!--- All Fields: default edit handler --->
				<ft:object objectID="#arguments.ObjectID#" format="edit" lFields="#valuelist(qFields.propertyname)#" r_stFields="stFields" />
				
				<cfoutput>
					<h1>#displayName#</h1>
					#stFields.configData.html#
				</cfoutput>
				
				<ft:buttonPanel>
					<ft:button value="Save" /> 
					<ft:button value="Cancel" validate="false" />
				</ft:buttonPanel>
				
			</ft:form>
			
		<cfelse>
			<cfset super.edit(argumentCollection = arguments) />
		</cfif>
		
	</cffunction>
	
</cfcomponent>