/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVVCR+Recorder.h"
#import "YHVVCR+Player.h"
#import "NSURLSessionConfiguration+YHVNSURLProtocol.h"
#import "NSURLSessionConnection+YHVRecorder.h"
#import "NSDictionary+YHVNSURLRequest.h"
#import "NSURLSessionTask+YHVRecorder.h"
#import "NSMutableDictionary+YHVMisc.h"
#import "NSURLConnection+YHVRecorder.h"
#import "YHVConfiguration+Private.h"
#import "NSURLRequest+YHVPlayer.h"
#import "NSDictionary+YHVNSURL.h"
#import "YHVPrivateStructures.h"
#import "YHVCassette+Private.h"
#import "YHVRequestMatchers.h"
#import "YHVNSURLProtocol.h"


#pragma mark Extern

YHVMatchers YHVMatcher = {
    .method = @"method",
    .uri = @"uri",
    .scheme = @"scheme",
    .host = @"host",
    .port = @"port",
    .path = @"path",
    .query = @"query",
    .body = @"body",
    .headers = @"headers"
};


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface YHVVCR ()


#pragma mark - Information

/**
 * @brief  Stores reference on configuration object which has been passed during VCR configuration method call.
 */
@property (nonatomic, copy) YHVConfiguration *sharedConfiguration;

/**
 * @brief  Stores reference on cassette which currently inserted into VCR.
 */
@property (nonatomic, strong, nullable) YHVCassette *cassette;

/**
 * @brief  Stores reference on dictionary which contain set of known matchers.
 * @discussion VCR use only those \c matchers for which it has been configured.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, YHVMatcherBlock> *matchers;

/**
 * @brief  Stores reference on queue which is used to serialize access to shared object information.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;


#pragma mark - Initialization and Configuration

/**
 * @brief      VCR singleton instance.
 * @discussion Create and configure with default configuration VCR instance.
 *
 * @return Reference on VCR singleton instance.
 */
+ (YHVVCR *)sharedInstance;

/**
 * @brief  Merge VCR's configuration with custom cassette's configuration.
 *
 * @param cassetteConfiguration Reference on
 */
- (YHVConfiguration *)sharedConfigurationMergedWith:(YHVConfiguration *)cassetteConfiguration;


#pragma mark - Cassette

/**
 * @brief  Insert new or existing cassette to VCR.
 *
 * @param isDefault Whether default VCR configuration should be used for cassette operation or not.
 * @param block     Reference on block which can be used to customize cassette's behaviour. Block pass only one argument - configuration object
 *                  which later will be merged with VCR's configuration and used for cassette.
 *
 * @return Reference on cassette which has been inserted to VCR.
 */
- (YHVCassette *)insertCassetteWithDefault:(BOOL)isDefault configuration:(void(^)(YHVConfiguration *configuration))block;

/**
 * @brief  Compose full path to cassette's data file.
 *
 * @param configuration Reference on configuration from which information for path should be taken.
 *
 * @return Full path to cassette's data file.
 */
- (NSString *)pathForCassetteWithConfiguration:(YHVConfiguration *)configuration;

/**
 * @brief  Make sure what cassettes directory exists and app has access to it.
 */
- (void)prepareCassettesDirectory;


#pragma mark - Filters

/**
 * @brief      Create request filtering block.
 * @discussion Stack all provided filters along with \c beforeRequestRecord block in single callable block.
 *
 * @param configuration Reference on cassette's configuration object.
 *
 * @return Reference on single request filtering block which will be called before save.
 */
- (YHVBeforeRecordRequestBlock)createBeforeRecordRequestBlockWithConfiguration:(YHVConfiguration *)configuration;

/**
 * @brief      Create response filtering block.
 * @discussion Stack all resopnse provided filters along with \c beforeResponseRecord block in single callable block.
 *
 * @param configuration Reference on cassette's configuration object.
 *
 * @return Reference on single response filtering block which will be called before save.
 */
- (YHVBeforeRecordResponseBlock)createBeforeRecordResponseBlockWithConfiguration:(YHVConfiguration *)configuration;

/**
 * @brief  Create request filtering block based on request host.
 *
 * @param configuration Reference on cassette's configuration object.
 *
 * @return Reference on block which will be called each time before request save / handle.
 */
- (YHVHostFilterBlock)createHostFilterBlockWithConfiguration:(YHVConfiguration *)configuration;

