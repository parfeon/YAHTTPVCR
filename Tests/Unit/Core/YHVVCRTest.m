/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/NSDictionary+YHVNSURL.h>
#import <YAHTTPVCR/YHVCassette+Private.h>
#import <YAHTTPVCR/YHVNSURLProtocol.h>
#import <YAHTTPVCR/YHVVCR+Recorder.h>
#import <YAHTTPVCR/YHVVCR+Player.h>
#import <YAHTTPVCR/YAHTTPVCR.h>
#import <OCMock/OCMock.h>


@interface YHVVCRTest : XCTestCase


#pragma mark - Information

@property (nonatomic, copy) NSString *cassettesPath;

#pragma mark -


@end


@implementation YHVVCRTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.cassettesPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString]
                          stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
}

- (void)tearDown {
    
    [super tearDown];
    
    [YHVVCR ejectCassette];
}


#pragma mark - Tests :: Setup

- (void)testSetupWithConfiguration_ShouldProvideConfigurationInstance_WhenVCRSetupCalled {
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        XCTAssertNotNil(configuration);
        XCTAssertEqual(configuration.matchers.count, 6);
        XCTAssertTrue([configuration.matchers containsObject:YHVMatcher.method]);
        XCTAssertTrue([configuration.matchers containsObject:YHVMatcher.scheme]);
        XCTAssertTrue([configuration.matchers containsObject:YHVMatcher.host]);
        XCTAssertTrue([configuration.matchers containsObject:YHVMatcher.port]);
        XCTAssertTrue([configuration.matchers containsObject:YHVMatcher.path]);
        XCTAssertTrue([configuration.matchers containsObject:YHVMatcher.query]);
        XCTAssertEqual(configuration.playbackMode, YHVChronologicalPlayback);
        XCTAssertEqual(configuration.recordMode, YHVRecordOnce);
        
        configuration.cassettesPath = NSTemporaryDirectory();
    }];
    
    XCTAssertNil(YHVVCR.cassette);
}

- (void)testSetupWithConfiguration_ShouldCreateCassettesDirectory_WhenCassettesPathIsSet {
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    
    XCTAssertTrue([NSFileManager.defaultManager fileExistsAtPath:self.cassettesPath]);
}

- (void)testSetupWithConfiguration_ShouldThrow_WhenCassettesPathIsNil {
    
    XCTAssertThrowsSpecificNamed([YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) { }], NSException,
                                 NSInternalInconsistencyException);
}


#pragma mark - Tests :: Cassette

- (void)testInsertCassetteWithPath_ShouldInsertCassette_WhenPathPassed {
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.playbackMode = YHVMomentaryPlayback;
        configuration.recordMode = YHVRecordAll;
    }];
    
    XCTAssertNotNil([YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString]);
    XCTAssertFalse(YHVVCR.cassette.writeProtected);
    XCTAssertFalse(YHVVCR.cassette.allPlayed);
    XCTAssertEqual(YHVVCR.cassette.requests.count, 0);
    XCTAssertEqual(YHVVCR.cassette.responses.count, 0);
}

- (void)testInsertCassetteWithPath_ShouldSetCassettePath {
    
    NSString *path = [NSUUID UUID].UUIDString;
    NSString *cassettePath = [[self.cassettesPath stringByAppendingPathComponent:path] stringByAppendingPathExtension:@"json"];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.playbackMode = YHVMomentaryPlayback;
        configuration.recordMode = YHVRecordAll;
    }];
    
    [YHVVCR insertCassetteWithPath:path];
    
    YHVConfiguration *configuration = YHVVCR.cassette.configuration;
    XCTAssertEqualObjects(configuration.cassettePath, cassettePath);
}

- (void)testInsertCassetteWithPath_ShouldMergeVCRConfigurationIntoCassette {
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.playbackMode = YHVMomentaryPlayback;
        configuration.recordMode = YHVRecordAll;
    }];
    
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    YHVConfiguration *configuration = YHVVCR.cassette.configuration;
    XCTAssertEqual(configuration.playbackMode, YHVMomentaryPlayback);
    XCTAssertEqual(configuration.recordMode, YHVRecordAll);
    XCTAssertNotNil(configuration.matchers);
}

- (void)testInsertCassetteWithPath_ShouldThrow_WhenPathIsNil {
    
    NSString *path = nil;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    
    XCTAssertThrowsSpecificNamed([YHVVCR insertCassetteWithPath:path], NSException, NSInternalInconsistencyException);
}

