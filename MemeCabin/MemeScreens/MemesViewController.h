//
//  MemesViewController.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 27/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

#import "WebViewController.h"
#import "DanMessage.h"

#import "MyFlowLayout.h"


@interface MemesViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource, SKStoreProductViewControllerDelegate>

{
    BOOL isLoadingMore;
}
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;

@property (strong, nonatomic) IBOutlet UIView *middleView;


@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

//top action
- (IBAction)markAallButtonAction:(UIButton *)sender;

- (IBAction)backButtonAction:(UIButton *)sender;
- (IBAction)menuButtonAction:(UIButton *)sender;

//bottom action
@property (nonatomic, weak) IBOutlet UIButton *backToHomeButton;
- (IBAction)backToHomeButtonAction:(UIButton *)sender;
- (IBAction)preferenceButtonAction:(UIButton *)sender;
- (IBAction)favoriteButtonAction:(UIButton *)sender;



//Dismiss popup


@end
