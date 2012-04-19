<cfcomponent extends="farcry.core.packages.formtools.array">
	
	<cfproperty name="ftJoinMethod" required="false" default="" hint="A method that returns a list of content types to join"/>
	<cfproperty name="ftJoinMethodTypename" required="false" default="" hint="The content type to use to run the ftJoinMethod.  Defaults to the calling content type."/>

	<cffunction name="prepMetadata" access="public" output="false" returntype="struct" hint="Allows modification of property metadata in the displayLibrary webskins">
		<cfargument name="stObject" type="struct" required="true" hint="The object being edited" />
		<cfargument name="stMetadata" type="struct" required="true" hint="The property metadata" />
		<cfif not structKeyExists(arguments.stObject,"typename") and structKeyExists(arguments.stObject, "objectid")>
			<cfset arguments.stObject.typename = application.fapi.findType(arguments.stObject.objectId) />
		</cfif>
		<cfif structKeyExists(arguments.stObject,"typename")>
			<cfset arguments.stMetadata = prepFtJoin(typename = arguments.stObject.typename, stMetadata = arguments.stMetadata) />
		</cfif>
		<cfreturn super.prepMetadata(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="prepFtJoin" access="private" output="false" returntype="struct">
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

</cfcomponent>