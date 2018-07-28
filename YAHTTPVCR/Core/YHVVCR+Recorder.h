/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVVCR.h"


#pragma mark Interface declaration

@interface YHVVCR (Recorder)


#pragma mark - Recording

/**
 * @brief  Start recording of original \a NSURLRequest data loading.
 *
 * @param task Reference on data fetch task for which progress should be recorded.
 */
+ (void)beginRecordingTask:(NSURLSessionTask *)task;

/**
 * @brief  Record remote server \c response for specified \c task.
 *
 * @param response Reference on response object which contain data w/o actual body loaded from server.
 * @param task     Reference on task which received this response for original \a NSURLRequest.
 */
+ (void)recordResponse:(NSURLResponse *)response forTask:(NSURLSessionTask *)task;

/**
 * @brief  Record remote server \c response body for specified \c task.
 *
 * @param data Reference on response body which has been requested by original \a NSURLRequest.
 * @param task Reference on task which received this response body.
 */
+ (void)recordData:(NSData *)data forTask:(NSURLSessionTask *)task;

/**
 * @brief  Handle \c task processing error.
 *
 * @param error Reference on error which happened during task's request processing.
 * @param task  Reference on task for which error has been created.
 */
+ (void)recordCompletionWithError:(NSError *)error forTask:(NSURLSessionTask *)task;

/**
 * @brief  Remove any data which has been fetched so far by \c task.
 *
 * @param task Reference for which fetched response body should be cleared.
 */
+ (void)clearFetchedDataForTask:(NSURLSessionTask *)task;

#pragma mark -


@end
