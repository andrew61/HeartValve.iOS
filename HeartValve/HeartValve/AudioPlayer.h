//
//  AudioPlayer.h
//  MyHealthApp
//
//  Created by Jonathan on 3/24/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayer : NSObject

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

+ (AudioPlayer *)sharedPlayer;
- (void)playAudioWithFileName:(NSString *)fileName;
+ (void)speak:(NSString *)string withSynthesizer:(AVSpeechSynthesizer *)synthesizer;

@end
