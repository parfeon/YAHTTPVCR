#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \a NSHTTPURLResponse extension to make data manipulation easier.
 *
 * @author Serhii Mamontov
 * @since 1.1.0
 */
@interface NSHTTPURLResponse (YHVMisc)


#pragma mark - Initialization and Configuration

/**
 * @brief      Update receivers data to conform request.
 * @discussion Since VCR doesn't record redirection steps (interested in response for particular request) theres is need to deal with
 *             redirections because of which response object change it's URL.
 *
 * @param request Reference on request from which information should be taken for new response.
 *
 * @return Updated HTTP response instance.
 */
- (NSHTTPURLResponse *)YHV_responseForRequest:(NSURLRequest *)request;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
