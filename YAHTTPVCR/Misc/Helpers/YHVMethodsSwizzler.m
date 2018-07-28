/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVMethodsSwizzler.h"
#import <objc/runtime.h>


#pragma mark Protected interface declaration

@interface YHVMethodsSwizzler ()


#pragma mark - Swizzle methods

/**
 * @brief      Swizzle methods implementation in \c target class with methods from \c source which prefixed with \c prefix.
 * @discussion Swizzle only portion of methods of \c target with methods of \c source which prefixed with \c prefix.
 * @note       Swizzler will remove \c prefix from \c source method name to identify name of method in \c target which should be swizzled.
 *
 * @param isClassMethods Whether swizzling class level methods for specified \c target or not.
 * @param target         Reference on class in which methods implementation will be swizzled.
 * @param source         Reference on class from which methods implementation for swizzling will be taken.
 */
+ (void)swizzleClass:(BOOL)isClassMethods methodsIn:(Class)target withMethodsFrom:(Class)source prefix:(nullable NSString *)prefix;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation YHVMethodsSwizzler


#pragma mark - Swizzle methods

+ (void)swizzleMethodsIn:(Class)target withMethodsFrom:(Class)source prefix:(NSString *)prefix {
    
    [self swizzleClass:NO methodsIn:target withMethodsFrom:source prefix:prefix];
    [self swizzleClass:YES methodsIn:target withMethodsFrom:source prefix:prefix];
}

+ (void)swizzleClass:(BOOL)isClassMethods methodsIn:(Class)target withMethodsFrom:(Class)source prefix:(nullable NSString *)prefix {
    
    NSAssert(target, @"Could not swizzle methods from 'source' class to 'target' because 'target' class is 'nil'.");
    NSAssert(source, @"Could not swizzle methods from 'source' class to 'target' because 'source' class is 'nil'.");
    
    source = isClassMethods ? object_getClass(source) : source;
    target = isClassMethods ? object_getClass(target) : target;
    unsigned int sourceMethodsCount = 0;
    Method *sourceMethods = class_copyMethodList(source, &sourceMethodsCount);

    for (unsigned int methodIdx = 0; methodIdx < sourceMethodsCount; methodIdx++) {
        SEL methodSelector = method_getName(sourceMethods[methodIdx]);
        NSString *methodName = NSStringFromSelector(methodSelector);
        const char *methodTypeEncoding = method_getTypeEncoding(sourceMethods[methodIdx]);
        
        if (prefix) {
            if ([methodName rangeOfString:prefix].location == NSNotFound) {
                continue;
            }
            
            methodName = [methodName stringByReplacingOccurrencesOfString:prefix withString:@""];
        }
        
        SEL originalSelector = NSSelectorFromString(methodName);
        SEL swizzledSelector = methodSelector;
        
        IMP originalImplementation = class_getMethodImplementation(target, originalSelector);
        IMP swizzledImplementation = method_getImplementation(sourceMethods[methodIdx]);
        
        if (!originalSelector) {
            NSLog(@"Unable to swizzle '%@', because '%@' doesn't have it.", methodName, NSStringFromClass(target));
            
            continue;
        }

        if (class_addMethod(target, swizzledSelector, originalImplementation, methodTypeEncoding)) {
            class_replaceMethod(target, originalSelector, swizzledImplementation, methodTypeEncoding);
        } else {
            Method (*yhv_class_getMethod)(Class cls, SEL name) = isClassMethods ? class_getClassMethod : class_getInstanceMethod;
            method_exchangeImplementations(yhv_class_getMethod(target, originalSelector), sourceMethods[methodIdx]);
        }
    }
}

#pragma mark -


@end
