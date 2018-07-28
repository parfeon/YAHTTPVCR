/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/YHVRequestMatchers.h>


@interface YHVRequestMatchersTest : XCTestCase


#pragma mark - Information


#pragma mark -


@end


@implementation YHVRequestMatchersTest


#pragma mark - Tests :: HTTP method

- (void)testHTTPMethod_ShouldMatch_WhenTwoRequestsHasSameHTTPMethod {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    
    XCTAssertTrue(YHVRequestMatchers.method(request1, request2));
}

- (void)testHTTPMethod_ShouldNotMatch_WhenTwoRequestsHasDifferentHTTPMethod {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    request2.HTTPMethod = @"POST";
    
    XCTAssertFalse(YHVRequestMatchers.method(request1, request2));
}

- (void)testHTTPMethod_ShouldNotMatch_WhenOneOfRequestsIsMissing {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = nil;
    
    XCTAssertFalse(YHVRequestMatchers.method(request1, request2));
}


#pragma mark - Tests :: URI

- (void)testURI_ShouldMatch_WhenTwoRequestsHasSameURI {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    
    XCTAssertTrue(YHVRequestMatchers.uri(request1, request2));
}

- (void)testURI_ShouldMatch_WhenTwoRequestsHasSameURIAndJSONInQuery {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1?data=%7B%22field1%22%3A%22value1%22%2C%22field2%22%3A%22value2%22%7D"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1?data=%7B%22field2%22%3A%22value2%22%2C%22field1%22%3A%22value1%22%7D"]];
    
    XCTAssertTrue(YHVRequestMatchers.uri(request1, request2));
}

- (void)testURI_ShouldNotMatch_WhenTwoRequestsHasDifferentURI {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    
    XCTAssertFalse(YHVRequestMatchers.uri(request1, request2));
}

- (void)testURI_ShouldNotMatch_WhenTwoRequestsHasSameURIAndDifferentJSONInQuery {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1?data=%7B%22field1%22%3A%22value1%22%2C%22field2%22%3A%22value2%22%7D"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1?data=%7B%22field2%22%3A%22value3%22%2C%22field1%22%3A%22value1%22%7D"]];
    
    XCTAssertFalse(YHVRequestMatchers.uri(request1, request2));
}

- (void)testURI_ShouldNotMatch_WhenOneOfRequestsIsMissing {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = nil;
    
    XCTAssertFalse(YHVRequestMatchers.uri(request1, request2));
}


#pragma mark - Tests :: Scheme

- (void)testScheme_ShouldMatch_WhenTwoRequestsHasSameScheme {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    
    XCTAssertTrue(YHVRequestMatchers.scheme(request1, request2));
}

- (void)testScheme_ShouldNotMatch_WhenTwoRequestsHasDifferentScheme {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://httpbin.org/2"]];
    
    XCTAssertFalse(YHVRequestMatchers.scheme(request1, request2));
}

- (void)testScheme_ShouldNotMatch_WhenOneOfRequestsIsMissing {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = nil;
    
    XCTAssertFalse(YHVRequestMatchers.scheme(request1, request2));
}


#pragma mark - Tests :: Host

- (void)testHost_ShouldMatch_WhenTwoRequestsHasSameScheme {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    
    XCTAssertTrue(YHVRequestMatchers.host(request1, request2));
}

- (void)testHost_ShouldNotMatch_WhenTwoRequestsHasDifferentScheme {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://httpbin.com/2"]];
    
    XCTAssertFalse(YHVRequestMatchers.host(request1, request2));
}

- (void)testHost_ShouldNotMatch_WhenOneOfRequestsIsMissing {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = nil;
    
    XCTAssertFalse(YHVRequestMatchers.host(request1, request2));
}


#pragma mark - Tests :: Port

- (void)testPort_ShouldMatch_WhenTwoRequestsDoesntHasPorts {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    
    XCTAssertTrue(YHVRequestMatchers.port(request1, request2));
}

- (void)testPort_ShouldMatch_WhenTwoRequestsHasSamePort {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:80/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:80/2"]];
    
    XCTAssertTrue(YHVRequestMatchers.port(request1, request2));
}

- (void)testPort_ShouldNotMatch_WhenTwoRequestsHasDifferentPorts {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:8080/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://httpbin.com:80/2"]];
    
    XCTAssertFalse(YHVRequestMatchers.port(request1, request2));
}

- (void)testPort_ShouldNotMatch_WhenOneOfRequestsIsMissing {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:8080/1"]];
    NSURLRequest *request2 = nil;
    
    XCTAssertFalse(YHVRequestMatchers.port(request1, request2));
}


#pragma mark - Tests :: Path

- (void)testPath_ShouldMatch_WhenTwoRequestsDoesntHasPath {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    
    XCTAssertTrue(YHVRequestMatchers.path(request1, request2));
}

- (void)testPath_ShouldMatch_WhenTwoRequestsHasSamePath {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:80/absolute-redirect/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:81/absolute-redirect/1"]];
    
    XCTAssertTrue(YHVRequestMatchers.path(request1, request2));
}

