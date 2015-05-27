//
//  HomeScreenViewController.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 27/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "MemesViewController.h"
#import "MotivationalViewController.h"
#import "TrendingViewController.h"
#import "FavoriteViewController.h"
#import "RacyMemeViewController.h"
#import "PreferenceViewController.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UIActivityIndicatorView+AFNetworking.h"

@interface HomeScreenViewController ()
{
    AppDelegate *appDelegate;
    
    CustomBadge *badgeForEveryoneMeme;
    CustomBadge *badgeForMotivationalMeme;
    CustomBadge *badgeForRacyMeme;
    CustomBadge *badgeForSpiffyGifs;
    
    DBHelper *dbhelper;
    
    NSMutableArray *danMessageArray;
    BOOL isFirstTimeInDashboard;
    
    //NSMutableArray *photoArray;
    
    GADInterstitial  *interstitial_;
    
}
@property (weak, nonatomic) IBOutlet UIView *iconHolderView;

@end

@implementation HomeScreenViewController
@synthesize danMessagePopupNew,danMessageNew;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - view life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFavoriteCounter) name:@"USER_FAVORITE_COUNTER_NOTIF" object:nil];
    
    dbhelper = [[DBHelper alloc] init];
    UIAppDelegate.photoArray = [NSMutableArray array];
    
    _popupView.hidden = YES;
    _menuPopupView.hidden = YES;
    _capturePopupView.hidden = YES;
    _passcodePopupView.hidden = YES;
    _gotItPopupView.hidden = YES;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    danMessageArray = [NSMutableArray array];
    
    /*
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_LOGIN])
    {
        isFirstTimeInDashboard = YES;
        [self checkForDanMessage];
    }
     */
    
    // Change Date: 9-Feb-2015
    //[self loadGIFs:NO];
    
//    [self loadAdMobIntersBanner];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAD) name:@"BANNAR_AD_IS_VISIBLE" object:nil];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(updateBadges)
                                   userInfo:nil
                                    repeats:YES];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkForDanMessageNew];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_myTextField];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // Change Date: 9-Feb-2015
    //[self loadGIFs:NO];
    
    //if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_LOGIN])
    //{
        //\\isFirstTimeInDashboard = YES;
        [self checkForDanMessage];
    //}
    
    NSLog(@"UIAppDelegate.bannerIsVisible=%hhd",UIAppDelegate.bannerIsVisible);
    if (UIAppDelegate.bannerIsVisible)
    {
        [UIAppDelegate hideFlurryAd];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTextFieldImage) name:UITextFieldTextDidChangeNotification object:_myTextField];
    
    [[GoogleAnalyticsCustom getSharedInstance] setCurrentScreenName:@"Dash-Board Screen"];
    //NSLog(@"viewWillAppear");
    
    self.navigationController.navigationBarHidden = YES;
    
    ///////////////
    //if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_LOGIN])
    //{
        NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] objectForKey:CHECK_FOR_USER_INFO];
        NSString *userId = [userInfoDisct objectForKey:@"userId"];
    if(userId.length==0)
        userId=@"";
        [UIAppDelegate checkForAppUpdateWithDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstLaunchTime"]
                                       andUserId:userId];
    //}
    
    //////////////
    
    //remove icons
    
    for (UIView *view in [self.iconHolderView subviews]) {
        [view removeFromSuperview];
    }
    //set icon positions
    
    NSMutableArray *enabledFeatureArr = [UIAppDelegate getEnabledFeature];
    
    int X = IS_IPHONE ? 20 : 75;
    int Y = 5;//IS_IPHONE ? (IS_IPHONE_4INCHES ? 157 : 102) : 285;
    
    int ICON_WIDTH = IS_IPHONE ? 72 : 120;
    int ICON_HEIGHT = IS_IPHONE ? 112 : 187;
    
    int ICON_BUTTON_WIDTH = IS_IPHONE ? 72 : 120;
    int ICON_BUTTON_HEIGHT = IS_IPHONE ? 72 : 120;
    
    int ICON_LEFT_PADDING = IS_IPHONE ? 32 : 130;
    int ICON_BOTTOM_PADDING = IS_IPHONE ? (IS_IPHONE_4INCHES ? 14 : 5) : 30;
    
    //int TEXT_TOP_PADDING  = IS_IPHONE ? 30 : 20;
    int c = 0;

    for (int i = 1; i <= enabledFeatureArr.count ; i++)
    {
        
        NSDictionary *dict = [enabledFeatureArr objectAtIndex:i-1];
        
        NSString *featureIcon = [dict valueForKey:@"featureIcon"];
        NSString *featureName = [dict valueForKey:@"featureName"];
        
        if ((i-1)%3 == 0) {
            c++;
        }
        
        int XPOS = X+(ICON_WIDTH+ICON_LEFT_PADDING)*((i-1)%3);
        int YPOS = Y+(ICON_HEIGHT+ICON_BOTTOM_PADDING)*(c-1);
        
        UIView *iconView = [self getViewForFeatureName:featureName];
        
        iconView.frame = CGRectMake(XPOS,
                                    YPOS,
                                    ICON_WIDTH,
                                    ICON_HEIGHT);
        
        //NSLog(@"iconViewFrame = %@",NSStringFromCGRect(iconView.frame));
        
        UIButton *btn  = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, ICON_BUTTON_WIDTH, ICON_BUTTON_HEIGHT);
        [btn setImage:[UIImage imageNamed:featureIcon] forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(iconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [iconView addSubview:btn];
        
        UILabel *lbl = [[UILabel alloc] init];
        [lbl setBackgroundColor:[UIColor clearColor]];
        //This Condition is for Motivation & Inspirational text label
        if (i == 2) {
            lbl.frame = CGRectMake(0, ICON_BUTTON_HEIGHT, ICON_WIDTH+2, ICON_HEIGHT - ICON_BUTTON_HEIGHT);
        } else {
            lbl.frame = CGRectMake(0, ICON_BUTTON_HEIGHT, ICON_WIDTH, ICON_HEIGHT - ICON_BUTTON_HEIGHT);
        }
        
        
        [lbl setText:featureName];
        
        // Change Date:9-Feb-2015
        if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_LOGIN])
        {
            if ([featureName isEqualToString:SAVED_FAVORITES])
            {
                [lbl setText:[NSString stringWithFormat:@"Your Saved Favorites (%ld)",(long)UIAppDelegate.userFavouriteNumber]];
            }
        }
        
        [lbl setNumberOfLines:0];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setTextColor:[UIColor whiteColor]];
        [lbl setFont:[UIFont systemFontOfSize:11*padFactor]];
        [iconView addSubview:lbl];
        iconView.tag = i;
        
