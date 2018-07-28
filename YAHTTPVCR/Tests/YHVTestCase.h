#import <XCTest/XCTest.h>
#import "YHVTestCaseDelegate.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      XCTest case helper subclass.
 * @discussion Subclass make it easier to utilyze YHVVCR functionality.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface YHVTestCase : XCTestCase <YHVTestCaseDelegate>


#pragma mark - Information

/**
 * @brief  Stores reference on path which point to location of all recorded cassettes.
 */
@property (nonatomic, readonly, copy) NSString *cassettesPath;

/**
 * @brief  Stores reference on path which contain cassette's data.
 */
@property (nonatomic, readonly, copy) NSString *cassettePath;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
