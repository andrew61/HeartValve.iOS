//
//  WeightGuidedVC.h
//  HeartValve
//
//  Created by Jonathan on 11/2/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreBluetoothDelegate.h"

@class AD_UC_352BLE;

@interface WeightGuidedVC : UIViewController<CoreBluetoothDelegate>

@property (strong, nonatomic) AD_UC_352BLE *scaleDevice;
@property (assign, nonatomic) BOOL weightInProgress;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UIView *weightView;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (assign, nonatomic) BOOL stopSpeaking;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;


- (IBAction)replayAudio:(id)sender;
- (IBAction)reset:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *weightImageView;

@end
