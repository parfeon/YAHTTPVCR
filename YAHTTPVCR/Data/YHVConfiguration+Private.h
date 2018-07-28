/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVConfiguration.h"


#pragma mark GCD block types

/**
 * @brief      URI path filter block.
 * @discussion Aggregation from path and query filtering blocks which will be called each time when URL (request, response or in error) should be
 *             filtered before stub save.
 *
 * @param request Reference on request for which URI filtering has been performed.
 *
 * @return Reference on URI object which can be used to replace original value.
 */
typedef NSURL * (^YHVURLFilterBlock)(NSURLRequest *request, NSURL *url);


#pragma mark - Private interface declaration

@interface YHVConfiguration (Private)


#pragma mark - Information

/**
 * @brief  Stores reference on block which allow to alter URI object before stub store.
 */
@property (nonatomic, copy) YHVURLFilterBlock urlFilter;


#pragma mark - Initialization and Configuration

/**
 * @brief  Create and configure default configuration object.
 *
 * @return Configured and ready to use configuration object.
 */
+ (instancetype)defaultConfiguration;

/**
 * @brief  Initialize default configuration object.
 *
 * @return Initialized and ready to use configuration object.
 */
- (instancetype)initWithDefaults;


#pragma mark - Copy

/**
 * @brief  Make copy using defaults from specified \c configuration.
 *
 * @param defaultConfiguration Reference on object from which values should be taken in case if receiver doesn't have value for property.
 *
 * @return Configuration which contain values fromreceiver and \c configuration (for missing properties).
 */
- (YHVConfiguration *)copyWithDefaultsFromConfiguration:(YHVConfiguration *)defaultConfiguration;

#pragma mark -


@end
