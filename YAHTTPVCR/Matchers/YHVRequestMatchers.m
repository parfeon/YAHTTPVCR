/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVRequestMatchers.h"
#import "NSURLRequest+YHVPlayer.h"
#import "NSDictionary+YHVNSURL.h"


#define YHV_OUTPUT_MATCHING 0


#pragma mark Interface implementation

@implementation YHVRequestMatchers


#pragma mark - Matchers

+ (YHVMatcherBlock)method {
    
    return ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) {
#if YHV_OUTPUT_MATCHING
        NSLog(@"\nMETHOD MATCH (STUB %@)\nORIG: %@\nSTUB: %@\nMATCH: %@",
              stubRequest ? @"EXISTS" : @"IS MISSING", request.HTTPMethod.lowercaseString, stubRequest.HTTPMethod.lowercaseString,
              stubRequest && [request.HTTPMethod.lowercaseString isEqualToString:stubRequest.HTTPMethod.lowercaseString] ? @"YES" : @"NO");
#endif
        
        return request && stubRequest && [request.HTTPMethod.lowercaseString isEqualToString:stubRequest.HTTPMethod.lowercaseString];
    };
}

+ (YHVMatcherBlock)uri {
    
    return ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) {
#if YHV_OUTPUT_MATCHING
        NSLog(@"\nURI MATCH (STUB %@)\nORIG: %@\nSTUB: %@\nMATCH: %@",
              stubRequest ? @"EXISTS" : @"IS MISSING", request.URL.absoluteString.lowercaseString, stubRequest.URL.absoluteString.lowercaseString,
              (stubRequest && self.scheme(request, stubRequest) && self.host(request, stubRequest) && self.port(request, stubRequest) &&
               self.path(request, stubRequest) && self.query(request, stubRequest)) ? @"YES" : @"NO");
#endif
        
        return (stubRequest && self.scheme(request, stubRequest) && self.host(request, stubRequest) && self.port(request, stubRequest) &&
                self.path(request, stubRequest) && self.query(request, stubRequest));
    };
}

+ (YHVMatcherBlock)scheme {
    
    return ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) {
#if YHV_OUTPUT_MATCHING
        NSLog(@"\nSCHEME MATCH (STUB %@)\nORIG: %@\nSTUB: %@\nMATCH: %@",
              stubRequest ? @"EXISTS" : @"IS MISSING", request.URL.scheme.lowercaseString, stubRequest.URL.scheme.lowercaseString,
              stubRequest && [request.URL.scheme.lowercaseString isEqualToString:stubRequest.URL.scheme.lowercaseString] ? @"YES" : @"NO");
#endif
        
        return stubRequest && [request.URL.scheme.lowercaseString isEqualToString:stubRequest.URL.scheme.lowercaseString];
    };
}

+ (YHVMatcherBlock)host {
    
    return ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) {
#if YHV_OUTPUT_MATCHING
        NSLog(@"\nHOST MATCH (STUB %@)\nORIG: %@\nSTUB: %@\nMATCH: %@",
              stubRequest ? @"EXISTS" : @"IS MISSING", request.URL.host.lowercaseString, stubRequest.URL.host.lowercaseString,
              stubRequest && [request.URL.host.lowercaseString isEqualToString:stubRequest.URL.host.lowercaseString] ? @"YES" : @"NO");
#endif
        
        return stubRequest && [request.URL.host.lowercaseString isEqualToString:stubRequest.URL.host.lowercaseString];
    };
}

+ (YHVMatcherBlock)port {
    
    return ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) {
        NSNumber *hostPort = request.URL.port;
        NSNumber *stubHostPort = stubRequest.URL.port;
#if YHV_OUTPUT_MATCHING
        NSLog(@"\nPORT MATCH (STUB %@)\nORIG: %@\nSTUB: %@\nMATCH: %@",
              stubRequest ? @"EXISTS" : @"IS MISSING", hostPort, stubHostPort,
              stubRequest && ((!hostPort && !stubHostPort) || (stubHostPort && [hostPort compare:stubHostPort] == NSOrderedSame)) ? @"YES" : @"NO");
#endif
        
        return stubRequest && ((!hostPort && !stubHostPort) || (stubHostPort && [hostPort compare:stubHostPort] == NSOrderedSame));
    };
}

