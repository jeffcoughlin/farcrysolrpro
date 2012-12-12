<cfcomponent displayname="CustomFunctions" output="false" hint="Return custom/helper functions">
	
	<cffunction name="millisecondsToDate" access="public" output="false" returnType="date" hint="Converts epoch milleseconds to a date timestamp.">
		<cfargument name="strMilliseconds" type="string" required="true" hint="The number of milliseconds." />
		<!---
		@author Steve Parks (steve@adeptdeveloper.com)
		@version 1, May 20, 2005
		--->  
	  <cfreturn dateAdd("s", strMilliseconds/1000, "january 1 1970 00:00:00") />
	</cffunction>	
<!---
	<cffunction name="xmlFormat2" access="public" output="false" returntype="string" hint="Similar to xmlFormat() but replaces all characters not on the &quot;good&quot; list as opposed to characters specifically on the &quot;bad&quot; list.">
		<cfargument name="inString" type="string" required="true" />
		<cfscript>
			/**
			* @author: Samuel Neff (sam@serndesign.com)
			* @version: 1, January 12, 2004
			*/
			var goodChars = "!@##$%^*()0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`~[]{};:,./?\| -_=+#chr(13)##chr(10)##chr(9)#";
			var i = 1;
			var c = "";
			var s = "";

			for (i=1; i LTE len(inString); i=i+1) {
				c = mid(inString, i, 1);
				if (find(c, goodChars)) {
					s = s & c;
				}else{
					s = s & "&##" & asc(c) & ";";
				}
			}
		</cfscript>

		<cfreturn s />

	</cffunction>
--->
	<cffunction name="xmlSafeText" returnType="string" output="false" hint="Replaces all characters that would break an xml file.">        
		<cfargument name="txt" type="string" required="true" />
		<!---
		@author David Hammond (dave@modernsignal.com) 
		@version 0, July 12, 2009 
		---> 
		<cfset var chars = "" />
		<cfset var replaced = "" />
		<cfset var i = "" />

		<!--- Use XmlFormat function first --->
		<cfset txt = XmlFormat(txt) />
		<!--- Get all other characters to replace. ---> 
		<cfset chars = REMatch("[^[:ascii:]]",txt) />
		<!--- Loop through characters and do replace. Maintain a list of characters already replaced to avoid duplicate work. --->
		<cfloop index="i" from="1" to="#ArrayLen(chars)#">
			<cfif listFind(replaced,chars[i]) is 0>
				<cfset txt = Replace(txt,chars[i],"&##" & asc(chars[i]) & ";","all") />
				<cfset replaced = ListAppend(replaced,chars[i]) />
			</cfif>
		</cfloop>
		<cfreturn txt />
	</cffunction>
<!---
	<cffunction name="stripHTML" access="public" output="false" returnType="string" hint="Removes HTML from the string">
		<cfargument name="inString" type="string" require="true" hint="HTML string to be converted" />
		<cfset var str = arguments.inString /> 
		<!--- 
		@version: 3, July 9, 2008
		@Authors: Raymond Camden, Steve Bryant
		--->
		<cfscript>
			str = reReplaceNoCase(str, "<.*?>","","all");
			//get partial html in front
			str = reReplaceNoCase(str, "^.*?>","");
			//get partial html at end
			str = reReplaceNoCase(str, "<.*$","");
			return str;
		</cfscript>
	
	</cffunction>
