//
//  WelcomeVC.h
//  HeartValve
//
//  Created by Jonathan on 11/2/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *dailyAssessmentButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

- (IBAction)replayAudio:(id)sender;

@end
