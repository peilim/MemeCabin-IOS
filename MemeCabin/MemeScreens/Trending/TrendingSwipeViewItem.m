//
//  TrendingSwipeViewItem.m
//  MemeCabin
//
//  Created by Himel on 12/6/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "TrendingSwipeViewItem.h"

@interface TrendingSwipeViewItem ()


@end

@implementation TrendingSwipeViewItem

-(void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.BGLike.layer.cornerRadius = 10;
    
}

@end
