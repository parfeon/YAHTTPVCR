#import <Foundation/Foundation.h>

/**
 * @brief      \a NSURLRequest functionality extension.
 * @discussion Provides functinoality which allow to bind request to chapter on cassette.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface NSURLRequest (YHVPlayer)


#pragma mark Information

/**
 * @brief  Stores reference on configured POST body.
 */
@property (nonatomic, readonly, strong) NSData *YHV_HTTPBody;

/**
 * @brief  Stores reference on identifier of chapter in which this request used.
 */
@property (nonatomic, copy) NSString *YHV_cassetteChapterIdentifier;

#pragma mark -


@end


/**
 * @brief  \a NSURLRequest interface extension.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface YHVNSURLRequest : NSObject


#pragma mark Initialization

/**
 * @brief  Patch native \a NSURLRequest interface.
 */
+ (void)patch;

#pragma mark -


@end