- (void)testInsertCassetteWithConfiguration_ShouldInsertCassette_WhenPathPassed {
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    
    YHVCassette *cassette = [YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettePath = [NSUUID UUID].UUIDString;
        configuration.matchers = @[];
    }];
    
    XCTAssertNotNil(cassette);
}

- (void)testInsertCassetteWithConfiguration_ShouldSetCassettePath {
    
    NSString *path = [NSUUID UUID].UUIDString;
    NSString *cassettePath = [[self.cassettesPath stringByAppendingPathComponent:path] stringByAppendingPathExtension:@"json"];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    
    YHVCassette *cassette = [YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettePath = path;
    }];
    XCTAssertEqualObjects(cassette.configuration.cassettePath, cassettePath);
}

- (void)testInsertCassetteWithConfiguration_ShouldOverrideVCRConfiguration {
    
    NSArray<NSString *> *expectedMatchers = @[YHVMatcher.query];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.playbackMode = YHVMomentaryPlayback;
        configuration.recordMode = YHVRecordAll;
    }];
    
    [YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettePath = [NSUUID UUID].UUIDString;
        configuration.playbackMode = YHVChronologicalPlayback;
        configuration.recordMode = YHVRecordNew;
        configuration.matchers = expectedMatchers;
    }];
    
    YHVConfiguration *configuration = YHVVCR.cassette.configuration;
    XCTAssertEqual(configuration.playbackMode, YHVChronologicalPlayback);
    XCTAssertEqual(configuration.recordMode, YHVRecordNew);
    XCTAssertEqual(configuration.matchers.count, expectedMatchers.count);
}

- (void)testInsertCassetteWithConfiguration_ShouldThrow_WhenPathIsNil {
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    
    XCTAssertThrowsSpecificNamed([YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {}], NSException,
                                 NSInternalInconsistencyException);
}


#pragma mark - Tests :: Filter

- (void)testFilter_ShouldCreateHostFilterBlock_WhenAllowedHostsListPassed {
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.hostsFilter = @[@"localhost"];
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    XCTAssertFalse([YHVVCR.cassette.configuration.hostsFilter isKindOfClass:[NSArray class]]);
}

- (void)testFilter_ShouldPassURL_WhenURLFromAllowedHosts {
    
    NSURL *requestURL = [NSURL URLWithString:@"http://localhost/something"];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.hostsFilter = @[@"localhost"];
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    XCTAssertTrue(((YHVHostFilterBlock)YHVVCR.cassette.configuration.hostsFilter)(requestURL.host));
}

- (void)testFilter_ShouldForbidURL_WhenURLNotFromAllowedHosts {
    
    NSURL *requestURL = [NSURL URLWithString:@"http://localhost2/something"];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.hostsFilter = @[@"localhost"];
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    XCTAssertFalse(((YHVHostFilterBlock)YHVVCR.cassette.configuration.hostsFilter)(requestURL.host));
}

- (void)testFilter_ShouldUseVCRHostFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    __block BOOL hostFilterBlockCalled = NO;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.hostsFilter = ^BOOL (NSString *host) {
            hostFilterBlockCalled = YES;
            return YES;
        };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    ((YHVHostFilterBlock)YHVVCR.cassette.configuration.hostsFilter)(@"host");
    XCTAssertTrue(hostFilterBlockCalled);
}

- (void)testFilter_ShouldUseCassetteHostFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    __block BOOL cassetteHostFilterBlockCalled = NO;
    __block BOOL vcrHostFilterBlockCalled = NO;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.hostsFilter = ^BOOL (NSString *host) {
            vcrHostFilterBlockCalled = YES;
            return YES;
        };
    }];
    [YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettePath = [NSUUID UUID].UUIDString;
        configuration.hostsFilter = ^BOOL (NSString *host) {
            cassetteHostFilterBlockCalled = YES;
            return YES;
        };
    }];
    
    ((YHVHostFilterBlock)YHVVCR.cassette.configuration.hostsFilter)(@"host");
    XCTAssertTrue(cassetteHostFilterBlockCalled);
    XCTAssertFalse(vcrHostFilterBlockCalled);
}

- (void)testFilter_ShouldCreateHeadersFilterBlock_WhenHeadersReplacementPassed {
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.headersFilter = @{ @"Content-Type": @"secret-content-type" };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    XCTAssertTrue(![YHVVCR.cassette.configuration.headersFilter isKindOfClass:[NSDictionary class]]);
}

