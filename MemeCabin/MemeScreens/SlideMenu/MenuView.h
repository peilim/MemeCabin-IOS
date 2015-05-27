//
//  MenuView.h
//  test
//
//  Created by AAPBD Mac mini on 10/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"
#import "LoginViewController.h"
#import <StoreKit/StoreKit.h>
#import "iRate.h"

@interface MenuView : UIView <UITableViewDelegate, UITableViewDataSource>

{
    UIViewController *vc;
    NSString *purchaseCode;
    
    BOOL alertIsShown;
}


@property (strong, nonatomic) IBOutlet UIButton *dismissSlideButton;
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (assign) BOOL shouldShowDisableAdsButton;
//@property (assign) BOOL shouldShowLogoutButton;

@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;
@property(nonatomic,retain) NSString *purchaseCode;

-(void)purchaseSubscription;
-(void)restorePurchase;

@end







