#import <Foundation/Foundation.h>


#pragma mark Class forward

@class YHVConfiguration;


/**
 * @brief      Protocol for test cases subclassed from \b YHVTestCase.
 * @discussion Subclasses of \b YHVTestCase is able to perform dynamic VCR configuration depending from test case or environment.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@protocol YHVTestCaseDelegate <NSObject>


#pragma mark - Configuration

/**
 * @brief      Whether VCR should be configured and used for test case.
 * @discussion This delegate callback allow decide at run-time whether test case should be used along with VCR or not.
 *
 * @return \c YES in case if VCR should be used to record or playback response for existing requests.
 */
- (BOOL)shouldSetupVCR;

/**
 * @brief      Update VCR's configuration delegate.
 * @discussion With provided configuration object it is possible to specify different location for cassettes or name of cassette. Various filters
 *             and handlers can be set with provided configuration object.
 *
 * @param configuration  Reference on VCR configuration instance with some pre-defined filters and values.
 */
- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration;

/**
 * @brief      Update cassette's configuration delegate.
 * @discussion With provided configuration object it is possible to specify different set of option for particular cassette. Various filters
 *             and handlers can be set with provided configuration object.
 *
 * @param configuration  Reference on cassette configuration instance with some pre-defined filters and values.
 */
- (void)updateCassetteConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration;

#pragma mark -


@end
