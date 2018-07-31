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
    
    if ([self.name rangeOfString:@"POSTDataToBodyFilter"].location != NSNotFound) {
        configuration.postBodyFilter = ^NSData * (NSURLRequest *request, NSData *body) {
            XCTAssertNotNil(body);
            
            return [NSJSONSerialization dataWithJSONObject:[self filteredPOSTBody] options:(NSJSONWritingOptions)0 error:nil];
        };
    }
}


#pragma mark - Tests :: Playback :: NSURLSession :: GET

- (void)testNSURLSessionPlaybackGET_ShouldReturnStubbedResponse {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self NSURLSessionSendRequest:targetRequest
      withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        [self assertResponse:response playedForRequest:request withData:data];
    }];
}

- (void)testNSURLSessionPlaybackGET_ShouldIgnoreAdditionalRequest_WhenHostFilterConfigured {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    NSURLRequest *ghRateLimits = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/rate_limit"]];
    NSArray<NSURLRequest *> *requests = @[targetRequest, ghRateLimits];
    
    [self NSURLSessionSendRequests:requests withResultVerificationBlock:nil];
}

- (void)testNSURLSessionPlaybackGET_ShouldIgnoreAdditionalRequest_WhenIgnoredInBeforeRecordRequest {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    NSURLRequest *ghRateLimits = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/rate_limit"]];
    NSArray<NSURLRequest *> *requests = @[targetRequest, ghRateLimits];
    
    [self NSURLSessionSendRequests:requests withResultVerificationBlock:nil];
}

- (void)testNSURLSessionPlaybackGET_ShouldReturnStubbedResponsesChronologically_WhenFewRequestStubbed {
    
    NSArray<NSURLRequest *> *requests = @[[self GETRequestWithPath:@"/delay/2"], [self GETRequestWithPath:@"/get"]];
    __block NSTimeInterval delayCompletionDate = 0;
    __block NSTimeInterval getCompletionDate = 0;
    
    [self NSURLSessionSendRequests:requests
       withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
           
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

- (void)testNSURLSessionPlaybackGET_ShouldReturnStubbedResponsesMomentary_WhenFewRequestStubbed {
    
    NSArray<NSURLRequest *> *requests = @[[self GETRequestWithPath:@"/delay/2"], [self GETRequestWithPath:@"/get"]];
    __block NSTimeInterval delayCompletionDate = 0;
    __block NSTimeInterval getCompletionDate = 0;
    
    [self NSURLSessionSendRequests:requests
       withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
           
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

- (void)testNSURLSessionPlaybackGET_ShouldReturnStubbedResponse_WhenRecordedRedirects {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/absolute-redirect/3"];
    
    [self NSURLSessionSendRequest:targetRequest
      withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        [self assertResponse:response playedForRequest:request withData:data];
    }];
}

- (void)testNSURLSessionPlaybackGET_ShouldReturnStubbedError_WhenRemoteDoesntRespondInTime {
    
    NSMutableURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    targetRequest.timeoutInterval = 1.f;
    
    [self NSURLSessionSendRequest:targetRequest
      withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        XCTAssertNotNil(error);
    }];
}

- (void)testNSURLSessionPlaybackGET_ShouldReturnStubbedError_WhenRequestCancelled {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    
    [self NSURLSessionSendRequest:targetRequest
            withCancellationAfter:0.5f
          resultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
              
        XCTAssertNotNil(error);
    }];
}


#pragma mark - Tests :: Playback :: NSURLConnection :: GET

- (void)testNSURLConnectionSynchronousPlaybackGET_ShouldReturnStubbedResponse {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:YES
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        [self assertResponse:response playedForRequest:request withData:data];
    }];
}

- (void)testNSURLConnectionSynchronousPlaybackGET_ShouldIgnoreAdditionalRequest_WhenHostFilterConfigured {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    NSURLRequest *ghRateLimits = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/rate_limit"]];
    NSArray<NSURLRequest *> *requests = @[targetRequest, ghRateLimits];
    
    [self NSURLConnectionSendRequests:requests synchronously:YES withResultVerificationBlock:nil];
}