+ (YHVMatcherBlock)path {
    
    return ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) {
#if YHV_OUTPUT_MATCHING
        NSLog(@"\nPATH MATCH (STUB %@)\nORIG: %@\nSTUB: %@\nMATCH: %@",
              stubRequest ? @"EXISTS" : @"IS MISSING", request.URL.path.lowercaseString, stubRequest.URL.path.lowercaseString,
              stubRequest && [request.URL.path.lowercaseString isEqualToString:stubRequest.URL.path.lowercaseString] ? @"YES" : @"NO");
#endif
        
        return stubRequest && [request.URL.path.lowercaseString isEqualToString:stubRequest.URL.path.lowercaseString];
    };
}

+ (YHVMatcherBlock)query {
    
    return ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) {
        NSDictionary *requestQuery = [NSDictionary YHV_dictionaryWithQuery:request.URL.query];
        NSDictionary *stubRequestQuery = [NSDictionary YHV_dictionaryWithQuery:stubRequest.URL.query];
#if YHV_OUTPUT_MATCHING
        NSData *requestQueryData = [NSJSONSerialization dataWithJSONObject:requestQuery options:(NSJSONWritingOptions)0 error:nil];
        NSData *stubRequestQueryData = [NSJSONSerialization dataWithJSONObject:stubRequestQuery options:(NSJSONWritingOptions)0 error:nil];
        NSLog(@"\nQUERY MATCH (STUB %@): '%@' vs '%@'\nORIG: %@\nSTUB: %@\nMATCH: %@",
              stubRequest ? @"EXISTS" : @"IS MISSING",
              request.URL.query, stubRequest.URL.query,
              [[NSString alloc] initWithData:requestQueryData encoding:NSUTF8StringEncoding],
              [[NSString alloc] initWithData:stubRequestQueryData encoding:NSUTF8StringEncoding],
              [requestQuery isEqualToDictionary:stubRequestQuery] ? @"YES" : @"NO");
#endif
        
        return [requestQuery isEqualToDictionary:stubRequestQuery];
    };
}

+ (YHVMatcherBlock)headers {
    
    return ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) {
#if YHV_OUTPUT_MATCHING
        NSData *requestHeadersData = [NSJSONSerialization dataWithJSONObject:request.allHTTPHeaderFields options:(NSJSONWritingOptions)0 error:nil];
        NSData *stubRequestHeadersData = [NSJSONSerialization dataWithJSONObject:stubRequest.allHTTPHeaderFields options:(NSJSONWritingOptions)0 error:nil];
        
        NSLog(@"\nHEADERS MATCH (STUB %@)\nORIG: %@\nSTUB: %@\nMATCH: %@",
              stubRequest ? @"EXISTS" : @"IS MISSING",
              [[NSString alloc] initWithData:requestHeadersData encoding:NSUTF8StringEncoding],
              [[NSString alloc] initWithData:stubRequestHeadersData encoding:NSUTF8StringEncoding],
              [request.allHTTPHeaderFields isEqualToDictionary:stubRequest.allHTTPHeaderFields] ? @"YES" : @"NO");
#endif
        
        return ((!request.allHTTPHeaderFields && !stubRequest.allHTTPHeaderFields) ||
                ([request.allHTTPHeaderFields isEqualToDictionary:stubRequest.allHTTPHeaderFields]));
    };
}

