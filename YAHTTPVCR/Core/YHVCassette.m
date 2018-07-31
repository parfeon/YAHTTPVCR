/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVCassette+Private.h"
#import "YHVConfiguration+Private.h"
#import "NSURLRequest+YHVPlayer.h"
#import "NSDictionary+YHVNSURL.h"
#import "YHVRequestMatchers.h"
#import "YHVNSURLProtocol.h"
#import "YHVScene.h"


#pragma mark Protected interface declaration

@interface YHVCassette ()


#pragma mark - Information

/**
 * @brief  Stores reference on dictionary which maps scene chapter identifier to protocol client which handle stubbed data.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, YHVNSURLProtocol *> *activeClients;

/**
 * @brief  Stores reference on list of identifiers for chapters which played all scenes.
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *completedChaptersIdentifier;

/**
 * @brief  Stores reference on list of chatpter identifiers for which request has been initiated by \a NSURLConnection.
 *
 * @since 1.1.0
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *connectionChapterIdentifiers;

/**
 * @brief  Stores whether this should be new cassette or no, because data file doesn't exists at specified location.
 */
@property (nonatomic, assign, getter = isNewCassette) BOOL newCassette;

/**
 * @brief  Stores reference on dictionary which maps request identifier to unique identifier under which scene will be stored.
 *
 * @since 1.1.0
 */
@property (nonatomic, strong) NSMutableDictionary *requestsIdentifiers;

/**
 * @brief  Stores reference on list of chapters which is recorded on cassette.
 * @note   Chapters stored in same order as they has been recorded (event thought, what one of them ends after another already has been started).
 */
@property (nonatomic, strong) NSArray<NSString *> *chapterIdentifiers;

/**
 * @brief  Stores reference on queue which is used to serialize access to shared object information.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief  Stores reference on set of recorded scenes (request and responses) which should be played on VCR.
 */
@property (nonatomic, strong) NSMutableArray<YHVScene *> *scenes;

/**
 * @brief  Stores reference on configuration which contain information about how cassette should operate and which data to use.
 */
@property (nonatomic, copy) YHVConfiguration *configuration;

/**
 * @brief  Stores whether there is changes in cassette's data which should be saved.
 */
@property (nonatomic, assign, getter = isDirty) BOOL dirty;

/**
 * @brief  Stores whether cassette's chapters playback started or not.
 */
@property (nonatomic, assign) BOOL playbackStarted;


#pragma mark - Initialization and Configuration

/**
 * @brief  Initialized cassette instance.
 *
 * @param configuration Reference on instance which contain information required for cassette to be loaded and handle requests.
 *
 * @return Initialized and ready to use cassette instance.
 */
- (instancetype)initWithConfiguration:(YHVConfiguration *)configuration;


#pragma mark - Content management

- (void)fetchListOfChapterIdentifiers;


#pragma mark - Playback

/**
 * @brief  Search and play scenes for chapter with specified identifier.
 *
 * @param chapterIdentifier Reference on unique identifier of chapter which stored on cassette and should be played.
 */
- (void)playResponsesForChapterWithIdentifier:(NSString *)chapterIdentifier;

/**
 * @brief  Mark scene for chapter as played.
 *
 * @param sceneType  Reference on one of \b YHVSceneType enum fields which specift type of data shown on scene.
 * @param identifier Reference on unique chapyer identifier to which played scene belongs.
 */
- (void)markSceneAsPlayed:(YHVSceneType)sceneType forChapterWithIdentifier:(NSString *)identifier;

/**
 * @brief  Retrieve index of scene which not played yet.
 *
 * @return Scene index inside of \c scenes list.
 */
- (NSUInteger)nextNotPlayedSceneIndex;

/**
 * @brief  Retrieve reference of next chapter for which not all scenes has been played.
 *
 * @return Unique identifier of chapter for which scenes should be played in next cycle.
 */
- (NSString *)nextIncompleteChapterIdentifier;