//        if(i != 4) // extract Spiffy Gif
            [self.iconHolderView addSubview:iconView];
        
    }
    
    /*
    if (IS_IPHONE)
    {
        if (IS_IPHONE_4INCHES)
        {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_RECY_MEME_IN_HOME_SCREEN] && ![UIAppDelegate isProUser])
            {
                _racyMemeView.hidden = NO;
                _removeAdsView.hidden = NO;
                _memeView.frame = CGRectMake(20, 157, 72, 99);
                _motivationalView.frame = CGRectMake(124, 157, 72, 99);
                _racyMemeView.frame = CGRectMake(228, 157, 72, 99);
                _spiffyGifsView.frame = CGRectMake(20, 274, 72, 99);
                _trendingView.frame = CGRectMake(124, 274, 72, 99);
                _uploadView.frame = CGRectMake(228, 274, 72, 112);
                _favoriteView.frame = CGRectMake(20, 404, 72, 112);
                _removeAdsView.frame = CGRectMake(124, 404, 72, 99);
                _singleDadView.frame = CGRectMake(228, 404, 72, 102);
            }
            else if ([[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_RECY_MEME_IN_HOME_SCREEN] && [UIAppDelegate isProUser])
            {
                _racyMemeView.hidden = YES;
                _removeAdsView.hidden = YES;
                _memeView.frame = CGRectMake(20, 157, 72, 99);
                _motivationalView.frame = CGRectMake(124, 157, 72, 99);
                //_racyMemeView.frame = CGRectMake(228, 157, 72, 99);
                _spiffyGifsView.frame = CGRectMake(20, 274, 72, 99);
                _trendingView.frame = CGRectMake(124, 274, 72, 99);
                _uploadView.frame = CGRectMake(228, 274, 72, 112);
                _favoriteView.frame = CGRectMake(20, 404, 72, 112);
                //_removeAdsView.frame = CGRectMake(124, 404, 72, 99);
                _singleDadView.frame = CGRectMake(228, 404, 72, 102);
            }
            else if ([[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_RECY_MEME_IN_HOME_SCREEN] || [UIAppDelegate isProUser])
            {
                if ([UIAppDelegate isProUser])
                {
                    _removeAdsView.hidden = YES;
                    _memeView.frame = CGRectMake(20, 157, 72, 99);
                    _motivationalView.frame = CGRectMake(124, 157, 72, 99);
                    _racyMemeView.frame = CGRectMake(228, 157, 72, 99);
                    _spiffyGifsView.frame = CGRectMake(20, 274, 72, 99);
                    _trendingView.frame = CGRectMake(124, 274, 72, 99);
                    _uploadView.frame = CGRectMake(228, 274, 72, 112);
                    _favoriteView.frame = CGRectMake(20, 404, 72, 112);
                    //_removeAdsView.frame = CGRectMake(124, 404, 72, 99);
                    _singleDadView.frame = CGRectMake(124, 404, 72, 102);
                }
                else
                {
                    _removeAdsView.hidden = NO;
                    _racyMemeView.hidden = YES;
                    _memeView.frame = CGRectMake(20, 157, 72, 99);
                    _motivationalView.frame = CGRectMake(124, 157, 72, 99);
                    //_racyMemeView.frame = CGRectMake(228, 157, 72, 99);
                    _spiffyGifsView.frame = CGRectMake(20, 274, 72, 99);
                    _trendingView.frame = CGRectMake(124, 274, 72, 99);
                    _uploadView.frame = CGRectMake(228, 274, 72, 112);
                    _favoriteView.frame = CGRectMake(20, 404, 72, 112);
                    _removeAdsView.frame = CGRectMake(124, 404, 72, 99);
                    _singleDadView.frame = CGRectMake(124, 404, 72, 102);
                }
            }
     
            else
            {
                _racyMemeView.hidden = YES;
                _memeView.frame = CGRectMake(20, 157, 72, 99);
                _motivationalView.frame = CGRectMake(124, 157, 72, 99);
                //_racyMemeView.frame = CGRectMake(230, 157, 72, 99);
                _trendingView.frame = CGRectMake(228, 157, 72, 99);
                _uploadView.frame = CGRectMake(20, 274, 72, 99);
                _favoriteView.frame = CGRectMake(124, 274, 72, 112);
                _singleDadView.frame = CGRectMake(124, 404, 72, 102);
            }
            
        }
        else
        {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_RECY_MEME_IN_HOME_SCREEN])
            {
                _racyMemeView.hidden = NO;
                _memeView.frame = CGRectMake(20, 102, 72, 99);
                _motivationalView.frame = CGRectMake(124, 102, 72, 99);
                _racyMemeView.frame = CGRectMake(228, 102, 72, 99);
                _spiffyGifsView.frame = CGRectMake(20, 221, 72, 99);
                _trendingView.frame = CGRectMake(124, 221, 72, 99);
                _uploadView.frame = CGRectMake(228, 221, 72, 112);
                _favoriteView.frame = CGRectMake(20, 337, 72, 112);
                _removeAdsView.frame = CGRectMake(124, 337, 72, 99);
                _singleDadView.frame = CGRectMake(228, 375, 72, 102);
            }
            else
            {
                _racyMemeView.hidden = YES;
                _memeView.frame = CGRectMake(20, 140, 72, 99);
                _motivationalView.frame = CGRectMake(124, 133, 72, 99);
                //_racyMemeView.frame = CGRectMake(230, 157, 72, 99);
                _trendingView.frame = CGRectMake(228, 140, 72, 99);
                _uploadView.frame = CGRectMake(20, 259, 72, 99);
                _favoriteView.frame = CGRectMake(124, 259, 72, 112);
                _singleDadView.frame = CGRectMake(124, 375, 72, 102);
            }
        }
    }
    else
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_RECY_MEME_IN_HOME_SCREEN])
        {
            _racyMemeView.hidden = NO;
            _memeView.frame = CGRectMake(75, 285, 120, 165);
            _motivationalView.frame = CGRectMake(325, 285, 120, 165);
            _racyMemeView.frame = CGRectMake(574, 285, 120, 165);
            _spiffyGifsView.frame = CGRectMake(574, 495, 120, 165);
            _trendingView.frame = CGRectMake(325, 495, 120, 165);
            _uploadView.frame = CGRectMake(574, 495, 120, 187);
            _favoriteView.frame = CGRectMake(75, 729, 120, 187);
            _removeAdsView.frame = CGRectMake(325, 729, 120, 165);
            _singleDadView.frame = CGRectMake(574, 729, 120, 170);
        }
        else
        {
            _racyMemeView.hidden = YES;
            _memeView.frame = CGRectMake(75, 285, 120, 165);
            _motivationalView.frame = CGRectMake(325, 285, 120, 165);
            //_racyMemeView.frame = CGRectMake(574, 285, 120, 165);
            _trendingView.frame = CGRectMake(574, 285, 120, 165);
            _uploadView.frame = CGRectMake(75, 495, 120, 165);
            _favoriteView.frame = CGRectMake(325, 495, 120, 187);
            _singleDadView.frame = CGRectMake(325, 729, 120, 170);
        }
    }
     
     */
    
    if (appDelegate.isFromAppDelegate) {
        [UIAppDelegate activityShow];
        appDelegate.isFromAppDelegate = NO;
    }
    
    [self performSelector:@selector(showBadge) withObject:nil afterDelay:2.5];
    //[self updateBadges];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_LOGIN])
    {
        NSLog(@"Saved favorite: %ld",(long)UIAppDelegate.userFavouriteNumber);
        
        //_savedFavouriteLabel.text = [NSString stringWithFormat:@"Your Saved Favorites (%ld)",(long)UIAppDelegate.userFavouriteNumber];
        [NSString stringWithFormat:@"Your Saved Favorites (%ld)",(long)((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT] : 0];
    }
    
    _pImage1.hidden = YES;
    _pImage2.hidden = YES;
    _pImage3.hidden = YES;
    _pImage4.hidden = YES;
    
}

- (void)loadAdMobIntersBanner
{
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = @"ca-app-pub-9152009225005926/7603657592";
    interstitial_.delegate = self;
    GADRequest *request = [GADRequest request];
    [interstitial_ loadRequest:request];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [interstitial_ presentFromRootViewController:self];
}