+ (YHVMatcherBlock)body {
    
    return ^BOOL (NSURLRequest *request, NSURLRequest *stubRequest) {
        if (!request.YHV_HTTPBody && !stubRequest.YHV_HTTPBody) {
#if YHV_OUTPUT_MATCHING
             NSLog(@"\nBODY MATCH (STUB %@)\nORIG: %@\nSTUB: %@\nMATCH: YES",
                   stubRequest ? @"EXISTS" : @"IS MISSING",
                   request.YHV_HTTPBody,
                   stubRequest.YHV_HTTPBody);
#endif
            
            return YES;
        } else if (!request.YHV_HTTPBody || !stubRequest.YHV_HTTPBody) {
#if YHV_OUTPUT_MATCHING
            NSLog(@"\nBODY MATCH (STUB %@)\nORIG: %@\nSTUB: %@\nMATCH: NO",
                  stubRequest ? @"EXISTS" : @"IS MISSING",
                  request.YHV_HTTPBody,
                  stubRequest.YHV_HTTPBody);
#endif
             
            return NO;
        }
        
        NSString *requestContentType = [request valueForHTTPHeaderField:@"Content-Type"];
        NSString *stubRequestContentType = [stubRequest valueForHTTPHeaderField:@"Content-Type"];
        NSDictionary *stubPostBody = nil;
        NSDictionary *postBody = nil;
        
        if (requestContentType && [requestContentType rangeOfString:@"application/json"].location != NSNotFound &&
            stubRequestContentType && [stubRequestContentType rangeOfString:@"application/json"].location != NSNotFound) {
            
            stubPostBody = [NSJSONSerialization JSONObjectWithData:stubRequest.YHV_HTTPBody options:NSJSONReadingAllowFragments error:nil];
            postBody = [NSJSONSerialization JSONObjectWithData:request.YHV_HTTPBody options:NSJSONReadingAllowFragments error:nil];
        } else if (requestContentType && [requestContentType rangeOfString:@"application/x-www-form-urlencoded"].location != NSNotFound &&
                   stubRequestContentType && [stubRequestContentType rangeOfString:@"application/x-www-form-urlencoded"].location != NSNotFound) {
            
            NSString *stubPostBodyString = [[NSString alloc] initWithData:stubRequest.YHV_HTTPBody encoding:NSUTF8StringEncoding];
            NSString *postBodyString = [[NSString alloc] initWithData:request.YHV_HTTPBody encoding:NSUTF8StringEncoding];
            stubPostBodyString = [stubPostBodyString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            postBodyString = [postBodyString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            stubPostBody = [NSDictionary YHV_dictionaryWithQuery:stubPostBodyString];
            postBody = [NSDictionary YHV_dictionaryWithQuery:postBodyString];
        }
        
#if YHV_OUTPUT_MATCHING
         NSLog(@"\nBODY MATCH (STUB %@)\nORIG: %@\nSTUB: %@\nMATCH: %@",
               stubRequest ? @"EXISTS" : @"IS MISSING",
               [[NSString alloc] initWithData:request.YHV_HTTPBody encoding:NSUTF8StringEncoding],
               [[NSString alloc] initWithData:stubRequest.YHV_HTTPBody encoding:NSUTF8StringEncoding],
               ((stubPostBody && postBody && [postBody isEqualToDictionary:stubPostBody]) ||
                [request.YHV_HTTPBody isEqual:stubRequest.YHV_HTTPBody]) ? @"YES" : @"NO");
#endif
        
        return ((stubPostBody && postBody && [postBody isEqualToDictionary:stubPostBody]) ||
                [request.YHV_HTTPBody isEqual:stubRequest.YHV_HTTPBody]);
    };
}


#pragma mark - Matching

+ (BOOL)request:(NSURLRequest *)originalRequest isMatchingTo:(NSURLRequest *)stubRequest withMatchers:(NSArray<YHVMatcherBlock> *)matchers {
    
    BOOL match = NO;
    
    if (!matchers.count) {
        return YES;
    }
    
    for (YHVMatcherBlock matchBlock in matchers) {
        match = matchBlock(originalRequest, stubRequest);
        
        if (!match) {
            break;
        }
    }
    
    return match;
}

#pragma mark -


@end
