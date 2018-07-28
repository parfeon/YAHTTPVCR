/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/NSURLSessionConfiguration+YHVNSURLProtocol.h>
#import <YAHTTPVCR/YHVNSURLProtocol.h>


#pragma mark Protected interface declaration

@interface NSURLSessionConfigurationCategoryTest : XCTestCase


#pragma mark - 


@end


#pragma mark - Interface implementation

@implementation NSURLSessionConfigurationCategoryTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    [YHVNSURLSessionConfiguration injectProtocol];
}


#pragma mark - Tests :: Custom protocol

- (void)testBackgroundSessionConfiguration_ShouldAddCustomProtocol {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"test"];
#pragma GCC diagnostic pop
    
    XCTAssertTrue([configuration.protocolClasses containsObject:[YHVNSURLProtocol class]]);
}

- (void)testBackgroundSessionConfigurationWithIdentifier_ShouldAddCustomProtocol {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"test"];
    
    XCTAssertTrue([configuration.protocolClasses containsObject:[YHVNSURLProtocol class]]);
}

- (void)testDefaultSessionConfiguration_ShouldAddCustomProtocol {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    XCTAssertTrue([configuration.protocolClasses containsObject:[YHVNSURLProtocol class]]);
}

- (void)testEphemeralSessionConfiguration_ShouldAddCustomProtocol {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    XCTAssertTrue([configuration.protocolClasses containsObject:[YHVNSURLProtocol class]]);
}

- (void)testSessionConfigurationForSharedSession_ShouldAddCustomProtocol {
    
    SEL selector = NSSelectorFromString(@"sessionConfigurationForSharedSession");
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration performSelector:selector];
    
    XCTAssertTrue([configuration.protocolClasses containsObject:[YHVNSURLProtocol class]]);
}

#pragma mark -


@end
