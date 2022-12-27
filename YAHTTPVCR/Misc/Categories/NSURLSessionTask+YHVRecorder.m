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
#import <objc/runtime.h>


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
        Class className = NSClassFromString(@"__NSCFURLSessionTask");
        
        // Check whether expected class exists and search replacement for it if not.
        if (!className) {
            unsigned int clsCount;
            Class *clss = objc_copyClassList(&clsCount);
            NSMutableArray<NSString *> *suitableClasses = [NSMutableArray new];
            
            for (NSUInteger clsIdx = 0; clsIdx < clsCount; clsIdx++) {
                Class cls = clss[clsIdx];
                NSString *clsName = NSStringFromClass(cls);
                if ([clsName rangeOfString:@"session"].location != NSNotFound ||
                    [clsName rangeOfString:@"Session"].location != NSNotFound) {
                    
                    NSMutableArray *methodsToCheck = [@[@"setError:", @"setResponse:", @"updateCurrentRequest:"] mutableCopy];
                    unsigned int methodsCount;
                    Method *methods = class_copyMethodList(cls, &methodsCount);
                    
                    for (NSUInteger methodIdx = 0; methodIdx < methodsCount; methodIdx++) {
                        Method method = methods[methodIdx];
                        NSString *methodName = NSStringFromSelector(method_getName(method));
                        
                        if ([methodsToCheck containsObject:methodName]) {
                            [methodsToCheck removeObject:methodName];
                        }
                    }
                    
                    if (methodsToCheck.count == 0) {
                        [suitableClasses addObject:clsName];
                    }
                    
                    free(methods);
                }
            }
            free(clss);
            
            if (suitableClasses.count > 0) {
                className = NSClassFromString(suitableClasses.firstObject);
            }
        }
        
        [YHVMethodsSwizzler swizzleMethodsIn:className withMethodsFrom:self prefix:@"YHV_"];
    });
}


#pragma mark - Swizzle methods

- (void)YHV_setError:(id)error {
    
    NSURLSessionTask *task = (NSURLSessionTask *)self;
    
    if (task.originalRequest.YHV_cassetteChapterIdentifier || task.currentRequest.YHV_cassetteChapterIdentifier) {
        if (((NSError *)error).code != NSURLErrorCancelled) {
            [YHVVCR handleError:error playedForTask:task];
        }
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
    
    if (request.YHV_cassetteIdentifier && !task.originalRequest.YHV_cassetteIdentifier) {
        task.originalRequest.YHV_cassetteIdentifier = request.YHV_cassetteIdentifier;
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
