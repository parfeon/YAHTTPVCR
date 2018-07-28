#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \a NSDictionary extension for usage with URL loading system.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface NSDictionary (YHVNSURL)


#pragma mark NSURL

/**
 * @brief  Create dictionary which contain key/value pairs from NSRUL query part.
 *
 * @param urlQuery Reference on \a NSURL's query string which should be parsed.
 *
 * @return Dictionary with keys and values extracted from NSURL query part.
 */
+ (instancetype)YHV_dictionaryWithQuery:(NSString *)urlQuery;

/**
 * @brief      Encode data stored in dictionary to query string.
 * @discussion All nested JSON compatible objects will be encoded to string with \a NSJSONSerialization.
 *
 * @return \a NSURL query string or \c nil in case if there is no data for serialization.
 */
- (nullable NSString *)YHV_toQueryString;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
