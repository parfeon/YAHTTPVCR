#import "YHVSerializableDataProtocol.h"
#import "YHVPrivateStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Storage for data fetch tasks progress.
 * @discussion Each change in data fetch task state stored in separate scene.
 *
 * @author Serhii Mamontov
 * @since 1.0.0
 */
@interface YHVScene : NSObject <YHVSerializableDataProtocol>


#pragma mark Information

/**
 * @brief  Stores reference on type of scene.
 */
@property (nonatomic, readonly, assign) YHVSceneType type;

/**
 * @brief      Unique identifier of chapter to which scene belongs.
 * @discussion This identifier is used to group scenes together and help to find related data.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 * @brief      Information about data stored in scene.
 * @discussion Data type depends from scene's \c type.
 */
@property (nonatomic, readonly, strong) id<YHVSerializableDataProtocol> data;

/**
 * @brief  Stores whether scene currently playing it's content or not.
 */
@property (nonatomic, readonly, assign) BOOL playing;

/**
 * @brief  Stores whether scene has been played or not.
 */
@property (nonatomic, readonly, assign) BOOL played;


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
+ (instancetype)sceneWithIdentifier:(NSString *)identifier type:(YHVSceneType)type data:(nullable id)data;


#pragma mark - Playback

/**
 * @brief Mark scene as currently active.
 *
 * @since 1.3.0
 */
- (void)setPlaying;

/**
 * @brief Set scene playback completion.
 *
 * @since 1.3.0
 */
- (void)setPlayed;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
