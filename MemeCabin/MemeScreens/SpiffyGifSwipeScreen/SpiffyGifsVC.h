//
//  SpiffyGifsVC.h
//  MemeCabin
//
//  Created by Himel on 1/7/15.
//  Copyright (c) 2015 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpiffyGifsVC : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIButton *backToHomeButton;

- (IBAction)markAallButtonAction:(UIButton *)sender;
- (IBAction)backButtonAction:(UIButton *)sender;
- (IBAction)menuButtonAction:(UIButton *)sender;
- (IBAction)backToHomeButtonAction:(UIButton *)sender;
- (IBAction)preferenceButtonAction:(UIButton *)sender;
- (IBAction)favoriteButtonAction:(UIButton *)sender;

@end
