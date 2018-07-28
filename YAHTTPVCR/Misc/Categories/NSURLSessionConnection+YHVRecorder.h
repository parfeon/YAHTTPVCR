#import <Foundation/Foundation.h>


/**
 * @brief      Extension which add ability to record \a NSURLSessionConnection state changes.
 * @discussion VCR's data recording extension to track session connection state changes.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface YHVNSURLSessionConnection : NSObject


#pragma mark Initialization

/**
 * @brief  Make changes to \a NSURLSessionConnection class to enable data recording.
 */
+ (void)makeRecordable;

#pragma mark -


@end
