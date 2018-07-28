#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \a NSDictionary extension to make data manipulation easier.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface NSMutableDictionary (YHVMisc)


#pragma mark Misc

/**
 * @brief  Replace values for keys which exists in receiving and \c dictionary dictionaries.
 *
 * @param dictionary Reference on dictionary from which values for existing keys should be taken.
 *
 * @return Reference on receiver so methods can be chained.
 */
- (NSMutableDictionary *)YHV_replaceValuesWithValuesFromDictionary:(NSDictionary *)dictionary;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
