/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/NSURLRequest+YHVPlayer.h>
#import <YAHTTPVCR/NSURLRequest+YHVSerialization.h>
#import <YAHTTPVCR/NSData+YHVSerialization.h>
#import <YAHTTPVCR/YHVSerializationHelper.h>


#pragma mark Protected interface declaration

@interface NSURLRequestCategoryTest : XCTestCase


#pragma mark - Information

@property (nonatomic, strong) NSDictionary *dictionaryRepresentation;
@property (nonatomic, strong) NSMutableURLRequest *request;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation NSURLRequestCategoryTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    BOOL shouldBePost = [self.name rangeOfString:@"testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentPipeliningFlag"].location == NSNotFound;
    NSString *postBodyString = @"Yet Another HTTP VCR";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:16.f];
    self.dictionaryRepresentation = @{
        @"cls": NSStringFromClass([NSURLRequest class]),
        @"url": request.URL.absoluteString,
        @"method": shouldBePost ? @"post" : @"get",
        @"headers": @{
            @"Content-Type": @"application/json",
            @"Accept": @"*/*"
        },
        @"body": [YHVSerializationHelper dictionaryFromObject:[postBodyString dataUsingEncoding:NSUTF8StringEncoding]],
        @"cache": @(request.cachePolicy),
        @"timeout": @(request.timeoutInterval),
        @"cookies": @NO,
        @"pipeline": @NO,
        @"cellular": @NO,
        @"network": @(NSURLNetworkServiceTypeVideo)
    };
    
    self.request = [request mutableCopy];
    [self.request setAllHTTPHeaderFields:self.dictionaryRepresentation[@"headers"]];
    self.request.HTTPMethod = self.dictionaryRepresentation[@"method"];
    if (shouldBePost) {
        self.request.HTTPBody = [postBodyString dataUsingEncoding:NSUTF8StringEncoding];
    }
    self.request.HTTPShouldHandleCookies = ((NSNumber *)self.dictionaryRepresentation[@"cookies"]).boolValue;
    self.request.HTTPShouldUsePipelining = YES;
    self.request.allowsCellularAccess = ((NSNumber *)self.dictionaryRepresentation[@"cellular"]).boolValue;
    self.request.networkServiceType = ((NSNumber *)self.dictionaryRepresentation[@"network"]).unsignedIntegerValue;
}


#pragma mark - Tests :: Player :: Property

- (void)testHTTPBody_ShouldHaveAdditionalProperty {
    
    XCTAssertTrue([self.request respondsToSelector:@selector(YHV_HTTPBody)]);
}

