#import <Foundation/Foundation.h>
#import "YHVStructures.h"


#pragma mark Class forward

@class YHVConfiguration, YHVCassette;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      VCR core.
 * @discussion This is base library class which is responsible for cassettes playback and recording for requests stubbing.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface YHVVCR : NSObject


#pragma mark - Information

/**
 * @brief  Stores reference on cassette which currently inserted into VCR.
 */
@property (class, nonatomic, readonly, strong) YHVCassette *cassette;

/**
 * @brief  Stores reference on map of registered request matcher names to their GCD blocks.
 */
@property (class, nonatomic, readonly, strong) NSDictionary<NSString *, YHVMatcherBlock> *matchers;


#pragma mark - Configuration

/**
 * @brief      Configure shared VCR instance.
 * @discussion Configure shared instance with configuration block. This method can be called as much time as required and it will completelly
 *             reset previous configuration.
 *
 * @param block Reference on block which can be used to customize VCR behaviour. Block pass only one argument - configuration object which later
 *              will be used by VCR.
 */
+ (void)setupWithConfiguration:(void(^)(YHVConfiguration *configuration))block;


#pragma mark - Cassette

/**
 * @brief  Insert new or existing cassette into VCR.
 *
 * @param path Reference on path to cassette inside of cassettes rack (\c cassettesPath property during VCR configuration).
 *
 * @return Reference on cassette which has been inserted into VCR.
 */
+ (YHVCassette *)insertCassetteWithPath:(NSString *)path;

/**
 * @brief  Insert new or existing cassette into VCR.
 *
 * @param block Reference on block which can be used to customize cassette's behaviour. Block pass only one argument - configuration object which
 *              later will be merged with VCR's configuration and used for cassette.
 *
 * @return Reference on cassette which has been inserted into VCR.
 */
+ (YHVCassette *)insertCassetteWithConfiguration:(void(^)(YHVConfiguration *configuration))block;

/**
 * @brief      Eject previously inserted cassette.
 * @discussion As soon as cassette will be ejected, no new requests will be recorded and mock for existing requests will be stopped.
 */
+ (void)ejectCassette;


#pragma mark - Matchers

/**
 * @brief  Register new matcher block with specified \c identifier.
 *
 * @param identifier Reference on unique identifier of matcher, which can be used during VCR configuration (as value of \c matchers field from
 *                   \b YHVVCRConfiguration).
 * @param block      Reference on matcher block which will be called when new request should be matched.
 */
+ (void)registerMatcher:(NSString *)identifier withBlock:(YHVMatcherBlock)block;

/**
 * @brief  Unregister matcher block with specified \c identifier.
 *
 * @param identifier Reference on unique identifier of matcher, with which it was registered before.
 */
+ (void)unregisterMatcher:(NSString *)identifier;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
