/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSURLRequest+YHVSerialization.h"
#import "NSURLRequest+YHVPlayer.h"
#import "YHVSerializationHelper.h"


#pragma mark Constants

/**
 * @brief  Stores reference on key under which name of serialized object class stored inside of serialized dictionary.
 */
static NSString * const kYHVObjectClassKey = @"cls";

/**
 * @brief  Stores reference on key under which request URL string stored inside of serialized dictionary.
 */
static NSString * const kYHVRequestURLKey = @"url";

/**
 * @brief  Stores reference on key under which used HTTP method stored inside of serialized dictionary.
 */
static NSString * const kYHVRequestHTTPMethodKey = @"method";

/**
 * @brief  Stores reference on key under which headers information stored inside of serialized dictionary.
 */
static NSString * const kYHVRequestHeadersKey = @"headers";

/**
 * @brief  Stores reference on key under which POST HTTP body stored inside of serialized dictionary.
 */
static NSString * const kYHVRequestHTTPBodyKey = @"body";

/**
 * @brief  Stores reference on key under which request response cache policy stored inside of serialized dictionary.
 */
static NSString * const kYHVRequestCachePolicyKey = @"cache";

/**
 * @brief  Stores reference on key under which request timeout interval stored inside of serialized dictionary.
 */
static NSString * const kYHVRequestTimeoutKey = @"timeout";

/**
 * @brief  Stores reference on key under which request cookies handling flag stored inside of serialized dictionary.
 */
static NSString * const kYHVRequestCookiesHandlingKey = @"cookies";

/**
 * @brief  Stores reference on key under which request pipeline usage flag stored inside of serialized dictionary.
 */
static NSString * const kYHVRequestPipelineKey = @"pipeline";

/**
 * @brief  Stores reference on key under which request cellular usage flag stored inside of serialized dictionary.
 */
static NSString * const kYHVRequestCellularKey = @"cellular";

/**
 * @brief  Stores reference on key under which request network service type stored inside of serialized dictionary.
 */
static NSString * const kYHVRequestNetworkTypeKey = @"network";


#pragma mark - Interface implementation

@implementation NSURLRequest (YHVSerialization)


#pragma mark - Serializable protocol methods

- (NSDictionary *)YHV_dictionaryRepresentation {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        kYHVObjectClassKey: NSStringFromClass([NSURLRequest class])
    }];
    dictionary[kYHVRequestURLKey] = self.URL.absoluteString;
    dictionary[kYHVRequestHTTPMethodKey] = self.HTTPMethod.lowercaseString;
    dictionary[kYHVRequestHeadersKey] = self.allHTTPHeaderFields;
    dictionary[kYHVRequestHTTPBodyKey] = [YHVSerializationHelper dictionaryFromObject:(id)self.YHV_HTTPBody];
    dictionary[kYHVRequestCachePolicyKey] = @(self.cachePolicy);
    dictionary[kYHVRequestTimeoutKey] = @(self.timeoutInterval);
    dictionary[kYHVRequestCookiesHandlingKey] = @(self.HTTPShouldHandleCookies);
    dictionary[kYHVRequestPipelineKey] = @(self.HTTPShouldUsePipelining);
    dictionary[kYHVRequestCellularKey] = @(self.allowsCellularAccess);
    dictionary[kYHVRequestNetworkTypeKey] = @(self.networkServiceType);
    
    return dictionary;
}

+ (instancetype)YHV_objectFromDictionary:(NSDictionary *)dictionary {
    
    NSAssert(dictionary, @"[%@] Unable initialize NSURLRequest instance from 'nil'.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVRequestURLKey], @"[%@] Request URL is missing.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVRequestHTTPMethodKey], @"[%@] Request HTTP method is missing.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVRequestCachePolicyKey], @"[%@] Request cache policy is missing.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVRequestTimeoutKey], @"[%@] Request timeout is missing.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVRequestCookiesHandlingKey], @"[%@] Request cookies handling flag is missing.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVRequestPipelineKey], @"[%@] Request pipeline usage flag is missing.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVRequestCellularKey], @"[%@] Request cellular usage flag is missing.", NSStringFromClass(self));
    NSAssert(dictionary[kYHVRequestNetworkTypeKey], @"[%@] Request network service type is missing.", NSStringFromClass(self));
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dictionary[kYHVRequestURLKey]]
                                                           cachePolicy:((NSNumber *)dictionary[kYHVRequestCachePolicyKey]).unsignedIntegerValue
                                                       timeoutInterval:((NSNumber *)dictionary[kYHVRequestTimeoutKey]).doubleValue];
    request.HTTPMethod = ((NSString *)dictionary[kYHVRequestHTTPMethodKey]).lowercaseString;
    [request setAllHTTPHeaderFields:dictionary[kYHVRequestHeadersKey]];
    request.HTTPBody = (NSData *)[YHVSerializationHelper objectFromDictionary:(id)dictionary[kYHVRequestHTTPBodyKey]];
    request.HTTPShouldHandleCookies = ((NSNumber *)dictionary[kYHVRequestCookiesHandlingKey]).boolValue;
    request.HTTPShouldUsePipelining = ((NSNumber *)dictionary[kYHVRequestPipelineKey]).boolValue;
    request.allowsCellularAccess = ((NSNumber *)dictionary[kYHVRequestCellularKey]).boolValue;
    request.networkServiceType = ((NSNumber *)dictionary[kYHVRequestNetworkTypeKey]).unsignedIntegerValue;
    
    return request;
}

#pragma mark -


@end