- (void)testPath_ShouldNotMatch_WhenTwoRequestsHasDifferentPaths {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:8080/absolute-redirect/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://httpbin.com:80/absolute-redirect/2"]];
    
    XCTAssertFalse(YHVRequestMatchers.path(request1, request2));
}

- (void)testPath_ShouldNotMatch_WhenOneOfRequestsIsMissing {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:8080/absolute-redirect/1"]];
    NSURLRequest *request2 = nil;
    
    XCTAssertFalse(YHVRequestMatchers.path(request1, request2));
}


#pragma mark - Tests :: Query

- (void)testQuery_ShouldMatch_WhenTwoRequestsDoesntHasQuery {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:80/absolute-redirect/1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:81/absolute-redirect/1"]];
    
    XCTAssertTrue(YHVRequestMatchers.query(request1, request2));
}

- (void)testQuery_ShouldMatch_WhenTwoRequestsHasSameQuery {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:80/absolute-redirect/1?message=hello"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:8080/absolute-redirect/1?message=hello"]];
    
    XCTAssertTrue(YHVRequestMatchers.query(request1, request2));
}

- (void)testQuery_ShouldMatch_WhenTwoRequestsHasSameQueryAndJSONValues {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:80/absolute-redirect/3?message=hello&data=%7B%22field1%22%3A%22value1%22%2C%22field2%22%3A%22value2%22%7D"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:80/absolute-redirect/1?message=hello&data=%7B%22field2%22%3A%22value2%22%2C%22field1%22%3A%22value1%22%7D"]];
    
    XCTAssertTrue(YHVRequestMatchers.query(request1, request2));
}

- (void)testQuery_ShouldNotMatch_WhenTwoRequestsHasDifferentQuery {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:8080/absolute-redirect/1?message=hello1"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://httpbin.com:80/absolute-redirect/2?message=hello2"]];
    
    XCTAssertFalse(YHVRequestMatchers.query(request1, request2));
}

- (void)testQuery_ShouldNotMatch_WhenTwoRequestsHasSameQueryAndDifferentJSONValues {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:80/absolute-redirect/1?message=hello&data=%7B%22field1%22%3A%22value1%22%2C%22field2%22%3A%22value2%22%7D"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:80/absolute-redirect/2?message=hello&data=%7B%22field2%22%3A%22value3%22%2C%22field1%22%3A%22value1%22%7D"]];
    
    XCTAssertFalse(YHVRequestMatchers.query(request1, request2));
}

- (void)testQuery_ShouldNotMatch_WhenOneOfRequestsIsMissing {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org:8080/absolute-redirect/1?message=hello"]];
    NSURLRequest *request2 = nil;
    
    XCTAssertFalse(YHVRequestMatchers.query(request1, request2));
}


#pragma mark - Tests :: Headers

- (void)testHeaders_ShouldMatch_WhenTwoRequestsDoesntHasHeaders {
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    NSURLRequest *request2 = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    
    XCTAssertTrue(YHVRequestMatchers.headers(request1, request2));
}

