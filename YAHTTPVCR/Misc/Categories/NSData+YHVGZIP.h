#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \a NSData functionality extension.
 * @discussion Provides functionality which allow to work with compressed binary data.
 *
 * @author Serhii Mamontov
 * @since 1.4.1
 */
@interface NSData (YHVGZIP)


#pragma mark - GZIP

/**
 * @brief Uncompress previously archived data.
 *
 * @return Uncompressed binary data.
 */
- (NSData *)YHV_unzipped;

#pragma nark -


@end

NS_ASSUME_NONNULL_END
