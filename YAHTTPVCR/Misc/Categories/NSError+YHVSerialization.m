/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSError+YHVSerialization.h"


#pragma mark Constants

/**
 * @brief  Stores reference on key under which name of serialized object class stored inside of serialized dictionary.
 */
static NSString * const kYHVObjectClassKey = @"cls";

/**
 * @brief  Stores reference on key under which error domain name stored inside of serialized dictionary.
 */
static NSString * const kYHVErrorDomainKey = @"domain";

/**
 * @brief  Stores reference on key under which error code stored inside of serialized dictionary.
 */
static NSString * const kYHVErrorCodeKey = @"code";

/**
 * @brief  Stores reference on key under which error information (descriptions and error reasons) stored inside of serialized dictionary.
 */
static NSString * const kYHVErrorUserInfoKey = @"info";


#pragma mark - Interface implementation

@implementation NSError (YHVSerialization)


#pragma mark - Serializable protocol methods

- (NSDictionary *)YHV_dictionaryRepresentation {
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{ kYHVObjectClassKey: NSStringFromClass([NSError class]) }];
    dictionary[kYHVErrorDomainKey] = self.domain;
    dictionary[kYHVErrorCodeKey] = @(self.code);
    
    if (userInfo[NSUnderlyingErrorKey]) {
        userInfo[NSUnderlyingErrorKey] = [(NSError *)userInfo[NSUnderlyingErrorKey] YHV_dictionaryRepresentation];
    }
    
    for (NSString *errorInfoKey in @[NSURLErrorKey, NSURLErrorFailingURLErrorKey]) {
        if (!userInfo[errorInfoKey]) {
            continue;
        }
        
        userInfo[errorInfoKey] = ((NSURL *)userInfo[errorInfoKey]).absoluteString;
    }
    
    [userInfo removeObjectsForKeys:@[NSURLErrorFailingURLPeerTrustErrorKey, NSRecoveryAttempterErrorKey]];
    
    dictionary[kYHVErrorUserInfoKey] = userInfo;
    
    return dictionary;
}

+ (instancetype)YHV_objectFromDictionary:(NSDictionary *)dictionary {
    
    NSAssert(dictionary, @"[%@] Unable initialize NSError instance from 'nil'.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVErrorDomainKey], @"[%@] Error domain is missing.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVErrorCodeKey], @"[%@] Error code is missing.", NSStringFromClass(self));
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:dictionary[kYHVErrorUserInfoKey]];
    
    if (userInfo[NSUnderlyingErrorKey]) {
        userInfo[NSUnderlyingErrorKey] = [NSError YHV_objectFromDictionary:userInfo[NSUnderlyingErrorKey]];
    }
    
    for (NSString *errorInfoKey in @[NSURLErrorKey, NSURLErrorFailingURLErrorKey]) {
        if (!userInfo[errorInfoKey]) {
            continue;
        }
        
        userInfo[errorInfoKey] = [NSURL URLWithString:userInfo[errorInfoKey]];
    }
    
    return [NSError errorWithDomain:dictionary[kYHVErrorDomainKey]
                               code:((NSNumber *)dictionary[kYHVErrorCodeKey]).integerValue
                           userInfo:userInfo];
}

#pragma mark -


@end
