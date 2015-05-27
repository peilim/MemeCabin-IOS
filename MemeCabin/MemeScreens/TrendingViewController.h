//
//  TrendingViewController.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 27/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <StoreKit/StoreKit.h>

@interface TrendingViewController : UIViewController <SKStoreProductViewControllerDelegate>


- (IBAction)todaysTopAction:(UIButton *)sender;
- (IBAction)topMemesSevenAction:(UIButton *)sender;
- (IBAction)topMemesThirtyAction:(UIButton *)sender;
- (IBAction)topMemesNinetyAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

//Top Bar Actions
- (IBAction)backButtonAction:(UIButton *)sender;
- (IBAction)menuButtonAction:(UIButton *)sender;

//Lower Bar Actions
- (IBAction)backToHomeButtonAction:(UIButton *)sender;
- (IBAction)preferenceButtonAction:(UIButton *)sender;
- (IBAction)favoriteButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *backToHomeButton;



@end
