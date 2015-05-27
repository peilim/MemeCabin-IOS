//
//  TrendingViewController.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 27/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "TrendingViewController.h"
#import "HomeScreenViewController.h"
#import "PreferenceViewController.h"
#import "FavoriteViewController.h"

#import "TrendingDetailView.h"

#import "MenuView.h"

@interface TrendingViewController ()

{
    MenuView *menuView;
    AppDelegate *appdelegate;
    BOOL isButtonClicked;
    UIView *rightSideView;
    
    CustomBadge *badgeForAllMeme;
}

@end

@implementation TrendingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)updateBottomBadgeCount
{
    [badgeForAllMeme removeFromSuperview];
    
    NSString *badgeString = nil;
    if ((UIAppDelegate.currentBadgeMemeEveryOne+UIAppDelegate.currentBadgeMemeMotiInsp+UIAppDelegate.currentBadgeMemeRacy+UIAppDelegate.currentBadgeMemeSpiffyGif) > 0) {
        if ((UIAppDelegate.currentBadgeMemeEveryOne+UIAppDelegate.currentBadgeMemeMotiInsp+UIAppDelegate.currentBadgeMemeRacy+UIAppDelegate.currentBadgeMemeSpiffyGif) > 99)
        {
            badgeString = @"99+";
        }
        else
        {
            badgeString = [NSString stringWithFormat:@"%ld",(UIAppDelegate.currentBadgeMemeEveryOne+UIAppDelegate.currentBadgeMemeMotiInsp+UIAppDelegate.currentBadgeMemeRacy+UIAppDelegate.currentBadgeMemeSpiffyGif)];
        }
        badgeForAllMeme = [CustomBadge customBadgeWithString:badgeString
                                             withStringColor:[UIColor whiteColor]
                                              withInsetColor:[UIColor redColor]
                                              withBadgeFrame:YES
                                         withBadgeFrameColor:[UIColor whiteColor]
                                                   withScale:1.0
                                                 withShining:YES];
        
        [badgeForAllMeme setFrame:
         CGRectMake(_backToHomeButton.frame.size.width-badgeForAllMeme.frame.size.width/2,
                    -5,
                    badgeForAllMeme.frame.size.width,
                    badgeForAllMeme.frame.size.height)];
        [_backToHomeButton addSubview:badgeForAllMeme];
    }
    else
        [badgeForAllMeme removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    isButtonClicked = NO;
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (IS_IPHONE) {
        if (IS_IPHONE_4INCHES) {
            menuView = [[MenuView alloc] initWithFrame:CGRectMake(320, 0,
                                                                  menuView.frame.size.width,
                                                                  menuView.frame.size.height)];
            menuView.frame = CGRectMake(320, 0, 274, 568);
        }
        else
        {
            menuView = [[MenuView alloc] initWithFrame:CGRectMake(320, 0,
                                                                  menuView.frame.size.width,
                                                                  menuView.frame.size.height)];
            menuView.frame = CGRectMake(320, 0, 274, 480);
        }
    }
    else
    {
        menuView = [[MenuView alloc] initWithFrame:CGRectMake(768, 0,
                                                              menuView.frame.size.width,
                                                              menuView.frame.size.height)];
        menuView.frame = CGRectMake(768, 0, 658, 1024);
    }
    
    //Menu Dismiss
    [menuView.dismissSlideButton addTarget:self action:@selector(dismissSlideMenuButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:menuView];
    
    CGRect rightSideViewFrame;
    if (IS_IPAD) {
        rightSideViewFrame = CGRectMake(0, 0, 110, 1024);
    }
    else
    {
        if (IS_IPHONE_4INCHES)
            rightSideViewFrame = CGRectMake(0, 0, 46, 568);
        else
            rightSideViewFrame = CGRectMake(0, 0, 46, 480);
    }
    
    rightSideView = [[UIView alloc] init];
    rightSideView.frame = rightSideViewFrame;
    rightSideView.backgroundColor = [UIColor clearColor];
    
    UIButton *rightViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightViewButton.frame = rightSideViewFrame;
    [rightViewButton addTarget:self action:@selector(dismissSlideMenuButtonAction)
              forControlEvents:UIControlEventTouchUpInside];
    
    [rightSideView addSubview:rightViewButton];
    [self.view addSubview:rightSideView];
    rightSideView.hidden = YES;
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[GoogleAnalyticsCustom getSharedInstance] setCurrentScreenName:@"Trending-Menu Screen"];
    
    if([UIAppDelegate isProUser])
    {
        //hideAdMob];
        [UIAppDelegate hideFlurryAd];
    }
    else
    {
        [UIAppDelegate addFlurryInView:_myView];
    }
    
    [self updateBottomBadgeCount];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[UIAppDelegate hideiAdinView];
}

#pragma mark Button Actions

- (IBAction)todaysTopAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Today's Top Meme Button Clicked"];
    
    TrendingDetailView *viewController =[[TrendingDetailView alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"TrendingDetailView"] bundle:nil];
    
    [viewController setTitleStr:@"Top Memes: Last 24 Hours"];
    [viewController setTopMemeByDays:1];
    
    [self.navigationController pushViewController:viewController animated:YES];
}
- (IBAction)topMemesSevenAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Seven Day,s Top Meme Button Clicked"];
    
    TrendingDetailView *viewController =[[TrendingDetailView alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"TrendingDetailView"] bundle:nil];
    
    [viewController setTitleStr:@"Top Memes: Last 7 Days"];
    [viewController setTopMemeByDays:7];
    
    [self.navigationController pushViewController:viewController animated:YES];
}
- (IBAction)topMemesThirtyAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Thirty Day's Top Meme Button Clicked"];
    
    TrendingDetailView *viewController =[[TrendingDetailView alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"TrendingDetailView"] bundle:nil];
    
     [viewController setTitleStr:@"Top Memes: Last 30 Days"];
    [viewController setTopMemeByDays:30];
    
    [self.navigationController pushViewController:viewController animated:YES];
}
- (IBAction)topMemesNinetyAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Ninety Day's Top Meme Button Clicked"];
    
    TrendingDetailView *viewController =[[TrendingDetailView alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"TrendingDetailView"] bundle:nil];
    
     [viewController setTitleStr:@"Top Memes: Last 90 Days"];
    [viewController setTopMemeByDays:90];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

