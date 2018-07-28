/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/YHVConfiguration+Private.h>


#pragma mark Protected interface declaration

@interface YHVConfigurationTest : XCTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) YHVConfiguration *configuration;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation YHVConfigurationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.configuration = [YHVConfiguration defaultConfiguration];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldSetDefaults {
    
    XCTAssertEqual(self.configuration.playbackMode, YHVChronologicalPlayback);
    XCTAssertEqual(self.configuration.recordMode, YHVRecordOnce);
    XCTAssertTrue([self.configuration.matchers containsObject:YHVMatcher.method], @"Missing HTTP method matcher in defaults.");
    XCTAssertTrue([self.configuration.matchers containsObject:YHVMatcher.scheme], @"Missing URI scheme matcher in defaults.");
    XCTAssertTrue([self.configuration.matchers containsObject:YHVMatcher.host], @"Missing URI host matcher in defaults.");
    XCTAssertTrue([self.configuration.matchers containsObject:YHVMatcher.port], @"Missing URI port matcher in defaults.");
    XCTAssertTrue([self.configuration.matchers containsObject:YHVMatcher.path], @"Missing URI path component matcher in defaults.");
    XCTAssertTrue([self.configuration.matchers containsObject:YHVMatcher.query], @"Missing URI query component matcher in defaults.");
}

- (void)testNew_ShouldThrow_WhenUsed {
    
    XCTAssertThrowsSpecificNamed([YHVConfiguration new], NSException, NSDestinationInvalidException);
}


#pragma mark - Tests :: Potocols :: NSCopying

- (void)testCopy_ShouldCreateIdenticalCopy {
    
    self.configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) { };
    self.configuration.beforeRecordResponse = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
        return @[response, data];
    };
    self.configuration.beforeRecordRequest = ^(NSURLRequest *request) {
        return request;
    };
    self.configuration.responseBodyFilter = ^NSData * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
        return data;
    };
    self.configuration.postBodyFilter = ^(NSURLRequest *request) {
        return request.HTTPBody;
    };
    self.configuration.cassettesPath = [NSUUID UUID].UUIDString;
    self.configuration.playbackMode = YHVMomentaryPlayback;
    self.configuration.cassettePath = [NSUUID UUID].UUIDString;
    self.configuration.headersFilter = ^(NSURLRequest *request, NSMutableDictionary *headers) { };
    self.configuration.hostsFilter = ^BOOL (NSString *host) {
        return YES;
    };
    self.configuration.pathFilter = ^NSString * (NSURLRequest *request) {
        return request.URL.path;
    };
    self.configuration.urlFilter = ^NSURL * (NSURLRequest *request, NSURL *url) {
        return url;
    };
    self.configuration.recordMode = YHVRecordNew;
    self.configuration.matchers = @[YHVMatcher.query];
    
    YHVConfiguration *configurationCopy = [self.configuration copy];
    
    XCTAssertEqualObjects(configurationCopy.queryParametersFilter, self.configuration.queryParametersFilter);
    XCTAssertEqualObjects(configurationCopy.beforeRecordResponse, self.configuration.beforeRecordResponse);
    XCTAssertEqualObjects(configurationCopy.beforeRecordRequest, self.configuration.beforeRecordRequest);
    XCTAssertEqualObjects(configurationCopy.responseBodyFilter, self.configuration.responseBodyFilter);
    XCTAssertEqualObjects(configurationCopy.headersFilter, self.configuration.headersFilter);
    XCTAssertEqualObjects(configurationCopy.postBodyFilter, self.configuration.postBodyFilter);
    XCTAssertEqualObjects(configurationCopy.cassettesPath, self.configuration.cassettesPath);
    XCTAssertEqualObjects(configurationCopy.pathFilter, self.configuration.pathFilter);
    XCTAssertEqual(configurationCopy.playbackMode, self.configuration.playbackMode);
    XCTAssertEqualObjects(configurationCopy.cassettePath, self.configuration.cassettePath);
    XCTAssertEqualObjects(configurationCopy.hostsFilter, self.configuration.hostsFilter);
    XCTAssertEqual(configurationCopy.recordMode, self.configuration.recordMode);
    XCTAssertEqualObjects(configurationCopy.matchers, self.configuration.matchers);
    XCTAssertEqualObjects(configurationCopy.urlFilter, self.configuration.urlFilter);
}

#pragma mark -


@end
