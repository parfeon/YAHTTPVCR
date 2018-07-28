/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/YHVSerializationHelper.h>


@interface YHVSerializationHelperTest : XCTestCase


#pragma mark - Information

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSDictionary *expectedDataDictionary;

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSDictionary *expectedArrayDictionary;


#pragma mark -


@end


@implementation YHVSerializationHelperTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
}


#pragma mark - Tests :: Dictionary representation

- (void)testDictionaryFromObject_ShouldReturnNSDictionary_WhenNSArrayPassed {
    
    NSArray *array = @[@"Some", @"value"];
    NSDictionary *expected = @{ @"cls": NSStringFromClass([NSArray class]), @"entries": @[@"Some", @"value"] };
    
    NSDictionary *dictionary = [YHVSerializationHelper dictionaryFromObject:(id)array];
    
    XCTAssertTrue([dictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(dictionary, expected);
}

- (void)testDictionaryFromObject_ShouldReturnNSDictionary_WhenNSDataPassed {
    
    NSData *data = [@"Yet Another HTTP VCR" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *expected = @{ @"base64": @"WWV0IEFub3RoZXIgSFRUUCBWQ1I=", @"cls": NSStringFromClass([NSData class]) };
    
    NSDictionary *dictionary = [YHVSerializationHelper dictionaryFromObject:(id)data];
    
    XCTAssertTrue([dictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(dictionary, expected);
}

- (void)testDictionaryFromObject_ShouldReturnNSDictionary_WhenNSErrorPassed {
    
    NSError *error = [NSError errorWithDomain:@"TestErrorDomain" code:-1000 userInfo:nil];
    NSDictionary *expected = @{ @"cls": NSStringFromClass([NSError class]), @"code": @(-1000), @"domain": @"TestErrorDomain", @"info": @{} };
    
    NSDictionary *dictionary = [YHVSerializationHelper dictionaryFromObject:(id)error];
    
    XCTAssertTrue([dictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(dictionary, expected);
}

- (void)testDictionaryFromObject_ShouldReturnNSDictionary_WhenNSHTTPURLResponsePassed {
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    NSDictionary *expected = @{
        @"cls": NSStringFromClass([NSHTTPURLResponse class]),
        @"url": response.URL.absoluteString,
        @"headers": response.allHeaderFields,
        @"status": @(response.statusCode)
    };
    
    NSDictionary *dictionary = [YHVSerializationHelper dictionaryFromObject:(id)response];
    
    XCTAssertTrue([dictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(dictionary, expected);
}

- (void)testDictionaryFromObject_ShouldReturnNSDictionary_WhenNSURLRequestPassed {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/16"]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:16.f];
    request.allowsCellularAccess = NO;
    request.HTTPShouldHandleCookies = NO;
    
    NSDictionary *expected = @{
        @"cls": NSStringFromClass([NSURLRequest class]),
        @"url": request.URL.absoluteString,
        @"method": @"get",
        @"cache": @(request.cachePolicy),
        @"timeout": @(request.timeoutInterval),
        @"cookies": @NO,
        @"pipeline": @NO,
        @"cellular": @NO,
        @"network": @(NSURLNetworkServiceTypeDefault)
    };
    
    NSDictionary *dictionary = [YHVSerializationHelper dictionaryFromObject:(id)request];
    
    XCTAssertTrue([dictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(dictionary, expected);
}


#pragma mark - Tests :: Dictionary representation

- (void)testObjectFromDictionary_ShouldReturnNSArray {
    
    NSDictionary *dictionary = @{ @"cls": NSStringFromClass([NSArray class]), @"entries": @[@"Some", @"value"] };
    NSArray *expected = @[@"Some", @"value"];
    
    NSArray *array = (id)[YHVSerializationHelper objectFromDictionary:dictionary];
    
    XCTAssertTrue([array isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(array, expected);
}

- (void)testObjectFromDictionary_ShouldReturnNSData {
    
    NSDictionary *dictionary = @{ @"base64": @"WWV0IEFub3RoZXIgSFRUUCBWQ1I=", @"cls": NSStringFromClass([NSData class]) };
    NSData *expected = [@"Yet Another HTTP VCR" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = (id)[YHVSerializationHelper objectFromDictionary:dictionary];
    
    XCTAssertTrue([data isKindOfClass:[NSData class]]);
    XCTAssertEqualObjects(data, expected);
}

- (void)testObjectFromDictionary_ShouldReturnNSError {
    
    NSDictionary *dictionary = @{ @"cls": NSStringFromClass([NSError class]), @"code": @(-1000), @"domain": @"TestErrorDomain", @"info": @{} };
    NSError *expected = [NSError errorWithDomain:@"TestErrorDomain" code:-1000 userInfo:nil];
    
    NSError *error = (id)[YHVSerializationHelper objectFromDictionary:dictionary];
    
    XCTAssertTrue([error isKindOfClass:[NSError class]]);
    XCTAssertEqualObjects(error, expected);
}

- (void)testObjectFromDictionary_ShouldReturnNSDictionary_WhenNSHTTPURLResponsePassed {
    
    NSHTTPURLResponse *expected = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    NSDictionary *dictionary = @{
        @"cls": NSStringFromClass([NSHTTPURLResponse class]),
        @"url": expected.URL.absoluteString,
        @"headers": expected.allHeaderFields,
        @"status": @(expected.statusCode)
    };
    
    NSHTTPURLResponse *response = (id)[YHVSerializationHelper objectFromDictionary:dictionary];
    
    XCTAssertTrue([response isKindOfClass:[NSHTTPURLResponse class]]);
    XCTAssertEqualObjects(response.URL, expected.URL);
    XCTAssertEqual(response.statusCode, expected.statusCode);
    XCTAssertEqualObjects(response.allHeaderFields, expected.allHeaderFields);
}

- (void)testObjectFromDictionary_ShouldReturnNSURLRequest {
    
    NSMutableURLRequest *expected = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/16"]
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:16.f];
    expected.allowsCellularAccess = NO;
    expected.HTTPShouldHandleCookies = NO;
    
    NSDictionary *dictionary = @{
        @"cls": NSStringFromClass([NSURLRequest class]),
        @"url": expected.URL.absoluteString,
        @"method": @"get",
        @"cache": @(expected.cachePolicy),
        @"timeout": @(expected.timeoutInterval),
        @"cookies": @NO,
        @"pipeline": @NO,
        @"cellular": @NO,
        @"network": @(NSURLNetworkServiceTypeDefault)
    };
    
    NSDictionary *request = (id)[YHVSerializationHelper objectFromDictionary:dictionary];
    
    XCTAssertTrue([request isKindOfClass:[NSURLRequest class]]);
    XCTAssertEqualObjects(request, expected);
}

#pragma mark -


@end
