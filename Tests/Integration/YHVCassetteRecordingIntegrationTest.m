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


#pragma mark - Tests :: Record :: GET

- (void)testRecordGET_ShouldRecordSingleRequest {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self sendRequest:targetRequest withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testRecordGET_ShouldRecordMultipleRequests_WhenSameRequestSentTwice {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/get"];
    
    [self sendRequest:targetRequest withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
    [self sendRequest:targetRequest withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 8);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testRecordGET_ShouldRecordRequest_WhenRemoteRedirects {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/absolute-redirect/3"];
    
    [self sendRequest:targetRequest withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

- (void)testRecordGET_ShouldRecordRequestError_WhenRemoteDoesntRespondInTime {
    
    NSMutableURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    targetRequest.timeoutInterval = 1.f;
    
    [self sendRequest:targetRequest withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 2);
        [self assertRequestWritten:request];
        [self assertRequest:request errorWritten:error];
    }];
}

- (void)testRecordGET_ShouldRecordRequestError_WhenRequestCancelled {
    
    NSURLRequest *targetRequest = [self GETRequestWithPath:@"/delay/6"];
    
    [self sendRequest:targetRequest withCancellationAfter:0.5f
    resultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 2);
        [self assertRequestWritten:request];
        [self assertRequest:request errorWritten:error];
    }];
}


#pragma mark - Tests :: Record :: POST

- (void)testRecordPOST_ShouldRecordSingleRequest {
    
    NSURLRequest *targetRequest = [self POSTRequestWithPath:@"/post"];
    
    [self sendRequest:targetRequest withResultVerificationBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *data, NSError *error) {
        XCTAssertEqual(YHVVCR.cassette.availableScenes.count, 4);
        [self assertRequestWritten:request];
        [self assertRequest:request responseWritten:response];
        [self assertResponse:response bodyWritten:data];
    }];
}

#pragma mark -


@end
