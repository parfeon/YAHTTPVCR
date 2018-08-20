/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSURLRequest+YHVPlayer.h"
#import "YHVMethodsSwizzler.h"


#pragma mark Constants

static NSString * const kYHVRequestCassetteChapterIdentifierKey = @"YHVRequestCassetteChapterIdentifier";
static NSString * const kYHVRequestCassetteIdentifierKey = @"YHVRequestCassetteIdentifier";
static NSString * const kYHVRequestUsingSessionKey = @"YHVRequestUsingSession";
static NSString * const kYHVRequestIdentifierKey = @"YHVRequestIdentifier";
static NSString * const kYHVRequestPOSTBodyKey = @"YHVRequestPOSTBody";
static NSString * const kYHVRequestIgnoredKey = @"kYHVRequestIgnored";


@interface YHVNSURLRequest ()


#pragma mark - Swizzle methods

- (void)YHV_setHTTPBody:(NSData * _Nullable)HTTPBody;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation NSURLRequest (YHVPlayer)


#pragma mark - Information

- (NSData *)YHV_HTTPBody {
    
    return [NSURLProtocol propertyForKey:kYHVRequestPOSTBodyKey inRequest:self] ?: self.HTTPBody;
}

- (void)setYHV_VCRIgnored:(BOOL)ignored {
    
    [NSURLProtocol setProperty:@(ignored) forKey:kYHVRequestIgnoredKey inRequest:(NSMutableURLRequest *)self];
}

- (BOOL)YHV_VCRIgnored {
    
    return ((NSNumber *)[NSURLProtocol propertyForKey:kYHVRequestIgnoredKey inRequest:self]).boolValue;
}

- (void)setYHV_usingNSURLSession:(BOOL)usingNSURLSession {
    
    [NSURLProtocol setProperty:@(usingNSURLSession) forKey:kYHVRequestUsingSessionKey inRequest:(NSMutableURLRequest *)self];
}

- (BOOL)YHV_usingNSURLSession {
    
    return ((NSNumber *)[NSURLProtocol propertyForKey:kYHVRequestUsingSessionKey inRequest:self]).boolValue;
}

- (void)setYHV_identifier:(NSString *)identifier {
    
    if (!self.YHV_identifier) {
        [NSURLProtocol setProperty:identifier forKey:kYHVRequestIdentifierKey inRequest:(NSMutableURLRequest *)self];
    }
}

- (NSString *)YHV_identifier {
    
    return [NSURLProtocol propertyForKey:kYHVRequestIdentifierKey inRequest:self];
}

- (void)setYHV_cassetteIdentifier:(NSString *)identifier {
    
    if (!self.YHV_cassetteIdentifier) {
        [NSURLProtocol setProperty:identifier forKey:kYHVRequestCassetteIdentifierKey inRequest:(NSMutableURLRequest *)self];
    }
}

- (NSString *)YHV_cassetteIdentifier {
    
    return [NSURLProtocol propertyForKey:kYHVRequestCassetteIdentifierKey inRequest:self];
}

- (void)setYHV_cassetteChapterIdentifier:(NSString *)identifier {
    
    if (!self.YHV_cassetteChapterIdentifier) {
        [NSURLProtocol setProperty:identifier forKey:kYHVRequestCassetteChapterIdentifierKey inRequest:(NSMutableURLRequest *)self];
    }
}

- (NSString *)YHV_cassetteChapterIdentifier {
    
    return [NSURLProtocol propertyForKey:kYHVRequestCassetteChapterIdentifierKey inRequest:self];
}


#pragma mark - Compare

- (BOOL)YHV_isEqual:(NSURLRequest *)request {
    
    if (self.cachePolicy != request.cachePolicy) {
        return NO;
    }
    
    if (self.timeoutInterval != request.timeoutInterval) {
        return NO;
    }
    
    if (self.HTTPShouldHandleCookies != request.HTTPShouldHandleCookies) {
        return NO;
    }
    
    if (self.HTTPShouldUsePipelining != request.HTTPShouldUsePipelining) {
        return NO;
    }
    
    if (self.allowsCellularAccess != request.allowsCellularAccess) {
        return NO;
    }
    
    if (self.networkServiceType != request.networkServiceType) {
        return NO;
    }
    
    if (![self.HTTPMethod isEqualToString:request.HTTPMethod]) {
        return NO;
    }
    
    if (![self.URL isEqual:request.URL]) {
        return NO;
    }
    
    if ((!self.HTTPBody.length && request.HTTPBody.length) || (self.HTTPBody.length && !request.HTTPBody.length) ||
        (self.HTTPBody.length && request.HTTPBody.length && ![self.HTTPBody isEqual:request.HTTPBody])) {
        return NO;
    }
    
    if ((!self.HTTPBodyStream && request.HTTPBodyStream) || (self.HTTPBodyStream && !request.HTTPBodyStream) ||
        (self.HTTPBodyStream && request.HTTPBodyStream  && ![self.HTTPBodyStream isEqual:request.HTTPBodyStream])) {
        
        return NO;
    }
    
    if ((!self.mainDocumentURL && request.mainDocumentURL) || (self.mainDocumentURL && !request.mainDocumentURL) ||
        (self.mainDocumentURL && request.mainDocumentURL && ![self.mainDocumentURL isEqual:request.mainDocumentURL])) {
        
        return NO;
    }
    
    if ((!self.allHTTPHeaderFields.count && request.allHTTPHeaderFields.count) ||
        (self.allHTTPHeaderFields.count && !request.allHTTPHeaderFields.count) ||
        (self.allHTTPHeaderFields.count && request.allHTTPHeaderFields.count && ![self.allHTTPHeaderFields isEqual:request.allHTTPHeaderFields])) {
        
        return NO;
    }
    
    return YES;
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
        [NSURLProtocol setProperty:data forKey:kYHVRequestPOSTBodyKey inRequest:(NSMutableURLRequest *)self];
    }
    
    [self YHV_setHTTPBody:HTTPBody];
}

#pragma mark -


@end