--->
	<cffunction name="tagStripper" access="public" output="false" returntype="string" hint="Strip HTML tags with options to preserve certain tags">
		<cfargument name="str" type="string" required="true" hint="String to manipulate" />
		<cfargument name="action" type="string" required="false" default="strip" hint="Options are 'strip' or 'preserve'. Default is strip." />
		<cfargument name="tagList" type="string" required="false" default="" hint="String to manipulate" />

		<cfscript>
			/**
			* @authors: Rick Root (rick@webworksllc.com), Ray Camden
			* @version: 2, July 2, 2008 
			*/
			var i = 1;
			//var action = 'strip';
			//var tagList = '';
			var tag = '';

			if (arrayLen(arguments) gt 1 and lcase(arguments[2]) eq 'preserve') {
				action = 'preserve';
			}
			if (arrayLen(arguments) gt 2) {
				tagList = arguments[3];
			}

			if (trim(lcase(action)) eq "preserve") {
				// strip only those tags in the tagList argument
				for (i=1;i lte listlen(tagList); i = i + 1) {
					tag = listGetAt(tagList,i);
					str = reReplaceNoCase(str,"</?#tag#.*?>","","ALL");
				}
			} else {
				// strip all, except those in the tagList argument
				// if there are exclusions, mark them with NOSTRIP
				if (tagList neq "") {
					for (i=1;i lte listlen(tagList); i = i + 1) {
						tag = listGetAt(tagList,i);
						str = reReplaceNoCase(str,"<(/?#tag#.*?)>","___TEMP___NOSTRIP___\1___TEMP___ENDNOSTRIP___","ALL");
					}
				}
				// strip all remaining tsgs.  This does NOT strip comments
				str = reReplaceNoCase(str,"</{0,1}[A-Z].*?>","","ALL");
				// convert unstripped back to normal
				str = replace(str,"___TEMP___NOSTRIP___","<","ALL");
				str = replace(str,"___TEMP___ENDNOSTRIP___",">","ALL");
			}

			// remove html comments (sean coyne, sean@n42designs.com)
			str = reReplaceNoCase(str, "<!--(.+?)-->","","ALL");

			return str;
		</cfscript>
	</cffunction>

	<cffunction name="XHTMLParagraphFormat" access="public" output="false" returnType="string" hint="Returns a XHTML compliant string wrapped with properly formatted paragraph tags.">
		<cfargument name="inString" type="string" required="true" hint="String you want XHTML formatted" />
		<cfargument name="inAttributeString" type="string" required="false" default="" hint="Optional attributes to assign to all opening paragraph tags (i.e. style=""font-family: tahoma"")" />
		<cfargument name="bWrapInParentParagraphTag" type="boolean" required="false" default="false" hint="optionally wrap entire return string in paragraph tag block." />
		<cfscript>
			/**
				* Returns a XHTML compliant string wrapped with properly formatted paragraph tags.
				*
				* @param string 	 String you want XHTML formatted.
				* @param attributeString 	 Optional attributes to assign to all opening paragraph tags (i.e. style=""font-family: tahoma"").
				* @return Returns a string.
				* @author Jeff Howden (jeff@members.evolt.org)
				* @version 1.2, March 30, 2005 (modified by Jeff Coughlin jeff@jeffcoughlin.com)
				*/
				var attributeString = '';
				var returnValue = '';
				if(arguments.inAttributeString neq ''){
					attributeString = ' ' & arguments.inAttributeString;
				}
				if(Len(Trim(inString))){
					returnValue = arguments.inString;
					if (arguments.bWrapInParentParagraphTag is true){ returnValue = '<p' & attributeString & '>' & returnValue; }
					returnValue = Replace(returnValue, Chr(13)&Chr(10)&Chr(13)&Chr(10), '</p><p' & attributeString & '>', 'ALL');
					returnValue = Replace(returnValue, Chr(10)&Chr(10), '</p><p' & attributeString & '>', 'ALL');
					returnValue = Replace(returnValue, Chr(13)&Chr(13), '</p><p' & attributeString & '>', 'ALL');
					returnValue = Replace(returnValue, Chr(13)&Chr(10), '<br />', 'ALL');
					returnValue = Replace(returnValue, Chr(10), '<br />', 'ALL');
					returnValue = Replace(returnValue, Chr(13), '<br />', 'ALL');
					if (arguments.bWrapInParentParagraphTag is true){ returnValue = returnValue & '</p>'; }
				}
		</cfscript>

		<cfreturn returnValue />

	</cffunction>

	<cffunction name="abbreviate" access="public" returntype="string" output="false" hint="Abbreviates a given string to roughly the given length, stripping any tags, making sure the ending doesn't chop a word in two, and adding an ellipsis character at the end.">
		<cfargument name="string" type="string" required="true" />
		<cfargument name="len" type="numeric" required="false" default="450" />

		<cfscript>
			/**
			* @authors: Gyrus (kenf@accessnet.netgyrus@norlonto.net), Ken Fricklas kenf@accessnet.net
			* @version: 3, September 6, 2005
			*/
			var newString = REReplace(string, "<[^>]*>", " ", "ALL");
			var lastSpace = 0;
			newString = REReplace(newString, " \s*", " ", "ALL");
			if (len(newString) gt len) {
				newString = left(newString, len-2);
				lastSpace = find(" ", reverse(newString));
				lastSpace = len(newString) - lastSpace;
				//newString = left(newString, lastSpace) & " &##8230;";
				newString = left(newString, lastSpace) & " ...";
			}
			return newString;
		</cfscript>

	</cffunction>

	<cffunction name="byteConvert" access="public" output="false" returnType="string" hint="Pass in a value in bytes, and this function converts it to a human-readable format of bytes, KB, MB, or GB.">
		<cfargument name="size" type="numeric" required="true" />
		<cfargument name="unit" type="string" required="false" default="" />

		<cfscript>
			var result = 0;
			var newunit = "";
			var num = arguments.size;

			// Set unit variables for convenience
			var bytes = 1; //byte
			var kb = 1024; //Kilobyte
			var mb = 1024^2; //Megabyte
			var gb = 1024^3; //Gigabyte
			var tb = 1024^4; //Terabyte
			var pb = 1024^5; //Petabyte
			var eb = 1024^6; //Exabyte
			var zb = 1024^7; //Zettabyte

			// Check to see if unit was passed in, and if it is valid
			if (arguments.unit neq '' AND "bytes,KB,MB,GB" contains arguments.unit) {
				newunit = arguments.unit;
			// If not, set unit depending on the size of num
			} else {
				if (num lt kb){
					newunit ="bytes";
				}else if (num lt mb){
					newunit ="KB";
				}else if (num lt gb){
					newunit ="MB";
				}else if (num lt tb){
					newunit ="GB";
				}else if (num lt pb){
					newunit ="TB";
				}else if (num lt eb){
					newunit ="PB";
				}else if (num lt zb){
					newunit ="EB";
				}else{
					newunit ="ZB";
				}
			}

			// Find the result by dividing num by the number represented by the unit
			result = num / evaluate(newunit);

			// Format the result
			if (result lt 10){
				result = NumberFormat(Round(result * 100) / 100,"0.00");
			}else if (result lt 100){
				result = NumberFormat(Round(result * 10) / 10,"90.0");
			}else{
				result = Round(result);
			}
		</cfscript>

		<!--- Concatenate result and unit together for the return value --->
		<cfreturn (result & " " & newunit) />
	</cffunction>

	<cffunction name="extractFromArrayOfStructs" access="public" returntype="array" output="false" hint="Takes and array of structs and converts it to a simple array using the value of the struct key specified.">
		<cfargument name="aObj" type="array" required="true" />
		<cfargument name="key" type="string" required="true" />
		<cfscript>
			/*
			 Takes and array of structs and converts it to a simple array using the value of the struct key specified
			 
			 @param aObj   Array of structs. (Required)
			 @param key    Key of the struct to get data from. (Required)
			 @return Returns a simple array of values. 
			 @author Sean Coyne (www.n42designs.com) 
			 @version 1, December 5, 2012 
			*/
			var result = [];
			for (var item in arguments.aObj) {
				arrayAppend(result, item[arguments.key]);
			}
			return result;
		</cfscript>	
	</cffunction>

</cfcomponent>