/**
 * @brief      Retrieve next within scene with specified \c identifier.
 * @discussion Depending from configuration, this method may return all responses one-by-one or if there is different requests it may return
 *             \c nil for time when another request processing required.
 *
 * @param identifier Reference on unique identifier within which next not played scene should be searched.
 *
 * @return Scene for playback.
 */
- (nullable YHVScene *)nextSceneForChapterWithIdentifier:(NSString *)identifier;

/**
 * @brief  Retrieve reference on chapter which contain scenes to re-play data for \c request.
 *
 * @param request Reference on request against which matchers should be applied.
 *
 * @return Non-\c nil chapter identifier if data recorded for request.
 */
- (nullable NSString *)chapterIdentifierForRequest:(NSURLRequest *)request;



#pragma mark - Recording

/**
 * @brief      Store specified \c scene on cassette's tape if possible.
 * @discussion Depending from \c recordMode code may throw exception in attempt to change cassette's content.
 *
 * @param scene Reference on object which should be recorded on tape.
 */
- (void)recordScene:(YHVScene *)scene;


#pragma mark - Misc

/**
 * @brief      Filter out sensitive data packed into error.
 * @discussion Usually errors associated with called URI - this is what should be filtered.
 *
 * @param error Reference on error instance which should be filtered out.
 *
 * @return Error instance which has filtered \c userInfo.
 */
- (NSError *)errorForRequest:(NSURLRequest *)request withFilteredUserInfo:(NSError *)error;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation YHVCassette


#pragma mark - Information

- (YHVConfiguration *)configuration {
    
    return [self->_configuration copy];
}

- (NSArray<YHVScene *> *)availableScenes {
    
    __block NSArray<YHVScene *> *availableScenes = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        availableScenes = self->_scenes;
    });
    
    return availableScenes;
}

- (NSUInteger)playCount {
    
    __block NSUInteger playCount = 0;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        for (NSUInteger sceneIdx = 0; sceneIdx < self.scenes.count; sceneIdx++) {
            if ((self.scenes[sceneIdx].type == YHVClosingScene || self.scenes[sceneIdx].type == YHVErrorScene) &&
                self.scenes[sceneIdx].played) {
                
                playCount++;
            }
        }
    });
    
    return playCount;
}

- (BOOL)allPlayed {
    
    NSUInteger requestsCount = self.requests.count;
    BOOL allPlayed = NO;
    
    if (!self.isNewCassette) {
        allPlayed = requestsCount > 0 && [self playCount] == requestsCount;
    }
    
    return allPlayed;
}

- (BOOL)isWriteProtected {
    
    return (!self.isNewCassette && self.configuration.recordMode == YHVRecordOnce) || self.configuration.recordMode == YHVRecordNone;
}

- (NSArray<NSURLRequest *> *)requests {
    
    NSMutableArray<NSURLRequest *> *requests = [NSMutableArray new];
    
    dispatch_sync(self.resourceAccessQueue, ^{
        for (YHVScene *scene in self.scenes) {
            if (scene.type != YHVRequestScene) {
                continue;
            }
            
            [requests addObject:(id)scene.data];
        }
    });
    
    return requests;
}

- (NSArray<NSArray *> *)responses {
    
    NSMutableArray<NSArray *> *requests = [NSMutableArray new];
    
    dispatch_sync(self.resourceAccessQueue, ^{
        for (YHVScene *responseScene in self.scenes) {
            if (responseScene.type != YHVResponseScene) {
                continue;
            }
            
            id data = nil;
            NSMutableData *accumulatedData = [NSMutableData new];

            for (YHVScene *responseDataScene in self.scenes) {
                if (![responseDataScene.identifier isEqualToString:responseScene.identifier] || responseDataScene.type != YHVDataScene) {
                    if (responseDataScene.type == YHVErrorScene) {
                        data = responseDataScene.data;
                        break;
                    }
                    continue;
                }
                
                [accumulatedData appendData:((id)responseDataScene.data ?: [NSData new])];
            }
            
            [requests addObject:@[responseScene.data, data ?: accumulatedData]];
        }
    });
    
    return requests;
}


