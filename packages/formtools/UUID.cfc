<cfcomponent extends="farcry.core.packages.formtools.UUID">
	
	<cfproperty name="ftJoinMethod" required="false" default="" hint="A method that returns a list of content types to join"/>
	<cfproperty name="ftJoinMethodTypename" required="false" default="" hint="The content type to use to run the ftJoinMethod.  Defaults to the calling content type."/>
	
	<cffunction name="prepFtJoin" access="public" output="false" returntype="struct">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var oType = "" />
		<cfparam name="arguments.stMetadata.ftJoinMethod" default="" />
		<cfparam name="arguments.stMetadata.ftJoinMethodTypename" default="#arguments.typename#" />
		<cfif not len(trim(arguments.stMetadata.ftJoinMethodTypename))>
			<cfset arguments.stMetadata.ftJoinMethodTypename = arguments.typename />
		</cfif>
		<cfif len(trim(arguments.stMetadata.ftJoinMethod))>
			<cfset oType = application.fapi.getContentType(arguments.stMetadata.ftJoinMethodTypename) />
			<cfinvoke component="#oType#" method="#arguments.stMetadata.ftJoinMethod#" returnvariable="arguments.stMetadata.ftJoin" />
		</cfif>
		
		<cfreturn arguments.stMetadata />
		
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
		
		<cfset arguments.stMetadata = prepFtJoin(typename = arguments.typename, stMetadata = arguments.stMetadata) />
		
		<cfreturn super.edit(argumentCollection = arguments) />
		
	</cffunction>
	
	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset arguments.stMetadata = prepFtJoin(typename = arguments.typename, stMetadata = arguments.stMetadata) />
		
		<cfreturn super.display(argumentCollection = arguments) />
		
	</cffunction>
	
	<cffunction name="libraryCallback" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="stPackage" required="true" type="struct" hint="Contains the metadata for the all fields for the current typename.">
		
		<cfset arguments.stMetadata = prepFtJoin(typename = arguments.typename, stMetadata = arguments.stMetadata) />
		
		<cfreturn super.libraryCallback(argumentCollection = arguments) />
		
	</cffunction>
	
</cfcomponent>