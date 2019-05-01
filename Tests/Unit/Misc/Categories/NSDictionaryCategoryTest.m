/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/NSDictionary+YHVNSURLRequest.h>
#import <YAHTTPVCR/NSDictionary+YHVNSURL.h>


#pragma mark Protected interface declaration

@interface NSDictionaryCategoryTest : XCTestCase


#pragma mark - Information

@property (nonatomic, copy) NSString *regularQueryString;
@property (nonatomic, copy) NSString *queryStringWithMissingValue;
@property (nonatomic, copy) NSString *queryStringWithUnsortedList;
@property (nonatomic, copy) NSString *queryStringWithMissingEqualSign;
@property (nonatomic, copy) NSString *queryStringWithJSONStringValue;
@property (nonatomic, copy) NSString *wwwFormURLEncodedString;
@property (nonatomic, copy) NSString *jsonBodyString;

@property (nonatomic, strong) NSDictionary *expectedForRegularQuery;
@property (nonatomic, strong) NSDictionary *expectedForQueryWithUnsortedList;
@property (nonatomic, strong) NSDictionary *expectedForQueryWithMissingValue;
@property (nonatomic, strong) NSDictionary *expectedForQueryWithMissingEqualSign;
@property (nonatomic, strong) NSDictionary *expectedForQueryWithJSONStringValue;
@property (nonatomic, strong) NSDictionary *expectedForWWWFormURLEncodedString;
@property (nonatomic, strong) NSDictionary *expectedForJSONBodyString;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation NSDictionaryCategoryTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSCharacterSet *charSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    self.queryStringWithUnsortedList = @"test=b_value,k_value,a_value";
    self.regularQueryString = @"test1=value1&test2=value2&test3=3";
    self.queryStringWithMissingValue = @"test1=value1&test2=&test3=value3";
    self.queryStringWithMissingEqualSign = @"test1=value1&test2=value2&test3";
    self.queryStringWithJSONStringValue = @"test1=value1&test2={\"title\":\"yet another http vcr\"}&test3=value3";
    self.wwwFormURLEncodedString = @"test1=value1&test2={\"title\":\"yet+another+http+vcr\"}&test3=value3";
    self.jsonBodyString = @"{\"title\":\"yet another http vcr\"}";
    self.regularQueryString = [self.regularQueryString stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    self.queryStringWithMissingValue = [self.queryStringWithMissingValue stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    self.queryStringWithMissingEqualSign = [self.queryStringWithMissingEqualSign stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    self.queryStringWithJSONStringValue = [self.queryStringWithJSONStringValue stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    self.wwwFormURLEncodedString = [self.wwwFormURLEncodedString stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    
    self.expectedForRegularQuery = @{ @"test1": @"value1", @"test2": @"value2", @"test3": @3 };
    self.expectedForQueryWithUnsortedList = @{ @"test": @"a_value,b_value,k_value" };
    self.expectedForQueryWithMissingValue = @{ @"test1": @"value1", @"test3": @"value3" };
    self.expectedForQueryWithMissingEqualSign = @{ @"test1": @"value1", @"test2": @"value2" };
    self.expectedForQueryWithJSONStringValue = @{ @"test1": @"value1", @"test2": @{ @"title" : @"yet another http vcr" }, @"test3": @"value3" };
    self.expectedForWWWFormURLEncodedString = @{ @"test1": @"value1", @"test2": @{ @"title" : @"yet another http vcr" }, @"test3": @"value3" };
    self.expectedForJSONBodyString = @{ @"title" : @"yet another http vcr" };
}


#pragma mark - Tests :: NSURL :: Query string

- (void)testDictionaryWithQuery_ShouldReturnNSDictionary {
  
    id dictionary = [NSDictionary YHV_dictionaryWithQuery:self.regularQueryString sortQueryListOnMatch:NO];
    XCTAssertTrue([dictionary isKindOfClass:[NSDictionary class]]);
}

- (void)testDictionaryWithQuery_ShouldReturnNSDictionary_WhenQueryNSStringPassed {
    
    XCTAssertEqualObjects([NSDictionary YHV_dictionaryWithQuery:self.regularQueryString sortQueryListOnMatch:NO],
                          self.expectedForRegularQuery);
}

- (void)testDictionaryWithQuery_ShouldIgnoreQueryParameter_WhenQueryParameterDoesntHaveValue {
    
    XCTAssertEqualObjects([NSDictionary YHV_dictionaryWithQuery:self.queryStringWithMissingValue sortQueryListOnMatch:NO],
                          self.expectedForQueryWithMissingValue);
}

- (void)testDictionaryWithQuery_ShouldIgnoreQueryParameter_WhenNoEualSignInPair {
    
    XCTAssertEqualObjects([NSDictionary YHV_dictionaryWithQuery:self.queryStringWithMissingEqualSign sortQueryListOnMatch:NO],
                          self.expectedForQueryWithMissingEqualSign);
}

- (void)testDictionaryWithQuery_ShouldJSONParseQueryValue_WhenJSONStringSetForQueryParameter {
    
    XCTAssertEqualObjects([NSDictionary YHV_dictionaryWithQuery:self.queryStringWithJSONStringValue sortQueryListOnMatch:NO],
                          self.expectedForQueryWithJSONStringValue);
}

- (void)testDictionaryWithQuery_ShouldMatchOrderedListSetToQueryParameter_WhenSortFlagIsSet {
  
  XCTAssertEqualObjects([NSDictionary YHV_dictionaryWithQuery:self.queryStringWithUnsortedList sortQueryListOnMatch:YES],
                        self.expectedForQueryWithUnsortedList);
}

- (void)testDictionaryWithQuery_ShouldNotMatchOrderedListSetToQueryParameter_WhenSortFlagIsSet {
  
  XCTAssertNotEqualObjects([NSDictionary YHV_dictionaryWithQuery:self.queryStringWithUnsortedList sortQueryListOnMatch:NO],
                           self.expectedForQueryWithUnsortedList);
}

- (void)testToQueryString_ShouldReturnNSString {
    
    XCTAssertTrue([[self.expectedForRegularQuery YHV_toQueryString] isKindOfClass:[NSString class]]);
}

- (void)testToQueryString_ShouldReturnQuery_WhenSimpleNSDictionaryPassed {
    
    XCTAssertEqualObjects([self.expectedForRegularQuery YHV_toQueryString], self.regularQueryString);
}

- (void)testToQueryString_ShouldReturnQuery_WhenNSDictionaryWithNestedDataPassed {
    
    XCTAssertEqualObjects([self.expectedForQueryWithJSONStringValue YHV_toQueryString], self.queryStringWithJSONStringValue);
}


#pragma mark - Tests :: NSURLRequest :: POST body

- (void)testDictionaryFromNSURLRequestPOSTBody_ShouldReturnNSDictionary_WhenRequestContainJSONPOSTBody {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    request.HTTPBody = [self.jsonBodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    
    NSDictionary *dictionary = [NSDictionary YHV_dictionaryFromNSURLRequestPOSTBody:request];
    
    XCTAssertTrue([dictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(dictionary, self.expectedForJSONBodyString);
}

- (void)testDictionaryFromNSURLRequestPOSTBody_ShouldReturnNSDictionary_WhenRequestContainWWWFormURLEncodedPOSTBody {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    request.HTTPBody = [self.wwwFormURLEncodedString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    
    NSDictionary *dictionary = [NSDictionary YHV_dictionaryFromNSURLRequestPOSTBody:request];
    
    XCTAssertTrue([dictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(dictionary, self.expectedForWWWFormURLEncodedString);
}

- (void)testDictionaryFromNSURLRequestPOSTBody_ShouldReturnNil_WhenRequestWithGETHTTPMethodPassed {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    
    XCTAssertNil([NSDictionary YHV_dictionaryFromNSURLRequestPOSTBody:request]);
}

- (void)testDictionaryFromNSURLRequestPOSTBody_ShouldReturnNil_WhenRequestWithUnknownContentTypePassed {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    [request setValue:@"Test-type" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [self.jsonBodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertNil([NSDictionary YHV_dictionaryFromNSURLRequestPOSTBody:request]);
}

- (void)testDictionaryFromDataForNSHTTPURLResponse_ShouldReturnNSDictionary_WhenRequestContainJSONPOSTBody {
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org"]
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/json" }];
    NSData *data = [self.jsonBodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dictionary = [NSDictionary YHV_dictionaryFromData:data forNSHTTPURLResponse:response];
    
    XCTAssertTrue([dictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(dictionary, self.expectedForJSONBodyString);
}

- (void)testDictionaryFromDataForNSHTTPURLResponse_ShouldReturnNSDictionary_WhenRequestContainWWWFormURLEncodedPOSTBody {
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org"]
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/x-www-form-urlencoded" }];
    NSData *data = [self.wwwFormURLEncodedString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dictionary = [NSDictionary YHV_dictionaryFromData:data forNSHTTPURLResponse:response];
    
    XCTAssertTrue([dictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(dictionary, self.expectedForWWWFormURLEncodedString);
}

- (void)testDictionaryFromDataForNSHTTPURLResponse_ShouldReturnNil_WhenRequestWithUnknownContentTypePassed {
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org"]
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"Test-type" }];
    NSData *data = [self.jsonBodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    XCTAssertNil([NSDictionary YHV_dictionaryFromData:data forNSHTTPURLResponse:response]);
}

- (void)testPOSTBodyForNSURLRequest_ShouldReturnNSData_WhenRequestContentTypeJSON {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    
    NSData *data = [self.expectedForJSONBodyString YHV_POSTBodyForNSURLRequest:request];
    
    XCTAssertTrue([data isKindOfClass:[NSData class]]);
    XCTAssertEqualObjects(data, [self.jsonBodyString dataUsingEncoding:NSUTF8StringEncoding]);
}

- (void)testPOSTBodyForNSURLRequest_ShouldReturnNSData_WhenRequestContentTypeWWWFormURLEncoded {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    
    NSData *data = [self.expectedForWWWFormURLEncodedString YHV_POSTBodyForNSURLRequest:request];
    
    XCTAssertTrue([data isKindOfClass:[NSData class]]);
    XCTAssertEqualObjects(data, [self.wwwFormURLEncodedString dataUsingEncoding:NSUTF8StringEncoding]);
}

- (void)testPOSTBodyForNSURLRequest_ShouldReturnNil_WhenRequestWithGETHTTPMethodPassed {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    
    XCTAssertNil([self.expectedForJSONBodyString YHV_POSTBodyForNSURLRequest:request]);
}

- (void)testPOSTBodyForNSURLRequest_ShouldReturnNil_WhenRequestWithUnknownContentTypePassed {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org"]];
    [request setValue:@"Test-type" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    
    XCTAssertNil([self.expectedForJSONBodyString YHV_POSTBodyForNSURLRequest:request]);
}

- (void)testDataForNSHTTPURLResponse_ShouldReturnNSData_WhenRequestContentTypeJSON {
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org"]
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/json" }];
    
    NSData *data = [self.expectedForJSONBodyString YHV_DataForNSHTTPURLResponse:response];
    
    XCTAssertTrue([data isKindOfClass:[NSData class]]);
    XCTAssertEqualObjects(data, [self.jsonBodyString dataUsingEncoding:NSUTF8StringEncoding]);
}

- (void)testDataForNSHTTPURLResponse_ShouldReturnNSData_WhenRequestContentTypeWWWFormURLEncoded {
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org"]
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"application/x-www-form-urlencoded" }];
    
    NSData *data = [self.expectedForWWWFormURLEncodedString YHV_DataForNSHTTPURLResponse:response];
    
    XCTAssertTrue([data isKindOfClass:[NSData class]]);
    XCTAssertEqualObjects(data, [self.wwwFormURLEncodedString dataUsingEncoding:NSUTF8StringEncoding]);
}

- (void)testDataForNSHTTPURLResponse_ShouldReturnNil_WhenRequestWithUnknownContentTypePassed {
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org"]
                                                              statusCode:200
                                                             HTTPVersion:nil
                                                            headerFields:@{ @"Content-Type": @"Test-type" }];
    
    XCTAssertNil([self.expectedForJSONBodyString YHV_DataForNSHTTPURLResponse:response]);
}

#pragma mark -


@end