#pragma mark - Initialization and Configuration

+ (instancetype)cassetteWithConfiguration:(YHVConfiguration *)configuration {
    
    return [[self alloc] initWithConfiguration:configuration];
}

- (instancetype)initWithConfiguration:(YHVConfiguration *)configuration {
    
    if ((self = [super init])) {
        _resourceAccessQueue = dispatch_queue_create("com.yetanotherhttpvcr.cassette", DISPATCH_QUEUE_SERIAL);
        _connectionChapterIdentifiers = [NSMutableArray new];
        _completedChaptersIdentifier = [NSMutableArray new];
        _requestsIdentifiers = [NSMutableDictionary new];
        _activeClients = [NSMutableDictionary new];
        _configuration = [configuration copy];
        _scenes = [NSMutableArray new];
        
    }
    
    return self;
}


#pragma mark - Content management

- (void)load {
    
    self.newCassette = ![NSFileManager.defaultManager fileExistsAtPath:self.configuration.cassettePath isDirectory:nil];
    
    if (self.isNewCassette) {
        return;
    }
    
    dispatch_sync(self.resourceAccessQueue, ^{
        NSMutableArray<YHVScene *> *deserializedScenes = [NSMutableArray new];
        NSArray<NSDictionary *> *content = nil;
        
        if ([[self.configuration.cassettePath pathExtension] isEqualToString:@"json"]) {
            NSData *jsonData = [NSData dataWithContentsOfFile:self.configuration.cassettePath];
            content = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        } else {
            content = [NSArray arrayWithContentsOfFile:self.configuration.cassettePath];
        }
        
        for (NSDictionary *sceneDictionary in content) {
            [deserializedScenes addObject:[YHVScene YHV_objectFromDictionary:sceneDictionary]];
        }
        
        [self.scenes addObjectsFromArray:deserializedScenes];
        
        [self fetchListOfChapterIdentifiers];
    });
}

- (void)save {
    
    dispatch_sync(self.resourceAccessQueue, ^{
        if (!self.isDirty) {
            return;
        }
        
        NSArray *serializedScenes = [self.scenes valueForKey:@"YHV_dictionaryRepresentation"];
        id content = serializedScenes;
        
        if ([[self.configuration.cassettePath pathExtension] isEqualToString:@"json"]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&error];
            content = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        [content writeToFile:self.configuration.cassettePath atomically:YES];
    });
}

- (void)fetchListOfChapterIdentifiers {
    
    NSMutableArray *identifiers = [NSMutableArray new];
    
    for (YHVScene *scene in self.scenes) {
        if (![identifiers containsObject:scene.identifier]) {
            [identifiers addObject:scene.identifier];
        }
    }
    
    self.chapterIdentifiers = identifiers;
}


#pragma mark - Playback

- (BOOL)sceneRequest:(YHVScene *)scene matchToRequest:(NSURLRequest *)request {
    
    BOOL match = NO;
    
    if (!scene || !request) {
        return match;
    }
    
    NSURLRequest *filteredRequest = self.configuration.beforeRecordRequest(request);
    
    if (filteredRequest && scene.type == YHVRequestScene) {
        match = [YHVRequestMatchers request:filteredRequest isMatchingTo:(id)scene.data withMatchers:self.configuration.matchers];
    }
    
    return match;
}

- (BOOL)canPlayResponseForRequest:(NSURLRequest *)request {
    
    if (self.configuration.recordMode == YHVRecordAll) {
        return NO;
    }
    
    __block BOOL canPlayResponse = NO;
    dispatch_sync(self.resourceAccessQueue, ^{
        NSString *chapterIdentifier = [self chapterIdentifierForRequest:request];
        canPlayResponse = chapterIdentifier != nil;
        
        if (canPlayResponse) {
            request.YHV_cassetteChapterIdentifier = chapterIdentifier;
        }
    });
    
    return canPlayResponse;
}