- (void)testFilter_ShouldReplaceSensitiveHeaders_WhenHeadersReplacementPassed {
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.headersFilter = @{ @"Content-Type": @"secret-content-type", @"Accept": [NSNull null] };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    ((YHVHeadersFilterBlock)YHVVCR.cassette.configuration.headersFilter)(request, headers);
    XCTAssertEqualObjects(headers[@"Content-Type"], @"secret-content-type");
    XCTAssertNil(headers[@"Accept"]);
}

- (void)testFilter_ShouldUseVCRHeadersFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    __block BOOL headersFilterBlockCalled = NO;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.headersFilter = ^(NSURLRequest *request, NSMutableDictionary *headers) {
            headersFilterBlockCalled = YES;
        };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    ((YHVHeadersFilterBlock)YHVVCR.cassette.configuration.headersFilter)(request, [NSMutableDictionary new]);
    XCTAssertTrue(headersFilterBlockCalled);
}

- (void)testFilter_ShouldUseCassetteHeadersFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    __block BOOL cassetteHeadersFilterBlockCalled = NO;
    __block BOOL vcrHeadersFilterBlockCalled = NO;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.headersFilter = ^(NSURLRequest *request, NSMutableDictionary *headers) {
            vcrHeadersFilterBlockCalled = YES;
        };
    }];
    [YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettePath = [NSUUID UUID].UUIDString;
        configuration.headersFilter = ^(NSURLRequest *request, NSMutableDictionary *headers) {
            cassetteHeadersFilterBlockCalled = YES;
        };
    }];
    
    ((YHVHeadersFilterBlock)YHVVCR.cassette.configuration.headersFilter)(request, [NSMutableDictionary new]);
    XCTAssertTrue(cassetteHeadersFilterBlockCalled);
    XCTAssertFalse(vcrHeadersFilterBlockCalled);
}

- (void)testFilter_ShouldReplaceSensitiveRequestPath_WhenPathFilterSpecified {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something/bad?field2=value2&field1=value1"]];
    NSString *expectedPath = @"something/good";
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.pathFilter = ^NSString * (NSURLRequest *request) {
            return expectedPath;
        };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    NSString *filteredPath = ((YHVPathFilterBlock)YHVVCR.cassette.configuration.pathFilter)(request);
    XCTAssertEqualObjects(filteredPath, expectedPath);
}

- (void)testFilter_ShouldUseVCRPathFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something/bad?field2=value2&field1=value1"]];
    __block BOOL pathFilterBlockCalled = NO;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.pathFilter = ^NSString * (NSURLRequest *request) {
            pathFilterBlockCalled = YES;
            return request.URL.path;
        };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    ((YHVPathFilterBlock)YHVVCR.cassette.configuration.pathFilter)(request);
    XCTAssertTrue(pathFilterBlockCalled);
}

- (void)testFilter_ShouldUseCassettePathFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something/bad?field2=value2&field1=value1"]];
    __block BOOL cassettePathFilterBlockCalled = NO;
    __block BOOL vcrPathFilterBlockCalled = NO;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.pathFilter = ^NSString * (NSURLRequest *request) {
            vcrPathFilterBlockCalled = YES;
            return request.URL.path;
        };
    }];
    [YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettePath = [NSUUID UUID].UUIDString;
        configuration.pathFilter = ^NSString * (NSURLRequest *request) {
            cassettePathFilterBlockCalled = YES;
            return request.URL.path;
        };
    }];
    
    ((YHVPathFilterBlock)YHVVCR.cassette.configuration.pathFilter)(request);
    XCTAssertTrue(cassettePathFilterBlockCalled);
    XCTAssertFalse(vcrPathFilterBlockCalled);
}

- (void)testFilter_ShouldCreateQueryFilterBlock_WhenParametersReplacementPassed {
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.queryParametersFilter = @{ @"field1": @"sceret-value" };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    XCTAssertTrue(![YHVVCR.cassette.configuration.queryParametersFilter isKindOfClass:[NSDictionary class]]);
}

- (void)testFilter_ShouldReplaceSensitiveRequestQuery_WhenQueryReplacementPassed {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something?field2=value2&field1=value1"]];
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:@{ @"field1": @"value1", @"field2": @"value2" }];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.queryParametersFilter = @{ @"field2": @"secret-query", @"field1": [NSNull null] };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    ((YHVQueryParametersFilterBlock)YHVVCR.cassette.configuration.queryParametersFilter)(request, query);
    XCTAssertEqualObjects(query[@"field2"], @"secret-query");
    XCTAssertNil(query[@"field1"]);
}

