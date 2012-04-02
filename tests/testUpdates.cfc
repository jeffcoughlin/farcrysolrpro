/**
*
* Author: Sean Coyne (sean@n42designs.com), Jeff Coughlin (www.jeffcoughlin.com)
*
*/
component extends="farcry.plugins.testMXUnit.tests.FarCryTestCase" {

	public void function setUp() {
		super.setUp();

		// set a default manifest and update url
		variables.installManifest = createObject("component","farcry.plugins.farcrysolrpro.tests.data.testUpdates.manifest-0-0-3");
		variables.updater = createObject("component","farcry.plugins.farcrysolrpro.packages.custom.updates").init(
			updateUrl = "http://" & cgi.http_host & "/farcrysolrpro/test/updates/0-0-2-update.json",
			installManifest = installManifest
		);
	}

	public void function testUpdateAvailable() {

		// set an old manifest and ensure that it recognizes an available update
		variables.updater.setInstallManifest(createObject("component","farcry.plugins.farcrysolrpro.tests.data.testUpdates.manifest-0-0-1"));
		assertTrue(variables.updater.updateAvailable(), "Return update unavailable even though manifest version is older");

		// set a new manifest and ensure that it recognizes no available update
		variables.updater.setInstallManifest(createObject("component","farcry.plugins.farcrysolrpro.tests.data.testUpdates.manifest-0-0-3"));
		assertFalse(variables.updater.updateAvailable(), "Returned update available even though manifest version is newer");

		// ensure we get a "true" response if our current version is not in 0.0.0 format
		variables.updater.setInstallManifest(createObject("component","farcry.plugins.farcrysolrpro.tests.data.testUpdates.manifest-alpha"));
		assertTrue(variables.updater.updateAvailable(), "Returned update unavailable even though current version is in unrecognizable format");

		// ensure we get a "false" response if our current version matches most recent
		variables.updater.setInstallManifest(createObject("component","farcry.plugins.farcrysolrpro.tests.data.testUpdates.manifest-0-0-2"));
		assertFalse(variables.updater.updateAvailable(), "Returned update available even though current version matches the most recent available version.");

		// ensure we get a "false" response if we have matching non-0.0.0 format versions
		variables.updater.setInstallManifest(createObject("component","farcry.plugins.farcrysolrpro.tests.data.testUpdates.manifest-alpha"));
		variables.updater.setUpdateUrl("http://" & cgi.http_host & "/farcrysolrpro/test/updates/alpha-update.json");
		assertFalse(variables.updater.updateAvailable(), "Returned update available even though we have matching unrecognizable versions");

		// ensure we get a "true" response if we have non-matching non-0.0.0 format versions
		variables.updater.setInstallManifest(createObject("component","farcry.plugins.farcrysolrpro.tests.data.testUpdates.manifest-alpha"));
		variables.updater.setUpdateUrl("http://" & cgi.http_host & "/farcrysolrpro/test/updates/beta-update.json");
		assertTrue(variables.updater.updateAvailable(), "Returned update unavailable even though we have non-matching unrecognizable versions");

	}

	public void function testGetMostRecentVersion() {

		var expected = "0.0.2";
		var actual = variables.updater.getMostRecentVersion();
		assertEquals(expected, actual);

		// try with an unavailable URL, should return "UNKNOWN"
		variables.updater.setUpdateUrl("http://this.doesntexist.com/update.json");
		assertEquals("UNKNOWN",variables.updater.getMostRecentVersion());

	}

	public void function testGetCurrentVersion() {
		var expected = variables.installManifest.version;
		var actual = variables.updater.getCurrentVersion();
		assertEquals(expected, actual);
	}

	public void function testGetDataFromJson() {
		var result = variables.updater.getDataFromJson();

		assertTrue(isArray(result));
		assertTrue(arrayLen(result) eq 2);
		assertTrue(isStruct(result[1]));
		assertTrue(structKeyExists(result[1],"version"));
		assertTrue(structKeyExists(result[1],"releasedate"));
		assertTrue(structKeyExists(result[1],"description"));
		assertTrue(structKeyExists(result[1],"changelog"));
		assertTrue(structKeyExists(result[1],"downloads"));
		assertTrue(structKeyExists(result[1],"requirements"));
		assertTrue(structKeyExists(result[1],"repositoryurl"));
		assertTrue(isArray(result[1]["downloads"]));
		assertTrue(arrayLen(result[1]["downloads"]) eq 2);
		assertTrue(isStruct(result[1]["downloads"][1]));
		assertTrue(structKeyExists(result[1]["downloads"][1],"url"));
		assertTrue(structKeyExists(result[1]["downloads"][1],"shortdesc"));
		assertTrue(structKeyExists(result[1]["downloads"][1],"size"));
		assertTrue(isStruct(result[1]["requirements"]));
		assertTrue(structKeyExists(result[1]["requirements"],"cfml"));
		assertTrue(structKeyExists(result[1]["requirements"],"farcry"));
		assertTrue(structKeyExists(result[1]["requirements"],"solr"));
	}

}