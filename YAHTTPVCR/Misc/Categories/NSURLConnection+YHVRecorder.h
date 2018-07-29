#import <Foundation/Foundation.h>

/**
 * @brief      Extension which add ability to record \a NSURLConnection state changes.
 * @discussion VCR's data recording extension to track connection state changes.
 *
 * @author Serhii Mamontov
 * @since 1.1.0
 */
@interface YHVNSURLConnection: NSObject


#pragma mark Initialization

/**
 * @brief  Make changes to \a NSURLConnection class to enable data recording.
 */
+ (void)makeRecordable;

#pragma mark -


@end
