/**
 * @author Serhii Mamontov
 */
#import <XCTest/XCTest.h>
#import <YAHTTPVCR/NSMutableDictionary+YHVMisc.h>


#pragma mark Protected interface declaration

@interface NSMutableDictionaryCategoryTest : XCTestCase


#pragma mark - Information

@property (nonatomic, strong) NSMutableDictionary *dictionary;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation NSMutableDictionaryCategoryTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.dictionary = [NSMutableDictionary dictionaryWithDictionary:@{ @"test1": @"value1", @"test2": @"value2", @"test3": @"value3" }];
}


#pragma mark - Tests :: Value replacement

- (void)testReplaceValues_ShouldReplaceExistingValue_WhenNewSetForExistingKeysPassed {
    
    NSMutableDictionary *expectedDictionary = [NSMutableDictionary dictionaryWithDictionary:self.dictionary];
    expectedDictionary[@"test2"] = @"value-2";
    
    [self.dictionary YHV_replaceValuesWithValuesFromDictionary:@{ @"test2": expectedDictionary[@"test2"] }];
    
    XCTAssertEqualObjects(self.dictionary, expectedDictionary);
}

- (void)testReplaceValues_ShouldReplaceNotAddValues_WhenNewSetForNotExistingKeysPassed {
    
    NSMutableDictionary *expectedDictionary = [self.dictionary copy];
    
    [self.dictionary YHV_replaceValuesWithValuesFromDictionary:@{ @"test4": @"value4" }];
    
    XCTAssertEqualObjects(self.dictionary, expectedDictionary);
}

- (void)testReplaceValues_ShouldRemoveValues_WhenSetWithNSNullValuesPassed {
    
    NSMutableDictionary *expectedDictionary = [NSMutableDictionary dictionaryWithDictionary:self.dictionary];
    [expectedDictionary removeObjectForKey:@"test2"];
    
    [self.dictionary YHV_replaceValuesWithValuesFromDictionary:@{ @"test2": [NSNull null] }];
    
    XCTAssertEqualObjects(self.dictionary, expectedDictionary);
}

#pragma mark -


@end
