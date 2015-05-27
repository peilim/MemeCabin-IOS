//
//  SwipeViewItem.m
//  MemeCabin
//
//  Created by Himel on 12/4/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "SwipeViewItem.h"
#import <QuartzCore/QuartzCore.h>

@interface SwipeViewItem ()



@end

@implementation SwipeViewItem

-(void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.likeBG.layer.cornerRadius = 10;
    
    self.titleBG.layer.cornerRadius = 10;
    //self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    if (self.imageView.image.size.width > self.imageView.bounds.size.width ||
//        self.imageView.image.size.height > self.imageView.bounds.size.height) {
//        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    }
//    else {
//        self.imageView.contentMode = UIViewContentModeCenter;
//    }
}

@end