-(void)showBadge
{
    if(!isHomeLoaded)
    {
        isHomeLoaded = YES;
        [UIAppDelegate activityHide];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_LOGIN]) {
        //\\_savedFavouriteLabel.text = [NSString stringWithFormat:@"Your Saved Favorites (%ld)",(long)UIAppDelegate.userFavouriteNumber];
        _savedFavouriteLabel.text = [NSString stringWithFormat:@"Your Saved Favorites (%ld)",(long)((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT] : 0];
        
        
    }
    
    [badgeForEveryoneMeme removeFromSuperview];
    [badgeForMotivationalMeme removeFromSuperview];
    [badgeForRacyMeme removeFromSuperview];
    [badgeForSpiffyGifs removeFromSuperview];
    
    /*
    NSString *everyOne = [NSString stringWithFormat:@"%ld",(long)appDelegate.badgeEveryoneMeme];
    NSString *motivational = [NSString stringWithFormat:@"%ld",(long)appDelegate.badgeMotivationalMeme];
    NSString *racy = [NSString stringWithFormat:@"%ld",(long)appDelegate.badgeRacyMeme];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_MEME_EVERYONE_NOTIFICATION]) {
        if (appDelegate.badgeEveryoneMeme > 0) {
            if (appDelegate.badgeEveryoneMeme > 99) {
                everyOne = @"99+";
            }
            badgeForEveryoneMeme = [CustomBadge customBadgeWithString:everyOne
                                                      withStringColor:[UIColor whiteColor]
                                                       withInsetColor:[UIColor redColor]
                                                       withBadgeFrame:YES
                                                  withBadgeFrameColor:[UIColor whiteColor]
                                                            withScale:1.0
                                                          withShining:YES];
            //NSLog(@"Badge frame: %f, %f",badgeForEveryoneMeme.frame.size.width, badgeForEveryoneMeme.frame.size.height);
            
            [badgeForEveryoneMeme setFrame:
             CGRectMake(_memeView.frame.size.width-badgeForEveryoneMeme.frame.size.width/2,
                        -badgeForEveryoneMeme.frame.size.height/2,
                        badgeForEveryoneMeme.frame.size.width,
                        badgeForEveryoneMeme.frame.size.height)];
            [_memeView addSubview:badgeForEveryoneMeme];
        }
        else
            [badgeForEveryoneMeme removeFromSuperview];
    } else {
        [badgeForEveryoneMeme removeFromSuperview];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_MOTIVATIONAL_NOTIFICATION]) {
        if (appDelegate.badgeMotivationalMeme > 0) {
            if (appDelegate.badgeMotivationalMeme > 99) {
                motivational = @"99+";
            }
            badgeForMotivationalMeme = [CustomBadge customBadgeWithString:motivational
                                                          withStringColor:[UIColor whiteColor]
                                                           withInsetColor:[UIColor redColor]
                                                           withBadgeFrame:YES
                                                      withBadgeFrameColor:[UIColor whiteColor]
                                                                withScale:1.0
                                                              withShining:YES];
            
            [badgeForMotivationalMeme setFrame:
             CGRectMake(_motivationalView.frame.size.width-badgeForMotivationalMeme.frame.size.width/2,
                        -badgeForMotivationalMeme.frame.size.height/2,
                        badgeForMotivationalMeme.frame.size.width,
                        badgeForMotivationalMeme.frame.size.height)];
            [_motivationalView addSubview:badgeForMotivationalMeme];
        }
        else
            [badgeForMotivationalMeme removeFromSuperview];
    } else {
        [badgeForMotivationalMeme removeFromSuperview];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_RECYMEME_NOTIFICATION]) {
        if (appDelegate.badgeRacyMeme > 0) {
            if (appDelegate.badgeRacyMeme > 99) {
                racy = @"99+";
            }
            badgeForRacyMeme = [CustomBadge customBadgeWithString:racy
                                                  withStringColor:[UIColor whiteColor]
                                                   withInsetColor:[UIColor redColor]
                                                   withBadgeFrame:YES
                                              withBadgeFrameColor:[UIColor whiteColor]
                                                        withScale:1.0
                                                      withShining:YES];
            
            [badgeForRacyMeme setFrame:
             CGRectMake(_racyMemeView.frame.size.width-badgeForRacyMeme.frame.size.width/2,
                        -badgeForRacyMeme.frame.size.height/2,
                        badgeForRacyMeme.frame.size.width,
                        badgeForRacyMeme.frame.size.height)];
            [_racyMemeView addSubview:badgeForRacyMeme];
        }
        else
            [badgeForRacyMeme removeFromSuperview];
    } else {
        [badgeForRacyMeme removeFromSuperview];
    }
    */
    
    
    NSString *everyOne = [NSString stringWithFormat:@"%ld",(long)appDelegate.currentBadgeMemeEveryOne];
    NSString *motivational = [NSString stringWithFormat:@"%ld",(long)appDelegate.currentBadgeMemeMotiInsp];
    NSString *racy = [NSString stringWithFormat:@"%ld",(long)appDelegate.currentBadgeMemeRacy];
    NSString *spiffyGifs = [NSString stringWithFormat:@"%ld",(long)appDelegate.currentBadgeMemeSpiffyGif];
    
    if ([UIAppDelegate isEnabled:MEME_FOR_EVERYONE_BADGE]) {
        if (appDelegate.currentBadgeMemeEveryOne > 0) {
            if (appDelegate.currentBadgeMemeEveryOne > 99) {
                everyOne = @"99+";
            }
            badgeForEveryoneMeme = [CustomBadge customBadgeWithString:everyOne
                                                      withStringColor:[UIColor whiteColor]
                                                       withInsetColor:[UIColor redColor]
                                                       withBadgeFrame:YES
                                                  withBadgeFrameColor:[UIColor whiteColor]
                                                            withScale:1.0
                                                          withShining:YES];
            //NSLog(@"Badge frame: %f, %f",badgeForEveryoneMeme.frame.size.width, badgeForEveryoneMeme.frame.size.height);
            
            [badgeForEveryoneMeme setFrame:
             CGRectMake(_memeForEveryOneView.frame.size.width-badgeForEveryoneMeme.frame.size.width/2,
                        -badgeForEveryoneMeme.frame.size.height/2,
                        badgeForEveryoneMeme.frame.size.width,
                        badgeForEveryoneMeme.frame.size.height)];
            
            [_memeForEveryOneView addSubview:badgeForEveryoneMeme];
        }
        else
            [badgeForEveryoneMeme removeFromSuperview];
    } else {
        [badgeForEveryoneMeme removeFromSuperview];
    }
    
    if ([UIAppDelegate isEnabled:MOTIVATIONAL_INSPIRATIONAL_BADGE]) {
        if (appDelegate.currentBadgeMemeMotiInsp > 0) {
            if (appDelegate.currentBadgeMemeMotiInsp > 99) {
                motivational = @"99+";
            }
            badgeForMotivationalMeme = [CustomBadge customBadgeWithString:motivational
                                                          withStringColor:[UIColor whiteColor]
                                                           withInsetColor:[UIColor redColor]
                                                           withBadgeFrame:YES
                                                      withBadgeFrameColor:[UIColor whiteColor]
                                                                withScale:1.0
                                                              withShining:YES];
            
            [badgeForMotivationalMeme setFrame:
             CGRectMake(_motivationalView.frame.size.width-badgeForMotivationalMeme.frame.size.width/2,
                        -badgeForMotivationalMeme.frame.size.height/2,
                        badgeForMotivationalMeme.frame.size.width,
                        badgeForMotivationalMeme.frame.size.height)];
            
            [_motivationalView addSubview:badgeForMotivationalMeme];
        }
        else
            [badgeForMotivationalMeme removeFromSuperview];
    } else {
        [badgeForMotivationalMeme removeFromSuperview];
    }
    
    if ([UIAppDelegate isEnabled:RACY_MEME_BADGE]) {
        if (appDelegate.currentBadgeMemeRacy > 0) {
            if (appDelegate.currentBadgeMemeRacy > 99) {
                racy = @"99+";
            }
            badgeForRacyMeme = [CustomBadge customBadgeWithString:racy
                                                  withStringColor:[UIColor whiteColor]
                                                   withInsetColor:[UIColor redColor]
                                                   withBadgeFrame:YES
                                              withBadgeFrameColor:[UIColor whiteColor]
                                                        withScale:1.0
                                                      withShining:YES];
            
            [badgeForRacyMeme setFrame:
             CGRectMake(_racyMemeView.frame.size.width-badgeForRacyMeme.frame.size.width/2,
                        -badgeForRacyMeme.frame.size.height/2,
                        badgeForRacyMeme.frame.size.width,
                        badgeForRacyMeme.frame.size.height)];
            
            [_racyMemeView addSubview:badgeForRacyMeme];
        }
        else
            [badgeForRacyMeme removeFromSuperview];
    } else {
        [badgeForRacyMeme removeFromSuperview];
    }
    
    if ([UIAppDelegate isEnabled:SPIFFY_GIFS_BADGE]) {
        if (appDelegate.currentBadgeMemeSpiffyGif > 0) {
            if (appDelegate.currentBadgeMemeSpiffyGif > 99) {
                spiffyGifs = @"99+";
            }
            badgeForSpiffyGifs = [CustomBadge customBadgeWithString:spiffyGifs
                                                    withStringColor:[UIColor whiteColor]
                                                     withInsetColor:[UIColor redColor]
                                                     withBadgeFrame:YES
                                                withBadgeFrameColor:[UIColor whiteColor]
                                                          withScale:1.0
                                                        withShining:YES];
            
            [badgeForSpiffyGifs setFrame:CGRectMake(_spiffyGifsView.frame.size.width-badgeForSpiffyGifs.frame.size.width/2,
                                                    -badgeForSpiffyGifs.frame.size.height/2,
                                                    badgeForSpiffyGifs.frame.size.width,
                                                    badgeForSpiffyGifs.frame.size.height)];
            [_spiffyGifsView addSubview:badgeForSpiffyGifs];
            
        }
        else
            [badgeForSpiffyGifs removeFromSuperview];
    } else {
        [badgeForSpiffyGifs removeFromSuperview];
    }
    
}