/**
 * @brief  Create request filtering block based on request headers.
 *
 * @param configuration Reference on cassette's configuration object.
 *
 * @return Reference on block which will be called each time before request save / handle.
 */
- (YHVHeadersFilterBlock)createHeadersFilterBlockWithConfiguration:(YHVConfiguration *)configuration;

/**
 * @brief  Create URL object filtering block.
 *
 * @param configuration Reference on cassette's configuration object.
 *
 * @return Reference on block which will be called each time before URL object should be saved.
 */
- (YHVURLFilterBlock)createURLFilterBlockWithConfiguration:(YHVConfiguration *)configuration;

/**
 * @brief  Create request filtering block based on request URL path part.
 *
 * @param configuration Reference on cassette's configuration object.
 *
 * @return Reference on block which will be called each time before request save / handle.
 */
- (YHVPathFilterBlock)createPathFilterBlockWithConfiguration:(YHVConfiguration *)configuration;

/**
 * @brief  Create request filtering block based on request URL query part.
 *
 * @param configuration Reference on cassette's configuration object.
 *
 * @return Reference on block which will be called each time before request save / handle.
 */
- (YHVQueryParametersFilterBlock)createQueryParametersFilterBlockWithConfiguration:(YHVConfiguration *)configuration;

/**
 * @brief  Create request filtering block based on request POST body.
 *
 * @param configuration Reference on cassette's configuration object.
 *
 * @return Reference on block which will be called each time before request save / handle.
 */
- (YHVPostBodyFilterBlock)createPOSTBodyFilterBlockWithConfiguration:(YHVConfiguration *)configuration;

/**
 * @brief  Create response body filtering block.
 *
 * @param configuration Reference on cassette's configuration object.
 *
 * @return Reference on block which will be called each time before response save / handle.
 */
- (YHVResponseBodyFilterBlock)createResponseBodyFilterBlockWithConfiguration:(YHVConfiguration *)configuration;


#pragma mark - Matchers

/**
 * @brief  Get requested list of matcher blocks.
 *
 * @param configuration Reference on object which contain list of required matcher identifiers.
 *
 * @return Reference on list with matcher blocks or \c nil in case if no matchers should be used.
 */
- (nullable NSArray<YHVMatcherBlock> *)matchersForConfiguration:(YHVConfiguration *)configuration;

/**
 * @brief  Register bundled request matchers.
 */
- (void)registerDefaultMatcher;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation YHVVCR


#pragma mark - Information

+ (YHVCassette *)cassette {
    
    __block YHVCassette *cassette = nil;
    
    dispatch_sync([self sharedInstance].resourceAccessQueue, ^{
        cassette = [self sharedInstance]->_cassette;
    });
    
    return cassette;
}

+ (NSDictionary<NSString *,YHVMatcherBlock> *)matchers {
    
    __block NSDictionary<NSString *,YHVMatcherBlock> *matchers = nil;
    
    dispatch_sync([self sharedInstance].resourceAccessQueue, ^{
        matchers = [[self sharedInstance]->_matchers copy];
    });
    
    return matchers;
}


#pragma mark - Initialization and Configuration

+ (void)load {

    [YHVNSURLSessionConfiguration injectProtocol];
    [YHVNSURLSessionConnection makeRecordable];
    [YHVNSURLSessionTask makeRecordable];
    [YHVNSURLConnection makeRecordable];
    [YHVNSURLRequest patch];
}

+ (YHVVCR *)sharedInstance {
    
    static YHVVCR *_sharedVCRInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedVCRInstance = [self new];
    });
    
    return _sharedVCRInstance;
}

+ (void)setupWithConfiguration:(void(^)(YHVConfiguration *configuration))block {
    
    YHVConfiguration *configuration = [YHVConfiguration defaultConfiguration];
    
    block(configuration);
    
    NSAssert(configuration.cassettesPath.length, @"VCR setup error. Cassettes path is empty or nil.");
    
    [self sharedInstance].sharedConfiguration = configuration;
    [[self sharedInstance] prepareCassettesDirectory];
}

- (instancetype)init {
    
    if ((self = [super init])) {
        _resourceAccessQueue = dispatch_queue_create("com.yetanotherhttpvcr.core", DISPATCH_QUEUE_SERIAL);
        _matchers = [NSMutableDictionary new];
        
        [self registerDefaultMatcher];
    }
    
    return self;
}

