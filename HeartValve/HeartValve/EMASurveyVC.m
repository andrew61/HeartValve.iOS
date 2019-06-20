//
//  EMASurveyVC.m
//  MyHealthApp
//
//  Created by Jonathan on 1/15/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "EMASurveyVC.h"
#import "MBProgressHUD.h"
#import "UIColor+HexValue.h"
#import "UIColor+Extensions.h"
#import "UserManager.h"
#import "User.h"
#import "JNKeychain.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@implementation EMASurveyVC
{
    MBProgressHUD *hud;
    AVSpeechSynthesizer *synthesizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.parentViewController.navigationItem.title = @"Survey";
    
    [[self.continueButton layer] setBorderWidth:1.0f];
    [[self.continueButton layer] setBorderColor:[UIColor appBlueColor].CGColor];
    [self.continueButton setBackgroundImage:[Utility imageWithColor:[UIColor appYellowColor]] forState:UIControlStateHighlighted];
    self.continueButton.hidden = YES;
    self.instructionsLabel.hidden = YES;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updateDailyAssessmentWithStep:2];
    
    synthesizer = [AVSpeechSynthesizer new];
    
    [AudioPlayer speak:@"Please answer the following questions" withSynthesizer:synthesizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.webView.scrollView.bounces = NO;
    
    NSDictionary *auth = [JNKeychain loadValueForKey:@"auth"];
    
    NSString *params = [NSString stringWithFormat:@"email=%@&password=%@", auth[@"username"], auth[@"password"]];
    NSData *data = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    
    NSString *urlString = @"https://hitechnologysolutions.com/HeartValve/Account/MobileLogin?ReturnUrl=/HeartValve/Survey?surveyId=3";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:length forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setTimeoutInterval:20];
    [urlRequest setHTTPBody:data];
    [self.webView loadRequest:urlRequest];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Loading...", nil);
    hud.color = [UIColor appYellowColor];
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *questionText = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('Question').innerHTML"];
    
    if (![questionText isEqualToString:@""])
    {
        [AudioPlayer speak:questionText withSynthesizer:synthesizer];
    }
    
    NSString *status = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('Status').innerHTML"];
    NSData* encodedData = [status dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:encodedData options:NSJSONReadingMutableLeaves error:nil];
    NSString *complete = dataDictionary[@"complete"];
    
    if ([complete isEqualToString:@"true"])
    {
        self.instructionsLabel.hidden = NO;
        self.continueButton.hidden = NO;
        self.webView.hidden = YES;
        
        [AudioPlayer speak:@"Thank you!  Press the continue button to take your blood pressure." withSynthesizer:synthesizer];
    }
    
    [hud hide:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [hud hide:YES];
}

@end