-(void)updateBadges
{
    /*
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_LOGIN])
    {
        NSLog(@"Saved favorite: %ld",UIAppDelegate.userFavouriteNumber);
        _savedFavouriteLabel.text = [NSString stringWithFormat:@"Your Saved Favorites (%ld)",(long)UIAppDelegate.userFavouriteNumber];
    }*/
    
    [badgeForEveryoneMeme removeFromSuperview];
    [badgeForMotivationalMeme removeFromSuperview];
    [badgeForRacyMeme removeFromSuperview];
    [badgeForSpiffyGifs removeFromSuperview];
    
    
    NSString *everyOne = [NSString stringWithFormat:@"%ld",(long)appDelegate.currentBadgeMemeEveryOne];
    NSString *motivational = [NSString stringWithFormat:@"%ld",(long)appDelegate.currentBadgeMemeMotiInsp];
    NSString *racy = [NSString stringWithFormat:@"%ld",(long)appDelegate.currentBadgeMemeRacy];
    NSString *spiffyGifs = [NSString stringWithFormat:@"%ld",(long)appDelegate.currentBadgeMemeSpiffyGif];
    
    if ([UIAppDelegate isEnabled:MEME_FOR_EVERYONE_BADGE])
    {
        if (appDelegate.currentBadgeMemeEveryOne > 0)
        {
            if (appDelegate.currentBadgeMemeEveryOne > 99)
            {
                everyOne = @"99+";
            }
            badgeForEveryoneMeme = [CustomBadge customBadgeWithString:everyOne
                                                      withStringColor:[UIColor whiteColor]
                                                       withInsetColor:[UIColor redColor]
                                                       withBadgeFrame:YES
                                                  withBadgeFrameColor:[UIColor whiteColor]
                                                            withScale:1.0
                                                          withShining:YES];
            
            [badgeForEveryoneMeme setFrame:
             CGRectMake(_memeForEveryOneView.frame.size.width-badgeForEveryoneMeme.frame.size.width/2,
                        -badgeForEveryoneMeme.frame.size.height/2,
                        badgeForEveryoneMeme.frame.size.width,
                        badgeForEveryoneMeme.frame.size.height)];
            [_memeForEveryOneView addSubview:badgeForEveryoneMeme];
        }
        else
            [badgeForEveryoneMeme removeFromSuperview];
    } else {
        [badgeForEveryoneMeme removeFromSuperview];
    }
    
    if ([UIAppDelegate isEnabled:MOTIVATIONAL_INSPIRATIONAL_BADGE]) {
        if (appDelegate.currentBadgeMemeMotiInsp > 0) {
            if (appDelegate.currentBadgeMemeMotiInsp > 99) {
                motivational = @"99+";
            }
            badgeForMotivationalMeme = [CustomBadge customBadgeWithString:motivational
                                                          withStringColor:[UIColor whiteColor]
                                                           withInsetColor:[UIColor redColor]
                                                           withBadgeFrame:YES
                                                      withBadgeFrameColor:[UIColor whiteColor]
                                                                withScale:1.0
                                                              withShining:YES];
            
            [badgeForMotivationalMeme setFrame:
             CGRectMake(_motivationalView.frame.size.width-badgeForMotivationalMeme.frame.size.width/2,
                        -badgeForMotivationalMeme.frame.size.height/2,
                        badgeForMotivationalMeme.frame.size.width,
                        badgeForMotivationalMeme.frame.size.height)];
            [_motivationalView addSubview:badgeForMotivationalMeme];
        }
        else
            [badgeForMotivationalMeme removeFromSuperview];
    } else {
        [badgeForMotivationalMeme removeFromSuperview];
    }
    
    if ([UIAppDelegate isEnabled:RACY_MEME_BADGE]) {
        if (appDelegate.currentBadgeMemeRacy > 0) {
            if (appDelegate.currentBadgeMemeRacy > 99) {
                racy = @"99+";
            }
            badgeForRacyMeme = [CustomBadge customBadgeWithString:racy
                                                  withStringColor:[UIColor whiteColor]
                                                   withInsetColor:[UIColor redColor]
                                                   withBadgeFrame:YES
                                              withBadgeFrameColor:[UIColor whiteColor]
                                                        withScale:1.0
                                                      withShining:YES];
            
            [badgeForRacyMeme setFrame:
             CGRectMake(_racyMemeView.frame.size.width-badgeForRacyMeme.frame.size.width/2,
                        -badgeForRacyMeme.frame.size.height/2,
                        badgeForRacyMeme.frame.size.width,
                        badgeForRacyMeme.frame.size.height)];
            [_racyMemeView addSubview:badgeForRacyMeme];
        }
        else
            [badgeForRacyMeme removeFromSuperview];
    } else {
        [badgeForRacyMeme removeFromSuperview];
    }
    
    if ([UIAppDelegate isEnabled:SPIFFY_GIFS_BADGE]) {
        if (appDelegate.currentBadgeMemeSpiffyGif > 0) {
            if (appDelegate.currentBadgeMemeSpiffyGif > 99) {
                spiffyGifs = @"99+";
            }
            badgeForSpiffyGifs = [CustomBadge customBadgeWithString:spiffyGifs
                                                    withStringColor:[UIColor whiteColor]
                                                     withInsetColor:[UIColor redColor]
                                                     withBadgeFrame:YES
                                                withBadgeFrameColor:[UIColor whiteColor]
                                                          withScale:1.0
                                                        withShining:YES];
            [badgeForSpiffyGifs setFrame:
             CGRectMake(_spiffyGifsView.frame.size.width-badgeForSpiffyGifs.frame.size.width/2,
                        -badgeForSpiffyGifs.frame.size.height/2,
                        badgeForSpiffyGifs.frame.size.width,
                        badgeForSpiffyGifs.frame.size.height)];
            [_spiffyGifsView addSubview:badgeForSpiffyGifs];
        }
        else
            [badgeForSpiffyGifs removeFromSuperview];
    } else {
        [badgeForSpiffyGifs removeFromSuperview];
    }
}

#pragma mark - Icon Button Actions

-(void)iconButtonAction:(UIButton *)sender
{
    NSMutableArray *enabledFeatureArr = [UIAppDelegate getEnabledFeature];
    
    NSDictionary *dict = [enabledFeatureArr objectAtIndex:sender.tag-1];
    NSString *featureName = [dict valueForKey:@"featureName"];
    
    if ([featureName isEqualToString:MEME_FOR_EVERYONE]) {
        [self memeEveryoneButtonAction:sender];
    }
    else if ([featureName isEqualToString:MOTIVATIONAL_INSPIRATIONAL]) {
        [self motivationalButtonAction:sender];
    }
    else if ([featureName isEqualToString:RACY_MEMES]) {
        [self recyMemeButtonAction:sender];
    }
    else if ([featureName isEqualToString:SPIFFY_GIFS]) {
        [self spiffyGifsButtonAction:sender];
    }
    else if ([featureName isEqualToString:TRENDING_POPULAR]) {
        [self trendingButtonAction:sender];
    }
    else if ([featureName isEqualToString:UPLOAD_AWESOME_MEME]) {
        [self shareButtonAction:sender];
    }
    else if ([featureName isEqualToString:SAVED_FAVORITES]) {
        [self favoriteButtonAction:sender];
    }
    else if ([featureName isEqualToString:REMOVE_ADS]) {
        [self removeAdsButtonAction:sender];
    }
    else if ([featureName isEqualToString:SINGLE_DAD_LAUGHING]) {
        [self commingSoonButtonAction:sender];
    }
}

- (IBAction)memeEveryoneButtonAction:(UIButton *)sender
{
    [UIAppDelegate checkForDeletedMemes];
    MemesViewController *viewController = [[MemesViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"MemesViewController"] bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)motivationalButtonAction:(UIButton *)sender
{
    [UIAppDelegate checkForDeletedMemes];
    MotivationalViewController *viewController = [[MotivationalViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"MotivationalViewController"] bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)trendingButtonAction:(UIButton *)sender
{
    [UIAppDelegate checkForDeletedMemes];
    TrendingViewController *viewController = [[TrendingViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"TrendingViewController"] bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)shareButtonAction:(UIButton *)sender
{
    
    [_sendButton setImage:[UIImage imageNamed:@"send_it_deselected.png"]
                 forState:UIControlStateNormal];
    [_cameraButton setImage:[UIImage imageNamed:@"camera_btn.png"]
                   forState:UIControlStateNormal];
    _cameraButton.enabled = YES;
    _sendButton.enabled = NO;
    
    _passcodePopupView.hidden = YES;
    _gotItPopupView.hidden = YES;
    _menuPopupView.hidden = YES;
    
    _popupView.hidden = NO;
    _capturePopupView.hidden = NO;
    
    [_capturePopupView setFrame:CGRectMake(_popupView.frame.size.width/2-_capturePopupView.frame.size.width/2,
                                           _popupView.frame.size.height/2-_capturePopupView.frame.size.height/2,
                                           _capturePopupView.frame.size.width, _capturePopupView.frame.size.height)];
    [_popupView addSubview:_capturePopupView];
}

- (IBAction)favoriteButtonAction:(UIButton *)sender
{
    [UIAppDelegate checkForDeletedMemes];
    FavoriteViewController *viewController = [[FavoriteViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"FavoriteViewController"] bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)removeAdsButtonAction:(UIButton *)sender
{
    DanMessagePopup *rAlert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self
                                                                 label1:@"REMOVE ADS?"
                                                                 label2:@"How can I blame you?! This app is awesome!"
                                                         button1stTitle:@"Disable for $0.99/year"
                                                         button2ndTitle:@"Disable forever for $4.99"
                                                         button3rdTitle:@"Restore Subscription"
                                                         button4thTitle:@"Nah. I changed my mind."
                                                        showTopBlackBar:NO];
    rAlert.tag = 1;
    [rAlert show];
}

- (IBAction)preferenceButtonAction:(UIButton *)sender
{
    PreferenceViewController *viewController = [[PreferenceViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"PreferenceViewController"] bundle:nil];
    
    UINavigationController *navContrl = [[UINavigationController alloc] initWithRootViewController:viewController];
    navContrl.navigationBarHidden = YES;
    
    [appDelegate.navigationController presentViewController:navContrl animated:YES completion:nil];
}

- (IBAction)logoutButtonAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Logout Button Clicked"];
    
    NSLog(@"MemeViewController logoutButtonAction tapped!!");
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CHECK_FOR_LOGIN];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CHECK_FOR_USER_INFO];
    
    UIAppDelegate.userFavouriteNumber = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MEME_FAVORITE_CURRENT_COUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIAppDelegate.isNewlyLaunched = YES;
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    if (appDelegate.isFromHome)
    {
        NSLog(@"isFromHome yes");
        
        LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"LoginViewController"] bundle:nil];
        [self.navigationController pushViewController:viewController animated:NO];
    }
    else
    {
        NSLog(@"isFromHome no");
        
        NSArray *vcArr = [self.navigationController viewControllers];
        NSLog(@"MyNav: %@", vcArr);
        UIViewController *vc = (UIViewController*)[vcArr objectAtIndex:1];
        
        for (id myVC in vcArr)
        {
            if ([myVC isKindOfClass:[LoginViewController class]])
            {
                vc = (UIViewController*)myVC;
                break;
            }
        }
        [self.navigationController popToViewController:vc animated:NO];
    }
}

