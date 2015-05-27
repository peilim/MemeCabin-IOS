//
//  TrendingDetailView.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 01/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <StoreKit/StoreKit.h>

@interface TrendingDetailView : UIViewController <UITableViewDelegate, UITableViewDataSource, SKStoreProductViewControllerDelegate>

@property (readwrite, getter = isFromRefreshController) BOOL fromRefreshController;


@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) IBOutlet UILabel *tableViewTitle;

@property (assign) NSInteger topMemeByDays;

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
