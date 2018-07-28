#import <Foundation/Foundation.h>


/**
 * @brief  Extension which add ability to add custom \a NSURLProtocol to any \a NSURLSessionConfiguration instances.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface YHVNSURLSessionConfiguration: NSObject


#pragma mark Initialization

/**
 * @brief  Make changes to \a NSURLSessionTask class to enable data recording.
 */
+ (void)injectProtocol;

#pragma mark -


@end