- (void)testFilter_ShouldUseVCRQueryFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something?field2=value2&field1=value1"]];
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:@{ @"field1": @"value1", @"field2": @"value2" }];
    __block BOOL queryFilterBlockCalled = NO;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) {
            queryFilterBlockCalled = YES;
        };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    ((YHVQueryParametersFilterBlock)YHVVCR.cassette.configuration.queryParametersFilter)(request, query);
    XCTAssertTrue(queryFilterBlockCalled);
}

- (void)testFilter_ShouldUseCassetteQueryFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something?field2=value2&field1=value1"]];
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:@{ @"field1": @"value1", @"field2": @"value2" }];
    __block BOOL cassetteQueryFilterBlockCalled = NO;
    __block BOOL vcrQueryFilterBlockCalled = NO;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) {
            vcrQueryFilterBlockCalled = YES;
        };
    }];
    [YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettePath = [NSUUID UUID].UUIDString;
        configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) {
            cassetteQueryFilterBlockCalled = YES;
        };
    }];
    
    ((YHVQueryParametersFilterBlock)YHVVCR.cassette.configuration.queryParametersFilter)(request, query);
    XCTAssertTrue(cassetteQueryFilterBlockCalled);
    XCTAssertFalse(vcrQueryFilterBlockCalled);
}

- (void)testFilter_ShouldCreateBodyFilterBlock_WhenParametersReplacementPassed {
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.postBodyFilter = @{ @"field1": @"sceret-value" };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    XCTAssertTrue(![YHVVCR.cassette.configuration.postBodyFilter isKindOfClass:[NSDictionary class]]);
}

- (void)testFilter_ShouldReplaceSensitiveBody_WhenJSONBodyReplacementPassed {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    request.HTTPBody = [@"{\"field1\":\"value1\",\"field2\":\"value2\"}" dataUsingEncoding:NSUTF8StringEncoding];
    [request setAllHTTPHeaderFields:@{ @"Content-Type": @"application/json" }];
    request.HTTPMethod = @"POST";
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.postBodyFilter = @{ @"field2": @"secret-body-value", @"field1": [NSNull null] };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    NSData *data = ((YHVPostBodyFilterBlock)YHVVCR.cassette.configuration.postBodyFilter)(request);
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    XCTAssertNotNil(data);
    XCTAssertNotEqualObjects(data, request.HTTPBody);
    XCTAssertEqualObjects(jsonData[@"field2"], @"secret-body-value");
    XCTAssertNil(jsonData[@"field1"]);
}

- (void)testFilter_ShouldReplaceSensitiveBody_WhenWWWFormURLEncodedBodyReplacementPassed {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    request.HTTPBody = [@"field1=value1&field2=value+2" dataUsingEncoding:NSUTF8StringEncoding];
    [request setAllHTTPHeaderFields:@{ @"Content-Type": @"application/x-www-form-urlencoded" }];
    request.HTTPMethod = @"POST";
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.postBodyFilter = @{ @"field2": [NSNull null], @"field1": @"secret-body-value" };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    NSData *data = ((YHVPostBodyFilterBlock)YHVVCR.cassette.configuration.postBodyFilter)(request);
    NSString *postBodyString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSDictionary *dataDictionary = [NSDictionary YHV_dictionaryWithQuery:postBodyString];
    XCTAssertNotNil(data);
    XCTAssertNotEqualObjects(data, request.HTTPBody);
    XCTAssertEqualObjects(dataDictionary[@"field1"], @"secret-body-value");
    XCTAssertNil(dataDictionary[@"field2"]);
}

- (void)testFilter_ShouldKeepBody_WhenRequestWithUnknownContentTypePassed {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    request.HTTPBody = [@"field1=value1&field2=value+2" dataUsingEncoding:NSUTF8StringEncoding];
    [request setAllHTTPHeaderFields:@{ @"Content-Type": @"application/text" }];
    request.HTTPMethod = @"POST";
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.postBodyFilter = @{ @"field2": [NSNull null], @"field1": @"secret-body-value" };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    NSData *data = ((YHVPostBodyFilterBlock)YHVVCR.cassette.configuration.postBodyFilter)(request);
    XCTAssertEqualObjects(data, request.HTTPBody);
}

- (void)testFilter_ShouldUseVCRBodyFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    request.HTTPBody = [@"{\"field1\":\"value1\",\"field2\":\"value2\"}" dataUsingEncoding:NSUTF8StringEncoding];
    [request setAllHTTPHeaderFields:@{ @"Content-Type": @"application/json" }];
    __block BOOL bodyFilterBlockCalled = NO;
    request.HTTPMethod = @"POST";
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.postBodyFilter = ^NSData * (NSURLRequest *request) {
            bodyFilterBlockCalled = YES;
            return nil;
        };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    ((YHVPostBodyFilterBlock)YHVVCR.cassette.configuration.postBodyFilter)(request);
    XCTAssertTrue(bodyFilterBlockCalled);
}

