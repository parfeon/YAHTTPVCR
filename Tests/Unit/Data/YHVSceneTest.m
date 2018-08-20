/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/NSURLRequest+YHVSerialization.h>
#import <YAHTTPVCR/YHVSerializationHelper.h>
#import <YAHTTPVCR/YHVScene.h>


#pragma mark Protected interface declaration

@interface YHVSceneTest : XCTestCase


#pragma mark - Information

@property (nonatomic, strong) NSHTTPURLResponse *expectedResponse;
@property (nonatomic, strong) NSURLRequest *expectedRequest;
@property (nonatomic, strong) NSError *expectedError;
@property (nonatomic, strong) NSData *expectedData;


#pragma mark - Misc

- (NSDictionary *)sceneDictionaryRepresentationForObject:(id)object withType:(YHVSceneType)type;
- (YHVScene *)sceneForObject:(id)object withType:(YHVSceneType)type;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation YHVSceneTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.expectedRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://httpbin.org/1"]
                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                        timeoutInterval:3.f];
    self.expectedResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org/2"]
                                                        statusCode:200
                                                       HTTPVersion:nil
                                                      headerFields:@{ @"Content-Type": @"application/json", @"Accept": @"*/*" }];
    self.expectedError = [NSError errorWithDomain:@"AnotherErrorTestDomain" code:-1000 userInfo:@{
        NSURLErrorKey: [NSURL URLWithString:@"https://httpbin.org/3"],
        NSUnderlyingErrorKey: [NSError errorWithDomain:@"AnotherUnderlyingErrorTestDomain" code:-1001 userInfo:@{
                NSURLErrorFailingURLErrorKey: [NSURL URLWithString:@"https://httpbin.org/4"]
            }]
        }];
    self.expectedData = [@"Yet Another HTTP VCR" dataUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateScene_WhenAllArgumentsPassed {
    
    NSString *expectedIdentifier = [NSUUID UUID].UUIDString;
    YHVSceneType expectedType = YHVRequestScene;
    id expectedData = @{};
    
    YHVScene *scene = [YHVScene sceneWithIdentifier:expectedIdentifier type:expectedType data:expectedData];
    
    XCTAssertNotNil(scene);
    XCTAssertEqualObjects(scene.identifier, expectedIdentifier);
    XCTAssertEqual(scene.type, expectedType);
    XCTAssertEqualObjects(scene.data, expectedData);
}

- (void)testConstructor_ShouldCreateScene_WhenDataNotPassed {
    
    XCTAssertNotNil([YHVScene sceneWithIdentifier:[NSUUID UUID].UUIDString type:YHVRequestScene data:nil]);
}

- (void)testConstructor_ShouldThrow_WhenIdentifierIsNil {
    
    NSString *identifier = nil;
    
    XCTAssertThrowsSpecificNamed([YHVScene sceneWithIdentifier:identifier type:YHVRequestScene data:nil], NSException,
                                 NSInternalInconsistencyException);
}

- (void)testConstructor_ShouldThrow_WhenUnknownTypePassed {
    
    XCTAssertThrowsSpecificNamed([YHVScene sceneWithIdentifier:[NSUUID UUID].UUIDString type:123456879 data:nil], NSException,
                                 NSInternalInconsistencyException);
}


#pragma mark - Tests :: Dictionary representation

- (void)testDictionaryRepresentation_ShouldReturnNSDictionary_WhenRepresentNSURLRequest {
    
    YHVScene *scene = [self sceneForObject:self.expectedRequest withType:YHVRequestScene];
    
    XCTAssertTrue([[scene YHV_dictionaryRepresentation] isKindOfClass:[NSDictionary class]]);
}

- (void)testDictionaryRepresentation_ShouldReturnNSDictionary_WhenRepresentNSHTTPURLResponse {
    
    YHVScene *scene = [self sceneForObject:self.expectedResponse withType:YHVResponseScene];
    
    XCTAssertTrue([[scene YHV_dictionaryRepresentation] isKindOfClass:[NSDictionary class]]);
}

- (void)testDictionaryRepresentation_ShouldReturnNSDictionary_WhenRepresentNSData {
    
    YHVScene *scene = [self sceneForObject:self.expectedData withType:YHVDataScene];
    
    XCTAssertTrue([[scene YHV_dictionaryRepresentation] isKindOfClass:[NSDictionary class]]);
}

- (void)testDictionaryRepresentation_ShouldReturnNSDictionary_WhenRepresentNSError {
    
    YHVScene *scene = [self sceneForObject:self.expectedError withType:YHVErrorScene];
    
    XCTAssertTrue([[scene YHV_dictionaryRepresentation] isKindOfClass:[NSDictionary class]]);
}

- (void)testDictionaryRepresentation_ShouldContainExpectedFieldsCount {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedResponse withType:YHVResponseScene];
    YHVScene *scene = [self sceneForObject:self.expectedResponse withType:YHVResponseScene];
    
    XCTAssertEqual([scene YHV_dictionaryRepresentation].count, dictionary.count);
}