- (YHVConfiguration *)sharedConfigurationMergedWith:(YHVConfiguration *)cassetteConfiguration {
    
    YHVConfiguration *configuration = [cassetteConfiguration copyWithDefaultsFromConfiguration:self.sharedConfiguration];
    configuration.cassettePath = [self pathForCassetteWithConfiguration:cassetteConfiguration];
    configuration.matchers = [self matchersForConfiguration:configuration];
    configuration.beforeRecordRequest = [self createBeforeRecordRequestBlockWithConfiguration:configuration];
    configuration.beforeRecordResponse = [self createBeforeRecordResponseBlockWithConfiguration:configuration];
    
    return configuration;
}


#pragma mark - Cassette

+ (YHVCassette *)insertCassetteWithPath:(NSString *)path {

    return [[self sharedInstance] insertCassetteWithDefault:YES configuration:^(YHVConfiguration *configuration) {
        configuration.cassettePath = path;
    }];
}

+ (YHVCassette *)insertCassetteWithConfiguration:(void(^)(YHVConfiguration *configuration))block {
    
    NSAssert(block, @"Cassette insertion error. Configuration block not provided.");
    
    return [[self sharedInstance] insertCassetteWithDefault:NO configuration:block];
}

+ (void)ejectCassette {
    
    dispatch_sync([self sharedInstance].resourceAccessQueue, ^{
        [[self sharedInstance].cassette save];
        [self sharedInstance].cassette = nil;
    });
}

- (YHVCassette *)insertCassetteWithDefault:(BOOL)isDefault configuration:(void(^)(YHVConfiguration *configuration))block {
    
    NSAssert(!self.cassette, @"Cassette insertion error. There is cassette in VCR. Eject cassette before inserting new.");
    
    __block YHVCassette *cassette = nil;
    __block YHVConfiguration *configuration = [YHVConfiguration defaultConfiguration];
    configuration.matchers = nil;
    
    block(configuration);
    
    NSAssert(configuration.cassettePath.length, @"Cassette insertion error. Cassette path is empty or nil.");
    
    dispatch_sync(self.resourceAccessQueue, ^{
        configuration = [self sharedConfigurationMergedWith:configuration];
        configuration.playbackMode = isDefault ? self.sharedConfiguration.playbackMode : configuration.playbackMode;
        configuration.recordMode = isDefault ? self.sharedConfiguration.recordMode : configuration.recordMode;
        
        self.cassette = [YHVCassette cassetteWithConfiguration:configuration];
        [self->_cassette load];
        
        cassette = self.cassette;
    });
    
    return cassette;
}

- (NSString *)pathForCassetteWithConfiguration:(YHVConfiguration *)configuration {
    
    NSString *path = [self.sharedConfiguration.cassettesPath stringByAppendingPathComponent:configuration.cassettePath];
    
    if (![path pathExtension].length) {
        path = [path stringByAppendingPathExtension:@"json"];
    }
    
    return path;
}

- (void)prepareCassettesDirectory {
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSString *path = self.sharedConfiguration.cassettesPath;
    BOOL isDirectory = YES;
    NSError *error = nil;
    
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        isDirectory = YES;
        
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSAssert(isDirectory, @"Cassettes path should point to directory (%@)", path);
    NSAssert(!error, @"Unable create directory (%@) because of error: %@", path, error);
}


#pragma mark - Playback

+ (BOOL)canPlayResponseForRequest:(NSURLRequest *)request {
    
    return [self.cassette canPlayResponseForRequest:request];
}

+ (void)prepareToPlayResponsesWithProtocol:(YHVNSURLProtocol *)protocol; {
    
    [self.cassette prepareToPlayResponsesWithProtocol:protocol];
}

+ (void)playResponsesForRequest:(NSURLRequest *)request {
    
    [self.cassette playResponsesForRequest:request];
}

+ (void)handleRequestPlayedForTask:(NSURLSessionTask *)task {
    
    [self.cassette handleRequestPlayedForTask:task];
}

+ (void)handleResponsePlayedForTask:(NSURLSessionTask *)task {
    
    [self.cassette handleResponsePlayedForTask:task];
}

+ (void)handleDataPlayedForTask:(NSURLSessionTask *)task {
    
    [self.cassette handleDataPlayedForTask:task];
}

+ (void)handleError:(NSError *)error playedForTask:(NSURLSessionTask *)task {
    
    [self.cassette handleError:error playedForTask:task];
}

+ (void)handleRequestPlayedForRequest:(NSURLRequest *)request {
    
    [self.cassette handleRequestPlayedForRequest:request];
}


