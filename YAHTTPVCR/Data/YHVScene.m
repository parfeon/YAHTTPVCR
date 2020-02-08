/**
 * @author Serhii Mamontov
 * @since 1.0.0
 */
#import "YHVScene.h"
#import "YHVSerializationHelper.h"


#pragma mark Constants

/**
 * @brief  Stores reference on key under which stored unique scene identifier inside of serialized dictionary.
 */
static NSString * const kYHVSceneIdentifierKey = @"id";

/**
 * @brief  Stores reference on key under which stored scene presented data inside of serialized dictionary.
 */
static NSString * const kYHVSceneDataKey = @"data";

/**
 * @brief  Stores reference on key under which stored scene data tyoe inside of serialized dictionary.
 */
static NSString * const kYHVSceneTypeKey = @"type";


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface YHVScene ()


#pragma mark - Information

/**
 * @brief  Stores reference on queue which is used to serialize access to shared object information.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief  Stores reference on type of scene.
 */
@property (nonatomic, assign) YHVSceneType type;

/**
 * @brief      Unique identifier of chapter to which scene belongs.
 * @discussion This identifier is used to group scenes together and help to find related data.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * @brief      Information about data stored in scene.
 * @discussion Data type depends from scene's \c type.
 */
@property (nonatomic, strong) id<YHVSerializableDataProtocol> data;

/**
 * @brief  Stores whether scene currently playing it's content or not.
 */
@property (nonatomic, assign) BOOL playing;

/**
 * @brief  Stores whether scene has been played or not.
 */
@property (nonatomic, assign) BOOL played;


#pragma mark - Initialization and Configuration

/**
 * @brief  Create and configure scene instance.
 *
 * @param identifier Unique chapter identifier to which scene belongs.
 * @param type       Type of scene and data which stored in scene.
 * @param data       Reference on object which should be stored in scene.
 *
 * @return Configured and read to use scene instance.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier type:(YHVSceneType)type data:(nullable id)data;


#pragma mark - Deserialization

/**
 * @brief  Extract data object which is presented with scene.
 *
 * @param dictionary Reference on dictionary which present previously serialized scene.
 *
 * @return Reference on previously represented data object.
 */
+ (nullable id)dataObjectFromDictionary:(NSDictionary *)dictionary;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation YHVScene


#pragma mark - Information

- (BOOL)playing {
    
    __block BOOL playing = NO;
    dispatch_sync(self.resourceAccessQueue, ^{
        playing = self->_playing;
    });
    
    return playing;
}

- (BOOL)played {
    
    __block BOOL played = NO;
    dispatch_sync(self.resourceAccessQueue, ^{
        played = self->_played;
    });
    
    return played;
}


#pragma mark - Initialization and Configuration

+ (instancetype)YHV_objectFromDictionary:(NSDictionary *)dictionary {
    
    NSAssert(dictionary, @"Unable initialize scene from 'nil'.");
    NSAssert(dictionary[kYHVSceneIdentifierKey], @"Scene identifier is 'nil'.");
    NSAssert(dictionary[kYHVSceneTypeKey], @"Scene type is 'nil'.");
    
    YHVSceneType type = ((NSNumber *)dictionary[kYHVSceneTypeKey]).unsignedIntegerValue;
    if (type == YHVRequestScene || type == YHVResponseScene || type == YHVErrorScene) {
        NSAssert(dictionary[kYHVSceneDataKey], @"Scene data is 'nil'.");
    }
    
    return [self sceneWithIdentifier:dictionary[kYHVSceneIdentifierKey] type:type data:[self dataObjectFromDictionary:dictionary]];
}

+ (instancetype)sceneWithIdentifier:(NSString *)identifier type:(YHVSceneType)type data:(id)data {
    
    NSAssert(identifier.length, @"Scene initialization error. Identifier is empty.");
    if (![@[@(YHVRequestScene), @(YHVResponseScene), @(YHVDataScene), @(YHVErrorScene), @(YHVClosingScene)] containsObject:@(type)]) {
        NSAssert(0, @"Scene initialization error. Unknown scene data type.");
    }
    
    return [[self alloc] initWithIdentifier:identifier type:type data:data];
}

- (instancetype)initWithIdentifier:(NSString *)identifier type:(YHVSceneType)type data:(id)data {
    
    if ((self = [super init])) {
        NSString *sceneQueueIdentifier = [@[@"com.yetanotherhttpvcr.cassette.scene", identifier] componentsJoinedByString:@"."];
        _resourceAccessQueue = dispatch_queue_create([sceneQueueIdentifier cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        
        _identifier = [identifier copy];
        _type = type;
        _data = data;
    }
    
    return self;
}


#pragma mark - Playback

- (void)setPlaying {
    
    dispatch_sync(self.resourceAccessQueue, ^{
        self.playing = YES;
    });
}

- (void)setPlayed {
    
    dispatch_sync(self.resourceAccessQueue, ^{
        self.playing = NO;
        self.played = YES;
    });
}


#pragma mark - Serialization

- (NSDictionary *)YHV_dictionaryRepresentation {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    dictionary[kYHVSceneIdentifierKey] = self.identifier;
    dictionary[kYHVSceneDataKey] = [YHVSerializationHelper dictionaryFromObject:self.data];
    dictionary[kYHVSceneTypeKey] = @(self.type);
    
    return dictionary;
}


#pragma mark - Deserialization

+ (id)dataObjectFromDictionary:(NSDictionary *)dictionary {

    return dictionary[kYHVSceneDataKey] ? [YHVSerializationHelper objectFromDictionary:dictionary[kYHVSceneDataKey]] : nil;
}


#pragma mark - Misc

- (NSString *)description {
    
    static NSArray *_sharedTypeNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTypeNames = @[@" YHVRequestScene", @"YHVResponseScene", @"    YHVDataScene", @"   YHVErrorScene", @" YHVClosingScene"];
    });
    
    return [NSString stringWithFormat:@"<YHVScene %p type: %@, id: %@, played: %@, playing: %@>", self, _sharedTypeNames[self.type], self.identifier, 
            self.played ? @"YES" : @"NO", self.playing ? @"YES" : @"NO"];
}

#pragma mark -


@end
