/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSMutableDictionary+YHVMisc.h"


#pragma mark Interface implementation

@implementation NSMutableDictionary (YHVMisc)


#pragma mark - Misc

- (NSMutableDictionary *)YHV_replaceValuesWithValuesFromDictionary:(NSDictionary *)dictionary {
    
    NSMutableDictionary *caseInsensitiveKeysMap = [NSMutableDictionary new];
    for (NSString *key in self) {
        caseInsensitiveKeysMap[key.lowercaseString] = key;
    }
    
    for (NSString *key in dictionary) {
        NSString *targetKey = caseInsensitiveKeysMap[key.lowercaseString];
        id replacement = dictionary[key];
        
        if (self[targetKey] == nil) {
            continue;
        }
        
        if ([replacement isKindOfClass:[NSNull class]] || !replacement) {
            [self removeObjectForKey:targetKey];
        } else {
            self[targetKey] = replacement;
        }
    }
    
    return self;
}

#pragma mark -


@end
