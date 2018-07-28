/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/NSError+YHVSerialization.h>


#pragma mark Protected interface declaration

@interface NSErrorCategoryTest : XCTestCase


#pragma mark - Information

@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSError *underlyingError;
@property (nonatomic, strong) NSDictionary *dictionaryRepresentation;
@property (nonatomic, strong) NSError *expectedError;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation NSErrorCategoryTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[NSLocalizedDescriptionKey] = @"TestError";
    userInfo[NSURLErrorKey] = [NSURL URLWithString:@"https://httpbin.org/1"];
    userInfo[NSURLErrorFailingURLPeerTrustErrorKey] = @"peer-trust";
    userInfo[NSRecoveryAttempterErrorKey] = @"recovery";
    
    self.underlyingError = [NSError errorWithDomain:@"TestUnderlyingErrorDomain" code:100 userInfo:[userInfo copy]];
    
    userInfo[NSUnderlyingErrorKey] = self.underlyingError;
    userInfo[NSURLErrorFailingURLErrorKey] = [NSURL URLWithString:@"https://httpbin.org/2"];
    self.error = [NSError errorWithDomain:@"TestErrorDomain" code:200 userInfo:[userInfo copy]];
    
    self.dictionaryRepresentation = @{
        @"cls": NSStringFromClass([NSError class]),
        @"code": @(-1000),
        @"domain": @"AnotherErrorTestDomain",
        @"info": @{
            NSURLErrorKey: @"https://httpbin.org/3",
            NSUnderlyingErrorKey: @{
                @"cls": NSStringFromClass([NSError class]),
                @"code": @(-1001),
                @"domain": @"AnotherUnderlyingErrorTestDomain",
                @"info": @{ NSURLErrorFailingURLErrorKey: @"https://httpbin.org/4" }
            }
        }
    };
    
    self.expectedError = [NSError errorWithDomain:@"AnotherErrorTestDomain" code:-1000 userInfo:@{
        NSURLErrorKey: [NSURL URLWithString:@"https://httpbin.org/3"],
        NSUnderlyingErrorKey: [NSError errorWithDomain:@"AnotherUnderlyingErrorTestDomain" code:-1001 userInfo:@{
            NSURLErrorFailingURLErrorKey: [NSURL URLWithString:@"https://httpbin.org/4"]
        }]
    }];
}


#pragma mark - Tests :: Dictionary representation

- (void)testDictionaryRepresentation_ShouldReturnNSDictionary {
    
    XCTAssertTrue([[self.error YHV_dictionaryRepresentation] isKindOfClass:[NSDictionary class]]);
}

- (void)testDictionaryRepresentation_ShouldContainExpectedFieldsCount {
    
    XCTAssertEqual([self.error YHV_dictionaryRepresentation].count, 4);
}

- (void)testDictionaryRepresentation_ShouldEncodeURL_WhenNSURLInstancesPassed {
    
    NSDictionary *userInfo = [self.error YHV_dictionaryRepresentation][@"info"];
    
    XCTAssertNotNil(userInfo);
    XCTAssertTrue([userInfo[NSURLErrorKey] isKindOfClass:[NSString class]]);
    XCTAssertTrue([userInfo[NSURLErrorFailingURLErrorKey] isKindOfClass:[NSString class]]);
}

- (void)testDictionaryRepresentation_ShouldEncodeError_WhenUnderlyingNSErrorInstancesPassed {
    
    NSDictionary *userInfo = [self.error YHV_dictionaryRepresentation][@"info"];
    
    XCTAssertNotNil(userInfo);
    XCTAssertTrue([userInfo[NSUnderlyingErrorKey] isKindOfClass:[NSDictionary class]]);
}

- (void)testDictionaryRepresentation_ShouldRemoveUnwantedData {
    
    NSDictionary *userInfo = [self.error YHV_dictionaryRepresentation][@"info"];
    
    XCTAssertNotNil(userInfo);
    XCTAssertNil(userInfo[NSURLErrorFailingURLPeerTrustErrorKey]);
    XCTAssertNil(userInfo[NSRecoveryAttempterErrorKey]);
}


#pragma mark - Tests :: Object from dictionary

- (void)testObjectFromDictionary_ShouldReturnNSError {
    
    XCTAssertTrue([[NSError YHV_objectFromDictionary:self.dictionaryRepresentation] isKindOfClass:[NSError class]]);
}

- (void)testObjectFromDictionary_ShouldProperlyDecodeOnRestore {
    
    XCTAssertEqualObjects([NSError YHV_objectFromDictionary:self.dictionaryRepresentation], self.expectedError);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenDictionaryIsNil {
    
    NSMutableDictionary *errorInfo = nil;
    
    XCTAssertThrowsSpecificNamed([NSError YHV_objectFromDictionary:errorInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenDomainIsMissing {
    
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [errorInfo removeObjectForKey:@"domain"];
    
    XCTAssertThrowsSpecificNamed([NSError YHV_objectFromDictionary:errorInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenErrorCodeIsMissing {
    
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionaryWithDictionary:self.dictionaryRepresentation];
    [errorInfo removeObjectForKey:@"code"];
    
    XCTAssertThrowsSpecificNamed([NSError YHV_objectFromDictionary:errorInfo], NSException, NSInternalInconsistencyException);
}

#pragma mark -


@end
