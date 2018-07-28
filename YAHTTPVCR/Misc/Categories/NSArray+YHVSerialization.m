/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSArray+YHVSerialization.h"
#import "YHVSerializationHelper.h"


#pragma mark Constants

/**
 * @brief  Stores reference on key under which name of serialized object class stored inside of serialized dictionary.
 */
static NSString * const kYHVObjectClassKey = @"cls";

/**
 * @brief  Stores reference on key under which array entries stored inside of serialized dictionary.
 */
static NSString * const kYHVArrayKey = @"entries";


#pragma mark Interface implementation

@implementation NSArray (YHVSerialization)


#pragma mark - Serializable protocol methods

- (NSDictionary *)YHV_dictionaryRepresentation {
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (id element in self) {
        [array addObject:[YHVSerializationHelper dictionaryFromObject:element]];
    }
    
    return @{ kYHVObjectClassKey: NSStringFromClass([NSArray class]), kYHVArrayKey: array };
}

+ (instancetype)YHV_objectFromDictionary:(NSDictionary *)dictionary {
    
    NSAssert(dictionary, @"[%@] Unable initialize NSArray instance from 'nil'.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVArrayKey], @"[%@] NSArray entries is missing.", NSStringFromClass(self));
    
    NSMutableArray *array = [NSMutableArray new];
    for (id element in dictionary[kYHVArrayKey]) {
        id object = element;
        [array addObject:[YHVSerializationHelper objectFromDictionary:object]];
    }
    
    return [array copy];
}

#pragma mark -


@end
