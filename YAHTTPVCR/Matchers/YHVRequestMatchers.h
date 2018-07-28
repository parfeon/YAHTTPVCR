#import <Foundation/Foundation.h>
#import "YHVStructures.h"


NS_ASSUME_NONNULL_BEGIN

@interface YHVRequestMatchers : NSObject


#pragma mark - Matchers

/**
 * @brief  Reference on requests HTTP method matcher block.
 */
@property (class, readonly, strong) YHVMatcherBlock method;

/**
 * @brief  Reference on requests full URI matcher block.
 */
@property (class, readonly, strong) YHVMatcherBlock uri;

/**
 * @brief  Reference on requests URI scheme matcher block.
 */
@property (class, readonly, strong) YHVMatcherBlock scheme;

/**
 * @brief  Reference on requests URI host name matcher block.
 */
@property (class, readonly, strong) YHVMatcherBlock host;

/**
 * @brief  Reference on requests URI host port matcher block.
 */
@property (class, readonly, strong) YHVMatcherBlock port;

/**
 * @brief  Reference on requests URI path part matcher block.
 */
@property (class, readonly, strong) YHVMatcherBlock path;

/**
 * @brief  Reference on requests URI query part matcher block.
 */
@property (class, readonly, strong) YHVMatcherBlock query;

/**
 * @brief  Reference on requests headers matcher block.
 */
@property (class, readonly, strong) YHVMatcherBlock headers;

/**
 * @brief      Reference on requests body matcher block.
 * @discussion If body represent \c application/json or \c application/x-www-form-urlencoded it will be translated to objects and comared in
 *             other case binary objects will be compared.
 */
@property (class, readonly, strong) YHVMatcherBlock body;


#pragma mark - Matching

/**
 * @brief  Check whether two requests match to each other.
 * @discussion Run set of requests checks using passed \c matchers list.
 *
 * @param originalRequest Reference on request which has been passed from URL loading system.
 * @param stubRequest     Reference on request which has been passed from cassette's tape.
 * @param matchers        Reference on list of matchers which should be used.
 *
 * @return \c YES in case if all matchers returned positive response.
 */
+ (BOOL)request:(NSURLRequest *)originalRequest isMatchingTo:(NSURLRequest *)stubRequest withMatchers:(NSArray<YHVMatcherBlock> *)matchers;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
