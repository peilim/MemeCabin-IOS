//
//  SwipeViewItem.h
//  MemeCabin
//
//  Created by Himel on 12/4/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"

@interface SwipeViewItem : UIView

@property (weak, nonatomic) IBOutlet UIView *likeBG;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewSwipeItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

//Title BG View
@property (weak, nonatomic) IBOutlet UIView *titleBG;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