- (void)testHeaders_ShouldMatch_WhenTwoRequestsHasSameHeaders {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    [request1 setAllHTTPHeaderFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    [request2 setAllHTTPHeaderFields:request1.allHTTPHeaderFields];
    
    XCTAssertTrue(YHVRequestMatchers.headers(request1, request2));
}

- (void)testHeaders_ShouldNotMatch_WhenTwoRequestsHasDifferentHeaders {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/absolute-redirect/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://httpbin.com/absolute-redirect/2"]];
    [request1 setAllHTTPHeaderFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    [request2 setAllHTTPHeaderFields:@{ @"Content-Type": @"application/x-www-form-urlencoded", @"Accept": @"*/*" }];
    
    XCTAssertFalse(YHVRequestMatchers.headers(request1, request2));
}

- (void)testHeaders_ShouldNotMatch_WhenOneOfRequestsIsMissing {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    [request1 setAllHTTPHeaderFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    NSURLRequest *request2 = nil;
    
    XCTAssertFalse(YHVRequestMatchers.headers(request1, request2));
}


#pragma mark - Tests :: Body

- (void)testBody_ShouldMatch_WhenTwoRequestsDoesntHasBody {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    request1.HTTPMethod = @"POST";
    request2.HTTPMethod = @"POST";
    
    XCTAssertTrue(YHVRequestMatchers.body(request1, request2));
}

- (void)testBody_ShouldMatch_WhenTwoRequestsHasSameBody {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    request1.HTTPMethod = @"POST";
    request2.HTTPMethod = @"POST";
    request1.HTTPBody = [@"Yet Another HTTP VCR" dataUsingEncoding:NSUTF8StringEncoding];
    request2.HTTPBody = request1.HTTPBody;
    
    XCTAssertTrue(YHVRequestMatchers.body(request1, request2));
}

- (void)testBody_ShouldMatch_WhenTwoRequestsHasSameJSONBody {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    [request1 setAllHTTPHeaderFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    [request2 setAllHTTPHeaderFields:request1.allHTTPHeaderFields];
    request1.HTTPMethod = @"POST";
    request2.HTTPMethod = @"POST";
    request1.HTTPBody = [@"{\"field1\":\"value1\",\"field2\":\"value2\"}" dataUsingEncoding:NSUTF8StringEncoding];
    request2.HTTPBody = [@"{\"field2\":\"value2\",\"field1\":\"value1\"}" dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertTrue(YHVRequestMatchers.body(request1, request2));
}

- (void)testBody_ShouldMatch_WhenTwoRequestsHasSameWWWFormURLEncodedBody {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    [request1 setAllHTTPHeaderFields:@{ @"Content-Type": @"application/x-www-form-urlencoded", @"Accept": @"*/*" }];
    [request2 setAllHTTPHeaderFields:request1.allHTTPHeaderFields];
    request1.HTTPMethod = @"POST";
    request2.HTTPMethod = @"POST";
    request1.HTTPBody = [@"field1=value1&field2=value+2" dataUsingEncoding:NSUTF8StringEncoding];
    request2.HTTPBody = [@"field2=value+2&field1=value1" dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertTrue(YHVRequestMatchers.body(request1, request2));
}

- (void)testBody_ShouldNotMatch_WhenTwoRequestsHasDifferentBody {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    request1.HTTPMethod = @"POST";
    request2.HTTPMethod = @"POST";
    request1.HTTPBody = [@"Yet Another HTTP VCR" dataUsingEncoding:NSUTF8StringEncoding];
    request2.HTTPBody = [@"Yet Another Simple HTTP VCR" dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertFalse(YHVRequestMatchers.body(request1, request2));
}

- (void)testBody_ShouldNotMatch_WhenTwoRequestsHasDifferentJSONBody {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    [request1 setAllHTTPHeaderFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    [request2 setAllHTTPHeaderFields:request1.allHTTPHeaderFields];
    request1.HTTPMethod = @"POST";
    request2.HTTPMethod = @"POST";
    request1.HTTPBody = [@"{\"field1\":\"value1\",\"field2\":\"value2\"}" dataUsingEncoding:NSUTF8StringEncoding];
    request2.HTTPBody = [@"{\"field2\":\"value3\",\"field1\":\"value1\"}" dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertFalse(YHVRequestMatchers.body(request1, request2));
}

- (void)testBody_ShouldNotMatch_WhenTwoRequestsHasDifferentWWWFormURLEncodedBody {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]];
    [request1 setAllHTTPHeaderFields:@{ @"Content-Type": @"application/x-www-form-urlencoded", @"Accept": @"*/*" }];
    [request2 setAllHTTPHeaderFields:request1.allHTTPHeaderFields];
    request1.HTTPMethod = @"POST";
    request2.HTTPMethod = @"POST";
    request1.HTTPBody = [@"field1=value1&field2=value+2" dataUsingEncoding:NSUTF8StringEncoding];
    request2.HTTPBody = [@"field2=value+2&field1=value+1" dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertFalse(YHVRequestMatchers.body(request1, request2));
}

- (void)testBody_ShouldNotMatch_WhenOneOfRequestsIsMissing {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]];
    request1.HTTPBody = [@"{\"field1\":\"value1\",\"field2\":\"value2\"}" dataUsingEncoding:NSUTF8StringEncoding];
    [request1 setAllHTTPHeaderFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    request1.HTTPMethod = @"POST";
    NSURLRequest *request2 = nil;
    
    XCTAssertFalse(YHVRequestMatchers.body(request1, request2));
}


#pragma mark - Tests :: Match on set

- (void)testMatchersList_ShouldMatch_WhenRequestsHasSameMethodPathAndHeaders {
    
    NSArray *matchers = @[YHVRequestMatchers.method, YHVRequestMatchers.path, YHVRequestMatchers.headers];
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/absolute-redirect/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/absolute-redirect/1"]];
    [request1 setAllHTTPHeaderFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    [request2 setAllHTTPHeaderFields:request1.allHTTPHeaderFields];
    
    XCTAssertTrue([YHVRequestMatchers request:request1 isMatchingTo:request2 withMatchers:matchers]);
}

- (void)testMatchersList_ShouldMatch_WhenEmptyMatchersListPassed {
    
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/absolute-redirect/1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/absolute-redirect/2"]];
    
    XCTAssertTrue([YHVRequestMatchers request:request1 isMatchingTo:request2 withMatchers:@[]]);
}

- (void)testMatchersList_ShouldNotMatch_WhenRequestsHasSameMethodPathAndDifferentQuery {
    
    NSArray *matchers = @[YHVRequestMatchers.method, YHVRequestMatchers.path, YHVRequestMatchers.query];
    NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/absolute-redirect/1?message=hello1"]];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/absolute-redirect/1?message=hello2"]];
    [request1 setAllHTTPHeaderFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    [request2 setAllHTTPHeaderFields:request1.allHTTPHeaderFields];
    
    XCTAssertFalse([YHVRequestMatchers request:request1 isMatchingTo:request2 withMatchers:matchers]);
}

#pragma mark -


@end