- (void)testHTTPBody_ShouldStoreData_WhenNonNilPassed {
    
    NSData *expectedData = [@"Yet Another HTTP VCR #2" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.HTTPBody = expectedData;
    
    XCTAssertNotNil(request.YHV_HTTPBody);
    XCTAssertNotEqualObjects(self.request.HTTPBody, expectedData);
    XCTAssertNotEqualObjects(self.request.YHV_HTTPBody, expectedData);
    XCTAssertEqualObjects(request.HTTPBody, expectedData);
    XCTAssertEqualObjects(request.YHV_HTTPBody, expectedData);
    XCTAssertNotEqualObjects(request.HTTPBody, self.request.HTTPBody);
    XCTAssertNotEqualObjects(request.YHV_HTTPBody, self.request.YHV_HTTPBody);
}

- (void)testHTTPBody_ShouldReturnNativeHTTPBody_WhenYHVHTTPBodyIsNil {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    [NSURLProtocol removePropertyForKey:@"YHVRequestPOSTBody" inRequest:request];
    
    XCTAssertNotNil(request.YHV_HTTPBody);
}

- (void)testHTTPBody_ShouldStoreCassetteIdentifier_WhenNonNilPassed {
    
    [YHVNSURLRequest patch];
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    NSData *expectedData = self.request.HTTPBody;
    request.HTTPBody = nil;
    
    XCTAssertNil(request.HTTPBody);
    XCTAssertEqualObjects(request.YHV_HTTPBody, expectedData);
}

- (void)testVCRIgnored_ShouldHaveAdditionalProperty {
    
    XCTAssertTrue([self.request respondsToSelector:@selector(YHV_VCRIgnored)]);
}

- (void)testVCRIgnored_ShouldStoreData {
    
    self.request.YHV_VCRIgnored = YES;
    
    XCTAssertTrue(self.request.YHV_VCRIgnored);
}

- (void)testUsingNSURLSession_ShouldHaveAdditionalProperty {
    
    XCTAssertTrue([self.request respondsToSelector:@selector(YHV_usingNSURLSession)]);
}

- (void)testUsingNSURLSession_ShouldStoreData {
    
    self.request.YHV_usingNSURLSession = YES;
    
    XCTAssertTrue(self.request.YHV_usingNSURLSession);
}

- (void)testIdentifier_ShouldHaveAdditionalProperty {
    
    XCTAssertTrue([self.request respondsToSelector:@selector(YHV_identifier)]);
}

- (void)testIdentifier_ShouldStoreIdentifier_WhenNoPreviousValueSet {
    
    NSString *expectedIdentifier = [NSUUID UUID].UUIDString;
    
    self.request.YHV_identifier = expectedIdentifier;
    
    XCTAssertEqualObjects(self.request.YHV_identifier, expectedIdentifier);
}

- (void)testIdentifier_ShouldNotStoreIdentifier_WhenPreviousValueSet {
    
    NSString *expectedIdentifier = [NSUUID UUID].UUIDString;
    
    self.request.YHV_identifier = expectedIdentifier;
    self.request.YHV_identifier = [NSUUID UUID].UUIDString;
    
    XCTAssertEqualObjects(self.request.YHV_identifier, expectedIdentifier);
}

- (void)testCassetteIdentifier_ShouldHaveAdditionalProperty {
    
    XCTAssertTrue([self.request respondsToSelector:@selector(YHV_cassetteIdentifier)]);
}

- (void)testCassetteIdentifier_ShouldStoreCassetteIdentifier_WhenNoPreviousValueSet {
    
    NSString *expectedIdentifier = [NSUUID UUID].UUIDString;
    
    self.request.YHV_cassetteIdentifier = expectedIdentifier;
    
    XCTAssertEqualObjects(self.request.YHV_cassetteIdentifier, expectedIdentifier);
}

- (void)testCassetteIdentifier_ShouldNotStoreCassetteIdentifier_WhenPreviousValueSet {
    
    NSString *expectedIdentifier = [NSUUID UUID].UUIDString;
    
    self.request.YHV_cassetteIdentifier = expectedIdentifier;
    self.request.YHV_cassetteIdentifier = [NSUUID UUID].UUIDString;
    
    XCTAssertEqualObjects(self.request.YHV_cassetteIdentifier, expectedIdentifier);
}

- (void)testCassetteChapterIdentifier_ShouldHaveAdditionalProperty {
    
    XCTAssertTrue([self.request respondsToSelector:@selector(YHV_cassetteChapterIdentifier)]);
}

- (void)testCassetteChapterIdentifier_ShouldStoreCassetteChapterIdentifier_WhenNoPreviousValueSet {
    
    NSString *expectedIdentifier = [NSUUID UUID].UUIDString;
    
    self.request.YHV_cassetteChapterIdentifier = expectedIdentifier;
    
    XCTAssertEqualObjects(self.request.YHV_cassetteChapterIdentifier, expectedIdentifier);
}

- (void)testCassetteChapterIdentifier_ShouldNotStoreCassetteChapterIdentifier_WhenPreviousValueSet {
    
    NSString *expectedIdentifier = [NSUUID UUID].UUIDString;
    
    self.request.YHV_cassetteChapterIdentifier = expectedIdentifier;
    self.request.YHV_cassetteChapterIdentifier = [NSUUID UUID].UUIDString;
    
    XCTAssertEqualObjects(self.request.YHV_cassetteChapterIdentifier, expectedIdentifier);
}


#pragma mark - Tests :: Compare

- (void)testIsEqual_ShouldReturnYES_WhenBothRequestsIdentical {
    
    XCTAssertTrue([[self.request mutableCopy] YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnYES_WhenBothDoesntHaveHTTPBody {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    self.request.HTTPBody = nil;
    request.HTTPBody = nil;
    
    XCTAssertTrue([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnYES_WhenBothDoesntHaveHeaders {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    [self.request setAllHTTPHeaderFields:nil];
    [request setAllHTTPHeaderFields:nil];
    
    XCTAssertTrue([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentCachePolicy {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentTimeout {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.timeoutInterval = 1236.f;
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentCookiesHandlingFlag {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.HTTPShouldHandleCookies = YES;
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentPipeliningFlag {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.HTTPShouldUsePipelining = NO;
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentCellularAccessFlag {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.allowsCellularAccess = YES;
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentNetworkServiceType {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.networkServiceType = NSURLNetworkServiceTypeVoice;
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentHTTPMethod {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.HTTPMethod = @"get";
    request.HTTPShouldUsePipelining = NO;
    
    NSLog(@"self.request.HTTPShouldUsePipelining: %@", self.request.HTTPShouldUsePipelining ? @"YES" : @"NO");
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentURL {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.URL = [NSURL URLWithString:@"https://127.0.0.1"];
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentHTTPBody {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.HTTPBody = [@"Yet Another HTTP VCR #2" dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenOneRequestsDoesntHaveHTTPBody {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.HTTPBody = nil;
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentHTTPBodyStream {
    
    self.request.HTTPBodyStream = [NSInputStream inputStreamWithData:self.request.HTTPBody];
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.HTTPBodyStream = [NSInputStream inputStreamWithData:[@"Yet Another HTTP VCR #2" dataUsingEncoding:NSUTF8StringEncoding]];
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenOneRequestsDoesntHaveHTTPBodyStream {
    
    self.request.HTTPBodyStream = [NSInputStream inputStreamWithData:self.request.HTTPBody];
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.HTTPBodyStream = nil;
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentMainDocumentURL {
    
    self.request.mainDocumentURL = [NSURL URLWithString:@"https://127.0.0.1"];
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.mainDocumentURL = [NSURL URLWithString:@"https://127.0.0.2"];
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenOneRequestsDoesntHaveMainDocumentURL {
    
    self.request.mainDocumentURL = [NSURL URLWithString:@"https://127.0.0.1"];
    NSMutableURLRequest *request = [self.request mutableCopy];
    request.mainDocumentURL = nil;
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenRequestsHasDifferentHeaders {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}

- (void)testIsEqual_ShouldReturnNO_WhenOneRequestsDoesntHaveHeaders {
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    
    XCTAssertFalse([request YHV_isEqual:self.request]);
}


#pragma mark - Tests :: Dictionary representation

- (void)testDictionaryRepresentation_ShouldReturnNSDictionary {
    
    XCTAssertTrue([[self.request YHV_dictionaryRepresentation] isKindOfClass:[NSDictionary class]]);
}

- (void)testDictionaryRepresentation_ShouldContainExpectedFieldsCount {
    
    XCTAssertEqual([self.request YHV_dictionaryRepresentation].count, self.dictionaryRepresentation.count);
}

- (void)testDictionaryRepresentation_ShouldEncodeURL_WhenNSURLInstancesPassed {
    
    NSString *url = [self.request YHV_dictionaryRepresentation][@"url"];
    
    XCTAssertNotNil(url);
    XCTAssertTrue([url isKindOfClass:[NSString class]]);
}

- (void)testDictionaryRepresentation_ShoulProvideExpectedOutput {
    
    XCTAssertEqualObjects([self.request YHV_dictionaryRepresentation], self.dictionaryRepresentation);
}


#pragma mark - Tests :: Object from dictionary

- (void)testObjectFromDictionary_ShouldReturnNSURLRequest {
    
    XCTAssertTrue([[NSURLRequest YHV_objectFromDictionary:self.dictionaryRepresentation] isKindOfClass:[NSURLRequest class]]);
}

- (void)testObjectFromDictionary_ShouldProperlyDecodeOnRestore {
    
    NSURLRequest *request = [NSURLRequest YHV_objectFromDictionary:self.dictionaryRepresentation];
    
    XCTAssertEqualObjects(request, self.request);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenDictionaryIsNil {
    
    NSMutableDictionary *requestInfo = nil;
    
    XCTAssertThrowsSpecificNamed([NSURLRequest YHV_objectFromDictionary:requestInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenURLIsMissing {
    
    NSMutableDictionary *requestInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [requestInfo removeObjectForKey:@"url"];
    
    XCTAssertThrowsSpecificNamed([NSURLRequest YHV_objectFromDictionary:requestInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenHTTPMethodIsMissing {
    
    NSMutableDictionary *requestInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [requestInfo removeObjectForKey:@"method"];
    
    XCTAssertThrowsSpecificNamed([NSURLRequest YHV_objectFromDictionary:requestInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenCachePolicyIsMissing {
    
    NSMutableDictionary *requestInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [requestInfo removeObjectForKey:@"cache"];
    
    XCTAssertThrowsSpecificNamed([NSURLRequest YHV_objectFromDictionary:requestInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenTimeoutIsMissing {
    
    NSMutableDictionary *requestInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [requestInfo removeObjectForKey:@"timeout"];
    
    XCTAssertThrowsSpecificNamed([NSURLRequest YHV_objectFromDictionary:requestInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenCookiesHandlingFlagIsMissing {
    
    NSMutableDictionary *requestInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [requestInfo removeObjectForKey:@"cookies"];
    
    XCTAssertThrowsSpecificNamed([NSURLRequest YHV_objectFromDictionary:requestInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenPipeliningFlagIsMissing {
    
    NSMutableDictionary *requestInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [requestInfo removeObjectForKey:@"pipeline"];
    
    XCTAssertThrowsSpecificNamed([NSURLRequest YHV_objectFromDictionary:requestInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenCellularUsageFlagIsMissing {
    
    NSMutableDictionary *requestInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [requestInfo removeObjectForKey:@"cellular"];
    
    XCTAssertThrowsSpecificNamed([NSURLRequest YHV_objectFromDictionary:requestInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenNetworkTypeIsMissing {
    
    NSMutableDictionary *requestInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [requestInfo removeObjectForKey:@"network"];
    
    XCTAssertThrowsSpecificNamed([NSURLRequest YHV_objectFromDictionary:requestInfo], NSException, NSInternalInconsistencyException);
}

#pragma mark -


@end