-(IBAction)singleDadButtonAction
{
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:SDL_APP_SCHEME]]]) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:SDL_APP_SCHEME]]];
        NSLog(@"canOpenURL");
    }
    else
    {
        if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:SDL_APP_iTUNES_URL]]]) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:SDL_APP_iTUNES_URL]]];
            NSLog(@"canOpenURL");
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Unable to open the page. Pleaes try later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil]show];
        }
    }
}
-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    NSLog(@"productViewControllerDidFinish");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)commingSoonButtonAction:(UIButton *)sender
{
    [self singleDadButtonAction];
}

- (IBAction)recyMemeButtonAction:(UIButton *)sender
{
    [UIAppDelegate checkForDeletedMemes];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:WILL_LOCK_RECY_MEME])
    {
        NSLog(@"WILL_LOCK_RECY_MEME");
        _passwordViewLabel.hidden = YES;
        
        _menuPopupView.hidden = YES;
        _capturePopupView.hidden = YES;
        _gotItPopupView.hidden = YES;
        _popupView.hidden = NO;
        _passcodePopupView.hidden = YES;
        _unloackRacyPopupView.hidden = NO;
        [_unloackRacyPopupView setFrame:CGRectMake(_popupView.frame.size.width/2-_unloackRacyPopupView.frame.size.width/2,
                                                _popupView.frame.size.height/2-_unloackRacyPopupView.frame.size.height/2,
                                                _unloackRacyPopupView.frame.size.width, _unloackRacyPopupView.frame.size.height)];
        _unloackRacyPopupView.center = self.view.center;
        [_popupView addSubview:_unloackRacyPopupView];
        [_myTextField becomeFirstResponder];
        
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_HOME_SCREEN_POPUP])
        {
            RacyMemeViewController *viewController = [[RacyMemeViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"RacyMemeViewController"] bundle:nil];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else
        {
            NSLog(@"recyMemeButtonAction Clicked");
            _passwordViewLabel.hidden = NO;
            _passwordViewLabel.text = @"Type a 4-digit code";
            _unloackRacyPopupView.hidden = YES;
            _passcodePopupView.hidden = YES;
            _capturePopupView.hidden = YES;
            _gotItPopupView.hidden = YES;
            _popupView.hidden = NO;
            _menuPopupView.hidden = NO;
            [_menuPopupView setFrame:CGRectMake(_popupView.frame.size.width/2-_menuPopupView.frame.size.width/2,
                                                _popupView.frame.size.height/2-_menuPopupView.frame.size.height/2,
                                                _menuPopupView.frame.size.width, _menuPopupView.frame.size.height)];
            _menuPopupView.center = self.view.center;
            [_popupView addSubview:_menuPopupView];
        }
        
    }
}

- (IBAction)spiffyGifsButtonAction:(UIButton *)sender
{
    
    // Change Date: 9-Feb-2015
    [self loadGIFs];
    /*
    if(photoArray.count == 0)
    {
        [self loadGIFs:YES];
    }
    else
    {
        MemesSwipeView *swipeView = [[MemesSwipeView alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"SpiffyGifSwipeVC"] bundle:nil];
        
        [swipeView setImageArray:photoArray];
        [swipeView setImageIndex:0];
        [swipeView setControllerIdentifier:5];
        
        [self.navigationController pushViewController:swipeView animated:YES];
    }
    */
}


#pragma mark - RacyMeme PopUp Button Actions
- (IBAction)setPasscodeButtonAction:(UIButton *)sender
{
    _menuPopupView.hidden = YES;
    _capturePopupView.hidden = YES;
    _gotItPopupView.hidden = YES;
    _popupView.hidden = NO;
    _passcodePopupView.hidden = NO;
    [_passcodePopupView setFrame:CGRectMake(_popupView.frame.size.width/2-_passcodePopupView.frame.size.width/2,
                                        (_passcodePopupView.frame.size.height/2-_passcodePopupView.frame.size.height)*factorY,
                                        _passcodePopupView.frame.size.width, _passcodePopupView.frame.size.height)];
    _passcodePopupView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-_passcodePopupView.frame.size.height);
    [_popupView addSubview:_passcodePopupView];
    
    [_myTextField becomeFirstResponder];
}

- (IBAction)dontShowButtonAction:(UIButton *)sender
{
    _menuPopupView.hidden = YES;
    _passcodePopupView.hidden = YES;
    _gotItPopupView.hidden = YES;
    _popupView.hidden = YES;
    _capturePopupView.hidden = YES;
    
    RacyMemeViewController *viewController = [[RacyMemeViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"RacyMemeViewController"] bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WILL_SHOW_HOME_SCREEN_POPUP];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)noWarriesButtonAction:(UIButton *)sender
{
    _popupView.hidden = YES;
    _menuPopupView.hidden = YES;
    _passcodePopupView.hidden = YES;
    _capturePopupView.hidden = YES;
    _gotItPopupView.hidden = YES;
    
    RacyMemeViewController *viewController = [[RacyMemeViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"RacyMemeViewController"] bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)getMeOutButtonAction:(UIButton *)sender
{
    [UIAppDelegate enableFeature:RACY_MEMES :NO];
    
    //hide popup
    _popupView.hidden = YES;
    _menuPopupView.hidden = YES;
    _passcodePopupView.hidden = YES;
    _capturePopupView.hidden = YES;
    _gotItPopupView.hidden = YES;
    
    //reposition icons
    [self.view setNeedsDisplay];
}


#pragma mark - Dismiss popup
- (IBAction)dismissPopUp:(UIButton *)sender
{
    [_myTextField resignFirstResponder];
    _popupView.hidden = YES;
    [self clearTextField];
    _myTextField.text = nil;
    
    
}

-(void)clearTextField
{
    _pImage1.hidden = YES;
    _pImage2.hidden = YES;
    _pImage3.hidden = YES;
    _pImage4.hidden = YES;
    
    _unImage1.hidden = YES;
    _unImage2.hidden = YES;
    _unImage3.hidden = YES;
    _unImage4.hidden = YES;
}
-(void)changeTextColor
{
    _passwordViewLabel.text = @"Re-Type your 4-digit code";
    _passwordViewLabel.textColor = [UIColor blueColor];
}

#pragma mark - Textfield delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _myTextField.text = nil;
    [self clearTextField];
    _myTextField.tag = 1;
    
    _passwordViewLabel.text = @"Type a 4-digit code";
    _passwordViewLabel.textColor = [UIColor blackColor];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:WILL_LOCK_RECY_MEME])
    {
        if (IS_IPHONE_4INCHES || IS_IPAD) {
            _unloackRacyPopupView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-_unloackRacyPopupView.frame.size.height*0.2);
        }
        else
        {
            _unloackRacyPopupView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-_unloackRacyPopupView.frame.size.height*0.4);
        }
    }
    else
    {
        if (IS_IPHONE_4INCHES || IS_IPAD)
        {
            _passcodePopupView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-_passcodePopupView.frame.size.height*0.2);
        }
        else
            _passcodePopupView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-_passcodePopupView.frame.size.height*0.4);
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    [_passcodePopupView setFrame:CGRectMake(_popupView.frame.size.width/2-_passcodePopupView.frame.size.width/2,
                                            _memeForEveryOneView.frame.origin.y+4,
                                            _passcodePopupView.frame.size.width, _passcodePopupView.frame.size.height)];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    //Detect Back button Press
    
