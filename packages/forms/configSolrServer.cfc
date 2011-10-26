<cfcomponent output="false" extends="farcry.core.packages.forms.forms" displayname="Solr Server" key="solrserver" hint="Configures Solr Server settings">
	
	<cfproperty ftSeq="110" ftFieldset="Solr Server" name="host" type="nstring" default="localhost" required="true" ftDefault="localhost" ftType="string" ftValidation="required" ftLabel="Host" ftHint="The hostname of the server (default: localhost)" />
	<cfproperty ftSeq="120" ftFieldset="Solr Server" name="port" type="nstring" default="8983" required="true" ftDefault="8983" ftType="string" ftValidation="required,validate-digits" ftLabel="Port" ftHint="The port number of the server (default: 8983)" />
	<cfproperty ftSeq="130" ftFieldset="Solr Server" name="path" type="nstring" default="/solr" required="true" ftDefault="/solr" ftType="string" ftValidation="required" ftLabel="Path" ftHint="The path to the solr instance (default: /solr)" />
	<cfproperty ftSeq="140" ftFieldset="Solr Server" name="queueSize" type="integer" default="100" required="true" ftDefault="100" ftType="integer" ftValidation="required,validate-integer" ftLabel="Queue Size" ftHint="The buffer size before the documents are sent to the server (default: 100)" />
	<cfproperty ftSeq="150" ftFieldset="Solr Server" name="threadCount" type="integer" default="5" required="true" ftDefault="5" ftType="integer" ftValidation="required,validate-integer" ftLabel="Thread Count" ftHint="The number of background threads used to empty the queue (default: 5)" />
	<cfproperty ftSeq="160" ftFieldset="Solr Server" name="binaryEnabled" type="boolean" default="1" required="true" ftDefault="1" ftType="boolean" ftLabel="Binary Enabled?" ftHint="Should we use the faster binary data transfer format? (default: true)" /> 

</cfcomponent>