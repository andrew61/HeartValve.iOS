//
//  AudioPlayer.m
//  MyHealthApp
//
//  Created by Jonathan on 3/24/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@implementation AudioPlayer

+ (AudioPlayer *)sharedPlayer
{
    static AudioPlayer *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)playAudioWithFileName:(NSString *)fileName
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
    NSURL *soundURL = [NSURL fileURLWithPath:path];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    [self.audioPlayer play];
}

+ (void)speak:(NSString *)string withSynthesizer:(AVSpeechSynthesizer *)synthesizer
{
    string = [string stringByReplacingOccurrencesOfString:@"," withString:@"."];
    NSArray *lines = [string componentsSeparatedByString:@"."];
    for (NSString *line in lines)
    {
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:line];
        utterance.rate = 0.41;
        utterance.postUtteranceDelay = 0.2;
        [synthesizer speakUtterance:utterance];
    }
}

@end
