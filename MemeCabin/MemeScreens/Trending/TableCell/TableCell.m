//
//  TableCell.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 01/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "TableCell.h"

@implementation TableCell

@synthesize numberLabel,leftImageView,rightButton,trendingLikesLabel,totalLikesLabel;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
       // self.backgroundColor = [UIColor clearColor];
        self.leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end






















