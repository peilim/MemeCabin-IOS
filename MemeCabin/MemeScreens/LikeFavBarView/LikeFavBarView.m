//
//  LikeFavBarView.m
//  MemeCabin
//
//  Created by Himel on 12/1/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "LikeFavBarView.h"

@implementation LikeFavBarView

@synthesize barFavButton, barLikeButton, barLikeLabel;

+(LikeFavBarView *)sharedInstance
{
    static LikeFavBarView *sharedInstance = nil;
    if (sharedInstance == nil)
    {
        sharedInstance = [[LikeFavBarView alloc] init];
    }
    return sharedInstance;
}



- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"LikeFavBarView" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UIView class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
