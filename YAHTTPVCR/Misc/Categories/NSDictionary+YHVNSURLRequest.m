/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "NSDictionary+YHVNSURLRequest.h"
#import "NSURLRequest+YHVPlayer.h"
#import "NSDictionary+YHVNSURL.h"


#pragma mark Protected interface declaration

@interface NSDictionary (YHVNSURLRequestPrivate)


#pragma mark - NSURLRequest
/**
 * @brief      Create and configure \a NSDictionary using data object with specified \c Content-Type used for transfer.
 * @discussion Serialize data content to dictionary if it is possible. Body can be serialized only if following \c Content-Type used:
 *             \c application/json and \c application/x-www-form-urlencoded.
 *
 * @param data        Reference on binary data which has been transfered over the network and should be serialized to dictionary.
 * @param contentType Reference on type which has been used to encode \c data for transfer over the network.
 *
 * @return Configured and ready to use dictionary or \c nil in case if binary data can't be serialized.
 */
+ (nullable instancetype)YHV_dictionaryFromData:(NSData *)data withContentType:(NSString *)contentType;

/**
 * @brief      Encode dictionary to \a NSData which can be used for transfer over the network.
 * @discussion This operation possible only for requests with following \c Content-Type used: \c application/json and
 *             \c application/x-www-form-urlencoded.
 *
 * @param contentType Reference on type which has been used to encode \c data for transfer over the network.
 *
 * @return Encoded to \a NSData object or \c nil in case if content type not supported.
 */
- (nullable NSData *)YHV_DataWithContentType:(NSString *)contentType;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation NSDictionary (YHVNSURLRequest)


#pragma mark - NSURLRequest

+ (instancetype)YHV_dictionaryFromNSURLRequestPOSTBody:(NSURLRequest *)request {
    
    NSArray<NSString *> *requestMethodsWithHTTPBody = @[@"post", @"put", @"patch"];
    NSDictionary *dictionary = nil;
    
    if ([requestMethodsWithHTTPBody containsObject:request.HTTPMethod.lowercaseString]) {
        dictionary = [self YHV_dictionaryFromData:request.YHV_HTTPBody withContentType:[request valueForHTTPHeaderField:@"Content-Type"]];
    }
    
    return dictionary.count ? dictionary : nil;
}

+ (nullable instancetype)YHV_dictionaryFromData:(NSData *)data forNSHTTPURLResponse:(NSHTTPURLResponse *)response {
    
    NSDictionary *dictionary = [self YHV_dictionaryFromData:data withContentType:response.allHeaderFields[@"Content-Type"]];
    
    return dictionary.count ? dictionary : nil;
}

+ (instancetype)YHV_dictionaryFromData:(NSData *)data withContentType:(NSString *)contentType {
    
    contentType = contentType.lowercaseString;
    NSDictionary *dictionary = nil;
    
    if (!data) {
        return nil;
    }
    
    if ([contentType rangeOfString:@"application/json"].location != NSNotFound) {
        dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    } else if ([contentType rangeOfString:@"application/x-www-form-urlencoded"].location != NSNotFound) {
        NSString *postBodyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        postBodyString = [postBodyString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        dictionary = [NSDictionary YHV_dictionaryWithQuery:postBodyString sortQueryListOnMatch:NO];
    }
    
    return dictionary.count ? dictionary : nil;
}

- (NSData *)YHV_POSTBodyForNSURLRequest:(NSURLRequest *)request {
    
    NSArray<NSString *> *requestMethodsWithHTTPBody = @[@"post", @"put", @"patch"];
    NSData *data = nil;
    
    if ([requestMethodsWithHTTPBody containsObject:request.HTTPMethod.lowercaseString]) {
        data = [self YHV_DataWithContentType:[request valueForHTTPHeaderField:@"Content-Type"]];
    }
    
    return data.length ? data : nil;
}

- (NSData *)YHV_DataForNSHTTPURLResponse:(NSHTTPURLResponse *)response {
    
    NSData *data = [self YHV_DataWithContentType:response.allHeaderFields[@"Content-Type"]];
    
    return data.length ? data : nil;
}

- (NSData *)YHV_DataWithContentType:(NSString *)contentType {
    
    contentType = contentType.lowercaseString;
    NSData *data = nil;
    
    if ([contentType rangeOfString:@"application/json"].location != NSNotFound) {
        data = [NSJSONSerialization dataWithJSONObject:self options:(NSJSONWritingOptions)0 error:nil];
    } else if ([contentType rangeOfString:@"application/x-www-form-urlencoded"].location != NSNotFound) {
        NSString *urlencodedForm = [[self YHV_toQueryString] stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];
        data = [urlencodedForm dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return data.length ? data : nil;
}

#pragma mark -


@end
