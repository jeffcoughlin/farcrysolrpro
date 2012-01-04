<cfcomponent>
	
<cffunction name="millisecondsToDate" access="public" output="false" returnType="date">
  <cfargument name="strMilliseconds" type="string" required="true" />
  <!---
  Converts epoch milleseconds to a date timestamp.
  @param strMilliseconds      The number of milliseconds. (Required)
  @return Returns a date.
  @author Steve Parks (steve@adeptdeveloper.com)
  @version 1, May 20, 2005
  --->  
  <cfreturn dateAdd("s", strMilliseconds/1000, "january 1 1970 00:00:00") />
</cffunction>	
	
</cfcomponent>