/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSDictionary+YHVNSURL.h"


#pragma mark Interface implementation

@implementation NSDictionary (YHVNSURL)


#pragma mark - NSURL

+ (instancetype)YHV_dictionaryWithQuery:(NSString *)urlQuery {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSArray<NSString *> *keyValuePairsList = [urlQuery componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in keyValuePairsList) {
        NSUInteger equalSignLocation = [keyValuePair rangeOfString:@"="].location;
        
        if (equalSignLocation == NSNotFound) {
            continue;
        }
        
        NSString *key = [keyValuePair substringToIndex:equalSignLocation];
        id value = ((NSString *)[keyValuePair substringFromIndex:(equalSignLocation + 1)]).stringByRemovingPercentEncoding;
        
        if (!((NSString *)value).length) {
            continue;
        }
        
        NSError *error = nil;
        NSData *valueData = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
        id object = [NSJSONSerialization JSONObjectWithData:valueData options:NSJSONReadingAllowFragments error:&error];
        
        if (!error && object) {
            value = object;
        }
        
        dictionary[key] = value;
    }
    
    return dictionary;
}

- (NSString *)YHV_toQueryString {
    
    NSCharacterSet *charSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSMutableArray<NSString *> *keyValuePairs = [NSMutableArray new];
    
    for (NSString *key in self) {
        NSError *error = nil;
        id value = self[key];
        
        if ([NSJSONSerialization isValidJSONObject:value]) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:(NSJSONWritingOptions)0 error:&error];
            
            if (!error && jsonData) {
                value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
        value = [value stringByAddingPercentEncodingWithAllowedCharacters:charSet];
        
        [keyValuePairs addObject:[@[key, @"=", value] componentsJoinedByString:@""]];
    }
    
    return keyValuePairs.count ? [keyValuePairs componentsJoinedByString:@"&"] : nil;
}

#pragma mark -


@end
