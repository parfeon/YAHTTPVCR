/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVSerializationHelper.h"


#pragma mark Constants

/**
 * @brief  Stores reference on key under which name of serialized object class stored inside of serialized dictionary.
 */
static NSString * const kYHVObjectClassKey = @"cls";


#pragma mark - Interface implementation

@implementation YHVSerializationHelper


#pragma mark - Serialization

+ (NSDictionary *)dictionaryFromObject:(id<YHVSerializableDataProtocol>)object {
    
    if (![object respondsToSelector:@selector(YHV_dictionaryRepresentation)]) {
        return (id)object;
    }
    
    return [object YHV_dictionaryRepresentation];
}

+ (id<YHVSerializableDataProtocol>)objectFromDictionary:(NSDictionary *)dictionary {
    
    Class<YHVSerializableDataProtocol> cls = nil;
    
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return (id)dictionary;
    }
    
    if (dictionary[kYHVObjectClassKey]) {
        cls = NSClassFromString(dictionary[kYHVObjectClassKey]);
        NSMutableDictionary *updatedDictionary = [dictionary mutableCopy];
        [updatedDictionary removeObjectForKey:kYHVObjectClassKey];
    }
    
    return [cls YHV_objectFromDictionary:dictionary];
}

#pragma mark -


@end
