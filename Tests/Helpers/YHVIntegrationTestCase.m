/**
 * @author Serhii Mamontov
 */
#import "YHVIntegrationTestCase.h"
#import <YAHTTPVCR/NSMutableDictionary+YHVMisc.h>
#import <YAHTTPVCR/YHVConfiguration+Private.h>
#import <YAHTTPVCR/NSDictionary+YHVNSURL.h>
#import <YAHTTPVCR/YHVCassette+Private.h>
#import <YAHTTPVCR/YHVScene.h>


#pragma mark Protected interface declaration

@interface YHVIntegrationTestCase ()


#pragma mark - Information

@property (nonatomic, copy) NSString *serviceURI;

@property (nonatomic, copy) NSDictionary *requestQuery;
@property (nonatomic, copy) NSDictionary *queryParametersFilter;
@property (nonatomic, copy) NSDictionary *expectedQuery;

@property (nonatomic, copy) NSDictionary *headers;
@property (nonatomic, copy) NSDictionary *headersFilter;
@property (nonatomic, copy) NSDictionary *expectedHeaders;

@property (nonatomic, copy) NSDictionary *postBody;
@property (nonatomic, copy) NSDictionary *postBodyFilter;
@property (nonatomic, copy) NSDictionary *expectedPostBody;

@property (nonatomic, copy) YHVResponseBodyFilterBlock responseBodyFilter;

@property (nonatomic, strong) NSURLSession *session;


#pragma mark - Request processing

/**
 * @brief      Send set of \c requests which will be cancelled after specified \c interval \a NSURLSession.
 * @discussion Send asynchronous \c requests and cancel them after specified amount of time.
 *
 * @param requests Reference on requests list which should be processed.
 * @param interval Interval after which request should be cancelled.
 * @param block    Reference on request processing completion block which should be used to verify results. Block will be called for each
 *                 request.
 */
- (void)NSURLSessionSendRequests:(NSArray<NSURLRequest *> *)requests
           withCancellationAfter:(NSTimeInterval)interval
         resultVerificationBlock:(nullable YHVVerificationBlock)block;

#pragma mark -


@end


@implementation YHVIntegrationTestCase


#pragma mark - Configuration

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    
    [super updateVCRConfigurationFromDefaultConfiguration:configuration];
    
    configuration.queryParametersFilter = self.queryParametersFilter;
    configuration.headersFilter = self.headersFilter;
    configuration.postBodyFilter = self.postBodyFilter;
    configuration.responseBodyFilter = self.responseBodyFilter;
    configuration.matchers = @[YHVMatcher.method, YHVMatcher.scheme, YHVMatcher.host, YHVMatcher.port, YHVMatcher.path, YHVMatcher.query,
                               YHVMatcher.body];
}


#pragma mark - Request configuration

- (NSMutableURLRequest *)GETRequestWithPath:(NSString *)path {
    
    return [self addHeadersToRequest:[NSMutableURLRequest requestWithURL:[self GETURIWithPath:path]]];
}

- (NSMutableURLRequest *)POSTRequestWithPath:(NSString *)path {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self POSTURIWithPath:path]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:self.postBody options:(NSJSONWritingOptions)0 error:nil];
    
    return [self addHeadersToRequest:request];
}

- (NSMutableURLRequest *)addHeadersToRequest:(NSMutableURLRequest *)request {
    
    for (NSString *headerName in self.headers) {
        [request setValue:self.headers[headerName] forHTTPHeaderField:headerName];
    }
    
    return request;
}

- (NSURL *)GETURIWithPath:(NSString *)path {
    
    path = [path hasPrefix:@"/"] ? path : [@"/" stringByAppendingString:path];
    
    return [NSURL URLWithString:[@[self.serviceURI, path, @"?", [self.requestQuery YHV_toQueryString]] componentsJoinedByString:@""]];
}

- (NSURL *)POSTURIWithPath:(NSString *)path {
    
    path = [path hasPrefix:@"/"] ? path : [@"/" stringByAppendingString:path];
    
    return [NSURL URLWithString:[@[self.serviceURI, path] componentsJoinedByString:@""]];
}


#pragma mark - Setup / Tear down