//    const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
//    int isBackSpace = strcmp(_char, "\b");
//
//    if (isBackSpace == -8) {
//        NSLog(@"isBackSpace :: %@",_myTextField.text);
//    }
    
    return ([newString stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceCharacterSet]].length<=4);
}



-(void)changeTextFieldImage
{
    
    
    NSInteger number = [[_myTextField.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceCharacterSet]] length];
    
    _myTextField.text = [_myTextField.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceCharacterSet]];
    
    NSLog(@"TEXT :: %@",_myTextField.text);
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:WILL_LOCK_RECY_MEME])
    {
        if (_myTextField.tag == 1)
        {
            switch (number) {
                case 0:
                    [self clearTextField];
                    break;
                case 1:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = YES;
                    _pImage3.hidden = YES;
                    _pImage4.hidden = YES;
                    break;
                case 2:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = YES;
                    _pImage4.hidden = YES;
                    break;
                case 3:
                    
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = NO;
                    _pImage4.hidden = YES;
                    break;
                case 4:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = NO;
                    _pImage4.hidden = NO;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:_myTextField.text forKey:@"password"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    _myTextField.tag = 2;
                    _myTextField.text = nil;
                    [self performSelector:@selector(clearTextField) withObject:nil afterDelay:0.5];
                    [self performSelector:@selector(changeTextColor) withObject:nil afterDelay:0.5];
                    
                    
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            switch (number)
            {
                case 0:
                    [self clearTextField];
                    break;
                case 1:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = YES;
                    _pImage3.hidden = YES;
                    _pImage4.hidden = YES;
                    break;
                case 2:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = YES;
                    _pImage4.hidden = YES;
                    break;
                case 3:
                    
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = NO;
                    _pImage4.hidden = YES;
                    break;
                case 4:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = NO;
                    _pImage4.hidden = NO;
                    if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"password"] isEqualToString:_myTextField.text])
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                        message:@"Password didn't mached."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles: nil];
                        [alert show];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:_myTextField.text forKey:RECY_MEME_LOCK_UNLOCK_PASSWORD];
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WILL_LOCK_RECY_MEME];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        _popupView.hidden = YES;
                        _menuPopupView.hidden = YES;
                        _passcodePopupView.hidden = YES;
                        _capturePopupView.hidden = YES;
                        _gotItPopupView.hidden = YES;
                        
                        RacyMemeViewController *viewController = [[RacyMemeViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"RacyMemeViewController"] bundle:nil];
                        [self.navigationController pushViewController:viewController animated:YES];
                        
                        [_myTextField resignFirstResponder];
                        
                    }
                    _myTextField.text = nil;
                    _myTextField.tag = 1;
                    [self clearTextField];
                    _passwordViewLabel.text = @"Type a 4-digit code";
                    _passwordViewLabel.textColor = [UIColor blackColor];
                    break;
                    
                default:
                    break;
            }
        }
    }
    else
    {
        switch (number)
        {
            case 0:
                [self clearTextField];
                break;
            case 1:
                _unImage1.hidden = NO;
                _unImage2.hidden = YES;
                _unImage3.hidden = YES;
                _unImage4.hidden = YES;
                break;
            case 2:
                _unImage1.hidden = NO;
                _unImage2.hidden = NO;
                _unImage3.hidden = YES;
                _unImage4.hidden = YES;
                break;
            case 3:
                
                _unImage1.hidden = NO;
                _unImage2.hidden = NO;
                _unImage3.hidden = NO;
                _unImage4.hidden = YES;
                break;
            case 4:
                _unImage1.hidden = NO;
                _unImage2.hidden = NO;
                _unImage3.hidden = NO;
                _unImage4.hidden = NO;
                
                if ([_myTextField.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:RECY_MEME_LOCK_UNLOCK_PASSWORD]])
                {
                    _popupView.hidden = YES;
                    _menuPopupView.hidden = YES;
                    _passcodePopupView.hidden = YES;
                    _capturePopupView.hidden = YES;
                    _gotItPopupView.hidden = YES;
                    
                    RacyMemeViewController *viewController = [[RacyMemeViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"RacyMemeViewController"] bundle:nil];
                    [self.navigationController pushViewController:viewController animated:YES];
                    
                    [_myTextField resignFirstResponder];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops! That wasn't quite right."
                                                                    message:@"Please enter the correct password."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles: nil];
                    [alert show];
                }
                
                _myTextField.text = nil;
                [self performSelector:@selector(clearTextField) withObject:nil afterDelay:0.5];
                break;
                
            default:
                break;
        }
    }
    
}

#pragma mark - Capture Popup Actions

- (IBAction)cameraButtonAction:(UIButton *)sender
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Sharing option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                             @"Use Camera",
                             @"Choose From Camera-Roll",
                             nil];
    popup.tag = 1;
    //[popup showInView:[UIApplication sharedApplication].keyWindow];
    
    
    
    if (IS_IPAD)
    {
        
        // In this case the device is an iPad.
        UIButton *btn = (UIButton *)sender;
        NSLog(@"btnP: %@",NSStringFromCGRect(btn.frame));
        [popup showFromRect:[btn frame] inView:btn animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [popup showInView:self.view];
    }
}

//-(void) openCamera
//{
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = NO;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    picker.modalPresentationStyle = UIModalPresentationFullScreen;
//
//    [self presentViewController:picker animated:YES completion:NULL];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
//}

