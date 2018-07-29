/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSURLSessionConnection+YHVRecorder.h"
#import "NSURLRequest+YHVPlayer.h"
#import "YHVMethodsSwizzler.h"
#import "YHVVCR+Recorder.h"
#import "YHVVCR+Player.h"


#pragma mark Protected interface declaration

@interface YHVNSURLSessionConnection ()


#pragma mark - Information

/**
 * @brief      Reference on task.
 * @discussion When this called on \c self from within swizzled method, it will became reference on private \a NSURLSessionConnection property.
 */
@property (nonatomic, readonly, copy) NSURLSessionTask *task;


#pragma mark - Swizzle methods

- (id)YHV_initWithTask:(id)arg1 delegate:(id)arg2 delegateQueue:(id)arg3;
- (void)YHV__redirectRequest:(id)request redirectResponse:(id)response completion:(id)block;
- (void)YHV__didReceiveData:(id)data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation YHVNSURLSessionConnection

@dynamic task;


#pragma mark - Initialization

+ (void)makeRecordable {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [YHVMethodsSwizzler swizzleMethodsIn:NSClassFromString(@"__NSCFURLLocalSessionConnection") withMethodsFrom:self prefix:@"YHV_"];
    });
}


#pragma mark - Swizzle methods

- (id)YHV_initWithTask:(NSURLSessionTask *)task delegate:(id)delegate delegateQueue:(id)queue {

    task.originalRequest.YHV_usingNSURLSession = YES;
    task.currentRequest.YHV_usingNSURLSession = YES;
    
    if (task.originalRequest.YHV_cassetteChapterIdentifier || task.currentRequest.YHV_cassetteChapterIdentifier) {
        [YHVVCR handleRequestPlayedForTask:task];
    } else {
        [YHVVCR beginRecordingTask:task];
    }
    
    return [self YHV_initWithTask:task delegate:delegate delegateQueue:queue];
}

- (void)YHV__redirectRequest:(id)request redirectResponse:(id)response completion:(id)block {
    
    [YHVVCR clearFetchedDataForTask:self.task];
    
    [self YHV__redirectRequest:request redirectResponse:response completion:block];
}

- (void)YHV__didReceiveData:(id)data {
    
    if (self.task.originalRequest.YHV_cassetteChapterIdentifier || self.task.currentRequest.YHV_cassetteChapterIdentifier) {
        [YHVVCR handleDataPlayedForTask:self.task];
    } else {
        [YHVVCR recordData:data forTask:self.task];
    }
    
    [self YHV__didReceiveData:data];
}

#pragma mark -


@end
