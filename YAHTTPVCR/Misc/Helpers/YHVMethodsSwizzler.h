#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Class methods modification helper.
 * @discussion Class allow to siwzzle all or part of methods using another class as source of methods and their target implementation.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface YHVMethodsSwizzler : NSObject


#pragma mark Swizzle methods

/**
 * @brief      Swizzle methods implementation in \c target class with methods from \c source which prefixed with \c prefix.
 * @discussion Swizzle only portion of methods of \c target with methods of \c source which prefixed with \c prefix.
 * @note       Swizzler will remove \c prefix from \c source method name to identify name of method in \c target which should be swizzled.
 *
 * @param target Reference on class in which methods implementation will be swizzled.
 * @param source Reference on class from which methods implementation for swizzling will be taken.
 * @param prefix Filter method name prefix.
 */
+ (void)swizzleMethodsIn:(Class)target withMethodsFrom:(Class)source prefix:(nullable NSString *)prefix;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
