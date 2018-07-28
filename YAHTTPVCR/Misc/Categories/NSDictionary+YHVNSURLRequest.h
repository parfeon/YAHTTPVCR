#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \a NSDictionary extension for usage with URL loading system.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface NSDictionary (YHVNSURLRequest)


#pragma mark NSURLRequest

/**
 * @brief      Create and configure \a NSDictionary using request's POST body.
 * @discussion Serialize \c request's POST body to dictionary if it is possible. POST body can be serialized only for requests with following
 *             \c Content-Type: \c application/json and \c application/x-www-form-urlencoded.
 *
 * @param request Reference on request from which POST body should be serialized to dictionary.
 *
 * @return Configured and ready to use dictionary or \c nil in case if POST body content can't be serialized.
 */
+ (nullable instancetype)YHV_dictionaryFromNSURLRequestPOSTBody:(NSURLRequest *)request;

/**
 * @brief      Create and configure \a NSDictionary using request's POST body.
 * @discussion Serialize \c response's received data to dictionary if it is possible. Data can be serialized only for responses with following
 *             \c Content-Type: \c application/json and \c application/x-www-form-urlencoded.
 *
 * @param data     Reference on \c response's body which has been received from remote server.
 * @param response Reference on object which contain information about received \c data.
 *
 * @return Configured and ready to use dictionary or \c nil in case if response's data content can't be serialized.
 */
+ (nullable instancetype)YHV_dictionaryFromData:(NSData *)data forNSHTTPURLResponse:(NSHTTPURLResponse *)response;

/**
 * @brief      Encode dictionary to \a NSData for \c request POST body.
 * @discussion Ecode dictionary to \a NSData instance which can be used as \c request's POST body. This operation possible only for requests with
 *             following \c Content-Type: \c application/json and \c application/x-www-form-urlencoded.
 *
 * @param request Reference on request for which POST body data should be created.
 *
 * @return Encoded to \a NSData object or \c nil in case if \c request's content type not supported.
 */
- (nullable NSData *)YHV_POSTBodyForNSURLRequest:(NSURLRequest *)request;

/**
 * @brief      Encode dictionary to response \a NSData object.
 * @discussion This operation possible only for responses with following \c Content-Type: \c application/json and
 *             \c application/x-www-form-urlencoded.
 *
 * @param response Reference on object for which data should be created.
 *
 * @return Encoded to \a NSData object or \c nil in case if \c response's content type not supported.
 */
- (nullable NSData *)YHV_DataForNSHTTPURLResponse:(NSHTTPURLResponse *)response;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
