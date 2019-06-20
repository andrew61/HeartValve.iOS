//
//  UIButton+VerticalLayout.m
//  MUSCMedPlan
//
//  Created by Jonathan on 7/22/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "UIButton+VerticalLayout.h"

@implementation UIButton (VerticalLayout)

- (void)centerVerticallyWithPadding:(float)padding
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    CGFloat totalHeight = (imageSize.height + titleSize.height + padding);
    
    self.imageEdgeInsets = UIEdgeInsetsMake(-12.0f, 0.0f, 0.0f, - titleSize.width);
    //self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, - imageSize.width, - (totalHeight - titleSize.height), 0.0f);
}

- (void)centerVertically
{
    const CGFloat kDefaultPadding = 6.0f;
    
    [self centerVerticallyWithPadding:kDefaultPadding];
}

@end