//
//  MyFlowLayout.m
//  MemeCabin
//
//  Created by Himel on 11/23/14.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "MyFlowLayout.h"

@implementation MyFlowLayout
/*
- (id)init
{
    self = [super init];
    if (self) {
        [self collectionViewContentSize];
    }
    
    return self;
}
*/
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self collectionViewContentSize];
    }
    
    return self;
}

- (CGSize)collectionViewContentSize
{
    if (IS_IPAD)
        [super setItemSize:CGSizeMake(153,153)];
    else
        [super setItemSize:CGSizeMake(80,80)];
    
    [super setMinimumLineSpacing:0.0];
    [super setMinimumInteritemSpacing:0];
    [super setSectionInset:UIEdgeInsetsZero];
   
    
    CGFloat height = [super collectionViewContentSize].height;
    
    // Always returns a contentSize larger then frame so it can scroll and UIRefreshControl will work
    if (height < self.collectionView.bounds.size.height) {
        height = self.collectionView.bounds.size.height + 1;
    }
   // return CGSizeMake(80,80);
    return CGSizeMake([super collectionViewContentSize].width, height);
}

@end