-(void)openWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.delegate = self;
    cameraUI.allowsEditing = NO;
    cameraUI.sourceType = sourceType;
    cameraUI.modalPresentationStyle = UIModalPresentationFullScreen;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self presentViewController:cameraUI animated:YES completion:nil];
        }];
        
    }
    else{
        
        [self presentViewController:cameraUI animated:YES completion:nil];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

//-(void) openLibrary
//{
//    
//    
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = NO;
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    picker.modalPresentationStyle = UIModalPresentationFullScreen;
//    
//    [self presentViewController:picker animated:YES completion:NULL];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
//}

- (IBAction)sendButtonAction:(UIButton *)sender
{
    UIImage *img = _cameraButton.imageView.image;
    NSLog(@"img%@",img);
    
    [self uploadImage];
    
}

#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex)
    {
        case 0:
            [self openWithSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        case 1:
            [self openWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 2:
            NSLog(@"Cancel.");
            break;
            
        default:
            break;
    }
    
}

#pragma mark - ImagePicker Delegates
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *url=[info
                objectForKey:UIImagePickerControllerReferenceURL];
    self.imageExtention = [url pathExtension];
    self.imageURL = url;
    
    /*ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
             resultBlock:^(ALAsset *asset)
     {
         ALAssetRepresentation *representation = [asset defaultRepresentation];
         //[representation ]
         
         Byte *buffer = (Byte*)malloc(representation.size);
         NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
         NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
         self.imageDATA = data;
         
     }
            failureBlock:^(NSError *error)
     {
         
     }
     ];*/
    
    NSLog(@"imageURL=%@",[self.imageURL path]);
    
    _sendButton.enabled = YES;
    //_cameraButton.enabled = NO;
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [_cameraButton setImage:chosenImage forState:UIControlStateNormal];
    
    _cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [_sendButton setImage:[UIImage imageNamed:@"send_it_selected.png"]
                 forState:UIControlStateNormal];
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    _capturePopupView.hidden = NO;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - Upload Images

-(void) uploadImage
{
    if(![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!"];
        return;
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //NSData *imageData = UIImagePNGRepresentation(_cameraButton.imageView.image);
    NSData *imageData;// = UIImageJPEGRepresentation(_cameraButton.imageView.image, 1.0);
    NSDictionary *parameters = nil;//@{@"userfile": imageData};
    
    NSString *imageMimeType;
    if ([self.imageExtention isEqualToString:@"JPG"]) {
        imageData = UIImageJPEGRepresentation(_cameraButton.imageView.image, 1.0);
        imageMimeType = @"image/jpeg";
    }
    else if ([self.imageExtention isEqualToString:@"GIF"]) {
        //imageData = [NSData dataWithContentsOfURL:self.imageURL];
        //imageData = [[NSFileManager defaultManager] contentsAtPath:[self.imageURL lastPathComponent]];
        imageData = [AnimatedGIFImageSerialization animatedGIFDataWithImage:_cameraButton.imageView.image error:nil];
        //imageData = self.imageDATA;
        imageMimeType = @"image/gif";
    }
    else if ([self.imageExtention isEqualToString:@"PNG"]) {
        imageData = UIImagePNGRepresentation(_cameraButton.imageView.image);
        imageMimeType = @"image/png";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestOperation *op = [manager POST:MEME_UPLOAD parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        
        
        [formData appendPartWithFileData:imageData
                                    name:@"userfile"
                                fileName:[NSString stringWithFormat:@"photo2.%@",[self.imageExtention lowercaseString]]
                                mimeType:imageMimeType];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [UIAppDelegate activityHide];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        
        NSDictionary *JSON = (NSDictionary *)responseObject;
        
        NSLog(@"disct: %@ ",JSON);

            if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
            {
                _menuPopupView.hidden = YES;
                _passcodePopupView.hidden = YES;
                _popupView.hidden = NO;
                _capturePopupView.hidden = YES;
                _gotItPopupView.hidden = NO;
                
                [_gotItPopupView setFrame:CGRectMake(_popupView.frame.size.width/2-_gotItPopupView.frame.size.width/2,
                                                     _popupView.frame.size.height/2-_gotItPopupView.frame.size.height/2,
                                                     _gotItPopupView.frame.size.width, _gotItPopupView.frame.size.height)];
                [_popupView addSubview:_gotItPopupView];
            }
            else
            {
                if ([[JSON objectForKey:@"message"] isEqualToString:@"File upload failed"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed!" message:@"Upload failed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [UIAppDelegate activityHide];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }];
    
    [op setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSLog(@"Wrote %ld/%ld", (long)totalBytesWritten, (long)totalBytesExpectedToWrite);
        
        [UIAppDelegate activityShow];
    }];
    
    
    [op start];
    
    // 
}



#pragma mark - Dan Message
-(void)checkForDanMessage
{
    if(![AppDelegate isNetworkAvailable])
    {
        //[UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!"];
        return;
    }
    
    NSString *urlString = MEME_MESSAGE_FROM_DAN;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = nil;//@{@"email": email, @"password": password, @"type": @"normal"};
    
    //if (isFirstTimeInDashboard)
    //{
        //\\[UIAppDelegate activityShow];
        isFirstTimeInDashboard = NO;
    //}
    
    
    NSLog(@"Started..");
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //\\try[UIAppDelegate activityHide];
         NSError *error = nil;
         NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
         if (error) {
             NSLog(@"Error serializing %@", error);
         }
         else
         {
             if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
             {
                 NSArray *listArray = [JSON objectForKey:@"result"];
                 
                 for (NSDictionary *listDic in listArray)
                 {
                     DanMessage *damMessage = [[DanMessage alloc] init];
                     
                     damMessage.dan_id = [listDic objectForKey:@"id"];
                     damMessage.dan_title = [listDic objectForKey:@"title"];
                     damMessage.dan_subtitle = [listDic objectForKey:@"subtitle"];
                     damMessage.dan_url = [listDic objectForKey:@"url"];
                     damMessage.dan_isPublished = [listDic objectForKey:@"IsPublish"];
                     damMessage.dan_counter = [listDic objectForKey:@"counter"];
                     
                     [danMessageArray addObject:damMessage];
                     
                     if ([[listDic objectForKey:@"IsPublish"] isEqualToString:@"on"])
                     {
                         if (![UIAppDelegate ratePopupIsOn])
                         {
                             if ([self showDanPopupRequire:damMessage])
                             {
                                 [UIAppDelegate setDanMessagePopupIsOn:YES];
                                 [self showDanPopUp:damMessage];
                             }
                         }
                         
                     }
                     
                 }
                 
                 
             }
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         //[UIAppDelegate activityHide];
     }];
}



-(BOOL)showDanPopupRequire:(DanMessage*)damMsg{
    BOOL flag=NO;
    int localDanCounter=[[NSUserDefaults standardUserDefaults] integerForKey:@"danMessageCounter"];
    if (localDanCounter==0)
    {
        flag=YES;
    }
    else
    {
        if ([damMsg.dan_counter intValue]>localDanCounter)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"danMessageRemindKey"];
            flag=YES;
        }
        else
        {
            NSDate *time= [[NSUserDefaults standardUserDefaults] objectForKey:@"danMessageRemindKey"];
            if (time!=nil)
            {
                int time3=[[NSDate date] timeIntervalSinceDate:time];
                if (time3>(24*60*60))
                {
                    flag=YES;
                }
            }
        }
    }
    return flag;
}

#pragma mark - Dan Message New

-(void)checkForDanMessageNew
{
    if(![AppDelegate isNetworkAvailable]){
        //[UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!"];
        return;
    }
    
    NSString *urlString = MEME_MESSAGE_FROM_DAN_NEW;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = nil;//@{@"email": email, @"password": password, @"type": @"normal"};
    
    
    
    
    NSLog(@"Started..");
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //\\try[UIAppDelegate activityHide];
         NSError *error = nil;
         NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
         if (error) {
             NSLog(@"Error serializing %@", error);
         }
         else
         {
             if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
             {
                 NSArray *listArray = [JSON objectForKey:@"result"];
                 
                 for (NSDictionary *listDic in listArray)
                 {
                     
                     DanMessageNew *danMsgNew=[[DanMessageNew alloc] init];
                     
                     danMsgNew.dan_id = [listDic objectForKey:@"id"];
                     danMsgNew.dan_title = [listDic objectForKey:@"title"];
                     danMsgNew.dan_subtitle = [listDic objectForKey:@"message"];
                     
                     NSString *myUrlString = [listDic objectForKey:@"url"];
                     
                     if(myUrlString.length>1)
                     {
                         if([myUrlString rangeOfString:@"http"].location == NSNotFound)
                         {
                             myUrlString = [NSString stringWithFormat:@"http://%@",myUrlString];
                         }
                         NSURL *myUrl = [NSURL URLWithString:[myUrlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
                         
                         danMsgNew.dan_url = [NSString stringWithFormat:@"%@",myUrl];//[listDic objectForKey:@"url"];
                     }
                     else
                     {
                         danMsgNew.dan_url = @"";
                     }
                     
                     danMsgNew.dan_isPublished = [listDic objectForKey:@"IsPublish"];
                     danMsgNew.dan_counter = [listDic objectForKey:@"counter"];
                     danMsgNew.dan_topBtnTxt = [listDic objectForKey:@"top_button_text"];
                     danMsgNew.dan_middleBtnTxt = [listDic objectForKey:@"middle_button_text"];
                     danMsgNew.dan_bottomBtnTxt = [listDic objectForKey:@"botton_button_text"];
                     self.danMessageNew=danMsgNew;
                     
                     if([danMsgNew.dan_isPublished isEqualToString:@"on"])
                     {
                         if ([self showDanPopupRequireNew:danMsgNew])
                         {
                             [self showDanPopUpNew:danMsgNew];
                         }
                     }
                     
                     
                 }
                 
                 
             }
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         //[UIAppDelegate activityHide];
     }];
}

-(void)showDanPopUpNew:(DanMessageNew*)danMsgNew
{
    
    [[NSUserDefaults standardUserDefaults] setInteger:[danMsgNew.dan_counter intValue] forKey:@"danMessageCounterNew"];
    [self.danMessagePopupNew removeFromSuperview];
    self.danMessagePopupNew = [[DanMessagePopupNew alloc] initWithFrame:self.view.bounds title:danMsgNew];
    self.danMessagePopupNew.danMessagePopupNewDelegate=self;
    [self.view addSubview:self.danMessagePopupNew];
    
}

-(BOOL)showDanPopupRequireNew:(DanMessageNew*)damMsgNew
{
    
    
    BOOL flag=NO;
    int localDanCounter=[[NSUserDefaults standardUserDefaults] integerForKey:@"danMessageCounterNew"];
    if (localDanCounter==0)
    {
        flag=YES;
    }
    else
    {
        if ([damMsgNew.dan_counter intValue] > localDanCounter)
        {
            if(UIAppDelegate.isNewlyLaunched)
            {
                UIAppDelegate.isNewlyLaunched = NO;
                //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"danMessageRemindKeyNew"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DAN_MESSAGE_POPUP_NEW_LATER];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DAN_MESSAGE_POPUP_NEW_NEXT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                flag=YES;
            }
            else
            {
                flag = NO;
            }
            
        }
        else
        {
            /*
            NSDate *time=[[NSUserDefaults standardUserDefaults] objectForKey:@"danMessageRemindKeyNew"];
            if (time!=nil)
            {
                int time3=[[NSDate date] timeIntervalSinceDate:time];
                if (time3>(24*60*60))
                {
                    flag=YES;
                }
            }
             */
            if(UIAppDelegate.isNewlyLaunched)
            {
                UIAppDelegate.isNewlyLaunched = NO;
                if([[NSUserDefaults standardUserDefaults] boolForKey:DAN_MESSAGE_POPUP_NEW_LATER])
                {
                    flag = YES;
                }
            }
            
            
            
        }
    }
    if(!flag)
        NSLog(@"Dan Message New: NO!!!!!");
    return flag;
}

#pragma mark - Dan Message Pop up Delegate
-(void)dismissDanMessagePopupNew:(DanMessagePopupNew*)danMsgNew WithIndex:(int)buttonIndex
{
    [self.danMessagePopupNew removeFromSuperview];
    if (buttonIndex==0)
    {
        //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:DAN_MESSAGE_POPUP_NEW_NEXT];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DAN_MESSAGE_POPUP_NEW_LATER];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:danMsgNew.danMsgNew.dan_url]];
    }
    else if (buttonIndex==1)
    {
        //[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"danMessageRemindKeyNew"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DAN_MESSAGE_POPUP_NEW_LATER];
        //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:DAN_MESSAGE_POPUP_NEW_NEXT];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (buttonIndex==2)
    {
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:DAN_MESSAGE_POPUP_NEW_NEXT];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DAN_MESSAGE_POPUP_NEW_LATER];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"danMessageRemindKeyNew"];
    }
    self.danMessagePopupNew=nil;
}




#pragma mark - Dan Message
-(void)showDanPopUp:(DanMessage*)damMessage
{
    [[NSUserDefaults standardUserDefaults] setInteger:[damMessage.dan_counter intValue] forKey:@"danMessageCounter"];
    [_danMessagePopup removeFromSuperview];
    _danMessagePopup = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self
                                                          label1:damMessage.dan_title
                                                          label2:damMessage.dan_subtitle
                                                  button1stTitle:@"YAY! TAKE ME TO SEE IT!"
                                                  button2ndTitle:@"REMIND ME NEXT TIME"
                                                  button3rdTitle:@"BAH! I don't care!"
                                                  button4thTitle:nil
                                                 showTopBlackBar:YES];
    
    [_danMessagePopup show];
}

#pragma mark - Custom Rating AlertView Delegate
-(void)danMessagePopupView:(DanMessagePopup *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        MenuView *menuView = [[MenuView alloc] init];
        switch (buttonIndex)
        {
            case 0:
                menuView.purchaseCode = PURCHASE_DISABLE_ANNUAL;
                if([AppDelegate isNetworkAvailable])
                    [menuView purchaseSubscription];
                else
                    [SVProgressHUD showErrorWithStatus:@"No internet connection detected. Please try later."];
                break;
                
            case 1:
                menuView.purchaseCode = PURCHASE_DISABLE_FOREVER;
                if([AppDelegate isNetworkAvailable])
                    [menuView purchaseSubscription];
                else
                    [SVProgressHUD showErrorWithStatus:@"No internet connection detected. Please try later."];
                break;
                
            case 2:
                [menuView restorePurchase];
                break;
                
            case 3:
                break;
                
            default:
                break;
        }
    }
    else
    {
        DanMessage *dMessage;
        switch (buttonIndex)
        {
            case 0:
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"danMessageRemindKey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (danMessageArray.count > 0)
                {
                    dMessage = [danMessageArray objectAtIndex:0];
                    
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:dMessage.dan_url]])
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dMessage.dan_url]];
                } else
                    return;
                
                break;
            case 1:
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"danMessageRemindKey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                break;
            case 2:
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"danMessageRemindKey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                break;
                
            default:
                break;
        }
    }
    
    
    
    //[UIAppDelegate setDanMessagePopupIsOn:NO];
    alertView = nil;
}