- (void)prepareToPlayResponsesWithProtocol:(YHVNSURLProtocol *)protocol {

    if (!protocol.request.YHV_usingNSURLSession) {
        dispatch_sync(self.resourceAccessQueue, ^{
            protocol.request.YHV_cassetteChapterIdentifier = [self chapterIdentifierForRequest:protocol.request];
            [self.connectionChapterIdentifiers addObject:protocol.request.YHV_cassetteChapterIdentifier];
        });
    }
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSAssert(protocol.request.YHV_cassetteChapterIdentifier, @"Unable to play response. Unknown request");
        NSAssert(!self.activeClients[protocol.request.YHV_cassetteChapterIdentifier], @"Already playing stubbed response.");
        
        self.activeClients[protocol.request.YHV_cassetteChapterIdentifier] = protocol;
    });
}

- (void)playResponsesForRequest:(NSURLRequest *)request {
    
    [self playResponsesForChapterWithIdentifier:request.YHV_cassetteChapterIdentifier];
}

- (void)playResponsesForChapterWithIdentifier:(NSString *)chapterIdentifier {
    
    __block BOOL readyToPlayScenesForChapter = NO;
    __block BOOL waitingForAnotherChapter = NO;
    __block BOOL chapterPlayed = NO;
    __block YHVScene *scene = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        chapterPlayed = [self.completedChaptersIdentifier containsObject:chapterIdentifier];
        readyToPlayScenesForChapter = self.activeClients[chapterIdentifier] != nil;
        scene = [self nextSceneForChapterWithIdentifier:chapterIdentifier];
        
        if (self.configuration.playbackMode == YHVMomentaryPlayback) {
            NSUInteger chapterIndex = [self.chapterIdentifiers indexOfObject:chapterIdentifier];
            NSString *previousChapterIdentifier = chapterIndex > 0 ? self.chapterIdentifiers[chapterIndex - 1] : nil;
            waitingForAnotherChapter = previousChapterIdentifier && ![self.completedChaptersIdentifier containsObject:previousChapterIdentifier];
        }
    });
    
    if (chapterPlayed || !readyToPlayScenesForChapter || waitingForAnotherChapter || !scene || scene.played || scene.playing) {
        NSString *nextChapterIdentifier = chapterPlayed ? [self nextIncompleteChapterIdentifier] : nil;
        
        if (nextChapterIdentifier) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self playResponsesForChapterWithIdentifier:nextChapterIdentifier];
            });
        }
        return;
    }
    
    dispatch_async(self.resourceAccessQueue, ^{
        YHVNSURLProtocol *protocol = self.activeClients[chapterIdentifier];
        scene.playing = YES;
        
        if (scene.type == YHVResponseScene) {
            [protocol.client URLProtocol:protocol didReceiveResponse:(id)scene.data cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            
            if ([self.connectionChapterIdentifiers containsObject:chapterIdentifier]) {
                [self handleResponsePlayedForRequest:protocol.request];
            }
        } else if (scene.type == YHVDataScene) {
            NSData *data = (id)scene.data;
            
            if (data.length) {
                [protocol.client URLProtocol:protocol didLoadData:data];
            }
            
            if (!data.length || [self.connectionChapterIdentifiers containsObject:chapterIdentifier]) {
                [self handleDataPlayedForRequest:protocol.request];
            }
        } else if (scene.type == YHVErrorScene) {
            [protocol.client URLProtocol:protocol didFailWithError:(id)scene.data];
            
            if ([self.connectionChapterIdentifiers containsObject:chapterIdentifier]) {
                [self handleError:(id)scene.data playedForRequest:protocol.request];
            }
        } else if (scene.type == YHVClosingScene) {
            [protocol.client URLProtocolDidFinishLoading:protocol];
            
            if ([self.connectionChapterIdentifiers containsObject:chapterIdentifier]) {
                [self handleError:nil playedForRequest:protocol.request];
            }
        }
    });
}

