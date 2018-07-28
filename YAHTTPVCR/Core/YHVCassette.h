#import <Foundation/Foundation.h>


#pragma mark Class forward

@class YHVConfiguration;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      VCR cassette.
 * @discussion Class represent cassette which is used by VCR to replay / record request sent by code.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface YHVCassette : NSObject


#pragma mark - Information

/**
 * @brief  Stores reference on final cassette configuration which has been created after merge with VCR configuration.
 */
@property (nonatomic, readonly, copy) YHVConfiguration *configuration;

/**
 * @brief  Stores number of requests for which responses has been played from cassette.
 */
@property (nonatomic, readonly, assign) NSUInteger playCount;

/**
 * @brief  Stores whether all responses has been played or not.
 */
@property (nonatomic, readonly, assign) BOOL allPlayed;

/**
 * @brief  Stores whether cassette has protection against write or not.
 */
@property (nonatomic, readonly, assign, getter = isWriteProtected) BOOL writeProtected;

/**
 * @brief      Stores list of all recorded so far requests.
 * @discussion List of requests in same order as they has been written.
 */
@property (nonatomic, readonly, strong) NSArray<NSURLRequest *> *requests;

/**
 * @brief      Stores list of all recorded so far responses.
 * @discussion List of responses is same order as they has been received. Each entry is list where first element is \a NSURLResponse and second
 *             is \a NSData (actual service response) or \a NSError (in case if request processing error has been recorded).
 */
@property (nonatomic, readonly, strong) NSArray<NSArray *> *responses;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
