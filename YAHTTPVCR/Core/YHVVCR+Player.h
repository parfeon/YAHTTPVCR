/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVVCR.h"


#pragma mark Class forward

@class YHVNSURLProtocol;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

@interface YHVVCR (Player)


#pragma mark - Playback

/**
 * @brief      Check whether VCR is able to provide response on \c request at this moment.
 * @discussion If current scene on cassete contains same request, then it is possible to provide response for it.
 *
 * @param request Reference on request for which response availability should be checked.
 *
 * @return \c YES in case if current scene is able to handle request and provide data for it.
 */
+ (BOOL)canPlayResponseForRequest:(NSURLRequest *)request;

/**
 * @brief  Prepare cassette to play responses and feed them to protocol's client.
 *
 * @param protocol Reference on URL loading protocol which controls client for which data should be sent.
 */
+ (void)prepareToPlayResponsesWithProtocol:(YHVNSURLProtocol *)protocol;

/**
 * @brief  Go throught chapters recorded for specified \c request.
 *
 * @param request Reference on request for which responses whould be played.
 */
+ (void)playResponsesForRequest:(NSURLRequest *)request;

/**
 * @brief  Confirm request scene playback completion.
 *
 * @param task Reference on data fetch task for which request scene has been played.
 */
+ (void)handleRequestPlayedForTask:(NSURLSessionTask *)task;

/**
 * @brief  Confirm response scene playback completion.
 *
 * @param task Reference on data fetch task for which response scene has been played.
 */
+ (void)handleResponsePlayedForTask:(NSURLSessionTask *)task;

/**
 * @brief  Confirm data scene playback completion.
 *
 * @param task Reference on data fetch task for which data scene has been played.
 */
+ (void)handleDataPlayedForTask:(NSURLSessionTask *)task;

/**
 * @brief  Confirm error scene playback completion.
 *
 * @param error Reference on error object from played scene.
 * @param task  Reference on data fetch task for which data scene has been played.
 */
+ (void)handleError:(nullable NSError *)error playedForTask:(NSURLSessionTask *)task;

/**
 * @brief  Confirm request scene playback completion.
 *
 * @param request Reference on request for which request scene has been played.
 *
 * @since 1.1.0
 */
+ (void)handleRequestPlayedForRequest:(NSURLRequest *)request;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
