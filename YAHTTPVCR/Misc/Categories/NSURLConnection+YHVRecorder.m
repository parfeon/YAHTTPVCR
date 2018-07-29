/**
 * @author Serhii Mamontov
 * @since 1.1.0
 */
#import "NSURLConnection+YHVRecorder.h"
#import "NSHTTPURLResponse+YHVMisc.h"
#import "YHVMethodsSwizzler.h"
#import "YHVVCR+Recorder.h"
#import "YHVVCR+Player.h"


#pragma mark Structures

/**
 * @brief      Request host filter block.
 * @discussion This block called once for each new request and allow to pass or ignore request.
 *
 * @param response        Reference on response object which created from service provided data.
 * @param data            Reference on service response body.
 * @param connectionError Reference on error which occurred during request.
 */
typedef void(^YHVNSURLComplectionBlock)(NSURLResponse * __nullable response, NSData * __nullable data, NSError * __nullable connectionError);


#pragma mark Protected interface declaration

@interface YHVNSURLConnection ()


#pragma mark - Swizzle methods

+ (id)YHV_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;
+ (void)YHV_sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(YHVNSURLComplectionBlock)handler;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation YHVNSURLConnection


+ (void)makeRecordable {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [YHVMethodsSwizzler swizzleMethodsIn:NSClassFromString(@"NSURLConnection") withMethodsFrom:self prefix:@"YHV_"];
    });
}


#pragma mark - Swizzle methods

+ (id)YHV_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {

    BOOL hasStubForRequest = [YHVVCR canPlayResponseForRequest:request];
    NSURLResponse *recordedResponse = nil;
    NSError *recordedError = nil;
    
    if (!hasStubForRequest) {
        [YHVVCR beginRecordingRequest:request];
    }
    
    NSData *recordedData = [self YHV_sendSynchronousRequest:request returningResponse:&recordedResponse error:&recordedError];
   
    
    if ([recordedResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        recordedResponse = [(NSHTTPURLResponse *)recordedResponse YHV_responseForRequest:request];
    }
    
    if (!hasStubForRequest && recordedResponse) {
        [YHVVCR recordResponse:recordedResponse forRequest:request];
    }
    
    if (!hasStubForRequest && !recordedError) {
        [YHVVCR recordData:recordedData forRequest:request];
    }
    
    if (!hasStubForRequest) {
        [YHVVCR recordCompletionWithError:recordedError forRequest:request];
    }
    
    if (response && recordedResponse) {
        *response = recordedResponse;
    }
    
    if (error && recordedError) {
        *error = recordedError;
    }
    
    return recordedData;
}

+ (void)YHV_sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(YHVNSURLComplectionBlock)handler {

    BOOL hasStubForRequest = [YHVVCR canPlayResponseForRequest:request];
    YHVNSURLComplectionBlock recordableHanlder = ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         NSURLResponse *recordedResponse = response;
        
        if ([recordedResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            recordedResponse = [(NSHTTPURLResponse *)recordedResponse YHV_responseForRequest:request];
        }
        
        if (!hasStubForRequest && recordedResponse) {
            [YHVVCR recordResponse:recordedResponse forRequest:request];
        }
        
        if (!hasStubForRequest && !connectionError) {
            [YHVVCR recordData:data forRequest:request];
        }
        
        if (!hasStubForRequest) {
            [YHVVCR recordCompletionWithError:connectionError forRequest:request];
        }
        
        if (handler) {
            handler(recordedResponse, data, connectionError);
        }
    };
    
    if (!hasStubForRequest) {
        [YHVVCR beginRecordingRequest:request];
    }
    
    [self YHV_sendAsynchronousRequest:request queue:queue completionHandler:recordableHanlder];
}

#pragma mark -


@end
