<cfcomponent output="false" accessors="true">

	<cfproperty name="url" type="string" />
	<cfproperty name="method" type="string" />
	<cfproperty name="throwOnError" type="boolean" default="false" />

	<cffunction name="send" access="public" output="false" returntype="struct">
		<cfset var result = {} />
		<cfhttp url="#getUrl()#" method="#getMethod()#" throwonerror="#getThrowOnError()#" result="result" />
		<cfreturn result />
	</cffunction>

</cfcomponent>