- (void)testFilter_ShouldUseCassetteBodyFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    request.HTTPBody = [@"{\"field1\":\"value1\",\"field2\":\"value2\"}" dataUsingEncoding:NSUTF8StringEncoding];
    [request setAllHTTPHeaderFields:@{ @"Content-Type": @"application/json" }];
    __block BOOL cassetteBodyFilterBlockCalled = NO;
    __block BOOL vcrBodyFilterBlockCalled = NO;
    request.HTTPMethod = @"POST";
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.postBodyFilter = ^NSData * (NSURLRequest *request) {
            vcrBodyFilterBlockCalled = YES;
            return nil;
        };
    }];
    [YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettePath = [NSUUID UUID].UUIDString;
        configuration.postBodyFilter = ^NSData * (NSURLRequest *request) {
            cassetteBodyFilterBlockCalled = YES;
            return nil;
        };
    }];
    
    ((YHVPostBodyFilterBlock)YHVVCR.cassette.configuration.postBodyFilter)(request);
    XCTAssertTrue(cassetteBodyFilterBlockCalled);
    XCTAssertFalse(vcrBodyFilterBlockCalled);
}

- (void)testFilter_ShouldReplaceSensitiveResponseBody_WhenJSONBodyReplacementPassed {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/json" }];
    NSData *responseData = [@"{\"field1\":\"value1\",\"field2\":\"value2\"}" dataUsingEncoding:NSUTF8StringEncoding];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.responseBodyFilter = @{ @"field2": @"secret-body-value", @"field1": [NSNull null] };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    NSData *data = ((YHVResponseBodyFilterBlock)YHVVCR.cassette.configuration.responseBodyFilter)(request, response, responseData);
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    XCTAssertNotNil(data);
    XCTAssertNotEqualObjects(data, responseData);
    XCTAssertEqualObjects(jsonData[@"field2"], @"secret-body-value");
    XCTAssertNil(jsonData[@"field1"]);
}

- (void)testFilter_ShouldReplaceSensitiveResponseBody_WhenWWWFormURLEncodedBodyReplacementPassed {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/x-www-form-urlencoded" }];
    NSData *responseData = [@"field1=value1&field2=value+2" dataUsingEncoding:NSUTF8StringEncoding];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.responseBodyFilter = @{ @"field2": [NSNull null], @"field1": @"secret-body-value" };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    NSData *data = ((YHVResponseBodyFilterBlock)YHVVCR.cassette.configuration.responseBodyFilter)(request, response, responseData);
    NSString *postBodyString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSDictionary *dataDictionary = [NSDictionary YHV_dictionaryWithQuery:postBodyString];
    XCTAssertNotNil(data);
    XCTAssertNotEqualObjects(data, responseData);
    XCTAssertEqualObjects(dataDictionary[@"field1"], @"secret-body-value");
    XCTAssertNil(dataDictionary[@"field2"]);
}

- (void)testFilter_ShouldKeepResponseBody_WhenRequestWithUnknownContentTypePassed {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/text" }];
    NSData *responseData = [@"field1=value1&field2=value+2" dataUsingEncoding:NSUTF8StringEncoding];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.responseBodyFilter = @{ @"field2": [NSNull null], @"field1": @"secret-body-value" };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    NSData *data = ((YHVResponseBodyFilterBlock)YHVVCR.cassette.configuration.responseBodyFilter)(request, response, responseData);
    XCTAssertEqualObjects(data, responseData);
}

- (void)testFilter_ShouldUseVCRResponseBodyFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/json" }];
    NSData *responseData = [@"{\"field1\":\"value1\",\"field2\":\"value2\"}" dataUsingEncoding:NSUTF8StringEncoding];
    __block BOOL bodyFilterBlockCalled = NO;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.responseBodyFilter = ^NSData * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
            bodyFilterBlockCalled = YES;
            return nil;
        };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    ((YHVResponseBodyFilterBlock)YHVVCR.cassette.configuration.responseBodyFilter)(request, response, responseData);
    XCTAssertTrue(bodyFilterBlockCalled);
}

