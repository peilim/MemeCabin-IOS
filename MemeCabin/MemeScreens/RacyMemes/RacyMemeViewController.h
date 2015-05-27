//
//  RacyMemeViewController.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 28/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyFlowLayout.h"

#import <StoreKit/StoreKit.h>

#import "WebViewController.h"

@interface RacyMemeViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource, SKStoreProductViewControllerDelegate>
{
    BOOL isloadingMore;
}
@property (readwrite, getter = isFromRefreshController) BOOL fromRefreshController;

@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;

@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

//top action
- (IBAction)backButtonAction:(UIButton *)sender;
- (IBAction)menuButtonAction:(UIButton *)sender;

//bottom action
@property (nonatomic, weak) IBOutlet UIButton *backToHomeButton;
- (IBAction)backToHomeButtonAction:(UIButton *)sender;
- (IBAction)preferenceButtonAction:(UIButton *)sender;
- (IBAction)favoriteButtonAction:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIView *middleView;
//Dismiss popup


- (IBAction)markAallButtonAction:(UIButton *)sender;


@end
