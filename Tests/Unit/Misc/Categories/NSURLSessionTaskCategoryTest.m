/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/NSURLSessionTask+YHVRecorder.h>
#import <YAHTTPVCR/YHVVCR+Recorder.h>
#import <OCMock/OCMock.h>


#pragma mark Protected interface declaration

@interface NSURLSessionTaskCategoryTest : XCTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation NSURLSessionTaskCategoryTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    [YHVNSURLSessionTask makeRecordable];
}


#pragma mark - Tests :: Custom protocol

- (void)testInitWithTask_ShouldCallVCRRecordCompletion {
    
    Class taskClass = NSClassFromString(@"__NSCFURLSessionTask");
    NSError *error = [NSError errorWithDomain:@"TestDomain" code:1000 userInfo:@{ NSLocalizedDescriptionKey: @"Tes error instance." }];
    id task = [taskClass new];
    
    id vcrClassMock = OCMClassMock([YHVVCR class]);
    OCMExpect([vcrClassMock recordCompletionWithError:error forTask:task]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [task performSelector:@selector(setError:) withObject:error];
#pragma clang diagnostic pop
    
    OCMVerifyAll(vcrClassMock);
}

- (void)testInitWithTask_ShouldCallVCRResponseRecord {
    
    Class taskClass = NSClassFromString(@"__NSCFURLSessionTask");
    NSURL *url = [NSURL URLWithString:@"https://httpbin.org/1"];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:nil headerFields:nil];
    id task = [taskClass new];
    
    id vcrClassMock = OCMClassMock([YHVVCR class]);
    OCMExpect([vcrClassMock recordResponse:[OCMArg any] forTask:task]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [task performSelector:@selector(setResponse:) withObject:response];
#pragma clang diagnostic pop
    
    OCMVerifyAll(vcrClassMock);
}

#pragma mark -


@end