- (void)markSceneAsPlayed:(YHVSceneType)sceneType forChapterWithIdentifier:(NSString *)identifier {
    
    dispatch_async(self.resourceAccessQueue, ^{
        if (![self.completedChaptersIdentifier containsObject:identifier]) {
            YHVScene *scene = [self nextSceneForChapterWithIdentifier:identifier];
            
            if (scene && !scene.played && (scene.playing || sceneType == YHVRequestScene) && scene.type == sceneType) {
                if (scene.type == YHVErrorScene || scene.type == YHVClosingScene) {
                    [self.completedChaptersIdentifier addObject:identifier];
                }
                
                scene.playing = NO;
                scene.played = YES;
                
                if (sceneType != YHVRequestScene) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self playResponsesForChapterWithIdentifier:identifier];
                    });
                }
            }
        }
    });
}

- (void)handleRequestPlayedForTask:(NSURLSessionTask *)task {

    [self handleRequestPlayedForRequest:task.originalRequest];
}

- (void)handleResponsePlayedForTask:(NSURLSessionTask *)task {

    [self handleResponsePlayedForRequest:task.originalRequest];
}

- (void)handleDataPlayedForTask:(NSURLSessionTask *)task {

    [self handleDataPlayedForRequest:task.originalRequest];
}

- (void)handleError:(NSError *)error playedForTask:(NSURLSessionTask *)task {

    [self handleError:error playedForRequest:task.originalRequest];
}

- (void)handleRequestPlayedForRequest:(NSURLRequest *)request {

    [self markSceneAsPlayed:YHVRequestScene forChapterWithIdentifier:request.YHV_cassetteChapterIdentifier];
}

- (void)handleResponsePlayedForRequest:(NSURLRequest *)request {

    [self markSceneAsPlayed:YHVResponseScene forChapterWithIdentifier:request.YHV_cassetteChapterIdentifier];
}

- (void)handleDataPlayedForRequest:(NSURLRequest *)request {

    [self markSceneAsPlayed:YHVDataScene forChapterWithIdentifier:request.YHV_cassetteChapterIdentifier];
}

- (void)handleError:(NSError *)error playedForRequest:(NSURLRequest *)request {

    [self markSceneAsPlayed:(error ? YHVErrorScene : YHVClosingScene) forChapterWithIdentifier:request.YHV_cassetteChapterIdentifier];
}

- (NSUInteger)nextNotPlayedSceneIndex {
    
    NSUInteger index = NSNotFound;
    
    for (NSUInteger sceneIdx = 0; sceneIdx < self.scenes.count; sceneIdx++) {
        if (self.scenes[sceneIdx].played) {
            continue;
        }
        
        index = sceneIdx;
        break;
    }
    
    return index;
}

- (NSString *)nextIncompleteChapterIdentifier {
    
    NSString *chapterIdentifier = nil;
    for (NSString *storedChapterIdentifier in self.chapterIdentifiers) {
        if ([self.completedChaptersIdentifier containsObject:storedChapterIdentifier]) {
            continue;
        }
        
        chapterIdentifier = [self nextSceneForChapterWithIdentifier:storedChapterIdentifier] ? storedChapterIdentifier: nil;
        if (chapterIdentifier) {
            break;
        }
    }
    
    return chapterIdentifier;
}

- (YHVScene *)nextSceneForChapterWithIdentifier:(NSString *)identifier {
    
    YHVScene *nextChapterScene = nil;
    
    for (YHVScene *scene in self.scenes) {
        if (scene.played) {
            continue;
        }
        
        if ([scene.identifier isEqualToString:identifier]) {
            nextChapterScene = scene;
        }
        
        if (nextChapterScene || self.configuration.playbackMode == YHVChronologicalPlayback) {
            break;
        }
    }
    
    return nextChapterScene;
}

