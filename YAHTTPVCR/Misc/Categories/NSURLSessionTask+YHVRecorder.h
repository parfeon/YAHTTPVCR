#import <Foundation/Foundation.h>


/**
 * @brief      Extension which add ability to record \a NSURLSessionTask results.
 * @discussion VCR's data recording extension to track session task results.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface YHVNSURLSessionTask : NSObject


#pragma mark Initialization

/**
 * @brief  Make changes to \a NSURLSessionTask class to enable data recording.
 */
+ (void)makeRecordable;

#pragma mark -


@end
