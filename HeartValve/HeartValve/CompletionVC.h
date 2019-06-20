//
//  CompletionVC.h
//  HeartValve
//
//  Created by Jonathan on 11/2/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompletionVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *feedbackView;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;

- (IBAction)replayAudio:(id)sender;
- (IBAction)exit:(id)sender;

@end