- (void)testDictionaryRepresentation_ShouldEncodeRepresentedData {
    
    YHVScene *scene = [self sceneForObject:self.expectedRequest withType:YHVRequestScene];
    
    XCTAssertTrue([[scene YHV_dictionaryRepresentation][@"data"] isKindOfClass:[NSDictionary class]]);
}


#pragma mark - Tests :: Object from dictionary

- (void)testObjectFromDictionary_ShouldReturnYHVScene_WhenDictionaryContainNSURLRequest {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedRequest withType:YHVRequestScene];
    
    XCTAssertTrue([[YHVScene YHV_objectFromDictionary:dictionary] isKindOfClass:[YHVScene class]]);
}

- (void)testObjectFromDictionary_ShouldReturnYHVScene_WhenDictionaryContainNSHTTPURLResponse {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedResponse withType:YHVResponseScene];
    
    XCTAssertTrue([[YHVScene YHV_objectFromDictionary:dictionary] isKindOfClass:[YHVScene class]]);
}

- (void)testObjectFromDictionary_ShouldReturnYHVScene_WhenDictionaryContainNSData {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedData withType:YHVDataScene];
    
    XCTAssertTrue([[YHVScene YHV_objectFromDictionary:dictionary] isKindOfClass:[YHVScene class]]);
}

- (void)testObjectFromDictionary_ShouldReturnYHVScene_WhenDictionaryContainNSError {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedError withType:YHVErrorScene];
    
    XCTAssertTrue([[YHVScene YHV_objectFromDictionary:dictionary] isKindOfClass:[YHVScene class]]);
}

- (void)testObjectFromDictionary_ShouldProperlyDecodeOnRestore_WhenDictionaryContainNSURLRequest {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedRequest withType:YHVRequestScene];
    YHVScene *expectedScene = [self sceneForObject:self.expectedRequest withType:YHVRequestScene];
    YHVScene *scene = [YHVScene YHV_objectFromDictionary:dictionary];
    
    XCTAssertEqualObjects(scene.identifier, expectedScene.identifier);
    XCTAssertEqual(scene.type, expectedScene.type);
    XCTAssertEqualObjects(scene.data, expectedScene.data);
}

- (void)testObjectFromDictionary_ShouldProperlyDecodeOnRestore_WhenDictionaryContainNSHTTPURLResponse {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedResponse withType:YHVResponseScene];
    YHVScene *expectedScene = [self sceneForObject:self.expectedResponse withType:YHVResponseScene];
    YHVScene *scene = [YHVScene YHV_objectFromDictionary:dictionary];
    
    XCTAssertEqualObjects(scene.identifier, expectedScene.identifier);
    XCTAssertEqual(scene.type, expectedScene.type);
    XCTAssertEqualObjects(((NSHTTPURLResponse *)scene.data).URL, self.expectedResponse.URL);
    XCTAssertEqualObjects(((NSHTTPURLResponse *)scene.data).allHeaderFields, self.expectedResponse.allHeaderFields);
    XCTAssertEqual(((NSHTTPURLResponse *)scene.data).statusCode, self.expectedResponse.statusCode);
}

