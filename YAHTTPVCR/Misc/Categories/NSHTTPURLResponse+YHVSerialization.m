/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSHTTPURLResponse+YHVSerialization.h"
#import "YHVMethodsSwizzler.h"
#import <objc/runtime.h>


#pragma mark Constants

/**
 * @brief  Stores reference on key under which name of serialized object class stored inside of serialized dictionary.
 */
static NSString * const kYHVObjectClassKey = @"cls";

/**
 * @brief  Stores reference on key under which URL string for requested response stored inside of serialized dictionary.
 */
static NSString * const kYHVResponseURLKey = @"url";

/**
 * @brief  Stores reference on key under which received headers information stored inside of serialized dictionary.
 */
static NSString * const kYHVResponseHeadersKey = @"headers";

/**
 * @brief  Stores reference on key under which request processing status code stored inside of serialized dictionary.
 */
static NSString * const kYHVResponseStatusCodeKey = @"status";


#pragma mark Interface implementation

@implementation NSHTTPURLResponse (YHVSerialization)


#pragma mark - Serializable protocol methods

- (NSDictionary *)YHV_dictionaryRepresentation {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        kYHVObjectClassKey: NSStringFromClass([NSHTTPURLResponse class])
    }];
    dictionary[kYHVResponseURLKey] = self.URL.absoluteString;
    dictionary[kYHVResponseHeadersKey] = self.allHeaderFields;
    dictionary[kYHVResponseStatusCodeKey] = @(self.statusCode);
    
    return dictionary;
}

+ (instancetype)YHV_objectFromDictionary:(NSDictionary *)dictionary {
    
    NSAssert(dictionary, @"[%@] Unable initialize NSHTTPURLResponse instance from 'nil'.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVResponseURLKey], @"[%@] Response URL is missing.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVResponseHeadersKey], @"[%@] Response headers is missing.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVResponseStatusCodeKey], @"[%@] Response status code is missing.", NSStringFromClass(self));
    
    return [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:dictionary[kYHVResponseURLKey]]
                                       statusCode:((NSNumber *)dictionary[kYHVResponseStatusCodeKey]).integerValue
                                      HTTPVersion:nil
                                     headerFields:dictionary[kYHVResponseHeadersKey]];
}

#pragma mark -


@end

