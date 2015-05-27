//
//  Cell.h
//  test
//
//  Created by AAPBD Mac mini on 31/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UICollectionViewCell

@property (retain, nonatomic) UIImageView* imageView;

@property (retain, nonatomic) UIButton *deleteButton;

@property (retain, nonatomic) UIImageView *deleteButtonImageView;

-(void) setViewed:(BOOL) viewed;

@end
