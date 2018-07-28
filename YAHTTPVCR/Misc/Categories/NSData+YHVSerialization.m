/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSData+YHVSerialization.h"


#pragma mark Constants

/**
 * @brief  Stores reference on key under which name of serialized object class stored inside of serialized dictionary.
 */
static NSString * const kYHVObjectClassKey = @"cls";

/**
 * @brief  Stores reference on key under which Base64 encoded string stored inside of serialized dictionary.
 */
static NSString * const kYHVDataKey = @"base64";


#pragma mark - Interface implementation

@implementation NSData (YHVSerialization)


#pragma mark - Serializable protocol methods

- (NSDictionary *)YHV_dictionaryRepresentation {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{ kYHVObjectClassKey: NSStringFromClass([NSData class]) }];
    dictionary[kYHVDataKey] = [self base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    
    return dictionary;
}

+ (instancetype)YHV_objectFromDictionary:(NSDictionary *)dictionary {
    
    NSAssert(dictionary, @"[%@] Unable initialize NSURLRequest instance from 'nil'.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVDataKey], @"[%@] Data base64 string is missing.", NSStringFromClass(self));
    
    return [[self alloc] initWithBase64EncodedString:dictionary[kYHVDataKey] options:(NSDataBase64DecodingOptions)0];
}

#pragma mark -


@end
