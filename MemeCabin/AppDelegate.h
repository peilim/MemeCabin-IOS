//
//  AppDelegate.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 26/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AFNetworking.h"

#import "DBHelper.h"
#import "Reachability.h"
#import "Flurry.h"
//#import "FlurryAds.h"
//#import "FlurryAdDelegate.h"
#import "FlurryAdBanner.h"
#import "FlurryAdBannerDelegate.h"
#import "FlurryAdInterstitial.h"
#import "FlurryAdInterstitialDelegate.h"
#import "CMPopTipView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADBannerViewDelegate.h>
#import <GoogleMobileAds/GADInterstitial.h>
#import <GoogleMobileAds/GADInterstitialDelegate.h>

#import "MPAdView.h"
#import "MPInterstitialAdController.h"

#define FlurryBannerAdName @"MainBannerBottom"
#define FlurryFullScreenAdName @"MainTakeover"

#define UIAppDelegate \
((AppDelegate *)[UIApplication sharedApplication].delegate)

#define ADMOB_ID @"ca-app-pub-9152009225005926/1696724799"
#define INTERSITIAL_ID @"ca-app-pub-9152009225005926/3173457990"

@class DanMessagePopup;
@interface AppDelegate : UIResponder <UIApplicationDelegate,FlurryAdBannerDelegate,FlurryAdInterstitialDelegate,GADBannerViewDelegate,GADInterstitialDelegate,MPAdViewDelegate,MPInterstitialAdControllerDelegate>

{
    DBHelper *dbhelper;
    UIView *holderView;
    
    /////////////
    BOOL bannerIsVisible;
    BOOL fullScreenIsVisible;
    
    UIView *flurryAdBannerView;
    UIView *flurryAdFullScreenView;
    
    BOOL bannerAdViewAdded;
    BOOL fullScreenAdViewAdded;
    
    BOOL isFlurryCurrent;
    BOOL isFlurryAdVisible;
    
    //////
    BOOL requestingAd;
    BOOL adIsShowing;
    
    FlurryAdBanner *obj_FlurryAdBanner;
    FlurryAdInterstitial *obj_FlurryAdInterstitial;
    
}

-(BOOL) isProUser;
-(void) setProUser;
-(void) removeProUser;

-(void)signInWithFacebook;
-(BOOL)isFBSessionValid;
//-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI;

@property (assign, readwrite) BOOL isFromHome;
@property (assign, readwrite) BOOL isFromAppDelegate;

@property (assign, readwrite) BOOL isFromFavourite;
@property (assign, readwrite) BOOL isFromMemeSwipe;
@property (assign, readwrite) BOOL isFromTrendingSwipe;

@property (assign) int ITEMS_PER_PAGE;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;


//First launch bool

//Meme category wise badge
@property (assign) NSInteger badgeEveryoneMeme;
@property (assign) NSInteger badgeMotivationalMeme;
@property (assign) NSInteger badgeRacyMeme;
@property (assign) NSInteger badgeSpiffyGifs;
@property (assign) NSInteger userFavouriteNumber;

@property (nonatomic, strong) NSMutableArray *photoArray;

-(void)checkForAppUpdateWithDate:(NSString *)installationdate andUserId:(NSString *)userId;
//@property (assign) NSInteger savedFavourites;

@property (nonatomic,assign) int pageNumberRequest;

@property (nonatomic, retain)DanMessagePopup *ratePopup;

@property (assign) BOOL danMessagePopupIsOn;
@property (assign) BOOL ratePopupIsOn;

@property (assign) BOOL proUserHasBeenMarked;

+ (BOOL)isNetworkAvailable;

//Flurry & iAd
//@property (nonatomic, strong) ADBannerView *iAdBannerView;
//@property (nonatomic, strong) ADInterstitialAd *iAdFullScreenAd;
//@property (nonatomic, strong) UIView *flurryBannerView;

//Alert
-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

//Activity Indicator
@property(nonatomic,retain)	UIActivityIndicatorView *activityIndicator;
- (void)activityShow;
- (void)activityHide;



//iAd
//-(void)showiAdInView:(UIView *)view Delegate:(id)delegate;
//-(void)hideiAdinView;
//-(void)showiAdFullScreenAdInView:(UIViewController *)controller Delegate:(id)delegate;
//
//Flurry
//-(void)showFlurryAdInView:(UIView *)view Delegate:(id)delegate viewController:(UIViewController *)controller;
//-(void)showFlurryFullScreenAdInView:(UIView *)view Delegate:(id)delegate;

//Day FDifference

//Move Slide Menu
-(void)moveView1:(UIView *)view1 andView2:(UIView *)view2 moveLeft:(BOOL)moveLeft;


// Ad Network
@property (nonatomic, assign) BOOL bannerIsVisible;
@property (nonatomic, assign) BOOL bannerAdViewAdded;
@property (nonatomic, assign) BOOL fullScreenAdViewAdded;
@property (nonatomic, assign) BOOL fullScreenIsVisible;
@property (nonatomic, assign) BOOL isFlurryCurrent;
@property (nonatomic, assign) BOOL isFlurryAdVisible;

//@property (nonatomic, retain) UIView *obj_FlurryAd;
@property (nonatomic, retain) GADBannerView *obj_FlurryAd;
//@property (nonatomic, retain) MPAdView *obj_FlurryAd;

@property (nonatomic, retain) UIView *flurryAdBannerView;
@property (nonatomic, retain) UIView *flurryAdFullScreenView;

@property (nonatomic, retain) FlurryAdInterstitial *obj_FlurryAdInterstitial;
@property (nonatomic, retain) FlurryAdBanner *obj_FlurryAdBanner;
@property (nonatomic, retain) CMPopTipView *popTipView;
@property (nonatomic, retain) GADBannerView *obj_GadAdBanner;
@property (nonatomic, retain) GADInterstitial *obj_GadInterstitial;
//@property (nonatomic, retain) MPInterstitialAdController *obj_GadInterstitial;


-(void)reloadInterstitialAds;

-(void)addFlurryAd;
-(void)addAdmob;


-(void)showFlurryAd;
-(void)hideFlurryAd;

-(void)addFlurryInView:(UIView *)view;

-(void)checkForDeletedMemes;

-(NSInteger)setAllBadgesCountForApplication;

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;


//Meme category wise badge
@property (nonatomic,assign) NSInteger currentBadgeMemeEveryOne;
@property (nonatomic,assign) NSInteger currentBadgeMemeMotiInsp;
@property (nonatomic,assign) NSInteger currentBadgeMemeRacy;
@property (nonatomic,assign) NSInteger currentBadgeMemeSpiffyGif;

@property (nonatomic,assign) NSInteger newMemeEveryOneCount;
@property (nonatomic,assign) NSInteger newMemeMotiInspCount;
@property (nonatomic,assign) NSInteger newMemeRacyCount;
@property (nonatomic,assign) NSInteger newMemeSpiffyCount;

//@property (assign) int userFavouriteNumber;

-(NSString *) makeHashKey:(NSString *)aString;

+ (BOOL) isRetinaDisplay;

#pragma mark - iCon Enable/Disable
-(void)enableFeature:(NSString*)feature :(BOOL)status;
-(BOOL) isEnabled:(NSString*)feature;
-(NSMutableArray *)getEnabledFeature;

@property (nonatomic, assign) BOOL isNewlyLaunched;

@end
