//
//  LikeFavBarView.h
//  MemeCabin
//
//  Created by Himel on 12/1/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikeFavBarView : UIView

+(LikeFavBarView *)sharedInstance;

@property (weak, nonatomic) IBOutlet UIButton *barFavButton;
@property (weak, nonatomic) IBOutlet UIButton *barLikeButton;

@property (weak, nonatomic) IBOutlet UILabel *barLikeLabel;

@end