- (void)setUp {
    
    self.serviceURI = @"https://httpbin.org";
    
    // Query parameters configuration.
    self.requestQuery = @{ @"queryField1": [NSUUID UUID].UUIDString, @"queryField2": @"queryValue2", @"queryField3": @"queryValue3" };
    self.queryParametersFilter = @{ @"queryField1": @"secret-query-value", @"queryField2": [NSNull null] };
    self.expectedQuery = [[self.requestQuery mutableCopy] YHV_replaceValuesWithValuesFromDictionary:self.queryParametersFilter];
    
    // Headers configuration.
    self.headers = @{ @"Content-Type": @"application/json", @"Authorization": @"Basic 1234567890", @"User-Agent": @"YHVVCR" };
    self.headersFilter = @{ @"Authorization": @"Basic secret-authorization-value", @"User-Agent": @"YHVVCR2" };
    self.expectedHeaders = [[self.headers mutableCopy] YHV_replaceValuesWithValuesFromDictionary:self.headersFilter];
    
    // POST body configuration.
    self.postBody = @{ @"postBodyField1": [NSUUID UUID].UUIDString, @"postBodyField2": @"postBodyValue2", @"postBodyField3": @"postBodyValue3" };
    self.postBodyFilter = @{ @"postBodyField1": @"secret-post-body-value", @"postBodyField3": [NSNull null] };
    self.expectedPostBody = [[self.postBody mutableCopy] YHV_replaceValuesWithValuesFromDictionary:self.postBodyFilter];
    
    // Response body configuration.
    __weak __typeof__(self) weakSelf = self;
    self.responseBodyFilter = ^NSData * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
        NSMutableDictionary *sentData = nil;
        NSData *filteredData = data;
        
        if (![((NSString *)response.allHeaderFields[@"Content-Type"]).lowercaseString isEqualToString:@"application/json"] || !data) {
            return filteredData;
        }
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if ([request.HTTPMethod.lowercaseString isEqualToString:@"get"]) {
            sentData = [responseBody[@"args"] mutableCopy];
            [sentData YHV_replaceValuesWithValuesFromDictionary:weakSelf.queryParametersFilter];
        } else if ([request.HTTPMethod.lowercaseString isEqualToString:@"post"]) {
            if (responseBody[@"data"]) {
                NSData *postData = [(NSString *)responseBody[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                sentData = [[NSJSONSerialization JSONObjectWithData:postData options:NSJSONReadingAllowFragments error:nil] mutableCopy];
                [sentData YHV_replaceValuesWithValuesFromDictionary:weakSelf.postBodyFilter];
            } else {
                sentData = [responseBody mutableCopy];
            }
        }
        
        return sentData ? [NSJSONSerialization dataWithJSONObject:sentData options:(NSJSONWritingOptions)0 error:nil] : filteredData;
#pragma clang diagnostic pop
    };
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPMaximumConnectionsPerHost = 10;
    self.session = [NSURLSession sessionWithConfiguration:configuration];
    
    [super setUp];
}


#pragma mark - Request processing

- (void)NSURLSessionSendRequest:(NSURLRequest *)request withResultVerificationBlock:(YHVVerificationBlock)block {
    
    [self NSURLSessionSendRequests:@[request] withResultVerificationBlock:block];
}

- (void)NSURLConnectionSendRequest:(NSURLRequest *)request
                     synchronously:(BOOL)synchronously
       withResultVerificationBlock:(YHVVerificationBlock)block {
    
    [self NSURLConnectionSendRequests:@[request] synchronously:synchronously withResultVerificationBlock:block];
}

- (void)NSURLSessionSendRequests:(NSArray<NSURLRequest *> *)requests withResultVerificationBlock:(YHVVerificationBlock)block {
    
    [self NSURLSessionSendRequests:requests withCancellationAfter:-1.f resultVerificationBlock:block];
}

- (void)NSURLConnectionSendRequests:(NSArray<NSURLRequest *> *)requests
                      synchronously:(BOOL)synchronously
        withResultVerificationBlock:(YHVVerificationBlock)block {
    
    NSOperationQueue *connectionQueue = [[NSOperationQueue alloc] init];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSUInteger completedRequests = 0;
    __block BOOL httpContainerError = NO;
    __block NSError *requestError = nil;
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    for (NSURLRequest *request in requests) {
        
        void(^handlerBlock)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!httpContainerError && ((NSHTTPURLResponse *)response).statusCode >= 500) {
                httpContainerError = YES;
                requestError = connectionError;
            }
            
            completedRequests++;
            
            if (block && ((NSHTTPURLResponse *)response).statusCode < 500) {
                block(request, (NSHTTPURLResponse *)response, data, connectionError);
            }
            
            if (!synchronously && completedRequests == requests.count) {
                dispatch_semaphore_signal(semaphore);
            }
        };
        
        if (synchronously) {
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            handlerBlock(response, data, error);
        } else {
            [NSURLConnection sendAsynchronousRequest:request queue:connectionQueue completionHandler:handlerBlock];
        }
    }
