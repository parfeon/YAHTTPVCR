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
 * @brief  Stores whether request has been ignored by VCR or not.
 *
 * @since 1.1.0
 */
@property (nonatomic, assign) BOOL YHV_VCRIgnored;

/**
 * @brief  Stores whether request delivered using \a NSURLSession or \a NSURLConnection.
 *
 * @since 1.1.0
 */
@property (nonatomic, assign) BOOL YHV_usingNSURLSession;

/**
 * @brief  Stores reference on unique request identifier (inherited from task or own).
 *
 * @since 1.1.0
 */
@property (nonatomic, copy) NSString *YHV_identifier;

/**
 * @brief  Stores reference on identifier of cassette which handle this request.
 */
@property (nonatomic, copy) NSString *YHV_cassetteIdentifier;

/**
 * @brief  Stores reference on identifier of chapter in which this request used.
 */
@property (nonatomic, copy) NSString *YHV_cassetteChapterIdentifier;


#pragma mark - Compare

/**
 * @brief  Check whether receiver is equal to target or not.
 *
 * @param request Reference on targert request against which check should be done.
 *
 * @return \c YES in case if requests main information are equal.
 *
 * @since 1.3.0
 */
- (BOOL)YHV_isEqual:(NSURLRequest *)request;

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
