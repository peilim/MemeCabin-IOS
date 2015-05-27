//
//  MotivationalViewController.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 27/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "MyFlowLayout.h"

#import "WebViewController.h"

@interface MotivationalViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource, SKStoreProductViewControllerDelegate>
{
    BOOL isLoadingMore;
}
@property (readwrite, getter = isFromRefreshController) BOOL fromRefreshController;

@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;


@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@property (strong, nonatomic) IBOutlet UIView *middleView;

//top action
- (IBAction)backButtonAction:(UIButton *)sender;
- (IBAction)menuButtonAction:(UIButton *)sender;

- (IBAction)markAallButtonAction:(UIButton *)sender;

//botton action
@property (nonatomic, weak) IBOutlet UIButton *backToHomeButton;
- (IBAction)backToHomeButtonAction:(UIButton *)sender;
- (IBAction)preferenceButtonAction:(UIButton *)sender;
- (IBAction)favoriteButtonAction:(UIButton *)sender;


//Dismiss popup



@end