-(void)hideAD
{
    NSLog(@"UIAppDelegate.bannerIsVisible=%hhd",UIAppDelegate.bannerIsVisible);
    [UIAppDelegate hideFlurryAd];
}

#pragma mark - loadGIFs
-(void)loadGIFs
{
    if(![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!"];
        return;
    }
    
    [UIAppDelegate activityShow];
    
    NSString *userId;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED]) {
        userId = @"";
    }
    else
    {
        NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
        userId = [userInfoDisct objectForKey:@"userId"];
    }
    
    NSString *urlString = MEME_GIFS;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *parameters = @{@"userID": userId, @"page_number" : @"1" , @"item_count" : [NSString stringWithFormat:@"%d",ITEMS_SPIFFY_PER_PAGE]};
    //NSDictionary *parameters = @{@"userID": userId, @"page_number" : @"1" , @"item_count" : @"10"};
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSError *error = nil;
         
         NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
         if (error) {
             NSLog(@"Error serializing %@", error);
         }
         else
         {
             //NSLog(@"%@",JSON);
             
             if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
             {
                 [UIAppDelegate.photoArray removeAllObjects];
                 
                 NSArray *listArray = [JSON objectForKey:@"result"];
                 
                 for (NSDictionary *listDic in listArray)
                 {
                     MemePhoto *memePhoto = [[MemePhoto alloc] init];
                     
                     memePhoto.photoID = [listDic objectForKey:@"id"];
                     memePhoto.photoTitle = [listDic objectForKey:@"title"];
                     memePhoto.photoLike = [listDic objectForKey:@"like"];
                     memePhoto.photoMyLike = [listDic objectForKey:@"isMyLike"];
                     memePhoto.photoMyFavorite = [listDic objectForKey:@"isMyFavorite"];
                     memePhoto.url = [listDic objectForKey:@"url"];
                     memePhoto.photoUploaddate = [listDic objectForKey:@"upload_date"];
                     memePhoto.baseURL = [JSON objectForKey:@"base_url"];
                     memePhoto.photoURL = [memePhoto.baseURL stringByAppendingString:memePhoto.url];
                     
                     BOOL test = [dbhelper isMemeIdExist:memePhoto.photoID];
                     if (!test)
                     {
                         [dbhelper insertWithMemeID:memePhoto.photoID
                                          likeCount:memePhoto.photoLike withCategory:@"4"];
                     }
                     
                     [UIAppDelegate.photoArray addObject:memePhoto];
                 }
                 
                 
                 NSLog(@"photoArray.count%lu",(unsigned long)UIAppDelegate.photoArray.count);
                 
                 if(UIAppDelegate.photoArray.count > 0)
                 {
                     MemesSwipeView *swipeView = [[MemesSwipeView alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"SpiffyGifSwipeVC"] bundle:nil];
                     
                     MemePhoto *aPhoto = [UIAppDelegate.photoArray lastObject];
                     [UIAppDelegate.photoArray addObject:aPhoto];
                     
                     [swipeView setImageArray:UIAppDelegate.photoArray];
                     [swipeView setImageIndex:0];
                     [swipeView setPageNumber:2];
                     [swipeView setTotalMeme:[[JSON objectForKey:@"total"] integerValue]];
                     [swipeView setControllerIdentifier:5];
                     
                     [self.navigationController pushViewController:swipeView animated:YES];
                 }
                 [UIAppDelegate activityHide];
             }
             else
             {
                 [UIAppDelegate activityHide];
             }
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         [UIAppDelegate activityHide];
     }];
}


#pragma mark - Get icon view for feature name
- (UIView *)getViewForFeatureName:(NSString *)featureName
{
    UIView *iconView;
    if ([featureName isEqualToString:MEME_FOR_EVERYONE])
    {
        _memeForEveryOneView = [[UIView alloc] init];
        iconView = _memeForEveryOneView;
    }
    else if ([featureName isEqualToString:MOTIVATIONAL_INSPIRATIONAL])
    {
        _motivationalView = [[UIView alloc] init];
        iconView = _motivationalView;
    }
    else if ([featureName isEqualToString:RACY_MEMES])
    {
        _racyMemeView = [[UIView alloc] init];
        iconView = _racyMemeView;
    }
    else if ([featureName isEqualToString:SPIFFY_GIFS])
    {
        _spiffyGifsView = [[UIView alloc] init];
        iconView = _spiffyGifsView;
    }
    else if ([featureName isEqualToString:TRENDING_POPULAR])
    {
        _trendingView = [[UIView alloc] init];
        iconView = _trendingView;
    }
    else if ([featureName isEqualToString:UPLOAD_AWESOME_MEME])
    {
        _uploadView = [[UIView alloc] init];
        iconView = _uploadView;
    }
    else if ([featureName isEqualToString:SAVED_FAVORITES])
    {
        _favoriteView = [[UIView alloc] init];
        iconView = _favoriteView;
    }
    else if ([featureName isEqualToString:REMOVE_ADS])
    {
        _removeAdsView = [[UIView alloc] init];
        iconView = _removeAdsView;
    }
    else if ([featureName isEqualToString:SINGLE_DAD_LAUGHING])
    {
        _singleDadView = [[UIView alloc] init];
        iconView = _singleDadView;
    }
    return iconView;
}

//Change Date: 9-Feb-2015
#pragma mark - Notification Handler
-(void)updateFavoriteCounter
{
    if (self.favoriteView)
    {
        for (UIView *view in [self.favoriteView subviews])
        {
            if ([view isKindOfClass:[UILabel class]])
            {
                [(UILabel *)view setText:[NSString stringWithFormat:@"Your Saved Favorites (%ld)",(long)UIAppDelegate.userFavouriteNumber]];
            }
        }
    }
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


























