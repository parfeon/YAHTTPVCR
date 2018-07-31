/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSURLSessionTask+YHVRecorder.h"
#import "NSHTTPURLResponse+YHVMisc.h"
#import "NSURLRequest+YHVPlayer.h"
#import "YHVMethodsSwizzler.h"
#import "YHVVCR+Recorder.h"
#import "YHVVCR+Player.h"


#pragma mark Protected interface declaration

@interface YHVNSURLSessionTask ()


#pragma mark - Swizzle methods

- (void)YHV_setError:(id)error;
- (void)YHV_setResponse:(id)response;
- (void)YHV_updateCurrentRequest:(NSURLRequest *)request;

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
    
    if (!task.originalRequest.YHV_cassetteChapterIdentifier && !task.currentRequest.YHV_cassetteChapterIdentifier) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            response = [response YHV_responseForRequest:task.originalRequest];
        }
        
        [YHVVCR recordResponse:response forTask:task];
    }
    
    [self YHV_setResponse:response];
}

- (void)YHV_updateCurrentRequest:(NSURLRequest *)request {
    
    NSURLSessionTask *task = (NSURLSessionTask *)self;
    
    if (request.YHV_cassetteChapterIdentifier && !task.originalRequest.YHV_cassetteChapterIdentifier) {
        task.originalRequest.YHV_cassetteChapterIdentifier = request.YHV_cassetteChapterIdentifier;
    }
    
    if (request.YHV_usingNSURLSession && !task.originalRequest.YHV_usingNSURLSession) {
        task.originalRequest.YHV_usingNSURLSession = request.YHV_usingNSURLSession;
    }
    
    if (request.YHV_identifier && !task.originalRequest.YHV_identifier) {
        task.originalRequest.YHV_identifier = request.YHV_identifier;
    }
    
    if (request.YHV_VCRIgnored && !task.originalRequest.YHV_VCRIgnored) {
        task.originalRequest.YHV_VCRIgnored = request.YHV_VCRIgnored;
    }
    
    [self YHV_updateCurrentRequest:request];
}

#pragma mark -


@end