#pragma GCC diagnostic pop
    
    if (!synchronously) {
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.f * NSEC_PER_SEC)));
    }
    
    if (httpContainerError) {
        NSLog(@"[%@] Error: %@", self.serviceURI, requestError);
        
        return;
    }
    
    if (YHVVCR.cassette && !YHVVCR.cassette.isNewCassette) {
        XCTAssertTrue(YHVVCR.cassette.allPlayed);
    }
}

- (void)NSURLSessionSendRequest:(NSURLRequest *)request
          withCancellationAfter:(NSTimeInterval)interval
        resultVerificationBlock:(YHVVerificationBlock)block {
    
    [self NSURLSessionSendRequests:@[request] withCancellationAfter:interval resultVerificationBlock:block];
}

- (void)NSURLSessionSendRequests:(NSArray<NSURLRequest *> *)requests
           withCancellationAfter:(NSTimeInterval)interval
         resultVerificationBlock:(YHVVerificationBlock)block {
    
    NSMutableArray<NSURLSessionDataTask *> *tasks = [NSMutableArray new];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSUInteger completedTasks = 0;
    __block BOOL httpContainerError = NO;
    __block NSError *requestError = nil;
    NSURLSessionDataTask *task = nil;
    
    for (NSURLRequest *request in requests) {
        task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!httpContainerError && ((NSHTTPURLResponse *)response).statusCode >= 500) {
                httpContainerError = YES;
                requestError = error;
            }
            
            completedTasks++;
            
            if (block && ((NSHTTPURLResponse *)response).statusCode < 500) {
                block(request, (NSHTTPURLResponse *)response, data, error);
            }
            
            if (completedTasks == requests.count) {
                dispatch_semaphore_signal(semaphore);
            }
        }];
        
        [tasks addObject:task];
        [task resume];
    }
    
    if (interval > 0.f) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), queue, ^{
            [tasks makeObjectsPerformSelector:@selector(cancel)];
        });
    }
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.f * NSEC_PER_SEC)));
    
    if (httpContainerError) {
        NSLog(@"[%@] Error: %@", self.serviceURI, requestError);
        
        return;
    }
    
    if (YHVVCR.cassette && !YHVVCR.cassette.isNewCassette) {
        XCTAssertTrue(YHVVCR.cassette.allPlayed);
    }
}


#pragma mark - Cassette

- (void)assertResponse:(NSHTTPURLResponse *)response playedForRequest:(NSURLRequest *)request withData:(NSData *)data {
    
    NSData *matchedBody = self.responseBodyFilter(request, response, data);
    
    XCTAssertTrue([data isEqual:matchedBody], @"Response body not played from cassette.");
}

- (void)assertRequestWritten:(NSURLRequest *)request {
    
    NSURLRequest *cassettesRequest = (NSURLRequest *)YHVVCR.cassette.availableScenes.firstObject.data;
    
    XCTAssertTrue([cassettesRequest isKindOfClass:[NSURLRequest class]]);
    if (![cassettesRequest isKindOfClass:[NSURLRequest class]]) {
        return;
    }
    
    NSURLRequest *matchedRequest = ((YHVBeforeRecordRequestBlock)YHVVCR.cassette.configuration.beforeRecordRequest)(request);
    
    XCTAssertTrue([cassettesRequest isEqual:matchedRequest], @"Request not stored on cassette.");
    XCTAssertNotEqual(matchedRequest, request);
}

