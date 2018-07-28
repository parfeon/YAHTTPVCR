/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/NSArray+YHVSerialization.h>
#import <YAHTTPVCR/NSData+YHVSerialization.h>
#import <YAHTTPVCR/YHVSerializationHelper.h>


@interface NSArrayCategoryTest : XCTestCase


#pragma mark - Information

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSDictionary *dictionaryRepresentation;


#pragma mark -


@end


@implementation NSArrayCategoryTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    NSString *testString = @"Yet Another HTTP VCR";
    NSData *testStringData = [testString dataUsingEncoding:NSUTF8StringEncoding];
    
    self.array = @[testStringData, @16, @[@20, testString]];
    self.dictionaryRepresentation = @{
        @"cls": NSStringFromClass([NSArray class]),
        @"entries": @[
            @{ @"base64": @"WWV0IEFub3RoZXIgSFRUUCBWQ1I=", @"cls": NSStringFromClass([NSData class]) },
            @16,
            @{ @"entries": @[@20, testString], @"cls": NSStringFromClass([NSArray class]) }
        ]
    };
}


#pragma mark - Tests :: Dictionary representation

- (void)testDictionaryRepresentation_ShouldReturnNSDictionary {
    
    XCTAssertTrue([[self.array YHV_dictionaryRepresentation] isKindOfClass:[NSDictionary class]]);
}

- (void)testDictionaryRepresentation_ShouldContainExpectedFieldsCount {
    
    XCTAssertEqual([self.array YHV_dictionaryRepresentation].count, 2);
}

- (void)testDictionaryRepresentation_ShouldProperlySerialize {
    
    XCTAssertEqualObjects([self.array YHV_dictionaryRepresentation], self.dictionaryRepresentation);
}

- (void)testDictionaryRepresentation_ShouldSerializeElements {
    
    NSArray *serializedElements = [self.array YHV_dictionaryRepresentation][@"entries"];
    
    XCTAssertTrue([serializedElements[0] isKindOfClass:[NSDictionary class]]);
    XCTAssertTrue([serializedElements[1] isKindOfClass:[NSNumber class]]);
    XCTAssertTrue([serializedElements[2] isKindOfClass:[NSDictionary class]]);
}


#pragma mark - Tests :: Object from dictionary

- (void)testObjectFromDictionary_ShouldReturnNSArray {
    
    XCTAssertTrue([[NSArray YHV_objectFromDictionary:self.dictionaryRepresentation] isKindOfClass:[NSArray class]]);
}

- (void)testObjectFromDictionary_ShouldProperlyDecodeOnRestore {
    
    NSArray *data = [NSArray YHV_objectFromDictionary:self.dictionaryRepresentation];
    
    XCTAssertEqualObjects(data[0], self.array[0]);
    XCTAssertEqualObjects(data[1], self.array[1]);
    XCTAssertEqualObjects(data[2], self.array[2]);
}

#pragma mark -


@end
