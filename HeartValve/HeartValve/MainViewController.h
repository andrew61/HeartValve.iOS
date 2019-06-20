//
//  MainViewController.h
//  HeartValve
//
//  Created by Computer Science Department on 8/18/17.
//  Copyright © 2017 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (assign) int indexValue;
@property (nonatomic) NSArray *viewControllerIDArr;
@end
