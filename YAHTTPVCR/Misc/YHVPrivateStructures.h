/**
 * @brief Set of types and structures which is used by VCR and it's components.
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 */
#ifndef YHVPrivateStructures_h
#define YHVPrivateStructures_h

#import "YHVStructures.h"


#pragma mark Types and Structures

/**
 * @brief  Recorded scene types.
 */
typedef NS_OPTIONS(NSUInteger, YHVSceneType) {
    
    /**
     * @brief      Scene represent initial request which has been sent.
     * @discussion Along with VCR playhead this scene help to verify whether requested response correspond to the one, which scene represent
     *             or not (exception can be thrown depending from record mode).
     */
    YHVRequestScene,
    
    /**
     * @brief      Scene represent HTTP response for request which has been sent.
     * @discussion If VCR playhead stumbles on this scene it will notify pending objects about it and go for next scene.
     */
    YHVResponseScene,
    
    /**
     * @brief      Scene represent HTTP body binary data from server.
     * @discussion If VCR playhead stumbles on this scene it will notify pending objects about it and go for next scene.
     */
    YHVDataScene,
    
    /**
     * @brief  Scene represent HTTP / network error.
     */
    YHVErrorScene,
    
    /**
     * @brief  Scene represent HTTP processing completion.
     */
    YHVClosingScene
};

#endif // YHVPrivateStructures_h
