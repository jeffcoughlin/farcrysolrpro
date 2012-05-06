<cfcomponent output="false" extends="farcry.core.packages.types.types" displayname="Solr Pro Elevation" hint="Manages elevation data for Solr Pro Plugin" bFriendly="false" bObjectBroker="false">
	
	<cfproperty ftSeq="110" ftFieldset="Elevation" ftLabel="Search String" bLabel="true" name="searchString" type="nstring" ftType="string" required="true" ftValidation="required" ftHint="The search string to elevate." />
	<cfproperty ftSeq="120" ftFieldset="Elevation" ftLabel="Documents to Elevate" name="aDocumentsToInclude" type="array" ftType="array" ftJoinMethod="getContentTypes" ftAllowCreate="false" ftAllowEdit="false" ftHint="Documents to elevate for this search string" />
	<cfproperty ftSeq="130" ftFieldset="Elevation" ftLabel="Documents to Exclude" name="aDocumentsToExclude" type="array" ftType="array" ftJoinMethod="getContentTypes" ftAllowCreate="false" ftAllowEdit="false" ftHint="Documents to exclude for this search string" />

	<cffunction name="getContentTypes" access="public" output="false" returntype="string">
		<cfset var oType = application.fapi.getcontenttype("solrProContentType") />
		<cfset var q = oType.getAllContentTypes(bIncludeNonSearchable = true) />
		<cfreturn valueList(q.contentType) />
	</cffunction>

	<cffunction name="ftValidateSearchString" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="objectid" required="true" type="string" hint="The objectid of the object that this field is part of.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = {} />		
		<cfset var oField = createObject("component", "farcry.core.packages.formtools.field") />
		<cfset var qDupeCheck = "" />		
		
		<!--- assume it passes --->
		<cfset stResult = oField.passed(value=arguments.stFieldPost.Value) />
			
		<cfif NOT len(stFieldPost.Value)>
			<cfset stResult = oField.failed(value=arguments.stFieldPost.value, message="This is a required field.") />
		</cfif>

		<!--- check for duplicates in the database --->
		<cfif not isUnique(queryText = trim(arguments.stFieldPost.value), objectid = arguments.objectid)>
			<cfset stResult = oField.failed(value=arguments.stFieldPost.value, message="The search term #trim(arguments.stFieldPost.value)# has already been used.  Solr does not allow duplicate search terms.") />
		</cfif>

		<!--- then, check to see if it exists in the XML --->
		<cfif existsInXml(trim(arguments.stFieldPost.value))>

			<!--- it does, this could be another record (a dupe) OR it could be the record we are modifying --->

			<!--- if it also exists in the DB with this ObjectID then it is the same record (not a dupe), if not, then its a dupe --->
			<cfif not existsInDb(trim(arguments.stFieldPost.value), arguments.objectid)>
				<cfset stResult = oField.failed(value=arguments.stFieldPost.value, message="The search term #trim(arguments.stFieldPost.value)# has already been used.  Solr does not allow duplicate search terms.") />
			</cfif>

		</cfif>

		<cfreturn stResult />
		
	</cffunction>

	<cffunction name="isUnique" access="private" output="false" returntype="boolean" hint="Checks for a record in the database with the same query text and a DIFFERENT objectid.">
		<cfargument name="queryText" type="string" required="true" />
		<cfargument name="objectId" type="uuid" required="true" />
		<cfset var q = "" />
		<cfquery name="q" datasource="#application.dsn#">
			select objectid from solrProElevation where lower(searchString) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(lcase(arguments.queryText))#" /> and objectid <> <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />;
		</cfquery>
		<cfif q.recordCount eq 0>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<cffunction name="existsInDb" access="private" output="false" returntype="boolean" hint="Checks for a record in the database with the same query text and the SAME objectid">
		<cfargument name="queryText" type="string" required="true" />
		<cfargument name="objectId" type="uuid" required="true" />
		<cfset var q = "" />
		<cfquery name="q" datasource="#application.dsn#">
			select objectid from solrProElevation where lower(searchString) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(lcase(arguments.queryText))#" /> and objectid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />;
		</cfquery>
		<cfreturn q.recordCount />
	</cffunction>

	<cffunction name="existsInXml" access="private" output="false" returntype="boolean" hint="Checks for the existence of a query node in the XML with the same 'text' attribute value">
		<cfargument name="queryText" type="string" required="true" />
		<cfset var xml = getXml() />
		<cfset var matches = xmlSearch(xml,"//elevate/query[@text='#xmlFormat(arguments.queryText)#']") />
		<cfreturn arrayLen(matches) />
	</cffunction>

	<cffunction name="getXml" access="private" output="false" returntype="xml" hint="Returns the XML from the elevate.xml file">
		<cfset var xmlFilePath = application.fapi.getConfig(key = "solrserver", name = "instanceDir") & "/data" & "/elevate.xml" />
		<cfif not fileExists(xmlFilePath)>
			<cfset var xml = "" />
			<cfsavecontent variable="xml">
			<cfoutput>
			<?xml version="1.0" encoding="UTF-8" ?>
			<!--
			If this file is found in the config directory, it will only be
			loaded once at startup.  If it is found in Solr's data
			directory, it will be re-loaded every commit.
			This file is managed by FarCrySolr Pro.  Do Not Modify.
			-->
			<elevate>
			</elevate>
			</cfoutput>
			</cfsavecontent>
			<cfset xml = xmlParse(trim(xml)) />
			<cfset saveXml(xml) />
			<cfreturn xml />
		</cfif>
		<cfreturn xmlParse(fileRead(xmlFilePath)) />
	</cffunction>

	<cffunction name="saveXml" access="private" output="false" returntype="void" hint="Saves the XML to the elevate.xml file">
		<cfargument name="xml" required="true" type="xml" />
		<cfset var xmlFilePath = application.fapi.getConfig(key = "solrserver", name = "instanceDir") & "/data" & "/elevate.xml" />
		<cffile action="write" output="#toString(arguments.xml)#" file="#xmlFilePath#" />
		<!--- make sure solr is running --->
		<cfset var oContentType = application.fapi.getContentType("solrProContentType") />
		<cfif oContentType.isSolrRunning()>
			<!--- reload the core so that the change is picked up --->
			<cfset oContentType.reload() />
		</cfif>
	</cffunction>

	<cffunction name="addElevateXmlNode" access="private" output="false" returntype="void" hint="Adds a query node to the elevate.xml file">
		<cfargument name="queryText" type="string" required="true" />
		<cfargument name="aDocumentsToInclude" type="array" required="false" default="#arrayNew(1)#" />
		<cfargument name="aDocumentsToExclude" type="array" required="false" default="#arrayNew(1)#" />

		<cfset var xml = getXml() />

		<!--- create the query node --->
		<cfset var queryNode = XmlElemNew(xml,"query") />
		<cfset queryNode.xmlAttributes["text"] = xmlFormat(arguments.queryText) />

		<cfset var doc = "" />
		<cfset var xmlDoc = "" />

		<cfloop array="#arguments.aDocumentsToInclude#" index="doc">
			<cfset xmlDoc = xmlElemNew(xml, "doc") />
			<cfset xmlDoc.xmlAttributes["id"] = application.applicationName & "_" & doc />
			<cfset arrayAppend(queryNode.xmlChildren, xmlDoc) />
		</cfloop>

		<cfloop array="#arguments.aDocumentsToExclude#" index="doc">
			<cfset xmlDoc = xmlElemNew(xml, "doc") />
			<cfset xmlDoc.xmlAttributes["id"] = application.applicationName & "_" & doc />
			<cfset xmlDoc.xmlAttributes["exclude"] = "true" />
			<cfset arrayAppend(queryNode.xmlChildren, xmlDoc) />
		</cfloop>

		<!--- add the query node to the xml document --->
		<cfset arrayAppend(xml["elevate"].xmlChildren, queryNode) />

		<cfset saveXml(xml) />

	</cffunction>

	<cffunction name="deleteElevateXmlNode" access="private" output="false" returntype="void" hint="Removes all query nodes with the matching text attribute from the elevate.xml file.">
		<cfargument name="queryText" type="string" required="true" />
		<cfset var xml = getXml() />
		<cfset var matches = xmlSearch(xml,"//elevate/query[@text='#xmlFormat(arguments.queryText)#']") />
		<cfset XmlDeleteNodes(xml, matches) />
		<cfset saveXml(xml) />
	</cffunction>

	<cffunction name="onDelete" returntype="void" access="public" output="false" hint="Is called after the object has been removed from the database">
		<cfargument name="typename" type="string" required="true" hint="The type of the object" />
		<cfargument name="stObject" type="struct" required="true" hint="The object" />
		<cfset deleteElevateXmlNode(queryText = arguments.stObject.searchString) />
		<cfset super.onDelete(argumentCollection = arguments) />
	</cffunction>
	
	<cffunction name="AfterSave" access="public" output="false" returntype="struct" hint="Called from setData and createData and run after the object has been saved.">
		<cfargument name="stProperties" required="yes" type="struct" hint="A structure containing the contents of the properties that were saved to the object.">
		<cfset deleteElevateXmlNode(queryText = arguments.stProperties.searchString) />
		<cfset addElevateXmlNode(queryText = arguments.stProperties.searchString, aDocumentsToInclude = arguments.stProperties.aDocumentsToInclude, aDocumentsToExclude = arguments.stProperties.aDocumentsToExclude) />
		<cfreturn super.afterSave(argumentCollection = arguments) />
	</cffunction>

	<cffunction
		name="XmlDeleteNodes"
		access="private"
		returntype="void"
		output="false"
		hint="I remove a node or an array of nodes from the given XML document.">

		<!--- http://www.bennadel.com/blog/1236-Deleting-XML-Node-Arrays-From-A-ColdFusion-XML-Document.htm --->

		<!--- Define arugments. --->
		<cfargument
			name="XmlDocument"
			type="any"
			required="true"
			hint="I am a ColdFusion XML document object."
			/>

		<cfargument
			name="Nodes"
			type="any"
			required="false"
			hint="I am the node or an array of nodes being removed from the given document."
			/>

		<!--- Define the local scope. --->
		<cfset var LOCAL = StructNew() />

		<!---
			Check to see if we have a node or array of nodes. If we
			only have one node passed in, let's create an array of
			it so we can assume an array going forward.
		--->
		<cfif NOT IsArray( ARGUMENTS.Nodes )>

			<!--- Get a reference to the single node. --->
			<cfset LOCAL.Node = ARGUMENTS.Nodes />

			<!--- Convert single node to array. --->
			<cfset ARGUMENTS.Nodes = [ LOCAL.Node ] />

		</cfif>


		<!---
			Flag nodes for deletion. We are going to need to delete
			these via the XmlChildren array of the parent, so we
			need to be able to differentiate them from siblings.
			Also, we only want to work with actual ELEMENT nodes,
			not attributes or anything, so let's remove any nodes
			that are not element nodes.
		--->
		<cfloop
			index="LOCAL.NodeIndex"
			from="#ArrayLen( ARGUMENTS.Nodes )#"
			to="1"
			step="-1">

			<!--- Get a node short-hand. --->
			<cfset LOCAL.Node = ARGUMENTS.Nodes[ LOCAL.NodeIndex ] />

			<!---
				Check to make sure that this node has an XmlChildren
				element. If it does, then it is an element node. If
				not, then we want to get rid of it.
			--->
			<cfif StructKeyExists( LOCAL.Node, "XmlChildren" )>

				<!--- Set delet flag. --->
				<cfset LOCAL.Node.XmlAttributes[ "delete-me-flag" ] = "true" />

			<cfelse>

				<!---
					This is not an element node. Delete it from out
					list of nodes to delete.
				--->
				<cfset ArrayDeleteAt(
					ARGUMENTS.Nodes,
					LOCAL.NodeIndex
					) />

			</cfif>

		</cfloop>


		<!---
			Now that we have flagged the nodes that need to be
			deleted, we can loop over them to find their parents.
			All nodes should have a parent, except for the root
			node, which we cannot delete.
		--->
		<cfloop
			index="LOCAL.Node"
			array="#ARGUMENTS.Nodes#">

			<!--- Get the parent node. --->
			<cfset LOCAL.ParentNodes = XmlSearch( LOCAL.Node, "../" ) />

			<!---
				Check to see if we have a parent node. We can't
				delete the root node, and we also be deleting other
				elements as well - make sure it is all playing
				nicely together. As a final check, make sure that
				out parent has children (only happens if we are
				dealing with the root document element).
			--->
			<cfif (
				ArrayLen( LOCAL.ParentNodes ) AND
				StructKeyExists( LOCAL.ParentNodes[ 1 ], "XmlChildren" )
				)>

				<!--- Get the parent node short-hand. --->
				<cfset LOCAL.ParentNode = LOCAL.ParentNodes[ 1 ] />

				<!---
					Now that we have a parent node, we want to loop
					over it's children to one the nodes flagged as
					deleted (and delete them). As we do this, we
					want to loop over the children backwards so that
					we don't go out of bounds as we start to remove
					child nodes.
				--->
				<cfloop
					index="LOCAL.NodeIndex"
					from="#ArrayLen( LOCAL.ParentNode.XmlChildren )#"
					to="1"
					step="-1">

					<!--- Get the current node shorthand. --->
					<cfset LOCAL.Node = LOCAL.ParentNode.XmlChildren[ LOCAL.NodeIndex ] />

					<!---
						Check to see if this node has been flagged
						for deletion.
					--->
					<cfif StructKeyExists( LOCAL.Node.XmlAttributes, "delete-me-flag" )>

						<!--- Delete this node from parent. --->
						<cfset ArrayDeleteAt(
							LOCAL.ParentNode.XmlChildren,
							LOCAL.NodeIndex
							) />

						<!---
							Clean up the node by removing the
							deletion flag. This node might still be
							used by another part of the program.
						--->
						<cfset StructDelete(
							LOCAL.Node.XmlAttributes,
							"delete-me-flag"
							) />

					</cfif>

				</cfloop>

			</cfif>

		</cfloop>

		<!--- Return out. --->
		<cfreturn />
	</cffunction>

</cfcomponent>