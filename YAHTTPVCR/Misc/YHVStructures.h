/**
 * @brief Set of types and structures which is used by VCR and it's components.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#ifndef YHVStructures_h
#define YHVStructures_h


#pragma mark Types and Structures

/**
 * @brief  Cassettes playback mode.
 */
typedef NS_OPTIONS(NSUInteger, YHVPlaybackMode) {
    
    /**
     * @brief      Mode in which recorded request, response and response body will be returned in same order as they has been recorded.
     * @discussion Long-poll requests or big data download requests are spreaded in time and there is a chance, what more requests has been sent
     *             and received while the one comletes. With this mode, request's data will be returned only after other requests will get their
     *             stubbed data.
     */
    YHVChronologicalPlayback,
    
    /**
     * @brief      Mode in which recorded response for request will be returned w/o waiting of other requests.
     * @discussion Long-poll requests or big data download requests are spreaded in time and there is a chance, what more requests has been sent
     *             and received while the one comletes. With this mode, it is possible to send all data (in same order as it has been recorded)
     *             even thought what stubs for other requests not requested yet.
     */
    YHVMomentaryPlayback
};

/**
 * @brief  Cassettes recording mode.
 */
typedef NS_OPTIONS(NSUInteger, YHVRecordMode) {
    
    /**
     * @brief      Mode in which cassettes content will be written only once.
     * @discussion With this mode cassette will store requests only in case if cassette just created. Exception will be thrown in case if user
     *             code will try to add more request to cassette which has been stored to bundle.
     */
    YHVRecordOnce,
    
    /**
     * @brief      Mode in which cassettes content will insert request into list of existing records.
     * @discussion Any new requests will be added into cassette at playhead location (insert before expected).
     */
    YHVRecordNew,
    
    /**
     * @brief      Mode in which cassette protected from any record attempt.
     * @discussion With this mode cassette will throw exception if user code will try to add more requests to cassette.
     */
    YHVRecordNone,
    
    /**
     * @brief      Mode in which cassette will be rewinded and recorded from start.
     * @discussion This mode allow to erase and write new requests to new or existing cassette. This mode is useful when API changes and stubs
     *             should be populated with new service responses.
     */
    YHVRecordAll
};


/**
 * @brief  Structure wich describe available request / response matchers.
 */
typedef struct YHVMatchers {
    
    /**
     * @brief  Stores reference on name of matcher which used to match against request HTTP method (like 'GET' or 'POST').
     */
    __unsafe_unretained NSString *method;
    
    /**
     * @brief  Stores reference on name of matcher which used to match whole request URI.
     */
    __unsafe_unretained NSString *uri;
    
    /**
     * @brief  Stores reference on name of matcher which used to match against used request shema (like 'http' or 'https').
     */
    __unsafe_unretained NSString *scheme;
    
    /**
     * @brief  Stores reference on name of matcher which used to match against name of host which receive request.
     */
    __unsafe_unretained NSString *host;
    
    /**
     * @brief  Stores reference on name of matcher which used to match against port of host which receive request.
     */
    __unsafe_unretained NSString *port;
    
    /**
     * @brief  Stores reference on name of matcher which used to match against request path part.
     */
    __unsafe_unretained NSString *path;
    
    /**
     * @brief  Stores reference on name of matcher which used to match against request query part.
     */
    __unsafe_unretained NSString *query;
    
    /**
     * @brief  Stores reference on name of matcher which used to match against request headers.
     */
    __unsafe_unretained NSString *headers;
    
    /**
     * @brief  Stores reference on name of matcher which used to match request body content (if Content-Type allows).
     */
    __unsafe_unretained NSString *body;
} YHVMatchers;

extern YHVMatchers YHVMatcher;


#pragma mark - GCD block types

/**
 * @brief      Request host filter block.
 * @discussion This block called once for each new request and allow to pass or ignore request.
 *
 * @param host Reference on host which should be filtered.
 *
 * @return \c YES in case if request should be handled or \c NO to ignore it.
 */
typedef BOOL (^YHVHostFilterBlock)(NSString *host);

/**
 * @brief      Request URI path filter block.
 * @discussion This block called once for each new request and allow to replace / remove sensitive information from URI path string.
 *
 * @param request Reference on request for which path filtering has been performed.
 *
 * @return Reference on string which should be used instead of exsiting URI path for \c request.
 */
typedef NSString * (^YHVPathFilterBlock)(NSURLRequest *request);

/**
 * @brief      Request query parameters filter block.
 * @discussion This block called once for each new request and allow to replace / remove sensitive information from query string.
 *
 * @param request         Reference on request for which query filtering has been performed.
 * @param queryParameters Reference on dictionary with URI queries which can be modified.
 */
typedef void(^YHVQueryParametersFilterBlock)(NSURLRequest *request, NSMutableDictionary *queryParameters);

/**
 * @brief      Request headers filter block.
 * @discussion This block called once for each new request and allow to replace / remove sensitive information from headers.
 *
 * @param request Reference on request for which headers filtering has been performed.
 * @param headers Reference on dictionary with request's headers which can be modified.
 */
typedef void(^YHVHeadersFilterBlock)(NSURLRequest *request, NSMutableDictionary *headers);

/**
 * @brief Request POST body filter block.
 *
 * @param request Reference on request for which POST body filtering has been performed.
 * @param body    Reference on data which should be filtered.
 *
 * @return Reference on value which should be used instead of original one or \c nil in case if POST body should be removed.
 *
 * @since 1.2.0
 */
typedef NSData * __nullable (^YHVPostBodyFilterBlock)(NSURLRequest *request, NSData * __nullable body);

/**
 * @brief Response body filter block.
 *
 * @param request  Reference on request for which \c response has been received.
 * @param response Reference on response for which body filtering has been performed.
 * @param data     Reference on bytes which is about to be stored / matched.
 *
 * @return Reference on value which should be used instead of original one or \c nil in case if response body should be removed.
 */
typedef NSData * __nullable (^YHVResponseBodyFilterBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSData * __nullable data);

/**
 * @brief      Requests match block.
 * @discussion VCR use this block to identify whether it can provide response from \a cassette or not.
 *
 * @param request Reference on request which is about to be sent by user's code.
 * @param stubRequest Reference on one of requests from \a cassette against which check should be done.
 *
 * @return \c YES in case if two requests match to each other.
 */
typedef BOOL (^YHVMatcherBlock)(NSURLRequest *request, NSURLRequest *stubRequest);

/**
 * @brief      Request pre-save handling block.
 * @discussion VCR use this block right before saving request onto cassette. This is final point where user can make changes to request which is
 *             about to be stored.
 *
 * @param request Reference on request which should be stored onto cassette.
 *
 * @return Reference on modified (same) \c request or \c nil in case if request should be ignored.
 */
typedef NSURLRequest * __nullable (^YHVBeforeRecordRequestBlock)(NSURLRequest *request);

/**
 * @brief      Response pre-save handling block.
 * @discussion VCR use this block right before saving response for \c request onto cassette. This is final point where user can make changes to
 *             response object and fetched data which is about to be stored.
 *
 * @param request  Reference on request for which response should be stored onto cassette.
 * @param response Reference on response object which provide information about received \c data.
 * @param data     Reference on actual server response binary data.
 *
 * @return List (tuple) where first element is modified (same) \c response and second element modified (same) response \c data. Pass array only
 *         with \c response to remove \c data from stub.
 */
typedef NSArray * (^YHVBeforeRecordResponseBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data);

#endif // YHVStructures_h
