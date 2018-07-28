/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVConfiguration+Private.h"


#pragma mark Protected interface declaration

@interface YHVConfiguration ()


#pragma mark - Information

/**
 * @brief  Stores reference on block which allow to alter URI object before stub store.
 */
@property (nonatomic, copy) YHVURLFilterBlock urlFilter;

#pragma mark -

@end


#pragma mark - Interface implementation

@implementation YHVConfiguration


#pragma mark - Initialization and Configuration

+ (instancetype)defaultConfiguration {
    
    return [[self alloc] initWithDefaults];
}

- (instancetype)init {
    
    [NSException raise:NSDestinationInvalidException format:@"-init not implemented."];
    
    return nil;
}

- (instancetype)initWithDefaults {
    
    if ((self = [super init])) {
        _matchers = @[YHVMatcher.method, YHVMatcher.scheme, YHVMatcher.host, YHVMatcher.port, YHVMatcher.path, YHVMatcher.query];
        _playbackMode = YHVChronologicalPlayback;
        _recordMode = YHVRecordOnce;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone {
    
    YHVConfiguration *configuration = [YHVConfiguration defaultConfiguration];
    configuration.queryParametersFilter = self.queryParametersFilter;
    configuration.beforeRecordResponse = self.beforeRecordResponse;
    configuration.beforeRecordRequest = self.beforeRecordRequest;
    configuration.responseBodyFilter = self.responseBodyFilter;
    configuration.postBodyFilter = self.postBodyFilter;
    configuration.headersFilter = self.headersFilter;
    configuration.cassettesPath = self.cassettesPath;
    configuration.playbackMode = self.playbackMode;
    configuration.cassettePath = self.cassettePath;
    configuration.hostsFilter = self.hostsFilter;
    configuration.recordMode = self.recordMode;
    configuration.pathFilter = self.pathFilter;
    configuration.urlFilter = self.urlFilter;
    configuration.matchers = self.matchers;
    
    return configuration;
}

- (YHVConfiguration *)copyWithDefaultsFromConfiguration:(YHVConfiguration *)defaultConfiguration {
    
    YHVConfiguration *configuration = [self copy];
    configuration.queryParametersFilter = configuration.queryParametersFilter ?: defaultConfiguration.queryParametersFilter;
    configuration.beforeRecordResponse = configuration.beforeRecordResponse ?: defaultConfiguration.beforeRecordResponse;
    configuration.beforeRecordRequest = configuration.beforeRecordRequest ?: defaultConfiguration.beforeRecordRequest;
    configuration.responseBodyFilter = configuration.responseBodyFilter ?: defaultConfiguration.responseBodyFilter;
    configuration.postBodyFilter = configuration.postBodyFilter ?: defaultConfiguration.postBodyFilter;
    configuration.headersFilter = configuration.headersFilter ?: defaultConfiguration.headersFilter;
    configuration.cassettesPath = configuration.cassettesPath ?: defaultConfiguration.cassettesPath;
    configuration.cassettePath = configuration.cassettePath ?: defaultConfiguration.cassettePath;
    configuration.hostsFilter = configuration.hostsFilter ?: defaultConfiguration.hostsFilter;
    configuration.pathFilter = configuration.pathFilter ?: defaultConfiguration.pathFilter;
    configuration.urlFilter = configuration.urlFilter ?: defaultConfiguration.urlFilter;
    configuration.matchers = configuration.matchers ?: defaultConfiguration.matchers;
    
    return configuration;
}

#pragma mark -


@end