#pragma mark - Recording

+ (void)beginRecordingTask:(NSURLSessionTask *)task {
    
    [self.cassette beginRecordingTask:task];
}

+ (void)recordResponse:(NSURLResponse *)response forTask:(NSURLSessionTask *)task {
    
    [self.cassette recordResponse:response forTask:task];
}

+ (void)recordData:(NSData *)data forTask:(NSURLSessionTask *)task {
    
    [self.cassette recordData:data forTask:task];
}

+ (void)recordCompletionWithError:(NSError *)error forTask:(NSURLSessionTask *)task {
    
    [self.cassette recordCompletionWithError:error forTask:task];
}

+ (void)clearFetchedDataForTask:(NSURLSessionTask *)task {
    
    [self.cassette clearFetchedDataForTask:task];
}


#pragma mark - Recording request

+ (void)beginRecordingRequest:(NSURLRequest *)request {
    
    [self.cassette beginRecordingRequest:request];
}

+ (void)recordResponse:(NSURLResponse *)response forRequest:(NSURLRequest *)request {
    
    [self.cassette recordResponse:response forRequest:request];
}

+ (void)recordData:(NSData *)data forRequest:(NSURLRequest *)request {
    
    [self.cassette recordData:data forRequest:request];
}

+ (void)recordCompletionWithError:(NSError *)error forRequest:(NSURLRequest *)request {
    
    [self.cassette recordCompletionWithError:error forRequest:request];
}


#pragma mark - Filters

- (YHVBeforeRecordRequestBlock)createBeforeRecordRequestBlockWithConfiguration:(YHVConfiguration *)configuration {
    
    YHVBeforeRecordRequestBlock beforeRecordRequest = configuration.beforeRecordRequest ?: self.sharedConfiguration.beforeRecordRequest;
    configuration.hostsFilter = [self createHostFilterBlockWithConfiguration:configuration];
    configuration.headersFilter = [self createHeadersFilterBlockWithConfiguration:configuration];
    configuration.pathFilter = [self createPathFilterBlockWithConfiguration:configuration];
    configuration.queryParametersFilter = [self createQueryParametersFilterBlockWithConfiguration:configuration];
    configuration.postBodyFilter = [self createPOSTBodyFilterBlockWithConfiguration:configuration];
    configuration.urlFilter = [self createURLFilterBlockWithConfiguration:configuration];
    
    return ^NSURLRequest * (NSURLRequest *request) {
        if (configuration.hostsFilter && !((YHVHostFilterBlock)configuration.hostsFilter)(request.URL.host)) {
            request.YHV_VCRIgnored = YES;
            return nil;
        }

        NSMutableURLRequest *finalRequest = [request mutableCopy];
        
        if (configuration.headersFilter) {
            NSMutableDictionary *headers = [request.allHTTPHeaderFields mutableCopy];
            
            ((YHVHeadersFilterBlock)configuration.headersFilter)(finalRequest, headers);
            [finalRequest setAllHTTPHeaderFields:[headers copy]];
        }
        
        finalRequest.URL = configuration.urlFilter(finalRequest, finalRequest.URL);
        
        if (configuration.postBodyFilter) {
            finalRequest.HTTPBody = ((YHVPostBodyFilterBlock)configuration.postBodyFilter)(finalRequest, finalRequest.YHV_HTTPBody);
        }
        
        NSURLRequest *updatedRequest = beforeRecordRequest ? beforeRecordRequest(finalRequest) : finalRequest;
        request.YHV_VCRIgnored = !updatedRequest;

        return updatedRequest;
    };
}

- (YHVBeforeRecordResponseBlock)createBeforeRecordResponseBlockWithConfiguration:(YHVConfiguration *)configuration {
    
    YHVBeforeRecordResponseBlock beforeRecordResponse = configuration.beforeRecordResponse ?: self.sharedConfiguration.beforeRecordResponse;
    configuration.responseBodyFilter = [self createResponseBodyFilterBlockWithConfiguration:configuration];
    
    return ^NSArray * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
        NSMutableDictionary *headers = [response.allHeaderFields mutableCopy];
        NSHTTPURLResponse *finalResponse = [response copy];
        NSData *finalData = [data copy];
        NSURL *url = configuration.urlFilter(request, request.URL);
        BOOL shouldRebuildResponse = ![response.URL.absoluteString.lowercaseString isEqualToString:url.absoluteString.lowercaseString];

        if (shouldRebuildResponse) {
            finalResponse = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:response.statusCode HTTPVersion:nil headerFields:headers];
        }
        
        if (configuration.responseBodyFilter) {
            finalData = ((YHVResponseBodyFilterBlock)configuration.responseBodyFilter)(request, finalResponse, finalData);
        }
        
        NSMutableArray *responseArray = [NSMutableArray arrayWithArray:@[finalResponse]];
        if (finalData) {
            [responseArray addObject:finalData];
        }
        
        return  beforeRecordResponse ? beforeRecordResponse(request, finalResponse, finalData) : responseArray;
    };
}