- (NSString *)chapterIdentifierForRequest:(NSURLRequest *)request {
    
    NSString *identifier = nil;
    
    for (YHVScene *scene in self.scenes) {
        if (scene.played || scene.type != YHVRequestScene) {
            continue;
        }
        
        if ([self sceneRequest:scene matchToRequest:request]) {
            identifier = scene.identifier;
            break;
        }
    }
    
    return identifier;
}


#pragma mark - Recording

- (void)beginRecordingTask:(NSURLSessionTask *)task {

    [self beginRecordingRequest:task.originalRequest];
}

- (void)recordResponse:(NSURLResponse *)response forTask:(NSURLSessionTask *)task {

    [self recordResponse:response forRequest:task.originalRequest];
}

- (void)recordData:(NSData *)data forTask:(NSURLSessionTask *)task {

    [self recordData:data forRequest:task.originalRequest];
}

- (void)recordCompletionWithError:(NSError *)error forTask:(NSURLSessionTask *)task {

    [self recordCompletionWithError:error forRequest:task.originalRequest];
}

- (void)clearFetchedDataForTask:(NSURLSessionTask *)task {

    [self clearFetchedDataForRequest:task.originalRequest];
}


#pragma mark - Recording request

- (void)beginRecordingRequest:(NSURLRequest *)request {
    
    if (request.YHV_VCRIgnored || request.YHV_cassetteChapterIdentifier) {
        return;
    }

    request.YHV_identifier = request.YHV_identifier ?: [NSUUID UUID].UUIDString;
    __block NSString *identifier = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        NSAssert(!self.requestsIdentifiers[request.YHV_identifier], @"Already tracking request with '%@' identifier.", request.YHV_identifier);
        
        identifier = [NSUUID UUID].UUIDString;
        self.requestsIdentifiers[request.YHV_identifier] = identifier;
    });
    
    NSURLRequest *fiteredRequest = self.configuration.beforeRecordRequest(request);
    
    if (fiteredRequest) {
        [self recordScene:[YHVScene sceneWithIdentifier:identifier type:YHVRequestScene data:fiteredRequest]];
    }
}


- (void)recordResponse:(NSURLResponse *)response forRequest:(NSURLRequest *)request {
    
    if (request.YHV_VCRIgnored || request.YHV_cassetteChapterIdentifier) {
        return;
    }

    __block YHVScene *requestScene = nil;
    __block NSString *identifier = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        identifier = self.requestsIdentifiers[request.YHV_identifier];
        
        for (YHVScene *scene in self.scenes) {
            if ([scene.identifier isEqualToString:identifier] && scene.type == YHVRequestScene) {
                requestScene = scene;
            }
            
            if (requestScene) {
                break;
            }
        }
    });
    
    NSAssert(identifier, @"Unable to record response. Currently doesn't track request with %@ identifier.", request.YHV_identifier);
    
    NSArray *filteredResponse = self.configuration.beforeRecordResponse((id)requestScene.data, (id)response, nil);
    
    [self recordScene:[YHVScene sceneWithIdentifier:identifier type:YHVResponseScene data:filteredResponse.firstObject]];
}

- (void)recordData:(NSData *)data forRequest:(NSURLRequest *)request {
    
    if (request.YHV_VCRIgnored || request.YHV_cassetteChapterIdentifier) {
        return;
    }

    __block YHVScene *responseScene = nil;
    __block YHVScene *requestScene = nil;
    __block NSString *identifier = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        identifier = self.requestsIdentifiers[request.YHV_identifier];
        
        for (YHVScene *scene in self.scenes) {
            if ([scene.identifier isEqualToString:identifier]) {
                if (scene.type == YHVRequestScene) {
                    requestScene = scene;
                } else if (scene.type == YHVResponseScene) {
                    responseScene = scene;
                }
            }
            
            if (requestScene && responseScene) {
                break;
            }
        }
    });
    
    NSAssert(identifier, @"Unable to record data. Currently doesn't track request with %@ identifier.", request.YHV_identifier);
    
    NSArray *filteredResponse = self.configuration.beforeRecordResponse((id)requestScene.data, (id)responseScene.data, data);
    
    if (filteredResponse.count == 2) {
        [self recordScene:[YHVScene sceneWithIdentifier:identifier type:YHVDataScene data:filteredResponse.lastObject]];
    }
}

