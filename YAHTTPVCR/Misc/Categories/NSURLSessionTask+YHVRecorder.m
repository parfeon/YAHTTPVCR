/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSURLSessionTask+YHVRecorder.h"
#import "NSURLRequest+YHVPlayer.h"
#import "YHVMethodsSwizzler.h"
#import "YHVVCR+Recorder.h"
#import "YHVVCR+Player.h"


#pragma mark Protected interface declaration

@interface YHVNSURLSessionTask ()


#pragma mark - Swizzle methods

- (void)YHV_setError:(id)error;
- (void)YHV_setResponse:(id)response;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation YHVNSURLSessionTask


#pragma mark - Initialization

+ (void)makeRecordable {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [YHVMethodsSwizzler swizzleMethodsIn:NSClassFromString(@"__NSCFURLSessionTask") withMethodsFrom:self prefix:@"YHV_"];
    });
}


#pragma mark - Swizzle methods

- (void)YHV_setError:(id)error {
    
    NSURLSessionTask *task = (NSURLSessionTask *)self;
    
    if (task.originalRequest.YHV_cassetteChapterIdentifier || task.currentRequest.YHV_cassetteChapterIdentifier) {
        [YHVVCR handleError:error playedForTask:task];
    } else {
        [YHVVCR recordCompletionWithError:error forTask:task];
    }
    
    [self YHV_setError:error];
}

- (void)YHV_setResponse:(id)response {
    
    NSURLSessionTask *task = (NSURLSessionTask *)self;
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        response = [[NSHTTPURLResponse alloc] initWithURL:task.originalRequest.URL
                                               statusCode:((NSHTTPURLResponse *)response).statusCode
                                              HTTPVersion:nil
                                             headerFields:((NSHTTPURLResponse *)response).allHeaderFields];
    }
    
    if (task.originalRequest.YHV_cassetteChapterIdentifier || task.currentRequest.YHV_cassetteChapterIdentifier) {
        [YHVVCR handleResponsePlayedForTask:task];
    } else {
        [YHVVCR recordResponse:response forTask:task];
    }
    
    [self YHV_setResponse:response];
}

#pragma mark -


@end