- (void)testFilter_ShouldUseCassetteResponseBodyFilterBlock_WhenFilterBlockPassedDuringConfiguration {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/something"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/json" }];
    NSData *responseData = [@"{\"field1\":\"value1\",\"field2\":\"value2\"}" dataUsingEncoding:NSUTF8StringEncoding];
    __block BOOL cassetteBodyFilterBlockCalled = NO;
    __block BOOL vcrBodyFilterBlockCalled = NO;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.responseBodyFilter = ^NSData * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
            vcrBodyFilterBlockCalled = YES;
            return nil;
        };
    }];
    [YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettePath = [NSUUID UUID].UUIDString;
        configuration.responseBodyFilter = ^NSData * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
            cassetteBodyFilterBlockCalled = YES;
            return nil;
        };
    }];
    
    ((YHVResponseBodyFilterBlock)YHVVCR.cassette.configuration.responseBodyFilter)(request, response, responseData);
    XCTAssertTrue(cassetteBodyFilterBlockCalled);
    XCTAssertFalse(vcrBodyFilterBlockCalled);
}

- (void)testBeforeRecordRequestFilter_ShouldAggregateFilters_WhenPassedDuringConfiguration {
    
    NSDictionary *headers = @{ @"Accept": @"*/*", @"Authorization": @"Basic 1234567890", @"Content-Type": @"application/json", @"Content-Length": @"16" };
    NSMutableDictionary *expectedHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
    [expectedHeaders addEntriesFromDictionary:@{ @"Accept": @"application/json", @"Authorization": @"some-basic-auth-token" }];
    
    NSDictionary *postBody = @{ @"field1": @"value1", @"field2": @"value2" };
    NSDictionary *expectedPostBody = @{ @"field2": @"secret-body-value" };
    
    NSDictionary *expectedQuery = @{ @"field3": @"sceret-value", @"field4": @"value4" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/?field4=value4&field3=value3"]];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:postBody options:(NSJSONWritingOptions)0 error:nil];
    [request setAllHTTPHeaderFields:headers];
    request.HTTPMethod = @"POST";
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.hostsFilter = @[@"localhost"];
        configuration.headersFilter = expectedHeaders;
        configuration.queryParametersFilter = @{ @"field3": @"sceret-value" };
        configuration.postBodyFilter = @{ @"field2": @"secret-body-value", @"field1": [NSNull null] };
        configuration.beforeRecordRequest = ^NSURLRequest * (NSURLRequest *request) {
            NSMutableURLRequest *changedRequest = [request mutableCopy];
            changedRequest.HTTPMethod = @"GET";
            
            return changedRequest;
        };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    NSURLRequest *finalRequest = YHVVCR.cassette.configuration.beforeRecordRequest(request);
    XCTAssertEqualObjects([NSDictionary YHV_dictionaryWithQuery:finalRequest.URL.query], expectedQuery);
    XCTAssertEqualObjects(finalRequest.allHTTPHeaderFields, expectedHeaders);
    XCTAssertEqualObjects([NSJSONSerialization JSONObjectWithData:finalRequest.HTTPBody options:NSJSONReadingAllowFragments error:nil], expectedPostBody);
    XCTAssertEqualObjects(finalRequest.HTTPMethod.lowercaseString, @"get");
}

- (void)testBeforeRecordRequestFilter_ShouldIgnoreRequest_WhenPassedRequestHostNotAllowed {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost2/?field4=value4&field3=value3"]];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.hostsFilter = @[@"localhost"];
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    XCTAssertNil(YHVVCR.cassette.configuration.beforeRecordRequest(request));
}

- (void)testBeforeRecordRequestFilter_ShouldReturnSameRequest_WhenNoFiltersSpecified {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost2/?field1=value1&field2=value2"]];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    XCTAssertEqualObjects(YHVVCR.cassette.configuration.beforeRecordRequest(request), request);
}

- (void)testBeforeRecordResponseFilter_ShouldReturnSameDataForResponse_WhenNoBeforeResponseRecordSpecified {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost2/?field1=value1&field2=value2"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:nil headerFields:nil];
    NSData *data = [@"Yet Another HTTP VCR" dataUsingEncoding:NSUTF8StringEncoding];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    NSArray *responseData = YHVVCR.cassette.configuration.beforeRecordResponse(request, response, data);
    XCTAssertEqualObjects(responseData.lastObject, data);
}

- (void)testBeforeRecordResponseFilter_ShouldReturnAlteredDataForResponse_WhenBeforeResponseRecordSpecified {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost2/?field1=value1&field2=value2"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:nil headerFields:nil];
    NSData *expectedData = [@"Yet Another HTTP VCR test" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [@"Yet Another HTTP VCR" dataUsingEncoding:NSUTF8StringEncoding];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.beforeRecordResponse = ^NSArray * (NSURLRequest *filteredRequest, NSHTTPURLResponse *filteredResponse, NSData *filtereddata) {
            return @[response, expectedData];
        };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    NSArray *responseData = YHVVCR.cassette.configuration.beforeRecordResponse(request, response, data);
    XCTAssertEqualObjects(responseData.lastObject, expectedData);
}


- (void)testBeforeRecordResponseFilter_ShouldAggregateFilters_WhenPassedDuringConfiguration {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/?field4=value4&field3=value3"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/json" }];
    NSData *data = [@"{\"field1\":\"value1\",\"field2\":\"value2\"}" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *expectedQuery = @{ @"field3": @"sceret-value", @"field4": @"value4" };
    NSDictionary *expectedResponseBody = @{ @"field2": @"secret-body-value" };
    __block BOOL beforeRecordResponseCalled = NO;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        configuration.queryParametersFilter = @{ @"field3": @"sceret-value" };
        configuration.responseBodyFilter = @{ @"field2": @"secret-body-value", @"field1": [NSNull null] };
        configuration.beforeRecordResponse = ^NSArray * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
            beforeRecordResponseCalled = YES;
            
            return @[response, data];
        };
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    NSArray *responseData = YHVVCR.cassette.configuration.beforeRecordResponse(request, response, data);
    XCTAssertEqualObjects([NSDictionary YHV_dictionaryWithQuery:((NSHTTPURLResponse *)responseData.firstObject).URL.query], expectedQuery);
    XCTAssertEqualObjects([NSJSONSerialization JSONObjectWithData:responseData.lastObject options:NSJSONReadingAllowFragments error:nil], expectedResponseBody);
    XCTAssertTrue(beforeRecordResponseCalled);
}


