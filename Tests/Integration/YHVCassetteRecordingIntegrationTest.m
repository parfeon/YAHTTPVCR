/**
 * @author Serhii Mamontov
 */
#import <YAHTTPVCR/NSDictionary+YHVNSURL.h>
#import <YAHTTPVCR/YHVCassette+Private.h>
#import "YHVIntegrationTestCase.h"


@interface YHVCassetteRecordingIntegrationTest : YHVIntegrationTestCase


#pragma mark -


@end


@implementation YHVCassetteRecordingIntegrationTest


#pragma mark - Tests :: Record :: NSURLSession :: GET

- (void)testNSURLSessionRecordGET_ShouldRecordSingleRequest {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self NSURLSessionSendRequest:targetRequest
      withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testNSURLSessionRecordGET_ShouldRecordMultipleRequests_WhenSameRequestSentTwice {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self NSURLSessionSendRequest:targetRequest
      withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
    
    [self NSURLSessionSendRequest:targetRequest
      withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 8);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testNSURLSessionRecordGET_ShouldRecordRequest_WhenRemoteRedirects {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/absolute-redirect/3"];
    
    [self NSURLSessionSendRequest:targetRequest
      withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testNSURLSessionRecordGET_ShouldRecordRequestError_WhenRemoteDoesntRespondInTime {
    
    NSMutableURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    targetRequest.timeoutInterval = 1.f;
    
    [self NSURLSessionSendRequest:targetRequest
      withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 2);
        [self assertRequestWritten:request];
        [self assertRequest:request errorWritten:error];
    }];
}

- (void)testNSURLSessionRecordGET_ShouldRecordRequestError_WhenRequestCancelled {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    
    [self NSURLSessionSendRequest:targetRequest
            withCancellationAfter:0.5f
          resultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 2);
        [self assertRequestWritten:request];
        [self assertRequest:request errorWritten:error];
    }];
}


#pragma mark - Tests :: Record :: NSURLConnection :: GET

- (void)testNSURLConnectionSynchronousRecordGET_ShouldRecordSingleRequest {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:YES
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testNSURLConnectionSynchronousRecordGET_ShouldRecordMultipleRequests_WhenSameRequestSentTwice {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:YES
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:targetRequest];
        [self assertRequest:targetRequest responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:YES
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 8);
        [self assertRequestWritten:targetRequest];
        [self assertRequest:targetRequest responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testNSURLConnectionSynchronousRecordGET_ShouldRecordRequest_WhenRemoteRedirects {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/absolute-redirect/3"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:YES
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
    
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:targetRequest];
        [self assertRequest:targetRequest responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testNSURLConnectionSynchronousRecordGET_ShouldRecordRequestError_WhenRemoteDoesntRespondInTime {
    
    NSMutableURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    targetRequest.timeoutInterval = 1.f;
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:YES
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 2);
        [self assertRequestWritten:request];
        [self assertRequest:request errorWritten:error];
    }];
}

- (void)testNSURLConnectionAsynchronousRecordGET_ShouldRecordSingleRequest {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:NO
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testNSURLConnectionAsynchronousRecordGET_ShouldRecordMultipleRequests_WhenSameRequestSentTwice {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:NO
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:targetRequest];
        [self assertRequest:targetRequest responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:NO
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 8);
        [self assertRequestWritten:targetRequest];
        [self assertRequest:targetRequest responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testNSURLConnectionAsynchronousRecordGET_ShouldRecordRequest_WhenRemoteRedirects {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/absolute-redirect/3"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:NO
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:targetRequest];
        [self assertRequest:targetRequest responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testNSURLConnectionAsynchronousRecordGET_ShouldRecordRequestError_WhenRemoteDoesntRespondInTime {
    
    NSMutableURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    targetRequest.timeoutInterval = 1.f;
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:NO
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 2);
        [self assertRequestWritten:request];
        [self assertRequest:request errorWritten:error];
    }];
}


#pragma mark - Tests :: Record :: NSURLSession :: POST

- (void)testNSURLSessionRecordPOST_ShouldRecordSingleRequest {
    
    NSURLRequest *targetRequest = [self POSTRequestWithPath:@"/post"];
    
    [self NSURLSessionSendRequest:targetRequest
      withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
          
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}


#pragma mark - Tests :: Record :: NSURLConnection :: POST

- (void)testNSURLConnectionSynchronousRecordPOST_ShouldRecordSingleRequest {
    
    NSURLRequest *targetRequest = [self POSTRequestWithPath:@"/post"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:YES
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testNSURLConnectionAsynchronousRecordPOST_ShouldRecordSingleRequest {
    
    NSURLRequest *targetRequest = [self POSTRequestWithPath:@"/post"];
    
    [self NSURLConnectionSendRequest:targetRequest
                       synchronously:NO
         withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
             
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

#pragma mark -


@end
