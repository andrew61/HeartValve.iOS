//
//  OxygenSaturationGuidedVC.h
//  HeartValve
//
//  Created by Jonathan on 11/2/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OxygenSaturationGuidedVC : UIViewController<UITextFieldDelegate>

@property (assign, nonatomic) NSInteger secondsRemaining;
@property (assign, nonatomic) BOOL spO2InProgress;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *spO2Label;
@property (weak, nonatomic) IBOutlet UILabel *pulseLabel;
@property (weak, nonatomic) IBOutlet UILabel *topHelpLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomHelpLabel;
@property (weak, nonatomic) IBOutlet UIImageView *connectedImageView;
@property (weak, nonatomic) IBOutlet UIView *spO2View;
@property (weak, nonatomic) IBOutlet UIView *pulseView;
@property (weak, nonatomic) IBOutlet UIImageView *disconnectedImageView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

- (IBAction)replayAudio:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *BatteryInfo;
@property (weak, nonatomic) IBOutlet UIButton *replayButton;

- (IBAction)SubmitButtonClicked:(id)sender;

@end
