<cfcomponent output="false" extends="farcry.core.packages.types.types" displayname="Fake Content Type" hint="A fake content type for testing" bFriendly="false" bObjectBroker="false">
	<cfproperty ftWizardStep="General" ftSeq="110" ftFieldset="General" ftLabel="Title" name="title" type="nstring" ftType="string" default="" ftDefault="" required="true" bLabel="true" />
	<cfproperty ftWizardStep="General" ftSeq="120" ftFieldset="General" ftLabel="Teaser" name="teaser" type="longchar" ftType="longchar" default="" ftDefault="" required="false" />
	<cfproperty ftWizardStep="General" ftSeq="130" ftFieldset="General" ftLabel="Date" name="somedate" type="date" ftType="datetime" default="" ftDefault="" required="false" />
	<cfproperty ftWizardStep="General" ftSeq="140" ftFieldset="General" ftLabel="Boolean" name="bSomeBoolean" type="boolean" ftType="boolean" default="0" ftDefault="0" required="true" />
	<cfproperty ftWizardStep="General" ftSeq="150" ftFieldset="General" ftLabel="Integer" name="someInteger" type="integer" ftType="integer" default="0" ftDefault="0" required="true" />
	<cfproperty ftWizardStep="General" ftSeq="160" ftFieldset="General" ftLabel="Long" name="somelong" type="numeric" ftType="numeric" default="0" ftDefault="0" required="true" />
	<cfproperty ftWizardStep="General" ftSeq="170" ftFieldset="General" ftLabel="Double" name="someDouble" type="numeric" ftType="numeric" default="0" ftDefault="0" required="true" />
	<cfproperty ftWizardStep="General" ftSeq="180" ftFieldset="General" ftLabel="Float" name="someFloat" type="numeric" ftType="numeric" default="0" ftDefault="0" required="true" />
	<cfproperty ftWizardStep="General" ftSeq="190" ftFieldset="General" ftLabel="Location" name="someLocation" type="nstring" ftType="string" default="" ftDefault="" required="false" />
	<cfproperty ftWizardStep="General" ftSeq="195" ftFieldset="General" ftLabel="Array" name="aSomeArray" type="array" ftType="array" ftJoin="dmHTML" />
	<cfproperty ftWizardStep="General" ftSeq="196" ftFieldset="General" ftLabel="String" name="someString" type="nstring" ftType="string" default="" ftDefault="" required="false" />
	<cfproperty ftWizardStep="General" ftSeq="197" ftFieldset="General" ftLabel="Field" name="someField" type="nstring" ftType="string" default="" ftDefault="" required="false" />
</cfcomponent>