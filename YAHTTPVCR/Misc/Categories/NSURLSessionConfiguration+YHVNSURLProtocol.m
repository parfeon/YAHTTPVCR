/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSURLSessionConfiguration+YHVNSURLProtocol.h"
#import "YHVMethodsSwizzler.h"
#import "YHVNSURLProtocol.h"


#pragma mark Proteced interface declaration

@interface YHVNSURLSessionConfiguration ()


#pragma mark - Swizzle methods

+ (id)YHV_backgroundSessionConfiguration:(id)arg1;
+ (id)YHV_backgroundSessionConfigurationWithIdentifier:(id)arg1;
+ (id)YHV_defaultSessionConfiguration;
+ (id)YHV_ephemeralSessionConfiguration;
+ (id)YHV_sessionConfigurationForSharedSession;


#pragma mark - Misc

/**
 * @brief  Add VCR's protocol to provide stub ability.
 *
 * @param configuration Reference on \a NSURLSessionConfiguration instance which has been used to setup new session and should be patched.
 */
+ (void)addProtocolToConfiguration:(NSURLSessionConfiguration *)configuration;

#pragma mark -


@end



#pragma mark - Interface implementation

@implementation YHVNSURLSessionConfiguration


#pragma mark - Initialization

+ (void)injectProtocol {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [YHVMethodsSwizzler swizzleMethodsIn:[NSURLSessionConfiguration class] withMethodsFrom:self prefix:@"YHV_"];
        [NSURLProtocol registerClass:[YHVNSURLProtocol class]];
    });
}


#pragma mark - Swizzle methods

+ (id)YHV_backgroundSessionConfiguration:(id)arg1 {
    
    NSURLSessionConfiguration *configuration = [self YHV_backgroundSessionConfiguration:arg1];
    [YHVNSURLSessionConfiguration addProtocolToConfiguration:configuration];
    
    return configuration;
}

+ (id)YHV_backgroundSessionConfigurationWithIdentifier:(id)arg1 {
    
    NSURLSessionConfiguration *configuration = [self YHV_backgroundSessionConfigurationWithIdentifier:arg1];
    [YHVNSURLSessionConfiguration addProtocolToConfiguration:configuration];
    
    return configuration;
}

+ (id)YHV_defaultSessionConfiguration {
    
    NSURLSessionConfiguration *configuration = [self YHV_defaultSessionConfiguration];
    [YHVNSURLSessionConfiguration addProtocolToConfiguration:configuration];
    
    return configuration;
}

+ (id)YHV_ephemeralSessionConfiguration {
    
    NSURLSessionConfiguration *configuration = [self YHV_ephemeralSessionConfiguration];
    [YHVNSURLSessionConfiguration addProtocolToConfiguration:configuration];
    
    return configuration;
}

+ (id)YHV_sessionConfigurationForSharedSession {
    
    NSURLSessionConfiguration *configuration = [self YHV_sessionConfigurationForSharedSession];
    [YHVNSURLSessionConfiguration addProtocolToConfiguration:configuration];
    
    return configuration;
}


#pragma mark - Misc

+ (void)addProtocolToConfiguration:(NSURLSessionConfiguration *)configuration {
    
    NSMutableArray *protocols = [NSMutableArray arrayWithArray:configuration.protocolClasses];
    [protocols insertObject:[YHVNSURLProtocol class] atIndex:0];
    
    configuration.protocolClasses = protocols;
}


#pragma mark -


@end
