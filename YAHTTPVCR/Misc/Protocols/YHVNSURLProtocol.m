/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVNSURLProtocol.h"
#import "NSURLRequest+YHVPlayer.h"
#import "YHVVCR+Player.h"


#pragma mark Interface implementation

@implementation YHVNSURLProtocol


#pragma mark - Request handling

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    return [YHVVCR canPlayResponseForRequest:request];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    return request;
}

- (instancetype)initWithRequest:(NSURLRequest *)request
                 cachedResponse:(NSCachedURLResponse *)__unused cachedResponse
                         client:(id<NSURLProtocolClient>)client {
    
    YHVNSURLProtocol *protocol = [super initWithRequest:request cachedResponse:nil client:client];
    
    [YHVVCR prepareToPlayResponsesWithProtocol:protocol];
    
    return protocol;
}


#pragma mark - Remote data fetching

- (void)startLoading {
    
    [YHVVCR playResponsesForRequest:self.request];
}

- (void)stopLoading {
    
    // Do nothing, but should be implemented by URL protocol subclass.
}

#pragma mark -


@end
