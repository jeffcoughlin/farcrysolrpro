component extends="farcry.plugins.testMXUnit.tests.FarCryTestCase" {
	
	private void function createFakeContentType() {
		var testDir = getDirectoryFromPath(getCurrentTemplatePath());
		var typesDir = testDir & "../packages/types/";
		fileCopy(testDir & "data/fakeContentType.cfc", typesDir & "fakeContentType.cfc");
		var md = createObject("component", application.packagepath & ".farcry.alterType").getCOAPIMetadata("types", "fakeContentType");
		application.stCOAPI["fakeContentType"] = md;
		application.types["fakeContentType"] = md;
	}
	
	private void function removeFakeContentType() {
		var testDir = getDirectoryFromPath(getCurrentTemplatePath());
		var typesDir = testDir & "../packages/types/";
		fileDelete(typesDir & "fakeContentType.cfc");
		structDelete(application.stCoapi, "fakeContentType");
		structDelete(application.types, "fakeContentType");
	}
	
	private void function cleanUpFakeData() {
		
		var queryService = new query();
		queryService.setSQL("delete from solrProIndexedProperty where objectid not in (select data from solrProContentType_aIndexedProperties join solrProContentType on parentid = solrProContentType.objectid where contentType <> 'fakeContentType');");
		queryService.setDatasource(application.dsn);
		queryService.execute();
		
		queryService = new query();
		queryService.setSQL("delete from solrProContentType where contentType = 'fakeContentType';");
		queryService.setDatasource(application.dsn);
		queryService.execute();
		
		queryService = new query();
		queryService.setSQL("delete from solrProContentType_aIndexedProperties where data not in (select objectid from solrProIndexedProperty) or parentid not in (select objectid from solrProContentType);");
		queryService.setDatasource(application.dsn);
		queryService.execute();
		
	}

	public void function beforeTests() {
		super.beforeTests();
		createFakeContentType();
		
	}
	
	public void function afterTests() {
		super.beforeTests();
		removeFakeContentType();
		cleanUpFakeData();
	}
	
	public void function setUp() {
		
		super.setUp();
		
		cleanUpFakeData();
		
		var fakeIndexedProps = [
			{ 
				fieldName = "title",
				lFieldTypes = "text:stored,phonetic:stored"
			},
			{
				fieldName = "teaser",
				lFieldTypes = "text:stored,phonetic:stored"
			},
			{
				fieldName = "someDate",
				lFieldTypes = "date:stored"
			},
			{
				fieldName = "bSomeBoolean",
				lFieldTypes = "boolean:stored"
			},
			{
				fieldName = "someInteger",
				lFieldTypes = "int:stored"
			},
			{
				fieldName = "someLong",
				lFieldTypes = "long:stored"
			},
			{
				fieldName = "someDouble",
				lFieldTypes = "double:stored"
			},
			{
				fieldName = "someFloat",
				lFieldTypes = "float:stored"
			},
			{
				fieldName = "someLocation",
				lFieldTypes = "location:stored"
			},
			{
				fieldName = "aSomeArray",
				lFieldTypes = "array:stored"
			},
			{
				fieldName = "someString",
				lFieldTypes = "string:stored"
			},
			{
				fieldName = "someField",
				lFieldTypes = "usercreated:stored"
			}
		];
		
		var aIndexedProperties = [];
		var oProp = application.fapi.getContentType("solrProIndexedProperty");
		
		for (var fakeProp in fakeIndexedProps) {
			
			var stFakeProp = oProp.beforeSave(stProperties = fakeProp, stFields = structNew());
			var propResult = oProp.createData(stProperties = stFakeProp);
			
			arrayAppend(aIndexedProperties, propResult.objectid);
			
			pinObjects(typename = "solrProIndexedProperty", objectid = propResult.objectid);
			
		}
		
		// variables.oContentType = application.fapi.getContentType("solrProContentType");
		variables.oContentType = createObject("component", "farcry.plugins.farcrysolrpro.tests.data.solrProContentType");

		variables.stFakeContentType = {
			title = "Fake Content Type",
			contentType = "fakeContentType",
			resultTitleField = "label",
			resultSummaryField = "teaser",
			lSummaryFields = "",
			resultImageField = "",
			lDocumentSizeFields = "",
			bEnableSearch = true,
			builtToDate = now(),
			defaultDocBoost = 0,
			aIndexedProperties = aIndexedProperties,
			bIndexRuleData = false,
			lIndexedRules = "",
			lCorePropertyBoost = "",
			bIndexOnSave = false
		};
		
		variables.stFakeContentType = variables.oContentType.beforeSave(stProperties = variables.stFakeContentType, stFields = {});
		var result = variables.oContentType.createData(stProperties = variables.stFakeContentType);
		
		pinObjects(typename = "solrProContentType", objectid = result.objectid);
		
	}
	
	public void function testDefaults() {
		
		// test with only required parameters 
		// (include phonetic, do not include non-string, starting qf of ['fcsp_rulecontent','fcsp_rulecontent_phonetic','objectid'])
		
		var expectedQF = "fcsp_rulecontent,fcsp_rulecontent_phonetic,objectid,somestring_string_stored,teaser_text_stored,teaser_phonetic_stored,title_text_stored,title_phonetic_stored,somefield_usercreated_stored";
		
		var expected = listToArray(lcase(expectedQF));
		
		var qf = variables.oContentType.getFieldListForType(typename = "fakeContentType");
		
		var actual = listToArray(lcase(qf), " ");
		
		arraySort(expected, "textnocase");
		arraySort(actual, "textnocase");
		
		debug([ expected, actual ]);
		
		assertArrayEquals(expected, actual);
		
	}
	
	public void function testNoPhoneticNoNonString() {
		
		// test with setting bIncludePhonetic = false, bIncludeNonString = false
		// starting qf of ['fcsp_rulecontent','fcsp_rulecontent_phonetic','objectid'])

		var expectedQF = "fcsp_rulecontent,objectid,somestring_string_stored,teaser_text_stored,title_text_stored,somefield_usercreated_stored";
		
		var expected = listToArray(lcase(expectedQF));
		
		var qf = variables.oContentType.getFieldListForType(typename = "fakeContentType", bIncludePhonetic = false, bIncludeNonString = false);
		
		var actual = listToArray(lcase(qf), " ");
		
		arraySort(expected, "textnocase");
		arraySort(actual, "textnocase");
		
		debug([ expected, actual ]);
		
		assertArrayEquals(expected, actual);
		
	}	
	
	public void function testYesPhoneticNoNonString() {
		
		// test with setting bIncludePhonetic = true, bIncludeNonString = false
		// starting qf of ['fcsp_rulecontent','fcsp_rulecontent_phonetic','objectid'])
		
		var expectedQF = "fcsp_rulecontent,fcsp_rulecontent_phonetic,objectid,somestring_string_stored,teaser_text_stored,teaser_phonetic_stored,title_text_stored,title_phonetic_stored,somefield_usercreated_stored";
		
		var expected = listToArray(lcase(expectedQF));
		
		var qf = variables.oContentType.getFieldListForType(typename = "fakeContentType", bIncludePhonetic = true, bIncludeNonString = false);
		
		var actual = listToArray(lcase(qf), " ");
		
		arraySort(expected, "textnocase");
		arraySort(actual, "textnocase");
		
		debug([ expected, actual ]);
		
		assertArrayEquals(expected, actual);
		
	}
	
	public void function testNoPhoneticYesNonString() {
		
		// test with setting bIncludePhonetic = false, bIncludeNonString = true
		// starting qf of ['fcsp_rulecontent','fcsp_rulecontent_phonetic','objectid'])

		var expectedQF = "fcsp_rulecontent,objectid,somestring_string_stored,teaser_text_stored,title_text_stored,somedate_date_stored,bsomeboolean_boolean_stored,someinteger_int_stored,somelong_long_stored,somedouble_double_stored,somefloat_float_stored,somelocation_location_stored,asomearray_array_stored,somefield_usercreated_stored";
		
		var expected = listToArray(lcase(expectedQF));
		
		var qf = variables.oContentType.getFieldListForType(typename = "fakeContentType", bIncludePhonetic = false, bIncludeNonString = true);
		
		var actual = listToArray(lcase(qf), " ");
		
		arraySort(expected, "textnocase");
		arraySort(actual, "textnocase");
		
		debug([ expected, actual ]);
		
		assertArrayEquals(expected, actual);
		
	}
	
	public void function testNoPhonetic() {
		
		// test with setting bIncludePhonetic = false (rest are defaults)
		// starting qf of ['fcsp_rulecontent','fcsp_rulecontent_phonetic','objectid'])
		
		var expectedQF = "fcsp_rulecontent,objectid,somestring_string_stored,teaser_text_stored,title_text_stored,somefield_usercreated_stored";
		
		var expected = listToArray(lcase(expectedQF));
		
		var qf = variables.oContentType.getFieldListForType(typename = "fakeContentType", bIncludePhonetic = false);
		
		var actual = listToArray(lcase(qf), " ");
		
		arraySort(expected, "textnocase");
		arraySort(actual, "textnocase");
		
		debug([ expected, actual ]);
		
		assertArrayEquals(expected, actual);
		
	}
	
	/*  */
	
	public void function testNoNonString() {
		
		// test with setting bIncludeNonString = false (rest are defaults)
		// starting qf of ['fcsp_rulecontent','fcsp_rulecontent_phonetic','objectid'])
		
		var expectedQF = "fcsp_rulecontent,fcsp_rulecontent_phonetic,objectid,somestring_string_stored,teaser_text_stored,teaser_phonetic_stored,title_text_stored,title_phonetic_stored,somefield_usercreated_stored";
		
		var expected = listToArray(lcase(expectedQF));
		
		var qf = variables.oContentType.getFieldListForType(typename = "fakeContentType", bIncludeNonString = false);
		
		var actual = listToArray(lcase(qf), " ");
		
		arraySort(expected, "textnocase");
		arraySort(actual, "textnocase");
		
		debug([ expected, actual ]);
		
		assertArrayEquals(expected, actual);
	}
	
	public void function testAllInclusive() {
		
		// test with setting bIncludePhonetic = true, bIncludeNonString = true
		// starting qf of ['fcsp_rulecontent','fcsp_rulecontent_phonetic','objectid'])
		
		
		var expectedQF = "fcsp_rulecontent,fcsp_rulecontent_phonetic,objectid,somestring_string_stored,teaser_text_stored,title_text_stored,somedate_date_stored,bsomeboolean_boolean_stored,someinteger_int_stored,somelong_long_stored,somedouble_double_stored,somefloat_float_stored,somelocation_location_stored,asomearray_array_stored,somefield_usercreated_stored,title_phonetic_stored,teaser_phonetic_stored";
		
		var expected = listToArray(lcase(expectedQF));
		
		var qf = variables.oContentType.getFieldListForType(typename = "fakeContentType", bIncludePhonetic = true, bIncludeNonString = true);
		
		var actual = listToArray(lcase(qf), " ");
		
		arraySort(expected, "textnocase");
		arraySort(actual, "textnocase");
		
		debug([ expected, actual ]);
		
		assertArrayEquals(expected, actual);
		
	}
	
	
	public void function testModifiedStartingQF() {
		
		// starting qf of ['test'])
		
		var expectedQF = "test,somestring_string_stored,teaser_text_stored,teaser_phonetic_stored,title_text_stored,title_phonetic_stored,somefield_usercreated_stored";
		
		var expected = listToArray(lcase(expectedQF));
		
		var qf = variables.oContentType.getFieldListForType(typename = "fakeContentType", qf = [ "test" ]);
		
		var actual = listToArray(lcase(qf), " ");
		
		arraySort(expected, "textnocase");
		arraySort(actual, "textnocase");
		
		debug([ expected, actual ]);
		
		assertArrayEquals(expected, actual);
		
	}
	
	public void function testModifiedStartingQFNoPhonetic() {
		
		// starting qf of ['test_phonetic', "test" ])
		
		var expectedQF = "test,test_phonetic,somestring_string_stored,teaser_text_stored,title_text_stored,somefield_usercreated_stored";
		
		var expected = listToArray(lcase(expectedQF));
		
		var qf = variables.oContentType.getFieldListForType(typename = "fakeContentType", qf = [ "test", "test_phonetic" ], bIncludePhonetic = false);
		
		var actual = listToArray(lcase(qf), " ");
		
		arraySort(expected, "textnocase");
		arraySort(actual, "textnocase");
		
		debug([ expected, actual ]);
		
		assertArrayEquals(expected, actual);
		
	}
	
}