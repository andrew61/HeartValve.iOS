//
//  HomeNavigationVC.m
//  MyHealthApp
//
//  Created by Jonathan on 1/24/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "HomeNavigationVC.h"
#import "UIColor+Extensions.h"

@interface HomeNavigationVC ()
{
    UIProgressView *progress;
}

@end

@implementation HomeNavigationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progress.progressTintColor = [UIColor appBlueColor];
    [self.view addSubview:progress];
    UINavigationBar *navBar = [self navigationBar];
    
    NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint constraintWithItem:progress attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeBottom multiplier:1 constant:-0.5];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:progress attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:progress attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:navBar attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.view addConstraint:constraint];
    
    [progress setTranslatesAutoresizingMaskIntoConstraints:NO];
    progress.hidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)showProgress
{
    progress.hidden = NO;
}

- (void)hideProgress
{
    progress.hidden = YES;
}

- (void)setProgress:(float)value
{
    progress.progress = value;
}



@end
