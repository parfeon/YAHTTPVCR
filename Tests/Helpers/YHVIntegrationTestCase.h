#import <YAHTTPVCR/YAHTTPVCR.h>


#pragma mark Structures

/**
 * @brief  Type of block which is used by request processing method to report results.
 */
typedef void(^YHVVerificationBlock)(NSURLRequest *request, NSHTTPURLResponse * __nullable response, NSData * __nullable data,
                                    NSError * __nullable error);


@interface YHVIntegrationTestCase : YHVTestCase


#pragma mark - Information

@property (nonatomic, readonly, copy) NSString *queryString;


#pragma mark - Request configuration

/**
 * @brief      Create and configure GET request to \c https://httpbin.org resource.
 * @discussion Configure request against resource which allow to simulate backend.
 *
 * @param path Reference on URI path component which should be appended.
 *
 * @return Configured and ready to use \a NSURLRequest instance.
 */
- (NSMutableURLRequest *)GETRequestWithPath:(NSString *)path;

/**
 * @brief      Create and configure POST request to \c https://httpbin.org resource.
 * @discussion Configure request against resource which allow to simulate backend and append pre-defined POST body.
 *
 * @param path Reference on URI path component which should be appended.
 *
 * @return Configured and ready to use \a NSURLRequest instance.
 */
- (NSMutableURLRequest *)POSTRequestWithPath:(NSString *)path;


#pragma mark - Request processing

/**
 * @brief      Send \c request with completion block.
 * @discussion Send asynchronous \c request and wait till it completion.
 *
 * @param request Reference on request which should be processed.
 * @param block   Reference on request processing completion block which should be used to verify results.
 */
- (void)sendRequest:(NSURLRequest *)request withResultVerificationBlock:(nullable YHVVerificationBlock)block;

/**
 * @brief      Send list of \c requests with completion block.
 * @discussion Send asynchronous \c requests and wait till all will be completion.
 *
 * @param requests Reference on requests list which should be processed.
 * @param block    Reference on request processing completion block which should be used to verify results. Block will be called for each
 *                 request.
 */
- (void)sendRequests:(NSArray<NSURLRequest *> *)requests withResultVerificationBlock:(nullable YHVVerificationBlock)block;

/**
 * @brief      Send \c request which will be cancelled after specified \c interval.
 * @discussion Send asynchronous \c request and cancel it after specified amount of time.
 *
 * @param request  Reference on request which should be processed.
 * @param interval Interval after which request should be cancelled.
 * @param block    Reference on request processing completion block which should be used to verify results.
 */
- (void)sendRequest:(NSURLRequest *)request
    withCancellationAfter:(NSTimeInterval)interval
  resultVerificationBlock:(nullable YHVVerificationBlock)block;


#pragma mark - Cassette

/**
 * @brief      Check whether response for specified \c response has been played or not.
 * @discussion Throw XCT assertion in case if response for specified \c request not played.
 *
 * @param response Reference on request for which \c response has been created.
 * @param request  Reference on request which has been used to fetch data from remote server.
 * @param data     Reference on object which has been received from server (stub).
 */
- (void)assertResponse:(NSHTTPURLResponse *)response playedForRequest:(NSURLRequest *)request withData:(NSData *)data;

/**
 * @brief      Check whether specified \c request has been written on cassette or not.
 * @discussion Throw XCT assertion in case if specified \c request not written onto cassette.
 *
 * @param request Reference on request which has been used to fetch data from remote server.
 */
- (void)assertRequestWritten:(NSURLRequest *)request;

/**
 * @brief      Check whether specified \c response has been written on cassette or not.
 * @discussion Throw XCT assertion in case if specified \c response not written onto cassette.
 *
 * @param request  Reference on request for which \c response has been created.
 * @param response Reference on remote server response.
 */
- (void)assertRequest:(NSURLRequest *)request responseWritten:(NSHTTPURLResponse *)response;

/**
 * @brief      Check whether specified \c response body has been written on cassette or not.
 * @discussion Throw XCT assertion in case if specified \c response body not written onto cassette.
 *
 * @param response Reference on remote server response.
 * @param data     Reference on response body binary.
 */
- (void)assertResponse:(NSHTTPURLResponse *)response bodyWritten:(NSData *)data;

/**
 * @brief      Check whether \c error for request has been written on cassette or not.
 * @discussion Throw XCT assertion in case if specified \c error not written onto cassette.
 *
 * @param request Reference on request for which \c error has been created.
 * @param error   Reference on request processing error.
 */
- (void)assertRequest:(NSURLRequest *)request errorWritten:(NSError *)error;

#pragma mark -


@end