- (YHVHostFilterBlock)createHostFilterBlockWithConfiguration:(YHVConfiguration *)configuration {
    
    id hostsFilter = configuration.hostsFilter ?: self.sharedConfiguration.hostsFilter;
    
    if (![hostsFilter isKindOfClass:[NSArray class]]) {
        return hostsFilter;
    }
    
    NSArray *allowedHosts = [hostsFilter copy];
    
    return ^BOOL (NSString *host) {
        return [allowedHosts containsObject:host];
    };
}

- (YHVHeadersFilterBlock)createHeadersFilterBlockWithConfiguration:(YHVConfiguration *)configuration {
    
    id headersFilter = configuration.headersFilter ?: self.sharedConfiguration.headersFilter;
    
    if (![headersFilter isKindOfClass:[NSDictionary class]]) {
        return headersFilter;
    }
    
    NSDictionary *headersForModification = [headersFilter copy];
    
    return ^(__unused NSURLRequest *request, NSMutableDictionary *headers) {
        [headers YHV_replaceValuesWithValuesFromDictionary:headersForModification];
    };
}

- (YHVURLFilterBlock)createURLFilterBlockWithConfiguration:(YHVConfiguration *)configuration {
    
    return ^NSURL * (NSURLRequest *request, NSURL *url) {
        NSMutableURLRequest *finalRequest = [request mutableCopy];
        finalRequest.URL = url;
        
        if (configuration.pathFilter) {
            NSURLComponents *urlComponents = [NSURLComponents componentsWithString:finalRequest.URL.absoluteString];
            urlComponents.path = configuration.pathFilter(finalRequest);
            finalRequest.URL = urlComponents.URL;
        }
        
        if (configuration.queryParametersFilter) {
            NSDictionary *query = [NSDictionary YHV_dictionaryWithQuery:finalRequest.URL.query];
            NSMutableDictionary *mutableQuery = [query mutableCopy];
            
            ((YHVQueryParametersFilterBlock)configuration.queryParametersFilter)(request, mutableQuery);
            
            if (![mutableQuery isEqualToDictionary:query]) {
                NSString *updatedQueryString = [mutableQuery YHV_toQueryString];
                NSString *urlString = finalRequest.URL.absoluteString;
                NSString *queryString = finalRequest.URL.query;
                
                urlString = [urlString stringByReplacingOccurrencesOfString:queryString withString:updatedQueryString];
                finalRequest.URL = [NSURL URLWithString:urlString];
            }
        }
        
        return finalRequest.URL;
    };
}

- (YHVPathFilterBlock)createPathFilterBlockWithConfiguration:(YHVConfiguration *)configuration {
    
    YHVPathFilterBlock pathFilter = configuration.pathFilter ?: self.sharedConfiguration.pathFilter;
    
    if (!pathFilter) {
        pathFilter = ^NSString * (NSURLRequest *request) { return request.URL.path; };
    }
    
    return pathFilter;
}

- (YHVQueryParametersFilterBlock)createQueryParametersFilterBlockWithConfiguration:(YHVConfiguration *)configuration {
    
    id queryParametersFilter = configuration.queryParametersFilter ?: self.sharedConfiguration.queryParametersFilter;
    
    if (![queryParametersFilter isKindOfClass:[NSDictionary class]]) {
        return queryParametersFilter;
    }
    
    NSDictionary *queryKeysForModification = [queryParametersFilter copy];
    
    return ^(__unused NSURLRequest *request, NSMutableDictionary *queryParameters) {
        [queryParameters YHV_replaceValuesWithValuesFromDictionary:queryKeysForModification];
    };
}

