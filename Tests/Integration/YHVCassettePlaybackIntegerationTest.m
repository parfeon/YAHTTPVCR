/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import "YHVIntegrationTestCase.h"


@interface YHVCassettePlaybackIntegerationTest : YHVIntegrationTestCase


#pragma mark -


@end


@implementation YHVCassettePlaybackIntegerationTest


#pragma mark - Setup / Tear down

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {

    [super updateVCRConfigurationFromDefaultConfiguration:configuration];

    if ([self.name rangeOfString:@"WhenHostFilterConfigured"].location != NSNotFound) {
        configuration.hostsFilter = @[@"httpbin.org"];
    }
}

- (void)updateCassetteConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    
    [super updateCassetteConfigurationFromDefaultConfiguration:configuration];
    
    if ([self.name rangeOfString:@"Momentary"].location != NSNotFound) {
        configuration.playbackMode = YHVMomentaryPlayback;
    }
    
    if ([self.name rangeOfString:@"WhenIgnoredInBeforeRecordRequest"].location != NSNotFound) {
        configuration.beforeRecordRequest = ^NSURLRequest * (NSURLRequest *request) {
            if ([request.URL.host rangeOfString:@"github.com"].location != NSNotFound) {
                return nil;
            }
            
            return request;
        };
    }
}


#pragma mark - Tests :: Playback :: GET

- (void)testPlaybackGET_ShouldReturnStubbedResponse {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self sendRequest:targetRequest withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self assertResponse:response playedForRequest:request withData:data];
    }];
}

- (void)testPlaybackGET_ShouldIgnoreAdditionalRequest_WhenHostFilterConfigured {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    NSURLRequest *ghRateLimits = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/rate_limit"]];
    NSArray<NSURLRequest *> *requests = @[targetRequest, ghRateLimits];
    
    [self sendRequests:requests withResultVerificationBlock:nil];
}

- (void)testPlaybackGET_ShouldIgnoreAdditionalRequest_WhenIgnoredInBeforeRecordRequest {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    NSURLRequest *ghRateLimits = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/rate_limit"]];
    NSArray<NSURLRequest *> *requests = @[targetRequest, ghRateLimits];
    
    [self sendRequests:requests withResultVerificationBlock:nil];
}

- (void)testPlaybackGET_ShouldReturnStubbedResponsesChronologically_WhenFewRequestStubbed {
    
    NSArray<NSURLRequest *> *requests = @[[self GETRequestWithPath:@"/delay/2"], [self GETRequestWithPath:@"/get"]];
    __block NSTimeInterval delayCompletionDate = 0;
    __block NSTimeInterval getCompletionDate = 0;
    
    [self sendRequests:requests withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        if ([request.URL.path isEqualToString:requests.firstObject.URL.path]) {
            delayCompletionDate = [NSDate date].timeIntervalSince1970;
            
            [self assertResponse:response playedForRequest:request withData:data];
        } else {
            getCompletionDate = [NSDate date].timeIntervalSince1970;
            
            [self assertResponse:response playedForRequest:request withData:data];
        }
    }];
    
    XCTAssertGreaterThan(delayCompletionDate, getCompletionDate);
}

- (void)testPlaybackGET_ShouldReturnStubbedResponsesMomentary_WhenFewRequestStubbed {
    
    NSArray<NSURLRequest *> *requests = @[[self GETRequestWithPath:@"/delay/2"], [self GETRequestWithPath:@"/get"]];
    __block NSTimeInterval delayCompletionDate = 0;
    __block NSTimeInterval getCompletionDate = 0;
    
    [self sendRequests:requests withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        if ([request.URL.path isEqualToString:requests.firstObject.URL.path]) {
            delayCompletionDate = [NSDate date].timeIntervalSince1970;
            
            [self assertResponse:response playedForRequest:request withData:data];
        } else {
            getCompletionDate = [NSDate date].timeIntervalSince1970;
            
            [self assertResponse:response playedForRequest:request withData:data];
        }
    }];
    
    XCTAssertTrue(delayCompletionDate <= getCompletionDate);
}

- (void)testPlaybackGET_ShouldReturnStubbedResponse_WhenRecordedRedirects {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/absolute-redirect/3"];
    
    [self sendRequest:targetRequest withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self assertResponse:response playedForRequest:request withData:data];
    }];
}

- (void)testPlaybackGET_ShouldReturnStubbedError_WhenRemoteDoesntRespondInTime {
    
    NSMutableURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    targetRequest.timeoutInterval = 1.f;
    
    [self sendRequest:targetRequest withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        XCTAssertNotNil(error);
    }];
}

- (void)testPlaybackGET_ShouldReturnStubbedError_WhenRequestCancelled {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    
    [self sendRequest:targetRequest withCancellationAfter:0.5f
    resultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        XCTAssertNotNil(error);
    }];
}


#pragma mark - Tests :: Playback :: POST

- (void)testPlaybackPOST_ShouldReturnStubbedResponse {
    
    NSURLRequest *targetRequest = [self POSTRequestWithPath:@"/post"];
    
    [self sendRequest:targetRequest withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self assertResponse:response playedForRequest:request withData:data];
    }];
}


#pragma mark -


@end
