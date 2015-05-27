//
//  MemesSwipeView.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 31/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemesSwipeView : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

//Passed from other
@property (assign, nonatomic) NSInteger imageIndex;
@property (strong, nonatomic) NSArray *imageArray;

//Top bar
@property (weak, nonatomic) IBOutlet UIImageView *topBarbg;
@property (weak, nonatomic) IBOutlet UIImageView *topBarText;
@property (weak, nonatomic) IBOutlet UIImageView *topBarRightImage;

- (IBAction)backButtonAction:(UIButton *)sender;

//Middle
//@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *totalLikesLabel;
@property (weak, nonatomic) IBOutlet UIButton *thumbButton;

- (IBAction)thumbButtonAction:(UIButton *)sender;

//Lower
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

- (IBAction)favoriteButtonAction:(UIButton *)sender;
- (IBAction)shareButtonAction:(UIButton *)sender;
- (IBAction)reloadButtonAction:(UIButton *)sender;
- (IBAction)backToHomeButtonAction:(UIButton *)sender;


@end