- (void)testObjectFromDictionary_ShouldProperlyDecodeOnRestore_WhenDictionaryContainNSData {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedData withType:YHVDataScene];
    YHVScene *expectedScene = [self sceneForObject:self.expectedData withType:YHVDataScene];
    YHVScene *scene = [YHVScene YHV_objectFromDictionary:dictionary];
    
    XCTAssertEqualObjects(scene.identifier, expectedScene.identifier);
    XCTAssertEqual(scene.type, expectedScene.type);
    XCTAssertEqualObjects(scene.data, expectedScene.data);
}

- (void)testObjectFromDictionary_ShouldProperlyDecodeOnRestore_WhenDictionaryContainNSError {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedError withType:YHVErrorScene];
    YHVScene *expectedScene = [self sceneForObject:self.expectedError withType:YHVErrorScene];
    YHVScene *scene = [YHVScene YHV_objectFromDictionary:dictionary];
    
    XCTAssertEqualObjects(scene.identifier, expectedScene.identifier);
    XCTAssertEqual(scene.type, expectedScene.type);
    XCTAssertEqualObjects(scene.data, expectedScene.data);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenDictionaryIsNil {
    
    NSMutableDictionary *sceneInfo = nil;
    
    XCTAssertThrowsSpecificNamed([YHVScene YHV_objectFromDictionary:sceneInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenIdentifierIsMissing {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedResponse withType:YHVResponseScene];
    NSMutableDictionary *sceneInfo = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [sceneInfo removeObjectForKey:@"id"];
    
    XCTAssertThrowsSpecificNamed([YHVScene YHV_objectFromDictionary:sceneInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenTypeIsMissing {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedRequest withType:YHVRequestScene];
    NSMutableDictionary *sceneInfo = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [sceneInfo removeObjectForKey:@"type"];
    
    XCTAssertThrowsSpecificNamed([YHVScene YHV_objectFromDictionary:sceneInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenDataForRequestIsMissing {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedError withType:YHVErrorScene];
    NSMutableDictionary *sceneInfo = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [sceneInfo removeObjectForKey:@"data"];
    
    XCTAssertThrowsSpecificNamed([YHVScene YHV_objectFromDictionary:sceneInfo], NSException, NSInternalInconsistencyException);
}

- (void)testObjectFromDictionary_ShouldThrow_WhenDataForResponseIsMissing {
    
    NSDictionary *dictionary = [self sceneDictionaryRepresentationForObject:self.expectedData withType:YHVDataScene];
    NSMutableDictionary *sceneInfo = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    sceneInfo[@"type"] = @(YHVResponseScene);
    [sceneInfo removeObjectForKey:@"data"];
    
    XCTAssertThrowsSpecificNamed([YHVScene YHV_objectFromDictionary:sceneInfo], NSException, NSInternalInconsistencyException);
}


#pragma mark - Tests :: Description

- (void)testDescription_ShouldProvideCustomizedDescription {
    
    YHVScene *scene = [self sceneForObject:self.expectedError withType:YHVErrorScene];
    NSString *description = [scene description];
    
    XCTAssertNotEqual([description rangeOfString:@"YHVErrorScene"].location, NSNotFound);
    XCTAssertNotEqual([description rangeOfString:@"type:"].location, NSNotFound);
    XCTAssertNotEqual([description rangeOfString:@"played:"].location, NSNotFound);
    XCTAssertNotEqual([description rangeOfString:@"playing:"].location, NSNotFound);
}


#pragma mark - Misc

- (NSDictionary *)sceneDictionaryRepresentationForObject:(id<YHVSerializableDataProtocol>)object withType:(YHVSceneType)type {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{ @"id": @"TestSceneIdentifier", @"type": @(type) }];
    dictionary[@"data"] = [YHVSerializationHelper dictionaryFromObject:object];
    
    return dictionary;
}

- (YHVScene *)sceneForObject:(id)object withType:(YHVSceneType)type {
    
    return [YHVScene sceneWithIdentifier:@"TestSceneIdentifier" type:type data:object];
}

#pragma mark -


@end
