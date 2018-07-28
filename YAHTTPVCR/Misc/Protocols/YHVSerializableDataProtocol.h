#import <Foundation/Foundation.h>


/**
 * @brief      Protocol for objects which declare their serializeability.
 * @discussion Each object which expect to be serialized by VCR during cassette save/load should conform to this protocol.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@protocol YHVSerializableDataProtocol <NSObject>


#pragma mark - Serialization

/**
 * @brief  Serialize content and type of secene into dictionary.
 *
 * @return Reference on dictionary which can be used later to restore \b YHVScene instance from it.
 */
- (NSDictionary *)YHV_dictionaryRepresentation;


#pragma mark - Deserialization

/**
 * @brief  Create and configure instance using previously generated dictionary.
 *
 * @param dictionary Reference on serialized instance data.
 *
 * @return Configured and ready to use instance.
 */
+ (instancetype)YHV_objectFromDictionary:(NSDictionary *)dictionary;

#pragma mark -


@end
