/**
 * @author Serhii Mamontov
 * @since 1.1.0
 */
#import "NSHTTPURLResponse+YHVMisc.h"


#pragma mark Interface implementation

@implementation NSHTTPURLResponse (YHVMisc)


#pragma mark - Initialization and Configuration

- (NSHTTPURLResponse *)YHV_responseForRequest:(NSURLRequest *)request {

    return [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:self.statusCode HTTPVersion:nil headerFields:self.allHeaderFields];
}

#pragma mark -


@end
