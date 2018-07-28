/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVCassette.h"


#pragma mark Class forward

@class YHVConfiguration, YHVNSURLProtocol, YHVScene;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface YHVCassette (Private)


#pragma mark - Information

/**
 * @brief  Stores reference on set of recorded scenes (request and responses) which should be played on VCR.
 */
@property (nonatomic, strong) NSArray<YHVScene *> *availableScenes;


#pragma mark - Initialization and Configuration

/**
 * @brief  Create and configure cassette instance.
 *
 * @param configuration Reference on instance which contain information required for cassette to be loaded and handle requests.
 *
 * @return Configured and ready to use cassette instance.
 */
+ (instancetype)cassetteWithConfiguration:(YHVConfiguration *)configuration;


#pragma mark - Content management

/**
 * @brief  Load cassettes content from configured location.
 */
- (void)load;

/**
 * @brief  Save any changes (if allowed by \c recordMode).
 */
- (void)save;


#pragma mark - Playback

/**
 * @brief      Check whether cassette is able to provide response on \c request at this moment.
 * @discussion If current VCR playhead position points to scene with same request, than cassette is able to provide response for it.
 *
 * @param request Reference on request for which response availability should be checked.
 *
 * @return \c YES in case if VCR playhead points to this request.
 */
- (BOOL)canPlayResponseForRequest:(NSURLRequest *)request;

/**
 * @brief  Prepare cassette to play responses and feed them to protocol's client.
 *
 * @param protocol Reference on URL loading protocol which controls client for which data should be sent.
 */
- (void)prepareToPlayResponsesWithProtocol:(YHVNSURLProtocol *)protocol;

/**
 * @brief  Go throught chapters recorded for specified \c request.
 *
 * @param request Reference on request for which responses whould be played.
 */
- (void)playResponsesForRequest:(NSURLRequest *)request;

/**
 * @brief  Confirm request scene playback completion.
 *
 * @param task Reference on data fetch task for which request scene has been played.
 */
- (void)handleRequestPlayedForTask:(NSURLSessionTask *)task;

/**
 * @brief  Confirm response scene playback completion.
 *
 * @param task Reference on data fetch task for which response scene has been played.
 */
- (void)handleResponsePlayedForTask:(NSURLSessionTask *)task;

/**
 * @brief  Confirm data scene playback completion.
 *
 * @param task Reference on data fetch task for which data scene has been played.
 */
- (void)handleDataPlayedForTask:(NSURLSessionTask *)task;

/**
 * @brief  Confirm error scene playback completion.
 *
 * @param error Reference on error object from played scene.
 * @param task  Reference on data fetch task for which data scene has been played.
 */
- (void)handleError:(nullable NSError *)error playedForTask:(NSURLSessionTask *)task;


#pragma mark - Recording

/**
 * @brief  Start recording of original \a NSURLRequest data loading.
 *
 * @param task Reference on data fetch task for which progress should be recorded.
 */
- (void)beginRecordingTask:(NSURLSessionTask *)task;

/**
 * @brief  Record remote server \c response for specified \c task.
 *
 * @param response Reference on response object which contain data w/o actual body loaded from server.
 * @param task     Reference on task which received this response for original \a NSURLRequest.
 */
- (void)recordResponse:(NSURLResponse *)response forTask:(NSURLSessionTask *)task;

/**
 * @brief  Record remote server \c response body for specified \c task.
 *
 * @param data Reference on response body which has been requested by original \a NSURLRequest.
 * @param task Reference on task which received this response body.
 */
- (void)recordData:(NSData *)data forTask:(NSURLSessionTask *)task;

/**
 * @brief  Handle \c task processing error.
 *
 * @param error Reference on error which happened during task's request processing.
 * @param task  Reference on task for which error has been created.
 */
- (void)recordCompletionWithError:(NSError *)error forTask:(NSURLSessionTask *)task;

/**
 * @brief  Remove any data which has been fetched so far by \c task.
 *
 * @param task Reference for which fetched response body should be cleared.
 */
- (void)clearFetchedDataForTask:(NSURLSessionTask *)task;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