- (YHVPostBodyFilterBlock)createPOSTBodyFilterBlockWithConfiguration:(YHVConfiguration *)configuration {
    
    id postBodyFilter = configuration.postBodyFilter ?: self.sharedConfiguration.postBodyFilter;
    NSDictionary *bodyKeysForModification = nil;
    
    if ([postBodyFilter isKindOfClass:[NSDictionary class]]) {
        bodyKeysForModification = [postBodyFilter copy];
    }
    
    return ^NSData * (NSURLRequest *request, NSData *body) {
        if (![request.HTTPMethod.lowercaseString isEqualToString:@"post"]) {
            return body;
        } else if (postBodyFilter && !bodyKeysForModification) {
            return ((YHVPostBodyFilterBlock)postBodyFilter)(request, body);
        }
        
        NSMutableDictionary *keyValue = [[NSDictionary YHV_dictionaryFromNSURLRequestPOSTBody:request] mutableCopy];
        
        if (!keyValue) {
            return body;
        }
        
        return [[keyValue YHV_replaceValuesWithValuesFromDictionary:bodyKeysForModification] YHV_POSTBodyForNSURLRequest:request];
    };
}

- (YHVResponseBodyFilterBlock)createResponseBodyFilterBlockWithConfiguration:(YHVConfiguration *)configuration {
    
    id responseBodyFilter = configuration.responseBodyFilter ?: self.sharedConfiguration.responseBodyFilter;
    
    if (![responseBodyFilter isKindOfClass:[NSDictionary class]]) {
        return responseBodyFilter;
    }
    
    NSDictionary *bodyKeysForModification = [responseBodyFilter copy];
    
    return ^NSData * (NSURLRequest * __unused request, NSHTTPURLResponse *response, NSData *data) {
        NSMutableDictionary *keyValue = [[NSDictionary YHV_dictionaryFromData:data forNSHTTPURLResponse:response] mutableCopy];
        
        if (!keyValue) {
            return data;
        }
        
        return [[keyValue YHV_replaceValuesWithValuesFromDictionary:bodyKeysForModification] YHV_DataForNSHTTPURLResponse:response];
    };
}


#pragma mark - Matchers

- (NSArray<YHVMatcherBlock> *)matchersForConfiguration:(YHVConfiguration *)configuration {
    
    if (!configuration || !configuration.matchers.count) {
        return nil;
    }
    
    NSArray<NSString *> *matcherIdentifiers = [configuration.matchers copy];
    NSMutableArray<YHVMatcherBlock> *matchers = [NSMutableArray new];
    
    for (NSString *matcherIdentifier in matcherIdentifiers) {
        id matcher = self.matchers[matcherIdentifier];
        
        NSAssert(matcher, @"Matcher %@ doesn't exist or isn't registered.", matcherIdentifier);
        
        [matchers addObject:matcher];
    }
    
    return matchers;
}

+ (void)registerMatcher:(NSString *)identifier withBlock:(YHVMatcherBlock)block {
    
    if (!identifier || !block) {
        return;
    }
    
    dispatch_sync([self sharedInstance].resourceAccessQueue, ^{
        [self sharedInstance].matchers[identifier] = block;
    });
}

+ (void)unregisterMatcher:(NSString *)identifier {
    
    NSArray<NSString *> *defaultMatchers = @[YHVMatcher.method, YHVMatcher.uri, YHVMatcher.scheme, YHVMatcher.host, YHVMatcher.port, 
                                             YHVMatcher.path, YHVMatcher.query, YHVMatcher.headers, YHVMatcher.body];

    if (!identifier || [defaultMatchers containsObject:identifier]) {
        return;
    }
    
    dispatch_sync([self sharedInstance].resourceAccessQueue, ^{
        [[self sharedInstance].matchers removeObjectForKey:identifier];
    });
}

- (void)registerDefaultMatcher {
    
    dispatch_sync(self.resourceAccessQueue, ^{
        self.matchers[YHVMatcher.method] = YHVRequestMatchers.method;
        self.matchers[YHVMatcher.uri] = YHVRequestMatchers.uri;
        self.matchers[YHVMatcher.scheme] = YHVRequestMatchers.scheme;
        self.matchers[YHVMatcher.host] = YHVRequestMatchers.host;
        self.matchers[YHVMatcher.port] = YHVRequestMatchers.port;
        self.matchers[YHVMatcher.path] = YHVRequestMatchers.path;
        self.matchers[YHVMatcher.query] = YHVRequestMatchers.query;
        self.matchers[YHVMatcher.headers] = YHVRequestMatchers.headers;
        self.matchers[YHVMatcher.body] = YHVRequestMatchers.body;
    });
}

#pragma mark -


@end