- (void)recordCompletionWithError:(NSError *)error forRequest:(NSURLRequest *)request {
    
    if (request.YHV_VCRIgnored || request.YHV_cassetteChapterIdentifier) {
        return;
    }

    __block NSString *identifier = nil;
    dispatch_sync(self.resourceAccessQueue, ^{
        identifier = self.requestsIdentifiers[request.YHV_identifier];
        [self.requestsIdentifiers removeObjectForKey:request.YHV_identifier];
    });
    
    NSAssert(identifier, @"Unable to record %@. Currently doesn't track request with %@ identifier.", (error ? @"error" : @"completion"),
             request.YHV_identifier);
    
    if (error) {
        error = [self errorForRequest:request withFilteredUserInfo:error];
    }
    
    [self recordScene:[YHVScene sceneWithIdentifier:identifier type:(error ? YHVErrorScene : YHVClosingScene) data:error]];
}

- (void)clearFetchedDataForRequest:(NSURLRequest *)request {
    
    if (request.YHV_VCRIgnored) {
        return;
    }

    __block NSString *identifier = nil;
    dispatch_sync(self.resourceAccessQueue, ^{
        identifier = self.requestsIdentifiers[request.YHV_identifier];
    });
    
    NSAssert(identifier, @"Unable clear fetched data. Currently doesn't track request with %@ identifier.", request.YHV_identifier);
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSMutableArray *dataScenes = [NSMutableArray new];
        
        for (YHVScene *responseDataScene in self.scenes) {
            if (responseDataScene.type == YHVDataScene && [responseDataScene.identifier isEqualToString:identifier]) {
                [dataScenes addObject:responseDataScene];
            }
        }
        
        [self.scenes removeObjectsInArray:dataScenes];
    });
}

- (void)recordScene:(YHVScene *)scene {
    
    NSAssert(!self.isWriteProtected, @"Cassette is write protected. Unable to write new data.");
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSUInteger nextSceneIndex = [self nextNotPlayedSceneIndex];
        scene.played = YES;
        self.dirty = YES;
        
        if (nextSceneIndex == NSNotFound || nextSceneIndex + 1 == self.scenes.count) {
            [self.scenes addObject:scene];
        } else {
            [self.scenes insertObject:scene atIndex:nextSceneIndex];
        }
    });
}


#pragma mark - Misc

- (NSError *)errorForRequest:(NSURLRequest *)request withFilteredUserInfo:(NSError *)error {
    
    NSMutableDictionary *errorUserInfo = [error.userInfo mutableCopy];
    
    if (!errorUserInfo.count) {
        return error;
    }
    
    for (NSString *errorInfoKey in @[NSURLErrorKey, NSURLErrorFailingURLErrorKey, NSURLErrorFailingURLStringErrorKey]) {
        if (!errorUserInfo[errorInfoKey]) {
            continue;
        }
        
        BOOL isStringifiedURL = [errorInfoKey isEqualToString:NSURLErrorFailingURLStringErrorKey];
        NSURL *url = isStringifiedURL ? [NSURL URLWithString:errorUserInfo[errorInfoKey]] : errorUserInfo[errorInfoKey];
        url = self.configuration.urlFilter(request, url);
        
        errorUserInfo[errorInfoKey] = isStringifiedURL ? url.absoluteString : url;
    }
    
    if (errorUserInfo[NSUnderlyingErrorKey]) {
        errorUserInfo[NSUnderlyingErrorKey] = [self errorForRequest:request withFilteredUserInfo:errorUserInfo[NSUnderlyingErrorKey]];
    }
    
    return [NSError errorWithDomain:error.domain code:error.code userInfo:errorUserInfo];
}

#pragma mark -


@end
