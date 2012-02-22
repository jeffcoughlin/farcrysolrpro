<cfcomponent output="false" extends="farcry.core.packages.types.types" displayname="Solr Pro Search Log" hint="Tracks Solr searches" bRefObjects="false" bFriendly="false" bObjectBroker="false">
	
	<cfproperty ftSeq="110" ftFieldset="Search Log" name="q" type="nstring" ftLabel="Search Criteria" ftType="string" ftDisplayOnly="true" />
	<cfproperty ftSeq="120" ftFieldset="Search Log" name="operator" type="nstring" ftLabel="Search Operator" ftType="string" ftDisplayOnly="true" />
	<cfproperty ftSeq="130" ftFieldset="Search Log" name="lContentTypes" type="nstring" ftLabel="Content Types" ftType="string" ftDisplayOnly="true" />
	<cfproperty ftSeq="140" ftFieldset="Search Log" name="orderBy" type="nstring" ftLabel="Sort Order" ftType="string" ftDisplayOnly="true" />
	<cfproperty ftSeq="150" ftFieldset="Search Log" name="numResults" type="integer" ftLabel="Num. Results" ftType="integer" ftDisplayOnly="true" />
	<cfproperty ftSeq="160" ftFieldset="Search Log" name="suggestion" type="nstring" ftLabel="Suggestion" ftType="string" ftDisplayOnly="true" />
	
	<cffunction name="purgeLog" access="public" output="false" returntype="void">
		<cfargument name="purgeDate" required="false" defaul="" type="string" />
		
		<!--- purge the log records --->
		<cfquery datasource="#application.dsn#">
		delete from solrProSearchLog 
		<cfif isDate(arguments.purgeDate)>
		where datetimecreated < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createDateTime(year(arguments.purgeDate),month(arguments.purgeDate),day(arguments.purgeDate),0,0,0)#" />
		</cfif>
		</cfquery>
				
	</cffunction>
	
	<cffunction name="getSearchLog" access="public" output="false" returntype="query">
		<cfargument name="startDate" type="date" required="false" />
		<cfargument name="endDate" type="date" required="false" />
		<cfargument name="queryString" type="string" required="false" default="" />
		
		<cfset var q = "" />
		
		<cfset arguments.startDate = createDateTime(year(arguments.startDate),month(arguments.startDate),day(arguments.startDate),0,0,0) />
		<cfset arguments.endDate = createDateTime(year(arguments.endDate),month(arguments.endDate),day(arguments.endDate),23,59,59) />
		
		<cfquery name="q" datasource="#application.dsn#">
			select q, operator, lcontenttypes, orderby, numResults, suggestion, datetimecreated from solrProSearchLog
			
			where 
			
			1=1
			
			<cfif len(trim(arguments.queryString))>
			and q like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(arguments.queryString)#%" />
			</cfif>
			
			<cfif structKeyExists(arguments,"startDate")>
			and datetimecreated >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#" />
			</cfif>
			
			<cfif structKeyExists(arguments,"endDate")>
			and datetimecreated <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#" />
			</cfif>
			
			order by datetimecreated desc

		</cfquery>
		
		<cfreturn q />
		
	</cffunction>
	
	<cffunction name="getSearchesWithoutResults" access="public" output="false" returntype="query">
		<cfargument name="startDate" type="date" required="false" />
		<cfargument name="endDate" type="date" required="false" />
		<cfargument name="queryString" type="string" required="false" default="" />
		
		<cfset var q = "" />
		
		<cfset arguments.startDate = createDateTime(year(arguments.startDate),month(arguments.startDate),day(arguments.startDate),0,0,0) />
		<cfset arguments.endDate = createDateTime(year(arguments.endDate),month(arguments.endDate),day(arguments.endDate),23,59,59) />
		
		<cfquery name="q" datasource="#application.dsn#">
			select q, operator, lcontenttypes, orderby, numResults, suggestion, datetimecreated from solrProSearchLog
			
			where 
			
			numResults = 0
			
			<cfif len(trim(arguments.queryString))>
			and q like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#trim(arguments.queryString)#%" />
			</cfif>
			
			<cfif structKeyExists(arguments,"startDate")>
			and datetimecreated >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.startDate#" />
			</cfif>
			
			<cfif structKeyExists(arguments,"endDate")>
			and datetimecreated <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.endDate#" />
			</cfif>
			
			order by datetimecreated desc

		</cfquery>
		
		<cfreturn q />
		
	</cffunction>
	
</cfcomponent>