- (void)testNSURLConnectionSynchronousPlaybackGET_ShouldIgnoreAdditionalRequest_WhenIgnoredInBeforeRecordRequest {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    NSURLRequest *ghRateLimits = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/rate_limit"]];
    NSArray<NSURLRequest *> *requests = @[targetRequest, ghRateLimits];
    
    [self NSURLConnectionSendRequests:requests synchronously:YES withResultVerificationBlock:nil];
}

- (void)testNSURLConnectionSynchronousPlaybackGET_ShouldReturnStubbedResponse_WhenRecordedRedirects {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/absolute-redirect/3"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:YES
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        [self assertResponse:response playedForRequest:request withData:data];
    }];
}

- (void)testNSURLConnectionSynchronousPlaybackGET_ShouldReturnStubbedError_WhenRemoteDoesntRespondInTime {
    
    NSMutableURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    targetRequest.timeoutInterval = 1.f;
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:YES
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        XCTAssertNotNil(error);
    }];
}

- (void)testNSURLConnectionAsynchronousPlaybackGET_ShouldReturnStubbedResponse {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:NO
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        [self assertResponse:response playedForRequest:request withData:data];
    }];
}

- (void)testNSURLConnectionAsynchronousPlaybackGET_ShouldIgnoreAdditionalRequest_WhenHostFilterConfigured {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    NSURLRequest *ghRateLimits = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/rate_limit"]];
    NSArray<NSURLRequest *> *requests = @[targetRequest, ghRateLimits];
    
    [self NSURLConnectionSendRequests:requests synchronously:NO withResultVerificationBlock:nil];
}

- (void)testNSURLConnectionAsynchronousPlaybackGET_ShouldIgnoreAdditionalRequest_WhenIgnoredInBeforeRecordRequest {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    NSURLRequest *ghRateLimits = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/rate_limit"]];
    NSArray<NSURLRequest *> *requests = @[targetRequest, ghRateLimits];
    
    [self NSURLConnectionSendRequests:requests synchronously:NO withResultVerificationBlock:nil];
}

- (void)testNSURLConnectionAsynchronousPlaybackGET_ShouldReturnStubbedResponse_WhenRecordedRedirects {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/absolute-redirect/3"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:NO
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        [self assertResponse:response playedForRequest:request withData:data];
    }];
}

- (void)testNSURLConnectionAsynchronousPlaybackGET_ShouldReturnStubbedError_WhenRemoteDoesntRespondInTime {
    
    NSMutableURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    targetRequest.timeoutInterval = 1.f;
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:NO
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        XCTAssertNotNil(error);
    }];
}


#pragma mark - Tests :: Playback :: NSURLSession :: POST

- (void)testNSURLSessionPlaybackPOST_ShouldReturnStubbedResponse {
    
    NSURLRequest *targetRequest = [self POSTRequestWithPath:@"/post"];
    
    [self NSURLSessionSendRequest:targetRequest
      withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
          [self assertResponse:response playedForRequest:request withData:data];
      }];
}

- (void)testNSURLSessionPlaybackPOST_ShouldPassStubbedPOSTDataToBodyFilter {
    
    NSURLRequest *targetRequest = [self POSTRequestWithPath:@"/post"];
    
    [self NSURLSessionSendRequest:targetRequest
      withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
          [self assertResponse:response playedForRequest:request withData:data];
      }];
}


#pragma mark - Tests :: Playback :: NSURLConnection :: POST

- (void)testNSURLConnectionSynchronousPlaybackPOST_ShouldReturnStubbedResponse {
    
    NSURLRequest *targetRequest = [self POSTRequestWithPath:@"/post"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:YES
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
          [self assertResponse:response playedForRequest:request withData:data];
      }];
}

- (void)testNSURLConnectionAsynchronousPlaybackPOST_ShouldReturnStubbedResponse {
    
    NSURLRequest *targetRequest = [self POSTRequestWithPath:@"/post"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:NO
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
          [self assertResponse:response playedForRequest:request withData:data];
      }];
}


#pragma mark -


@end
