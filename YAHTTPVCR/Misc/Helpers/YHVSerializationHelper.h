#import "YHVSerializableDataProtocol.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Objects serialization initialization helper.
 * @discussion Helper class which allow easily serialize and initialize from dictionary object.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface YHVSerializationHelper : NSObject


#pragma mark Serialization

/**
 * @brief  Serialize passed \c object to \a NSDictionary instance.
 *
 * @param object Reference on object which should be serialized.
 *
 * @return \c object dictionary representation.
 */
+ (NSDictionary *)dictionaryFromObject:(nullable id<YHVSerializableDataProtocol>)object;


#pragma mark - Initialization and Configuration

/**
 * @brief  Create and configiure object from passed \c dictionary.
 *
 * @param dictionary Reference on dictionary which contain information about object and it's data.
 *
 * @return Configured and ready to use object instance.
 */
+ (id<YHVSerializableDataProtocol>)objectFromDictionary:(nullable NSDictionary *)dictionary;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
