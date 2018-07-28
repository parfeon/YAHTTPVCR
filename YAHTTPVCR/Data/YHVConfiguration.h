#import <Foundation/Foundation.h>
#import "YHVStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      VCR components configuration object.
 * @discussion Base class for VCR components configuration objects.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface YHVConfiguration : NSObject <NSCopying>


#pragma mark Information

/**
 * @brief      Stores reference on path where stored existing cassettes and new should be stored.
 * @discussion This configuration in most cases is set during \c VCR configuration.
 * @note       Last path component should be bundle name with \c .bundle extension.
 */
@property (nonatomic, copy) NSString *cassettesPath;

/**
 * @brief      Stores reference on path where stored cassette is stored or should be stored inside of bundle specified by \c cassettesPath VCR
 *             configuration option.
 * @discussion Final path will be created by concatination of VCR's \c cassettesPath and this property.
 * @discussion This configuration in most cases is set during \c cassette configuration.
 * @note       If cassette path ends with \c .json or \c .plist extension - corresponding serializer will be used. If no information about
 *             extension passed, then \c .json will be used.
 */
@property (nonatomic, copy) NSString *cassettePath;

/**
 * @brief      Stores reference on object which is used to filter requests basing on host names.
 * @discussion Object can be \a NSArray with name of allowed hosts or \b YHVHostFilterBlock.
 *             \b YHVHostFilterBlock allow to make decisions dynamically basing on request.
 */
@property (nonatomic, copy) id hostsFilter;

/**
 * @brief      Stores reference on list of registered matchers (from \c YHVMatcher typedef) basing on which two requests should be compared with
 *             each other.
 * @discussion Matchers used during cassette playback to check whether next recorded request is matching to the one which has been requested.
 * @discussion By default enabled following matchers: \c YHVMatcher.method, \c YHVMatcher.scheme, \c YHVMatcher.host, \c YHVMatcher.port,
 *             \c YHVMatcher.path, \c YHVMatcher.query.
 */
@property (nonatomic, nullable, copy) NSArray *matchers;

/**
 * @brief      Stores default cassettess recording mode described in \c YHNRecordMode enum.
 * @discussion This mode describes VCR behavior during cassete playback (yes, mostly it affect cassettes playback, because depending from
 *             configuration it may accept and write new requests or throw exceptions for not recorded).
 * @discussion By default mode set to: \c YHNRecordOnce.
 */
@property (nonatomic, assign) YHVRecordMode recordMode;

/**
 * @brief      Stores default cassettess recording mode described in \c YHVPlaybackMode enum.
 * @discussion This mode describes VCR behavior during cassete playback (yes, mostly it affect cassettes playback, because depending from
 *             configuration it may accept and write new requests or throw exceptions for not recorded).
 * @discussion By default mode set to: \c YHVChronologicalPlayback.
 */
@property (nonatomic, assign) YHVPlaybackMode playbackMode;

/**
 * @brief  Stores reference on block which allow to alter request's URI path component before stub store.
 */
@property (nonatomic, copy) YHVPathFilterBlock pathFilter;

/**
 * @brief      Stores reference on object which is used to filter/replace query parameter values before stub store.
 * @discussion Object can be \a NSDictionary or \b YHVQueryParametersFilterBlock and help to replace or remove (for \c NSDictionary should
 *             store [NSNull null] for \c key which should be removed) values for specific key in \a NSURL query string.
 *             \b YHVQueryParametersFilterBlock allow to make decisions dynamically basing on request.
 */
@property (nonatomic, copy) id queryParametersFilter;

/**
 * @brief      Stores reference on object which is used to filter/replace header values before stub store.
 * @discussion Object can be \a NSDictionary or \b YHVHeadersFilterBlock and help to replace or remove (for \c NSDictionary should store
 *             [NSNull null] for \c header which should be removed) values for specific header in \a NSURLRequest.
 *             \b YHVHeadersFilterBlock allow to make decisions dynamically basing on request.
 */
@property (nonatomic, copy) id headersFilter;

/**
 * @brief      Stores reference on object which is used to filter/replace POST body before stub store.
 * @discussion For requests with POST body and content type set to : \c application/json or \c application/x-www-form-urlencoded it is possible
 *             to pass \a NSDictionary instance which allow to replace or remove (should store [NSNull null] for \c key which should be removed)
 *             values in encoded POST body. \a NSDictionary can be used only against JSON object or \c application/x-www-form-urlencoded.
 *             \b YHVPostBodyFilterBlock can be used for same purpose and allow to make decisions dynamically basing on request.
 */
@property (nonatomic, copy) id postBodyFilter;

/**
 * @brief      Stores reference on object which is used to filter/replace response body before stub store.
 * @discussion For response with content type set to : \c application/json or \c application/x-www-form-urlencoded it is possible
 *             to pass \a NSDictionary instance which allow to replace or remove (should store [NSNull null] for \c key which should be removed)
 *             values in encoded POST body. \a NSDictionary can be used only against JSON object or \c application/x-www-form-urlencoded.
 *             \b YHVResponseBodyFilterBlock can be used for same purpose and allow to make decisions dynamically basing on response.
 */
@property (nonatomic, copy) id responseBodyFilter;

/**
 * @brief      Stores reference on block which will be called by VCR each time when new request not from cassette will be noticed.
 * @discussion This is final point where it is possible to alter values of \a NSURLRequest which will be stored onto cassette.
 */
@property (nonatomic, copy) YHVBeforeRecordRequestBlock beforeRecordRequest;

/**
 * @brief      Stores reference on block which will be called by VCR each time when response for new request will be received.
 * @discussion This is final point where it is possible to alter values of \a NSHTTPURLResponse and service response binary \c data which will be
 *             stored onto cassette.
 */
@property (nonatomic, copy) YHVBeforeRecordResponseBlock beforeRecordResponse;


#pragma mark - Initialization and Configuration

/**
 * @brief  VCR configuration object can be constructed only by \b YHVVCR class.
 *
 * @return \c nil reference because instance can't be created this way.
 */
- (instancetype)__unavailable init;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