- (void)assertRequest:(NSURLRequest *)request responseWritten:(NSHTTPURLResponse *)response {
    
    __block NSHTTPURLResponse *cassettesResponse = nil;
    [YHVVCR.cassette.availableScenes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(YHVScene *obj, NSUInteger idx, BOOL *stop) {
        if (obj.type == YHVResponseScene) {
            cassettesResponse = (NSHTTPURLResponse *)obj.data;
        }
        
        *stop = cassettesResponse != nil;
    }];
    
    XCTAssertTrue([cassettesResponse isKindOfClass:[NSHTTPURLResponse class]]);
    if (![cassettesResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        return;
    }
    
    NSMutableDictionary *matchedHeaders = [response.allHeaderFields mutableCopy];
    NSURL *url = YHVVCR.cassette.configuration.urlFilter(request, response.URL);
    ((YHVHeadersFilterBlock)YHVVCR.cassette.configuration.headersFilter)(request, matchedHeaders);
    
    NSHTTPURLResponse *matchedResponse = [[NSHTTPURLResponse alloc] initWithURL:url
                                                                     statusCode:response.statusCode
                                                                    HTTPVersion:@"HTTP/1.1"
                                                                   headerFields:matchedHeaders];
    
    BOOL written = ([cassettesResponse.URL isEqual:matchedResponse.URL] &&
                    [cassettesResponse.allHeaderFields isEqual:matchedResponse.allHeaderFields] &&
                    cassettesResponse.statusCode == matchedResponse.statusCode);

    XCTAssertTrue(written, @"Response not saved on cassette.");
    if (![request.HTTPMethod.lowercaseString isEqualToString:@"post"]) {
        XCTAssertTrue(![matchedResponse.URL isEqual:response.URL]);
    }
}

- (void)assertResponse:(NSHTTPURLResponse *)response bodyWritten:(NSData *)data {
    
    NSURLRequest *cassettesRequest = (NSURLRequest *)YHVVCR.cassette.availableScenes.firstObject.data;
    NSData *cassettesResponseData = (NSData *)YHVVCR.cassette.availableScenes[YHVVCR.cassette.availableScenes.count - 2].data;
    
    XCTAssertTrue([cassettesResponseData isKindOfClass:[NSData class]]);
    if (![cassettesResponseData isKindOfClass:[NSData class]]) {
        return;
    }
    
    NSData *matchedBody = self.responseBodyFilter(cassettesRequest, response, data);
    
    XCTAssertTrue([cassettesResponseData isEqual:matchedBody], @"Response body not stored on cassette.");
    XCTAssertFalse([matchedBody isEqual:data]);
}

- (void)assertRequest:(NSURLRequest *)request errorWritten:(NSError *)error {
    
    NSError *cassettesRequestError = (NSError *)YHVVCR.cassette.availableScenes.lastObject.data;
    
    XCTAssertTrue([cassettesRequestError isKindOfClass:[NSError class]]);
    if (![cassettesRequestError isKindOfClass:[NSError class]]) {
        return;
    }
    
    NSError *matchedError = [self errorForRequest:request withFilteredUserInfo:error];
    
    XCTAssertTrue([cassettesRequestError isEqual:matchedError], @"Request error not stored on cassette.");
    XCTAssertFalse([matchedError isEqual:error]);
}


#pragma mark - Misc

- (NSError *)errorForRequest:(NSURLRequest *)request withFilteredUserInfo:(NSError *)error {
    
    NSMutableDictionary *errorUserInfo = [error.userInfo mutableCopy];
    
    if (!errorUserInfo.count) {
        return error;
    }
    
    for (NSString *errorInfoKey in @[NSURLErrorKey, NSURLErrorFailingURLErrorKey, NSURLErrorFailingURLStringErrorKey]) {
        if (!errorUserInfo[errorInfoKey]) {
            continue;
        }
        
        BOOL isStringifiedURL = [errorInfoKey isEqualToString:NSURLErrorFailingURLStringErrorKey];
        NSURL *url = isStringifiedURL ? [NSURL URLWithString:errorUserInfo[errorInfoKey]] : errorUserInfo[errorInfoKey];
        url = YHVVCR.cassette.configuration.urlFilter(request, url);
        
        errorUserInfo[errorInfoKey] = isStringifiedURL ? url.absoluteString : url;
    }
    
    if (errorUserInfo[NSUnderlyingErrorKey]) {
        errorUserInfo[NSUnderlyingErrorKey] = [self errorForRequest:request withFilteredUserInfo:errorUserInfo[NSUnderlyingErrorKey]];
    }
    
    return [NSError errorWithDomain:error.domain code:error.code userInfo:errorUserInfo];
}

#pragma mark -


@end
