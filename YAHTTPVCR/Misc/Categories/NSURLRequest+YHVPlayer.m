/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSURLRequest+YHVPlayer.h"
#import "YHVMethodsSwizzler.h"
#import <objc/runtime.h>


#pragma mark Constants

static const void *YHVRequestCassetteChapterIDKey = &YHVRequestCassetteChapterIDKey;
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