#pragma mark - Tests :: Matchers

- (void)testRegisterMatcher_ShouldRegisterMatcher_WhenBlockPassedWithConfiguration {

    YHVMatcherBlock matcher = ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) { return YES; };
    NSUInteger matchersCount = YHVVCR.matchers.count;
    NSString *matcherIdentifier = @"tester";
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    
    [YHVVCR registerMatcher:matcherIdentifier withBlock:matcher];
    XCTAssertEqual(YHVVCR.matchers.count, matchersCount + 1);
    XCTAssertNotNil(YHVVCR.matchers[matcherIdentifier]);
}

- (void)testRegisterMatcher_ShouldNotRegisterMatcher_WhenBlockPassedWithOutIdentifierWithConfiguration {
    
    YHVMatcherBlock matcher = ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) { return YES; };
    NSUInteger matchersCount = YHVVCR.matchers.count;
    NSString *matcherIdentifier = nil;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    
    [YHVVCR registerMatcher:matcherIdentifier withBlock:matcher];
    XCTAssertEqual(YHVVCR.matchers.count, matchersCount);
}

- (void)testRegisterMatcher_ShouldNotRegisterMatcher_WhenBlockNotPassedWithConfiguration {
    
    NSUInteger matchersCount = YHVVCR.matchers.count;
    NSString *matcherIdentifier = @"tester";
    YHVMatcherBlock matcher = nil;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    
    [YHVVCR registerMatcher:matcherIdentifier withBlock:matcher];
    XCTAssertEqual(YHVVCR.matchers.count, matchersCount);
    XCTAssertNil(YHVVCR.matchers[matcherIdentifier]);
}

- (void)testUnregisterMatcher_ShouldRegisterMatcher_WhenBlockPassedWithConfiguration {
    
    YHVMatcherBlock matcher = ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) { return YES; };
    NSString *matcherIdentifier = @"tester";
    NSString *nilIdentifier = nil;
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    
    [YHVVCR registerMatcher:matcherIdentifier withBlock:matcher];
    XCTAssertNotNil(YHVVCR.matchers[matcherIdentifier]);
    [YHVVCR unregisterMatcher:matcherIdentifier];
    [YHVVCR unregisterMatcher:nilIdentifier];
    XCTAssertNil(YHVVCR.matchers[matcherIdentifier]);
}


#pragma mark - Tests :: Playback

- (void)testCanPlayResponse_ShouldForwardMethodCallToCassette {
    
    NSURLRequest *expectedRequest = [NSURLRequest new];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    id cassettePartialMock = OCMPartialMock(YHVVCR.cassette);
    OCMExpect([cassettePartialMock canPlayResponseForRequest:expectedRequest]).andDo(^(NSInvocation *invocation) {});
    
    [YHVVCR canPlayResponseForRequest:expectedRequest];
    
    OCMVerifyAll(cassettePartialMock);
    
    [cassettePartialMock stopMocking];
    cassettePartialMock = nil;
}

