/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/NSHTTPURLResponse+YHVSerialization.h>


#pragma mark Protected interface declaration

@interface NSHTTPURLResponseCategoryTest : XCTestCase


#pragma mark - Information

@property (nonatomic, strong) NSDictionary *dictionaryRepresentation;
@property (nonatomic, strong) NSHTTPURLResponse *expectedResponse;


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation NSHTTPURLResponseCategoryTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.expectedResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]
                                                        statusCode:200
                                                       HTTPVersion:nil
                                                      headerFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    self.dictionaryRepresentation = @{
        @"cls": NSStringFromClass([NSHTTPURLResponse class]),
        @"url": self.expectedResponse.URL.absoluteString,
        @"headers": self.expectedResponse.allHeaderFields,
        @"status": @(self.expectedResponse.statusCode)
    };
}


#pragma mark - Tests :: Dictionary representation

- (void)testDictionaryRepresentation_ShouldReturnNSDictionary {
    
    XCTAssertTrue([[self.expectedResponse YHV_dictionaryRepresentation] isKindOfClass:[NSDictionary class]]);
}

- (void)testDictionaryRepresentation_ShouldContainExpectedFieldsCount {
    
    XCTAssertEqual([self.expectedResponse YHV_dictionaryRepresentation].count, 4);
}

- (void)testDictionaryRepresentation_ShouldEncodeURL_WhenNSURLInstancesPassed {
    
    NSString *url = [self.expectedResponse YHV_dictionaryRepresentation][@"url"];
    
    XCTAssertNotNil(url);
    XCTAssertTrue([url isKindOfClass:[NSString class]]);
}

- (void)testDictionaryRepresentation_ShoulProvideExpectedOutput {
    
    XCTAssertEqualObjects([self.expectedResponse YHV_dictionaryRepresentation], self.dictionaryRepresentation);
}


#pragma mark - Tests :: Object from dictionary

- (void)testObjectFromDictionary_ShouldReturnNSHTTPURLResponse {
    
    XCTAssertTrue([[NSHTTPURLResponse YHV_objectFromDictionary:self.dictionaryRepresentation] isKindOfClass:[NSHTTPURLResponse class]]);
}

- (void)testObjectFromDictionary_ShouldProperlyDecodeOnRestore {
    
    NSHTTPURLResponse *response = [NSHTTPURLResponse YHV_objectFromDictionary:self.dictionaryRepresentation];
    
    XCTAssertEqualObjects(response.URL, self.expectedResponse.URL);
    XCTAssertEqualObjects(response.allHeaderFields, self.expectedResponse.allHeaderFields);
    XCTAssertEqual(response.statusCode, self.expectedResponse.statusCode);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenDictionaryIsNil {
    
    NSMutableDictionary *errorInfo = nil;
    
    XCTAssertThrowsSpecificNamed([NSHTTPURLResponse YHV_objectFromDictionary:errorInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenURLIsMissing {
    
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [errorInfo removeObjectForKey:@"url"];
    
    XCTAssertThrowsSpecificNamed([NSHTTPURLResponse YHV_objectFromDictionary:errorInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenHeadersIsMissing {
    
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [errorInfo removeObjectForKey:@"headers"];
    
    XCTAssertThrowsSpecificNamed([NSHTTPURLResponse YHV_objectFromDictionary:errorInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenStatusCodeIsMissing {
    
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [errorInfo removeObjectForKey:@"status"];
    
    XCTAssertThrowsSpecificNamed([NSHTTPURLResponse YHV_objectFromDictionary:errorInfo], NSException, NSInternalInconsistencyException);
}

#pragma mark -


@end
