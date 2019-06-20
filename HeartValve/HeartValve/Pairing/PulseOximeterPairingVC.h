//
//  PulseOximeterPairingVC.h
//  HeartValve
//
//  Created by Jameson B on 10/31/17.
//  Copyright © 2017 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PulseOximeterPairingVC : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *statusText;
@property (weak, nonatomic) IBOutlet UITextField *MacAddrText;
@property (weak, nonatomic) IBOutlet UITextView *ScanFeedText;
@property (weak, nonatomic) IBOutlet UIButton *ScanButton;
@property (weak, nonatomic) IBOutlet UILabel *scanningText;
- (IBAction)ScanButtonPushed:(id)sender;
- (IBAction)BackButton:(id)sender;

@end
