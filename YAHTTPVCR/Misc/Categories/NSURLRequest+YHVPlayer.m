/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSURLRequest+YHVPlayer.h"
#import "YHVMethodsSwizzler.h"
#import <objc/runtime.h>


#pragma mark Constants

static const void *YHVRequestCassetteChapterIDKey = &YHVRequestCassetteChapterIDKey;
static const void *YHVRequestUsingSessionKey = &YHVRequestUsingSessionKey;
static const void *YHVRequestIdentifierKey = &YHVRequestIdentifierKey;
static const void *YHVRequestIgnoredKey = &YHVRequestIgnoredKey;

static NSString * const kYHVRequestPOSTBody = @"HVRequestPOSTBody";


@interface YHVNSURLRequest ()


#pragma mark - Swizzle methods

- (void)YHV_setHTTPBody:(NSData * _Nullable)HTTPBody;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation NSURLRequest (YHVPlayer)


#pragma mark - Information

- (NSData *)YHV_HTTPBody {
    
    return [NSURLProtocol propertyForKey:kYHVRequestPOSTBody inRequest:self] ?: self.HTTPBody;
}

- (void)setYHV_VCRIgnored:(BOOL)YHV_VCRIgnored {
    
    objc_setAssociatedObject(self, YHVRequestIgnoredKey, @(YHV_VCRIgnored), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)YHV_VCRIgnored {
    
    return ((NSNumber *)objc_getAssociatedObject(self, YHVRequestIgnoredKey)).boolValue;
}

- (void)setYHV_identifier:(NSString *)YHV_identifier {
    
    if (!self.YHV_identifier) {
        objc_setAssociatedObject(self, YHVRequestIdentifierKey, YHV_identifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)setYHV_usingNSURLSession:(BOOL)YHV_usingNSURLSession {
    
    objc_setAssociatedObject(self, YHVRequestUsingSessionKey, @(YHV_usingNSURLSession), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)YHV_usingNSURLSession {
    
    return ((NSNumber *)objc_getAssociatedObject(self, YHVRequestUsingSessionKey)).boolValue;
}

- (NSString *)YHV_identifier {
    
    return objc_getAssociatedObject(self, YHVRequestIdentifierKey);
}

- (void)setYHV_cassetteChapterIdentifier:(NSString *)identifier {
    
    if (!self.YHV_cassetteChapterIdentifier) {
        objc_setAssociatedObject(self, YHVRequestCassetteChapterIDKey, identifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (NSString *)YHV_cassetteChapterIdentifier {
    
    return objc_getAssociatedObject(self, YHVRequestCassetteChapterIDKey);
}

#pragma mark -


@end


@implementation YHVNSURLRequest


#pragma mark - Initialization

+ (void)patch {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [YHVMethodsSwizzler swizzleMethodsIn:NSClassFromString(@"NSMutableURLRequest") withMethodsFrom:self prefix:@"YHV_"];
    });
}


#pragma mark - Swizzle methods

- (void)YHV_setHTTPBody:(NSData *)HTTPBody {
    
    NSData *data = HTTPBody ?: ((NSURLRequest *)self).HTTPBody;
    
    if (data) {
        [NSURLProtocol setProperty:data forKey:kYHVRequestPOSTBody inRequest:(NSMutableURLRequest *)self];
    }
    
    [self YHV_setHTTPBody:HTTPBody];
}

#pragma mark -


@end
