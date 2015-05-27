//
//  Cell.m
//  test
//
//  Created by AAPBD Mac mini on 31/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "Cell.h"

static UIImage *grayFrame;
static UIImage *normalFrame;

@implementation Cell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!grayFrame) {
            grayFrame = [UIImage imageNamed:@"frame_photo_grey.png"];
        }
        if (!normalFrame) {
            normalFrame = [UIImage imageNamed:@"frame_photo.png"];
        }
        
        CGRect imgFrame;
        if (IS_IPAD) {
            imgFrame = CGRectMake(5.0, 5.0, 143, 143);
        } else{
            
            imgFrame = CGRectMake(5.0, 5.0, 70, 70);
        }
        
        self.backgroundView = [[UIImageView alloc] initWithImage:grayFrame];
        
        self.imageView = [[UIImageView alloc] initWithFrame:imgFrame];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
        
        self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(51.0, 1.0, 25, 35)];
        [self.contentView addSubview:self.deleteButton];
        
        self.deleteButtonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.0, 0.0, 25, 25)];
        [self.deleteButtonImageView setImage:[UIImage imageNamed:@"cross_30.png"]];
        [self.deleteButton addSubview:self.deleteButtonImageView];
    }
    
    //NSLog(@"%f",self.bounds.size.width);
    return self;
}

-(void)setViewed:(BOOL)viewed {
    [(UIImageView *)self.backgroundView setImage:viewed? grayFrame:normalFrame];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
