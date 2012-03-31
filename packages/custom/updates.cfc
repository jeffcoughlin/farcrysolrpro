/**
*
* Plugin Updater
* Authors: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com)
*
*/
component accessors="true" {

	property name="updateUrl" type="string";
	property name="installManifest" type="any";

	public any function init(string updateUrl, any installManifest) {
		if (structKeyExists(arguments,"updateUrl")) {
			setUpdateUrl(arguments.updateUrl);
		} else {
			setUpdateUrl("");
		}
		if (structKeyExists(arguments,"installManifest")) {
			setInstallManifest(arguments.installManifest);
		} else {
			setInstallManifest(application.stPlugins["farcrysolrpro"].oManifest);
		}
		return this;
	}

	public string function getCurrentVersion() {
		return getInstallManifest().version;;
	}

	public boolean function updateAvailable() {

		// get the current and most recent available versions
		var currentVersion = getCurrentVersion();
		var mostRecentVersion = getMostRecentVersion();

		// if the most recent version is "UNKNOWN" there was a problem accessing the update site
		if (mostRecentVersion eq "UNKNOWN") {
			return true;
		}

		// is this in 0.0.0 format?
		if (listLen(mostRecentVersion, ".") eq 3) {
			var major = listFirst(mostRecentVersion,".");
			var minor = listGetAt(mostRecentVersion, 2, ".");
			var patch = listLast(mostRecentVersion, ".");

			if (isNumeric(major) and isNumeric(minor) and isNumeric(patch)) {
				// is the current version in 0.0.0 format?
				if (listLen(currentVersion, ".") eq 3) {
					var currentMajor = listFirst(currentVersion,".");
					var currentMinor = listGetAt(currentVersion, 2, ".");
					var currentPatch = listLast(currentVersion, ".");
					if (isNumeric(currentMajor) and isNumeric(currentMinor) and isNumeric(currentPatch)) {
						if (major gt currentMajor) {
							// major version increase
							return true;
						} else if (major eq currentMajor) {
							// same major version
							if (minor gt currentMinor) {
								// minor version increase
								return true;
							} else if (minor eq currentMinor) {
								// same minor version
								if (patch gt currentPatch) {
									// patch version increase
									return true;
								} else {
									// same or older patch version
									return false;
								}
							} else {
								// older minor version
								return false;
							}
						} else {
							// older major version
							return false;
						}
					}
				}
			}
		}

		// assume its newer since its in an unrecognizable format, unless its the same as the current, in which case there is no available update
		return currentVersion neq mostRecentVersion;

	}

	public string function getMostRecentVersion() {
		var versions = getAvailableVersions();
		if (arrayLen(versions)) {
			return versions[1].version;
		} else {
			return "UNKNOWN";
		}
	}

	public array function getAvailableVersions() {
		var theXml = getUpdateXml();
		var versions = [];
		var downloads = [];
		var i = "";
		var d = "";
		for (var i = 1; i lte arrayLen(theXml["versions"].xmlChildren); i++) {
			for (var d = 1; d lte arrayLen(theXml["versions"].xmlChildren[i]["downloads"].xmlChildren); d++) {
				arrayAppend(downloads,{
					"url" = trim(theXml["versions"].xmlChildren[i]["downloads"].xmlChildren[d]["url"].xmlText),
					"shortdesc" = trim(theXml["versions"].xmlChildren[i]["downloads"].xmlChildren[d]["shortdesc"].xmlText),
					"size" = trim(theXml["versions"].xmlChildren[i]["downloads"].xmlChildren[d]["size"].xmlText)
				});
			}
			arrayAppend(versions,{
				"version" = trim(theXml["versions"].xmlChildren[i]["version"].xmlText),
				"description" = trim(theXml["versions"].xmlChildren[i]["description"].xmlText),
				"releasedate" = trim(theXml["versions"].xmlChildren[i]["releasedate"].xmlText),
				"downloads" = downloads
			});
		downloads = [];			
		}
		return versions;
	}

	private xml function getUpdateXml() {
		try {
			var updateUrl = getUpdateUrl();
			var http = new com.adobe.coldfusion.http();
			http.setUrl(updateUrl);
			http.setMethod("GET");
			http.setThrowOnError(true);
			var result = http.send();
			var theXml = result.getPrefix().fileContent;
			if (isXml(theXml)) {
				return xmlParse(theXml);
			} else {
				return xmlParse("<versions />");
			}
		} catch (any err) {
			return xmlParse("<versions />");
		}
	}

}