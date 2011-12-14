<cfcomponent output="false" extends="farcry.core.packages.types.types" displayname="Solr Pro Indexed Property" hint="Manages indexed properties for a content type" bFriendly="false" bObjectBroker="false">
	
	<cfproperty ftSeq="110" ftFieldset="Indexed Property" name="fieldName" bLabel="true" type="nstring" required="true" ftValidation="required" ftType="string" ftHint="The name of the field being indexed." />
	<cfproperty ftSeq="120" ftFieldset="Indexed Property" name="lFieldTypes" type="longchar" ftType="longchar" required="true" ftHint="A list of field types to use for this field." />
	<cfproperty ftSeq="130" ftFieldset="Indexed Property" name="fieldBoost" type="numeric" ftType="numeric" required="true" default="5" ftDefault="5" ftHint="The boost value to apply for this field." />
	
</cfcomponent>