//Top Bar Actions
- (IBAction)backButtonAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)menuButtonAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Menu Button Clicked"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED]) {
        //menuView.logoutButton.hidden = YES;
        [menuView.logoutLabel setText:@"LOGIN"];
    }
    else {
        //menuView.logoutButton.hidden = NO;
        [menuView.logoutLabel setText:@"LOGOUT"];
    }
    
    if (isButtonClicked)
    {
        isButtonClicked = NO;
    }
    
    if (sender.tag == 100) {
        rightSideView.hidden = YES;
        _menuButton.tag = 101;
        [UIAppDelegate moveView1:menuView andView2:_myView moveLeft:YES];
        
        if ([UIAppDelegate isProUser])
        {
            [UIAppDelegate.obj_FlurryAd removeFromSuperview];            
        }
    }
    else
    {
        rightSideView.hidden = NO;
        _menuButton.tag = 100;
        [UIAppDelegate moveView1:menuView andView2:_myView moveLeft:NO];
    }
}


//Lower Bar Actions
- (IBAction)backToHomeButtonAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Home Button Clicked"];
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[HomeScreenViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (IBAction)preferenceButtonAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Preference On Facebok Button Clicked"];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PreferenceViewController *viewController = [[PreferenceViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"PreferenceViewController"] bundle:nil];
    
    UINavigationController *navContrl = [[UINavigationController alloc] initWithRootViewController:viewController];
    navContrl.navigationBarHidden = YES;
    
    [appDelegate.navigationController presentViewController:navContrl animated:YES completion:nil];
}

- (IBAction)favoriteButtonAction:(UIButton *)sender
{
//    FavoriteViewController *viewController = [[FavoriteViewController alloc] initWithNibName:@"FavoriteViewController" bundle:nil];
//    
//    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)dismissSlideMenuButtonAction
{
    NSLog(@"TrendingViewController dismissSlideMenu tapped!!");
    
    if (isButtonClicked) {
        isButtonClicked = NO;
        return;
    }
    
    _menuButton.tag = 101;
    rightSideView.hidden = YES;
    [UIAppDelegate moveView1:menuView andView2:_myView moveLeft:YES];
    
    if ([UIAppDelegate isProUser])
    {
        [UIAppDelegate.obj_FlurryAd removeFromSuperview];
    }
}


#pragma mark Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

