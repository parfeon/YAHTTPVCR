/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/NSData+YHVSerialization.h>


@interface NSDataCategoryTest : XCTestCase


#pragma mark - Information

@property (nonatomic, copy) NSDictionary *dictionaryRepresentation;
@property (nonatomic, copy) NSString *base64EncodedTestString;
@property (nonatomic, copy) NSData *testStringData;
@property (nonatomic, copy) NSString *testString;


#pragma mark -


@end


@implementation NSDataCategoryTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.testString = @"Yet Another HTTP VCR";
    self.testStringData = [self.testString dataUsingEncoding:NSUTF8StringEncoding];
    self.base64EncodedTestString = @"WWV0IEFub3RoZXIgSFRUUCBWQ1I=";
    self.dictionaryRepresentation = [self.testStringData YHV_dictionaryRepresentation];
}


#pragma mark - Tests :: Dictionary representation

- (void)testDictionaryRepresentation_ShouldReturnNSDictionary {
    
    XCTAssertTrue([[self.testStringData YHV_dictionaryRepresentation] isKindOfClass:[NSDictionary class]]);
}

- (void)testDictionaryRepresentation_ShouldContainExpectedFieldsCount {
    
    XCTAssertEqual([self.testStringData YHV_dictionaryRepresentation].count, 2);
}

- (void)testDictionaryRepresentation_ShouldContainBase64Encoded {
    
    XCTAssertEqualObjects(self.dictionaryRepresentation[@"base64"], self.base64EncodedTestString);
}


#pragma mark - Tests :: Object from dictionary

- (void)testObjectFromDictionary_ShouldReturnNSData {
    
    XCTAssertTrue([[NSData YHV_objectFromDictionary:self.dictionaryRepresentation] isKindOfClass:[NSData class]]);
}

- (void)testObjectFromDictionary_ShouldProperlyDecodeOnRestore {
    
    NSData *data = [NSData YHV_objectFromDictionary:self.dictionaryRepresentation];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    XCTAssertEqualObjects(data, self.testStringData);
    XCTAssertEqualObjects(string, self.testString);
}

#pragma mark -


@end
