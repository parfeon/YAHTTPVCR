/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVTestCase.h"
#import <objc/runtime.h>
#import "YHVConfiguration+Private.h"
#import "YHVVCR.h"


#pragma mark Static

static const void *YHVTestCaseCassettesPathKey = &YHVTestCaseCassettesPathKey;


#pragma mark - Protected interface declaration

@interface YHVTestCase ()


#pragma mark - Information

/**
 * @brief  Reference on singleton map which maps test suite name to cassettes path.
 */
+ (NSMutableDictionary<NSString *, NSString *> *)cassettesPaths;

/**
 * @brief  Stores reference on path which point to location of all recorded cassettes.
 */
@property (nonatomic, copy) NSString *cassettesPath;

/**
 * @brief  Stores reference on path which contain cassette's data.
 */
@property (nonatomic, copy) NSString *cassettePath;

/**
 * @brief  Reference on queue which is used to access shared resources.
 */
+ (dispatch_queue_t)resourcesAccessQueue;


#pragma mark - Misc

/**
 * @brief  Ensture to set cassettes location path.
 */
- (void)setCassettesPathIfRequired;

/**
 * @brief  Ensture to set particular cassette data location path.
 */
- (void)setCassettePathIfRequired;

/**
 * @brief  Extract cassette name using information about test case.
 */
- (NSString *)cassetteName;


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation YHVTestCase


#pragma mark - Information

+ (NSMutableDictionary<NSString *,NSString *> *)cassettesPaths {
    
    static NSMutableDictionary<NSString *,NSString *> *_cassettesPaths;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cassettesPaths = [NSMutableDictionary new];
    });
    
    return _cassettesPaths;
}

+ (dispatch_queue_t)resourcesAccessQueue {
    
    static dispatch_queue_t _resourceAccessQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _resourceAccessQueue = dispatch_queue_create("com.yhvvvcr.test.accessqueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return _resourceAccessQueue;
}

- (NSString *)cassettesPath {
    
    __block NSString *cassettesPath = nil;
    
    dispatch_sync([[self class] resourcesAccessQueue], ^{
        cassettesPath = [[self class] cassettesPaths][NSStringFromClass([self class])];
    });
    
    return cassettesPath;
}

- (void)setCassettesPath:(NSString *)cassettesPath {
    
    dispatch_async([[self class] resourcesAccessQueue], ^{
        [[self class] cassettesPaths][NSStringFromClass([self class])] = cassettesPath;
    });
}


#pragma mark - Configuration

- (BOOL)shouldSetupVCR {
    
    return YES;
}

- (void)updateCassetteConfigurationFromDefaultConfiguration:(YHVConfiguration *)__unused configuration {
    // Do nothing.
}


- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)__unused configuration {
    // Do nothing.
}


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    [self setCassettesPathIfRequired];
    [self setCassettePathIfRequired];
    
    if (![self shouldSetupVCR]) {
        return;
    }
    
    [YHVVCR setupWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettesPath = self.cassettesPath;
        [self updateVCRConfigurationFromDefaultConfiguration:configuration];
    }];
    
    [YHVVCR insertCassetteWithConfiguration:^(YHVConfiguration *configuration) {
        configuration.cassettePath = [self cassetteName];
        [self updateCassetteConfigurationFromDefaultConfiguration:configuration];
    }];
}

- (void)tearDown {
    
    if ([self shouldSetupVCR]) {
        [YHVVCR ejectCassette];
    }
    
    [super tearDown];
}


#pragma mark - Misc

- (void)setCassettesPathIfRequired {
    
    if (self.cassettesPath) {
        return;
    }
    
    NSString *testSuiteName = NSStringFromClass([self class]);
    NSString *cassettesPath = [[NSBundle bundleForClass:[self class]] pathForResource:testSuiteName ofType:@"bundle" inDirectory:@"Fixtures"];
    
    if (!cassettesPath) {
        NSString *path = [@[NSTemporaryDirectory(), [NSUUID UUID].UUIDString, testSuiteName] componentsJoinedByString:@"/"];
        
        cassettesPath = [path stringByAppendingPathExtension:@"bundle"];
    }
    
    self.cassettesPath = cassettesPath;
}

- (void)setCassettePathIfRequired {

    self.cassettePath = [[self.cassettesPath stringByAppendingPathComponent:[self cassetteName]] stringByAppendingPathExtension:@"json"];
}

- (NSString *)cassetteName {
    
    NSMutableString *cassetteName = [NSMutableString stringWithString:[self.name componentsSeparatedByString:@" "].lastObject];
    [cassetteName replaceOccurrencesOfString:@"]" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, cassetteName.length)];
    [cassetteName replaceOccurrencesOfString:@"test" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, cassetteName.length)];
    [cassetteName replaceOccurrencesOfString:@"_" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, cassetteName.length)];
    
    return [cassetteName copy];
}

#pragma mark -


@end
