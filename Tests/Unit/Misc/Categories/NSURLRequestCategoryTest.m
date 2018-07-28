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
@property (nonatomic, strong) NSURLRequest *request;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation NSURLRequestCategoryTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSString *postBodyString = @"Yet Another HTTP VCR";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:16.f];
    self.dictionaryRepresentation = @{
        @"cls": NSStringFromClass([NSURLRequest class]),
        @"url": request.URL.absoluteString,
        @"method": @"post",
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
    [request setAllHTTPHeaderFields:self.dictionaryRepresentation[@"headers"]];
    request.HTTPMethod = self.dictionaryRepresentation[@"method"];
    request.HTTPBody = [postBodyString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPShouldHandleCookies = ((NSNumber *)self.dictionaryRepresentation[@"cookies"]).boolValue;
    request.HTTPShouldUsePipelining = YES;
    request.allowsCellularAccess = ((NSNumber *)self.dictionaryRepresentation[@"cellular"]).boolValue;
    request.networkServiceType = ((NSNumber *)self.dictionaryRepresentation[@"network"]).unsignedIntegerValue;
    
    self.request = request;
}


#pragma mark - Tests :: Player :: Property

- (void)testCassetteChapterIdentifier_ShouldHaveAdditionalProperty {
    
    XCTAssertTrue([self.request respondsToSelector:@selector(YHV_cassetteChapterIdentifier)]);
}

- (void)testCassetteChapterIdentifier_ShouldStoreCassetteIdentifier_WhenNoPreviousValueSet {
    
    NSString *expectedIdentifier = [NSUUID UUID].UUIDString;
    
    self.request.YHV_cassetteChapterIdentifier = expectedIdentifier;
    
    XCTAssertEqualObjects(self.request.YHV_cassetteChapterIdentifier, expectedIdentifier);
}

- (void)testCassetteChapterIdentifier_ShouldNotStoreCassetteIdentifier_WhenPreviousValueSet {
    
    NSString *expectedIdentifier = [NSUUID UUID].UUIDString;
    
    self.request.YHV_cassetteChapterIdentifier = expectedIdentifier;
    self.request.YHV_cassetteChapterIdentifier = [NSUUID UUID].UUIDString;
    
    XCTAssertEqualObjects(self.request.YHV_cassetteChapterIdentifier, expectedIdentifier);
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
