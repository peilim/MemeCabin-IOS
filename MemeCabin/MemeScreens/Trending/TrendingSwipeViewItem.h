//
//  TrendingSwipeViewItem.h
//  MemeCabin
//
//  Created by Himel on 12/6/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendingSwipeViewItem : UIView

@property (weak, nonatomic) IBOutlet UIView *BGLike;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *todaysLikes;
@property (weak, nonatomic) IBOutlet UILabel *sevenDaysLikes;
@property (weak, nonatomic) IBOutlet UILabel *thirtyDaysLikes;
@property (weak, nonatomic) IBOutlet UILabel *totalLikes;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewTrendingSwipeItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end