- (void)testPrepareToPlayResponses_ShouldForwardMethodCallToCassette {
    
    YHVNSURLProtocol *expectedProtocol = [YHVNSURLProtocol new];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    id cassettePartialMock = OCMPartialMock(YHVVCR.cassette);
    OCMExpect([cassettePartialMock prepareToPlayResponsesWithProtocol:expectedProtocol]).andDo(^(NSInvocation *invocation) {});
    
    [YHVVCR prepareToPlayResponsesWithProtocol:expectedProtocol];
    
    OCMVerifyAll(cassettePartialMock);
    
    [cassettePartialMock stopMocking];
    cassettePartialMock = nil;
}

- (void)testPlayResponsesForRequest_ShouldForwardMethodCallToCassette {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/?field4=value4&field3=value3"]];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    id cassettePartialMock = OCMPartialMock(YHVVCR.cassette);
    OCMExpect([cassettePartialMock playResponsesForRequest:request]).andDo(^(NSInvocation *invocation) {});
    
    [YHVVCR playResponsesForRequest:request];
    
    OCMVerifyAll(cassettePartialMock);
    
    [cassettePartialMock stopMocking];
    cassettePartialMock = nil;
}


#pragma mark - Recording

- (void)testBeginRecording_ShouldForwardMethodCallToCassette {
    
    NSURLSessionTask *expectedTask = [NSURLSessionTask new];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    id cassettePartialMock = OCMPartialMock(YHVVCR.cassette);
    OCMExpect([cassettePartialMock beginRecordingTask:expectedTask]).andDo(^(NSInvocation *invocation) {});
    
    [YHVVCR beginRecordingTask:expectedTask];
    
    OCMVerifyAll(cassettePartialMock);
    
    [cassettePartialMock stopMocking];
    cassettePartialMock = nil;
}

- (void)testRecordResponse_ShouldForwardMethodCallToCassette {
    
    NSHTTPURLResponse *expectedResponse = [NSHTTPURLResponse new];
    NSURLSessionTask *expectedTask = [NSURLSessionTask new];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    id cassettePartialMock = OCMPartialMock(YHVVCR.cassette);
    OCMExpect([cassettePartialMock recordResponse:expectedResponse forTask:expectedTask]).andDo(^(NSInvocation *invocation) {});
    
    [YHVVCR recordResponse:expectedResponse forTask:expectedTask];
    
    OCMVerifyAll(cassettePartialMock);
    
    [cassettePartialMock stopMocking];
    cassettePartialMock = nil;
}

- (void)testRecordData_ShouldForwardMethodCallToCassette {
    
    NSData *expectedData = [@"Yet Another HTTP VCR" dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask *expectedTask = [NSURLSessionTask new];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    id cassettePartialMock = OCMPartialMock(YHVVCR.cassette);
    OCMExpect([cassettePartialMock recordData:expectedData forTask:expectedTask]).andDo(^(NSInvocation *invocation) {});
    
    [YHVVCR recordData:expectedData forTask:expectedTask];
    
    OCMVerifyAll(cassettePartialMock);
    
    [cassettePartialMock stopMocking];
    cassettePartialMock = nil;
}

- (void)testCompletionWithError_ShouldForwardMethodCallToCassette {
    
    NSError *expectedError = [NSError errorWithDomain:@"TestErrorDomain" code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Local description" }];
    NSURLSessionTask *expectedTask = [NSURLSessionTask new];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    id cassettePartialMock = OCMPartialMock(YHVVCR.cassette);
    OCMExpect([cassettePartialMock recordCompletionWithError:expectedError forTask:expectedTask]).andDo(^(NSInvocation *invocation) {});
    
    [YHVVCR recordCompletionWithError:expectedError forTask:expectedTask];
    
    OCMVerifyAll(cassettePartialMock);
    
    [cassettePartialMock stopMocking];
    cassettePartialMock = nil;
}

- (void)testClearFetchedData_ShouldForwardMethodCallToCassette {
    
    NSURLSessionTask *expectedTask = [NSURLSessionTask new];
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
    }];
    [YHVVCR insertCassetteWithPath:[NSUUID UUID].UUIDString];
    
    id cassettePartialMock = OCMPartialMock(YHVVCR.cassette);
    OCMExpect([cassettePartialMock clearFetchedDataForTask:expectedTask]).andDo(^(NSInvocation *invocation) {});
    
    [YHVVCR clearFetchedDataForTask:expectedTask];
    
    OCMVerifyAll(cassettePartialMock);
    
    [cassettePartialMock stopMocking];
    cassettePartialMock = nil;
}

#pragma mark -


@end
