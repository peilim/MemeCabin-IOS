//
//  FavoriteViewController.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 28/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <StoreKit/StoreKit.h>

#import "WebViewController.h"

#import "AppDelegate.h"
#import "LoginViewController.h"

#import "MyFlowLayout.h"

@interface FavoriteViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource, UIAlertViewDelegate, SKStoreProductViewControllerDelegate>
{
    BOOL isLoadingMore;
}
@property (readwrite, getter = isFromRefreshController) BOOL fromRefreshController;

@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;

@property (assign, nonatomic) NSIndexPath *findIndexPath;
@property (nonatomic, assign ,getter = isEditMode) BOOL editMode;

@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIView *noFavouriteView;

//top action
- (IBAction)backButtonAction:(UIButton *)sender;
- (IBAction)menuButtonAction:(UIButton *)sender;

//bottom action
- (IBAction)backToHomeButtonAction:(UIButton *)sender;
- (IBAction)preferenceButtonAction:(UIButton *)sender;

//noFavouriteView Button & Label
@property (nonatomic, weak) IBOutlet UILabel *lbl_noFav;
@property (nonatomic, weak) IBOutlet UIButton *btn_noFav;
-(IBAction)btn_noFavAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *backToHomeButton;

@end
