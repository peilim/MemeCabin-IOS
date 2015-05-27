//
//  TableCell.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 01/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *trendingLikesLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLikesLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;


@end
