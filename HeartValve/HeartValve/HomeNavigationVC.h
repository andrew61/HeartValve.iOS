//
//  HomeNavigationVC.h
//  MyHealthApp
//
//  Created by Jonathan on 1/24/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeNavigationVC : UINavigationController

- (void)showProgress;
- (void)hideProgress;
- (void)setProgress:(float)value;

@end