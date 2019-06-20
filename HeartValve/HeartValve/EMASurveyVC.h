//
//  EMASurveyVC.h
//  MyHealthApp
//
//  Created by Jonathan on 1/15/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMASurveyVC : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;

@end
