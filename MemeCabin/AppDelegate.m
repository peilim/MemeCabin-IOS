//
//  AppDelegate.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 26/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeScreenViewController.h"
#import "LoginViewController.h"

#import "MemePhoto.h"
#import "iRate.h"
#import "DanMessagePopup.h"
#import "MCHTTPManager.h"

#import "MKStoreKit.h"
#import <CommonCrypto/CommonDigest.h>
#import <FacebookSDK/FacebookSDK.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "SVProgressHUD.h"

static UIViewController *rootController;

@implementation AppDelegate
{
}
@synthesize obj_FlurryAd;
@synthesize bannerIsVisible;
@synthesize flurryAdBannerView,flurryAdFullScreenView,bannerAdViewAdded,fullScreenIsVisible,fullScreenAdViewAdded,isFlurryCurrent,isFlurryAdVisible;
@synthesize isFromHome;
@synthesize currentBadgeMemeEveryOne,currentBadgeMemeMotiInsp,currentBadgeMemeRacy,currentBadgeMemeSpiffyGif,newMemeEveryOneCount,newMemeMotiInspCount,newMemeRacyCount,newMemeSpiffyCount,userFavouriteNumber,obj_FlurryAdBanner,obj_FlurryAdInterstitial,popTipView,obj_GadAdBanner,obj_GadInterstitial,isNewlyLaunched;

+ (void)initialize
{
    //set the bundle ID. normally you wouldn't need to do this
    //as it is picked up automatically from your Info.plist file
    //but we want to test with an app that's actually on the store
    [iRate sharedInstance].applicationBundleID = @"com.app.memecabin";//@"com.charcoaldesign.rainbowblocks-free";
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 15;
    
    //enable preview mode
    [iRate sharedInstance].previewMode = NO;
}

-(void)initializeMkStoreKit
{
    [[MKStoreKit sharedKit] startProductRequest];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Products available: %@", [[MKStoreKit sharedKit] availableProducts]);
                                                  }];
    
    
    /*[[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
     object:nil
     queue:[[NSOperationQueue alloc] init]
     usingBlock:^(NSNotification *note) {
     
     NSLog(@"Purchased/Subscribed to product with id: %@", [note object]);
     
     NSLog(@"%@", [[MKStoreKit sharedKit] valueForKey:@"purchaseRecord"]);
     }];*/
    
    /*[[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoredPurchasesNotification
     object:nil
     queue:[[NSOperationQueue alloc] init]
     usingBlock:^(NSNotification *note) {
     
     NSLog(@"Restored Purchases");
     }];*/
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoringPurchasesFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Failed restoring purchases with error: %@", [note object]);
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitSubscriptionExpiredNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Purchased Item expired!!: %@", [note object]);
                                                  }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Test commit
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    _ITEMS_PER_PAGE = 40;
    self.photoArray = [[NSMutableArray alloc] init];
    self.pageNumberRequest = 0;
    
    sleep(2);
    
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"AllMemesLoaded"] &&
//        ![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLaunch"])
//    {
//        [self loadAllMemesIntoDB];
//    }
    
    self.isNewlyLaunched = YES;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil]];
    }
    
    [[UITableView appearance] setBackgroundColor:[UIColor clearColor]];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLaunch"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLaunch"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", (int) [[NSDate date] timeIntervalSince1970]] forKey:@"FirstLaunchTime"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //********* NEW ************
        [self enableAllFeatureOnDashBoard];
    }
    
    /*
    //For Test Hemal
    [[NSUserDefaults standardUserDefaults] setObject:@"1419673526" forKey:@"FirstLaunchTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];*/
    
    NSLog(@"Installation Date: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstLaunchTime"]);
    
    NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] objectForKey:CHECK_FOR_USER_INFO];
    NSString *userId = [userInfoDisct objectForKey:@"userId"];
    if(userId.length==0)
        userId=@"";
    [UIAppDelegate checkForAppUpdateWithDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstLaunchTime"]
                                   andUserId:userId];
    NSDictionary *aDictionary = [NSDictionary dictionaryWithObjects:@[[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstLaunchTime"],userId] forKeys:@[@"aDate",@"aUserId"]];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:20
                                                        target:self
                                                      selector:@selector(checkForUpdatedContent:)
                                                      userInfo:aDictionary
                                                       repeats:YES];
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background handler called. Not running background tasks anymore.");
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    
    
    
    //DB
    dbhelper = [[DBHelper alloc] init];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[dbhelper getDbFilePath]])
    {
        [dbhelper createTable:[dbhelper getDbFilePath]];
    }
    //DB
    
    
    [Flurry startSession:FlurryADId];
    //\\[FlurryAds initialize:self.window.rootViewController];

    
    [self initializeMkStoreKit];
    
    //NSLog(@"[dbhelper getSavedFavourites]=%ld",(long)[dbhelper getSavedFavourites]);
    //_savedFavourites = [dbhelper getSavedFavourites];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_LOGIN]) {
        
        LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"LoginViewController"] bundle:nil];
        self.isFromHome = NO;
        _navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CHECK_FOR_IS_SKIPPED];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        HomeScreenViewController *homeController = [[HomeScreenViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"HomeScreenViewController"] bundle:nil];
        self.isFromHome = YES;
        _navigationController = [[UINavigationController alloc] initWithRootViewController:homeController];
    }
    
    self.isFromAppDelegate = YES;
    _navigationController.navigationBarHidden = YES;
    self.window.rootViewController = _navigationController;
    
    //UIAppDelegate.bannerIsVisible = YES;
    
    if([self daysRemainingOnSubscription:[[NSUserDefaults standardUserDefaults] objectForKey:PURCHASE_DATE]]== 0)
    {
        [self removeProUser];
    }
    
    if (![self isProUser])
    {
        [self addFlurryAd];
        //[self addAdMob];
        /*
        if(!UIAppDelegate.bannerAdViewAdded)
        {
            [self addFlurryAd];
            UIAppDelegate.bannerAdViewAdded = YES;
        }
        else
        {
            if(UIAppDelegate.bannerIsVisible)
            {
                [self.window.rootViewController.view addSubview:UIAppDelegate.obj_FlurryAd];
            }
            else
            {
                [self addFlurryAd];
                UIAppDelegate.bannerAdViewAdded = YES;
            }
        }
        */
    }
    else
    {
        //[self hideAdMob];
        [self hideFlurryAd];
    }
    
    [self.window makeKeyAndVisible];
    
    [Fabric with:@[CrashlyticsKit]];
    return YES;
}

-(int)daysRemainingOnSubscription:(NSString*)dateString
{
    NSDateFormatter *dateformatter = [NSDateFormatter new];
    [dateformatter setDateFormat:@"dd-MM-yyyy"];
    
    //NSDate * expiryDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"PurchaseExpirationDate"];
    NSDate * expiryDate = [dateformatter dateFromString:dateString];
    
    
    NSTimeInterval timeInt = [[dateformatter dateFromString:[dateformatter stringFromDate:expiryDate]] timeIntervalSinceDate: [dateformatter dateFromString:[dateformatter stringFromDate:[NSDate date]]]]; //Is this too complex and messy?
    int days = timeInt / 60 / 60 / 24;
    
    if (days >= 0) {
        return days;
    } else {
        return 0;
    }
}

#pragma mark - Public method implementation
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI forPermission:(int)permissionType
{
    NSLog(@"openSessionWithAllowLoginUI");
    BOOL openSessionResult = NO;
    NSArray *_permisssion=nil;
    if(EMAIL==permissionType)
        _permisssion=[NSArray arrayWithObjects:@"email",@"user_friends",nil];
    
    FBSession *session = [[FBSession alloc] initWithAppID:nil
                                              permissions:_permisssion
                                          urlSchemeSuffix:nil
                                       tokenCacheStrategy:nil];
    
    
    
    // If showing the login UI, or if a cached token is available,
    // then open the session.
    if (allowLoginUI || session.state == FBSessionStateCreatedTokenLoaded) {
        // For debugging purposes log if cached token was found
        if (session.state == FBSessionStateCreatedTokenLoaded) {
            //VVLog(@"Cached token found.");
        }
        // Set the active session
        [FBSession setActiveSession:session];
        // Open the session.
        [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                completionHandler:^(FBSession *session,
                                    FBSessionState state,
                                    NSError *error)
         {
             
             [self sessionStateChanged:session
                                 state:state
                                 error:error permission:permissionType];
             
         }];
        // Return the result - will be set to open immediately from the session
        // open call if a cached token was previously found.
        openSessionResult = session.isOpen;
        
        
    }
    return openSessionResult;
    self.isFromAppDelegate = YES;
}

- (void)FbUserDictionary:(NSDictionary*)dict
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FACEBOOK_LOGIN_SUCCESS" object:dict];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error permission:(int)permissionType
{
    
    switch (state)
    {
            
        case FBSessionStateOpen: {
            // Handle the logged in scenario
            
            // You may wish to show a logged in view
            //VVLog(@"facebook FBSessionStateOpen  %@  permissionType %d",FBSession.activeSession.accessTokenData.accessToken,permissionType);
            //VVLog(@">>>>>>>>>>>>>>>*********************** access token %@",FBSession.activeSession.accessTokenData.accessToken );
            
            [[NSUserDefaults standardUserDefaults] setObject:FBSession.activeSession.accessTokenData.accessToken forKey:@"FBAccessTokenKey"];
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"FACEBOOK_USER_INFO_DONE"]==nil)
            {
                [[FBRequest requestForMe] startWithCompletionHandler:
                 ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                     if (!error) {
                         [self FbUserDictionary:user];
                     }
                     else
                     {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alertView show];
                     }
                     
                 }];
            }
            
            
            
            break;
        }
        case FBSessionStateClosed:
        {
            //VVLog(@"facebook FBSessionStateClosed");
            // Close the active session
            // [FBSession.activeSession closeAndClearTokenInformation];
            
        }
        case FBSessionStateClosedLoginFailed:
        {
            // Handle the logged out scenario
            //VVLog(@"facebook FBSessionStateClosedLoginFailed");
            //  [[NSNotificationCenter defaultCenter]postNotificationName:@"HIDE_PROGRESS_VIEW_8" object:nil];
            // You may wish to show a logged out view
            
            break;
        }
        default:
            break;
        
    }
    
    
    if (error)
    {
        [self handleAuthReopenError:error];
    }
}

- (void)handleAuthReopenError:(NSError *)error{
    NSString *alertMessage = nil, *alertTitle = nil;
    //NSLog(@"facebook error %@",error);
    
    if (error.fberrorShouldNotifyUser) {
        if ([[error userInfo][FBErrorLoginFailedReason]
             isEqualToString:FBErrorLoginFailedReasonSystemDisallowedWithoutErrorValue]) {
            // Show a different error message
            alertTitle = @"App Disabled";
            alertMessage = @"Go to Settings > Facebook and turn ON MemeCabin.";
            // Perform any additional customizations
        } else {
            // If the SDK has a message for the user, surface it.
            alertTitle = @"Something Went Wrong";
            alertMessage = error.fberrorUserMessage;
        }
    }
    else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        NSInteger underlyingSubCode = [[error userInfo]
                                       [@"com.facebook.sdk:ParsedJSONResponseKey"]
                                       [@"body"]
                                       [@"error"]
                                       [@"error_subcode"] integerValue];
        if (underlyingSubCode == 458) {
            alertTitle = @"Something Went Wrong";
            alertMessage = @"The app was removed. Please log in again.";
        } else {
            alertTitle = @"Something Went Wrong";
            alertMessage = @"Your current session is no longer valid. Please log in again.";
        }
    }
    
    if (alertMessage)
    {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alerView show];
    }
}

-(BOOL)isFBSessionValid
{
    if(FBSession.activeSession.isOpen)
        return YES;
    else
        return NO;
}

-(void) createfacebookinstance:(int)permissionType
{
    NSLog(@"createfacebookinstance");
    if (FBSession.activeSession.isOpen==NO  || [ FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound)
    {
        [self openSessionWithAllowLoginUI:YES forPermission:permissionType];
    }
    
}

-(void)signInWithFacebook
{
    
    if (![self isFBSessionValid])
    {
        [self createfacebookinstance:EMAIL];
        NSLog(@"(![self isFBSessionValid])");
    }
    else
    {
        NSLog(@"signInWithFacebook");
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self signInWithFacebook];
            // If the session state is not any of the two "open" states when the button is clicked
        }
    }
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
// Override application:openURL:sourceApplication:annotation to call the FBsession object that handles the incoming URL
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        //[self openSessionWithAllowLoginUI:NO forPermission:0];
    }
    
    [FBAppCall handleDidBecomeActive];
    [FBSession.activeSession handleDidBecomeActive];
    
    [self checkForDeletedMemes];
    [self checkForUpdatedContent:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (BOOL)isNetworkAvailable
{
    //Checking Network rechability
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable)
    {
        return  NO;
    }
    else
        return YES;
    
    return NO;
}

-(void)checkForAppUpdateWithDate:(NSString *)installationdate andUserId:(NSString *)userId
{
    NSString *urlString = MEME_UPCOMMING_APP_LINK;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"type": @"ios",@"date": installationdate,@"userID":userId};
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Sample logic to check login status
        
        NSError *error = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error)
            NSLog(@"Error serializing %@", error);
        
        else
            if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
            {
                NSLog(@"%@",JSON);
                NSString *EveryoneMeme = [JSON objectForKey:@"total_everyoneMemes"];
                NSString *MotivationalMeme = [JSON objectForKey:@"total_motivationalMemes"];
                NSString *RacyMeme = [JSON objectForKey:@"total_racyMemes"];
                NSString *SpiffyGifs = [JSON objectForKey:@"total_spiffyMemes"];
                
                NSString *FavouriteNumber = [JSON objectForKey:@"total_myFavourite"];
                
                NSInteger aFavCount = [FavouriteNumber integerValue];
                self.userFavouriteNumber = ((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? ((aFavCount >= [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT]) ?  aFavCount : [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT]) : aFavCount;
                
                [[NSUserDefaults standardUserDefaults] setInteger:self.userFavouriteNumber forKey:MEME_FAVORITE_CURRENT_COUNT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //Change Date: 9-Feb-2015
                [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_FAVORITE_COUNTER_NOTIF" object:nil];
                
                //[[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.userFavouriteNumber forKey:MEME_FAVORITE_CURRENT_COUNT];
                //[[NSUserDefaults standardUserDefaults] synchronize];
               self.userFavouriteNumber = [[NSString stringWithFormat:@"%@",FavouriteNumber] integerValue];
                
                self.newMemeEveryOneCount = [EveryoneMeme integerValue] - [[NSUserDefaults standardUserDefaults] integerForKey:MEME_EVERYONE_SERVER_COUNT] ;
                self.newMemeMotiInspCount =  [MotivationalMeme integerValue] - [[NSUserDefaults standardUserDefaults] integerForKey:MEME_MOTI_INSP_SERVER_COUNT] ;
                self.newMemeRacyCount =  [RacyMeme integerValue] - [[NSUserDefaults standardUserDefaults] integerForKey:MEME_RACY_SERVER_COUNT] ;
                self.newMemeSpiffyCount = [SpiffyGifs integerValue] - [[NSUserDefaults standardUserDefaults] integerForKey:MEME_SPIFFY_GIFS_SERVER_COUNT];
                
                [[NSUserDefaults standardUserDefaults] setInteger:[EveryoneMeme integerValue] forKey:MEME_EVERYONE_SERVER_COUNT];
                [[NSUserDefaults standardUserDefaults] setInteger:[MotivationalMeme integerValue] forKey:MEME_MOTI_INSP_SERVER_COUNT];
                [[NSUserDefaults standardUserDefaults] setInteger:[RacyMeme integerValue] forKey:MEME_RACY_SERVER_COUNT];
                [[NSUserDefaults standardUserDefaults] setInteger:[SpiffyGifs integerValue] forKey:MEME_SPIFFY_GIFS_SERVER_COUNT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                [self setAllBadgesCountForApplication];
                /*
                 NSInteger EveryoneMemeCount = ([[NSString stringWithFormat:@"%@",EveryoneMeme] integerValue]);
                 NSInteger EveryoneMemeCountDB = [dbhelper getViewCounterWithCategory:@"1"];
                 _badgeEveryoneMeme = EveryoneMemeCount - EveryoneMemeCountDB;
                 
                 NSInteger MotivationalMemeCount = ([[NSString stringWithFormat:@"%@",MotivationalMeme] integerValue]);
                 NSInteger MotivationalMemeCountDB = [dbhelper getViewCounterWithCategory:@"2"];
                 _badgeMotivationalMeme = MotivationalMemeCount - MotivationalMemeCountDB;
                 
                 NSInteger RacyMemeCount = ([[NSString stringWithFormat:@"%@",RacyMeme] integerValue]);
                 NSInteger RacyMemeCountDB = [dbhelper getViewCounterWithCategory:@"3"];
                 _badgeRacyMeme = RacyMemeCount - RacyMemeCountDB;
                 
                 
                 NSLog(@"_userFavouriteNumber=%ld",(long)_userFavouriteNumber);
                 
                 NSInteger totalBadgeCount = _badgeEveryoneMeme+_badgeMotivationalMeme+_badgeRacyMeme;
                 
                 if (totalBadgeCount > 0) {
                 [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalBadgeCount];
                 }
                 */
                
            }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [self setAllBadgesCountForApplication];
    }];
    
}


-(void)checkForUpdatedContent:(NSTimer *)aTimer
{
    @autoreleasepool {
        
        //NSLog(@"Timer User Info: %@",aTimer.userInfo);
        
        NSDictionary *aDictionary = aTimer.userInfo;
        NSString *installationdate = [aDictionary objectForKey:@"aDate"];
    
        NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
        NSString *userId = [userInfoDisct objectForKey:@"userId"];
    
        if(installationdate.length == 0)
            installationdate = @"";
        if(userId.length ==0)
            userId = @"";
        
        
        
        NSString *urlString = MEME_UPCOMMING_APP_LINK;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer new];
        serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
        manager.responseSerializer = serializer; //[AFHTTPResponseSerializer serializer];
        NSDictionary *parameters = @{@"type": @"ios",@"date": installationdate,@"userID":userId};
        
        [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //Sample logic to check login status
            
            NSError *error = nil;
            NSDictionary *JSON = (NSDictionary *)responseObject;//[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            if (error)
                NSLog(@"Error serializing %@", error);
            
            else
                if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
                {
                    NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
                    
                    //NSLog(@"USER_ID=%@, Response=%@",[userInfoDisct objectForKey:@"userId"],JSON);
                    
                    NSString *EveryoneMeme = [JSON objectForKey:@"total_everyoneMemes"];
                    NSString *MotivationalMeme = [JSON objectForKey:@"total_motivationalMemes"];
                    NSString *RacyMeme = [JSON objectForKey:@"total_racyMemes"];
                    NSString *SpiffyGifs = [JSON objectForKey:@"total_spiffyMemes"];
                    
                    NSString *FavouriteNumber = [JSON objectForKey:@"total_myFavourite"];
                    NSInteger aFavCount = [FavouriteNumber integerValue];
                    self.userFavouriteNumber = ((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? ((aFavCount >= [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT]) ?  aFavCount : [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT]) : aFavCount;
                    
                    [[NSUserDefaults standardUserDefaults] setInteger:self.userFavouriteNumber forKey:MEME_FAVORITE_CURRENT_COUNT];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    self.newMemeEveryOneCount = [EveryoneMeme integerValue] - [[NSUserDefaults standardUserDefaults] integerForKey:MEME_EVERYONE_SERVER_COUNT] ;
                    self.newMemeMotiInspCount =  [MotivationalMeme integerValue] - [[NSUserDefaults standardUserDefaults] integerForKey:MEME_MOTI_INSP_SERVER_COUNT] ;
                    self.newMemeRacyCount =  [RacyMeme integerValue] - [[NSUserDefaults standardUserDefaults] integerForKey:MEME_RACY_SERVER_COUNT] ;
                    self.newMemeSpiffyCount = [SpiffyGifs integerValue] - [[NSUserDefaults standardUserDefaults] integerForKey:MEME_SPIFFY_GIFS_SERVER_COUNT];
                    
                    /*
                    NSInteger previousServerCountEvery = [[NSUserDefaults standardUserDefaults] integerForKey:MEME_EVERYONE_SERVER_COUNT];
                    NSInteger previousServerCountMoti = [[NSUserDefaults standardUserDefaults] integerForKey:MEME_MOTI_INSP_SERVER_COUNT];
                    NSInteger previousServerCountRacy = [[NSUserDefaults standardUserDefaults] integerForKey:MEME_RACY_SERVER_COUNT];
                    
                    self.currentBadgeMemeEveryOne = [[NSUserDefaults standardUserDefaults] integerForKey:MEME_EVERYONE_CURRENT_COUNT];
                    self.currentBadgeMemeMotiInsp = [[NSUserDefaults standardUserDefaults] integerForKey:MEME_MOTI_INSP_CURRENT_COUNT];
                    self.currentBadgeMemeRacy = [[NSUserDefaults standardUserDefaults] integerForKey:MEME_RACY_CURRENT_COUNT];
                    
                    NSInteger tempEvery = [EveryoneMeme integerValue] < previousServerCountEvery ?( self.currentBadgeMemeEveryOne - (previousServerCountEvery -[EveryoneMeme integerValue])) : 0;
                    NSInteger tempMoti = [MotivationalMeme integerValue] < previousServerCountMoti ?( self.currentBadgeMemeMotiInsp - (previousServerCountMoti -[MotivationalMeme integerValue])) : 0;
                    NSInteger tempRacy = [RacyMeme integerValue] < previousServerCountRacy ?( self.currentBadgeMemeRacy - (previousServerCountRacy -[RacyMeme integerValue])) : 0;
                    
                    
                    
                    
                    self.currentBadgeMemeEveryOne = tempEvery > 0 ? self.currentBadgeMemeEveryOne - tempEvery : self.currentBadgeMemeEveryOne;
                    self.currentBadgeMemeMotiInsp = tempMoti > 0 ? self.currentBadgeMemeMotiInsp - tempMoti : self.currentBadgeMemeMotiInsp;
                    self.currentBadgeMemeRacy = tempRacy > 0 ? self.currentBadgeMemeRacy - tempRacy : self.currentBadgeMemeRacy;
                    
                    [[NSUserDefaults standardUserDefaults] setInteger:self.currentBadgeMemeEveryOne forKey:MEME_EVERYONE_CURRENT_COUNT];
                    [[NSUserDefaults standardUserDefaults] setInteger:self.currentBadgeMemeMotiInsp forKey:MEME_MOTI_INSP_CURRENT_COUNT];
                    [[NSUserDefaults standardUserDefaults] setInteger:self.currentBadgeMemeRacy forKey:MEME_RACY_CURRENT_COUNT];
                    [[NSUserDefaults standardUserDefaults] synchronize];*/
                    
                    [[NSUserDefaults standardUserDefaults] setInteger:[EveryoneMeme integerValue] forKey:MEME_EVERYONE_SERVER_COUNT];
                    [[NSUserDefaults standardUserDefaults] setInteger:[MotivationalMeme integerValue] forKey:MEME_MOTI_INSP_SERVER_COUNT];
                    [[NSUserDefaults standardUserDefaults] setInteger:[RacyMeme integerValue] forKey:MEME_RACY_SERVER_COUNT];
                    [[NSUserDefaults standardUserDefaults] setInteger:[SpiffyGifs integerValue] forKey:MEME_SPIFFY_GIFS_SERVER_COUNT];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                    [self setAllBadgesCountForApplication];
                    /*
                     NSInteger EveryoneMemeCount = ([[NSString stringWithFormat:@"%@",EveryoneMeme] integerValue]);
                     NSInteger EveryoneMemeCountDB = [dbhelper getViewCounterWithCategory:@"1"];
                     _badgeEveryoneMeme = EveryoneMemeCount - EveryoneMemeCountDB;
                     
                     NSInteger MotivationalMemeCount = ([[NSString stringWithFormat:@"%@",MotivationalMeme] integerValue]);
                     NSInteger MotivationalMemeCountDB = [dbhelper getViewCounterWithCategory:@"2"];
                     _badgeMotivationalMeme = MotivationalMemeCount - MotivationalMemeCountDB;
                     
                     NSInteger RacyMemeCount = ([[NSString stringWithFormat:@"%@",RacyMeme] integerValue]);
                     NSInteger RacyMemeCountDB = [dbhelper getViewCounterWithCategory:@"3"];
                     _badgeRacyMeme = RacyMemeCount - RacyMemeCountDB;
                     
                     
                     NSLog(@"_userFavouriteNumber=%ld",(long)_userFavouriteNumber);
                     
                     NSInteger totalBadgeCount = _badgeEveryoneMeme+_badgeMotivationalMeme+_badgeRacyMeme;
                     
                     if (totalBadgeCount > 0) {
                     [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalBadgeCount];
                     }
                     */
                    
                }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            
            [self setAllBadgesCountForApplication];
        }];
    }
    
}


-(void)checkForDeletedMemes
{
    /*
    NSString *urlString = MEME_DELETED_LIST;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = nil;//@{@"type": @"ios",@"date": installationdate,@"userID":userId};
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Sample logic to check login status
        
        NSError *error = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error)
            NSLog(@"Error serializing %@", error);
        
        else
            if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
            {
                NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
                
                NSLog(@"USER_ID=%@, Response=%@",[userInfoDisct objectForKey:@"userId"],JSON);
                
                
                NSArray *aArray = [JSON objectForKey:@"result"];
                self.currentBadgeMemeEveryOne = (((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_EVERYONE_CURRENT_COUNT] != [NSNull null]) ? [[NSUserDefaults standardUserDefaults] integerForKey:MEME_EVERYONE_CURRENT_COUNT] : 0);
                
                self.currentBadgeMemeMotiInsp = (((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_MOTI_INSP_CURRENT_COUNT] != [NSNull null]) ? [[NSUserDefaults standardUserDefaults] integerForKey:MEME_MOTI_INSP_CURRENT_COUNT] : 0);
                
                self.currentBadgeMemeRacy = (((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_RACY_CURRENT_COUNT] != [NSNull null]) ? [[NSUserDefaults standardUserDefaults] integerForKey:MEME_RACY_CURRENT_COUNT] : 0);
                
                
                NSDictionary *aDictionary = [dbhelper updateMemeViewsForMemeIds:aArray.count > 0 ? aArray : nil];
                NSInteger everyCount = [[aDictionary objectForKey:EVERYONE_MEME] integerValue];
                NSInteger motivCount = [[aDictionary objectForKey:MOTIVATIONAL_MEME] integerValue];
                NSInteger racyCount = [[aDictionary objectForKey:RACY_MEME] integerValue];
                
                self.currentBadgeMemeEveryOne = self.currentBadgeMemeEveryOne - everyCount;
                self.currentBadgeMemeMotiInsp = self.currentBadgeMemeMotiInsp - motivCount;
                self.currentBadgeMemeRacy = self.currentBadgeMemeRacy - racyCount;
                
                self.currentBadgeMemeEveryOne = (self.currentBadgeMemeEveryOne < 0) ? 0 : self.currentBadgeMemeEveryOne;
                self.currentBadgeMemeMotiInsp = (self.currentBadgeMemeMotiInsp < 0) ? 0 : self.currentBadgeMemeMotiInsp;
                self.currentBadgeMemeRacy = (self.currentBadgeMemeRacy < 0) ? 0 : self.currentBadgeMemeRacy;
                
                [[NSUserDefaults standardUserDefaults] setInteger:self.currentBadgeMemeEveryOne forKey:MEME_EVERYONE_CURRENT_COUNT];
                [[NSUserDefaults standardUserDefaults] setInteger:self.currentBadgeMemeMotiInsp forKey:MEME_MOTI_INSP_CURRENT_COUNT];
                [[NSUserDefaults standardUserDefaults] setInteger:self.currentBadgeMemeRacy forKey:MEME_RACY_CURRENT_COUNT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self setAllBadgesCountForApplication];
                
                
            }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [self setAllBadgesCountForApplication];
    }];
     */
    
    
    /*
    NSString *installationdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"FirstLaunchTime"];
    NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
    NSString *userId = [userInfoDisct objectForKey:@"userId"];
    
    if(installationdate.length == 0)
        installationdate = @"";
    if(userId.length ==0)
        userId = @"";
    
    
    
    NSString *urlString = MEME_UPCOMMING_APP_LINK;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"type": @"ios",@"date": installationdate,@"userID":userId};
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Sample logic to check login status
        
        NSError *error = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error)
            NSLog(@"Error serializing %@", error);
        
        else
            if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
            {
                NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
                
                NSLog(@"USER_ID=%@, Response=%@",[userInfoDisct objectForKey:@"userId"],JSON);
                
                NSString *EveryoneMeme = [JSON objectForKey:@"total_everyoneMemes"];
                NSString *MotivationalMeme = [JSON objectForKey:@"total_motivationalMemes"];
                NSString *RacyMeme = [JSON objectForKey:@"total_racyMemes"];
                
                NSString *FavouriteNumber = [JSON objectForKey:@"total_myFavourite"];
                NSInteger aFavCount = [FavouriteNumber integerValue];
                self.userFavouriteNumber = ((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? ((aFavCount >= [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT]) ?  aFavCount : [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT]) : aFavCount;
                
                [[NSUserDefaults standardUserDefaults] setInteger:self.userFavouriteNumber forKey:MEME_FAVORITE_CURRENT_COUNT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                self.newMemeEveryOneCount = [EveryoneMeme integerValue] - [[NSUserDefaults standardUserDefaults] integerForKey:MEME_EVERYONE_SERVER_COUNT] ;
                self.newMemeMotiInspCount =  [MotivationalMeme integerValue] - [[NSUserDefaults standardUserDefaults] integerForKey:MEME_MOTI_INSP_SERVER_COUNT] ;
                self.newMemeRacyCount =  [RacyMeme integerValue] - [[NSUserDefaults standardUserDefaults] integerForKey:MEME_RACY_SERVER_COUNT] ;
                
                [[NSUserDefaults standardUserDefaults] setInteger:[EveryoneMeme integerValue] forKey:MEME_EVERYONE_SERVER_COUNT];
                [[NSUserDefaults standardUserDefaults] setInteger:[MotivationalMeme integerValue] forKey:MEME_MOTI_INSP_SERVER_COUNT];
                [[NSUserDefaults standardUserDefaults] setInteger:[RacyMeme integerValue] forKey:MEME_RACY_SERVER_COUNT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                [self setAllBadgesCountForApplication];
                
                
            }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [self setAllBadgesCountForApplication];
    }];*/

}


-(NSInteger)setAllBadgesCountForApplication
{
    //NSLog(@"Before=======");
    //NSLog(@"MEME_EVERYONE_CURRENT_COUNT %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:MEME_EVERYONE_CURRENT_COUNT]);
    //NSLog(@"MEME_MOTI_INSP_CURRENT_COUNT %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:MEME_MOTI_INSP_CURRENT_COUNT]);
    //NSLog(@"MEME_RACY_CURRENT_COUNT %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:MEME_RACY_CURRENT_COUNT]);
    //NSLog(@"MEME_SPIFFY_GIFS_CURRENT_COUNT %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:MEME_SPIFFY_GIF_CURRENT_COUNT]);
    
    self.currentBadgeMemeEveryOne = (((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_EVERYONE_CURRENT_COUNT] != [NSNull null]) ? [[NSUserDefaults standardUserDefaults] integerForKey:MEME_EVERYONE_CURRENT_COUNT] : 0) + (self.newMemeEveryOneCount > 0 ? self.newMemeEveryOneCount : 0);
    
    self.currentBadgeMemeMotiInsp = (((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_MOTI_INSP_CURRENT_COUNT] != [NSNull null]) ? [[NSUserDefaults standardUserDefaults] integerForKey:MEME_MOTI_INSP_CURRENT_COUNT] : 0) + (self.newMemeMotiInspCount > 0 ? self.newMemeMotiInspCount : 0);
    
    self.currentBadgeMemeRacy = (((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_RACY_CURRENT_COUNT] != [NSNull null]) ? [[NSUserDefaults standardUserDefaults] integerForKey:MEME_RACY_CURRENT_COUNT] : 0) + (self.newMemeRacyCount > 0 ? self.newMemeRacyCount : 0);
    
    self.currentBadgeMemeSpiffyGif = (((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_SPIFFY_GIF_CURRENT_COUNT] != [NSNull null]) ? [[NSUserDefaults standardUserDefaults] integerForKey:MEME_SPIFFY_GIF_CURRENT_COUNT] : 0) + (self.newMemeSpiffyCount > 0 ? self.newMemeSpiffyCount : 0);
    
    self.newMemeEveryOneCount = 0;
    self.newMemeMotiInspCount = 0;
    self.newMemeRacyCount = 0;
    self.newMemeSpiffyCount = 0;
    
    NSInteger totalBadgeCount = self.currentBadgeMemeEveryOne+self.currentBadgeMemeMotiInsp+self.currentBadgeMemeRacy+self.currentBadgeMemeSpiffyGif;
    
    
    self.currentBadgeMemeEveryOne = self.currentBadgeMemeEveryOne < 0 ? 0 : self.currentBadgeMemeEveryOne;
    self.currentBadgeMemeMotiInsp = self.currentBadgeMemeMotiInsp < 0 ? 0 : self.currentBadgeMemeMotiInsp;
    self.currentBadgeMemeRacy = self.currentBadgeMemeRacy < 0 ? 0 : self.currentBadgeMemeRacy;
    self.currentBadgeMemeSpiffyGif = self.currentBadgeMemeSpiffyGif < 0 ? 0 : self.currentBadgeMemeSpiffyGif;
    
    
    if (totalBadgeCount > 0)
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalBadgeCount];
    }
    else
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentBadgeMemeEveryOne forKey:MEME_EVERYONE_CURRENT_COUNT];
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentBadgeMemeMotiInsp forKey:MEME_MOTI_INSP_CURRENT_COUNT];
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentBadgeMemeRacy forKey:MEME_RACY_CURRENT_COUNT];
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentBadgeMemeSpiffyGif forKey:MEME_SPIFFY_GIF_CURRENT_COUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //NSLog(@"After=======");
    //NSLog(@"MEME_EVERYONE_CURRENT_COUNT %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:MEME_EVERYONE_CURRENT_COUNT]);
    //NSLog(@"MEME_MOTI_INSP_CURRENT_COUNT %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:MEME_MOTI_INSP_CURRENT_COUNT]);
    //NSLog(@"MEME_RACY_CURRENT_COUNT %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:MEME_RACY_CURRENT_COUNT]);
    //NSLog(@"MEME_SPIFFY_GIF_CURRENT_COUNT %ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:MEME_SPIFFY_GIF_CURRENT_COUNT]);
    
    return totalBadgeCount;
    
    return 0;
}

#pragma mark - Alert
-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Activity Indicator
- (void)activityShow
{
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    });*/
    
    
    if (_activityIndicator == nil)
    {
        //CGRect screenRect = [[UIScreen mainScreen] bounds];
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
        _activityIndicator.frame = CGRectMake(0, 0, 200, 200);
        CGAffineTransform transform = CGAffineTransformMakeScale(2.5f, 2.5f);
        _activityIndicator.transform = transform;
        _activityIndicator.center = self.window.center;
        CAGradientLayer *gradiant = [CAGradientLayer layer];
        gradiant.colors = [NSArray arrayWithObjects:(id)[[UIColor greenColor] CGColor], (id)[[UIColor blueColor] CGColor], nil];
        [_activityIndicator.layer insertSublayer:gradiant atIndex:0];
    }
    
    [_activityIndicator startAnimating];
    [_activityIndicator setHidden:NO];
    
    [self.window addSubview:_activityIndicator];
    [self.window bringSubviewToFront:_activityIndicator];
    
}
- (void)activityHide
{
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
     */
    
    
    [_activityIndicator stopAnimating];
    [_activityIndicator setHidden:YES];
    
}


#pragma mark - App Rate

-(BOOL)iRateShouldPromptForRating
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:kRateAppNotification object:nil];
    //CustomRatingView *ratingView = [[CustomRatingView alloc] init];
    
    [_ratePopup removeFromSuperview];
    
    _ratePopup = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self
                                                                 label1:@"Will you rate this app?"
                                                                 label2:@"Would you mind taking a sec to help a brother from another mother?"
                                                         button1stTitle:@"YES! Five stars, baby!"
                                                         button2ndTitle:@"Hey Dan, remind me later."
                                                         button3rdTitle:@"No. I don't wanna" button4thTitle:nil
                                           showTopBlackBar:NO];
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_LOGIN])
    {
        if (![self danMessagePopupIsOn]) {
            [_ratePopup show];
            [self setRatePopupIsOn:YES];
        }
        
    }
    else
    {
        [self performSelector:@selector(showRateAppViewAfterSomeTimes) withObject:nil afterDelay:60];
    }
    
    //[self.window.rootViewController.view addSubview:customRatingView];
    return NO;
}

-(void)showRateAppViewAfterSomeTimes
{
    if (![self danMessagePopupIsOn]) {
        [_ratePopup show];
        [self setRatePopupIsOn:YES];
    }
}

-(void)danMessagePopupView:(DanMessagePopup *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Rate-Now on Rate popup"];
            [iRate sharedInstance].ratedThisVersion = YES;
            [[iRate sharedInstance] openRatingsPageInAppStore];
            [_ratePopup removeFromSuperview];
            
            break;
        case 1:
            [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Remind-Later on Rate popup"];
            [iRate sharedInstance].lastReminded = [NSDate date];
            [_ratePopup removeFromSuperview];
            
            break;
        case 2:
            [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Cancel on Rate popup"];
            [iRate sharedInstance].declinedThisVersion = YES;
            [_ratePopup removeFromSuperview];
            break;
            
        default:
            break;
    }
    _ratePopup = nil;
    //[self setDanMessagePopupIsOn:NO];
    [self setRatePopupIsOn:NO];
}



#pragma mark - Move Slide Menu
-(void)moveView1:(UIView *)view1 andView2:(UIView *)view2 moveLeft:(BOOL)moveLeft
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    
    BOOL is_iOS_6 = NO;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        is_iOS_6 = NO;
    } else {
        is_iOS_6 = YES;
    }
    
    if (moveLeft)
    {
        CGRect frame1 = view1.frame;
        frame1.origin.y = 0;
        if (IS_IPAD)
            frame1.origin.x = 768;
        else
            frame1.origin.x = 320;
        view1.frame = frame1;
        
        
        CGRect frame2 = view2.frame;
        frame2.origin.y = 0;
        frame2.origin.x = 0;
        view2.frame = frame2;
    }
    else
    {
        CGRect frame1 = view1.frame;
        frame1.origin.y = 0;
        if (IS_IPAD)
            frame1.origin.x = 110;
        else
            frame1.origin.x = 46;
        view1.frame = frame1;
        
        
        CGRect frame2 = view2.frame;
        frame2.origin.y = 0;
        if (IS_IPAD)
            frame2.origin.x = -658;
        else
            frame2.origin.x = -274;
        view2.frame = frame2;
    }
    
    [UIView commitAnimations];
}

#pragma mark - Load All Memes Into DB
-(void)loadAllMemesIntoDB
{
    if(![AppDelegate isNetworkAvailable]){
        return;
    }
    
    NSString *urlString = MEME_MESSAGE_FROM_DAN;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = nil;//@{@"email": email, @"password": password, @"type": @"normal"};
    
    [UIAppDelegate activityShow];
    
    NSLog(@"Started..");
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [UIAppDelegate activityHide];
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
                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AllMemesLoaded"];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     
                 }
                 
                 
             }
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         [UIAppDelegate activityHide];
     }];
}

#pragma mark - Admob
-(void)addAdmob
{
    [[GoogleAnalyticsCustom getSharedInstance] trackEventViewController:@"Add Ads(Flurry)"];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    if (!IS_IPAD)
    {
        UIAppDelegate.obj_FlurryAd = [[GADBannerView alloc]
                                      initWithFrame:CGRectMake(0.0,
                                                               rect.size.height-105,
                                                               rect.size.width,
                                                               50)];
    }
    else
    {
        UIAppDelegate.obj_FlurryAd = [[GADBannerView alloc]
                                      initWithFrame:CGRectMake(0.0,
                                                               rect.size.height-149,
                                                               rect.size.width,
                                                               50)];
    }
    
    //UIAppDelegate.obj_FlurryAd.backgroundColor = [UIColor blackColor];
    UIAppDelegate.obj_FlurryAd.hidden = YES;
    
    UIAppDelegate.obj_GadAdBanner = [[GADBannerView alloc] initWithFrame:UIAppDelegate.obj_FlurryAd.frame];
    UIAppDelegate.obj_GadAdBanner.adUnitID = @"ca-app-pub-9152009225005926/6126924393";//@"ca-app-pub-9152009225005926/8692051598";
    
    GADRequest *gadRequest = [GADRequest request];
#if (TARGET_IPHONE_SIMULATOR)
    
    gadRequest.testDevices = @[@"Simulator"];
    
#endif
    
    [UIAppDelegate.obj_GadAdBanner loadRequest:gadRequest];
    
}




#pragma mark - AdNetwork Flurry

-(void)addFlurryAd
{
    [[GoogleAnalyticsCustom getSharedInstance] trackEventViewController:@"Add Ads(MoPub)"];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    if (!IS_IPAD)
    {
        UIAppDelegate.obj_FlurryAd = [[GADBannerView alloc]
                                      initWithFrame:CGRectMake(0.0,
                                                               rect.size.height-105,
                                                               rect.size.width,
                                                               50)];
        UIAppDelegate.obj_FlurryAd.adSize = GADAdSizeFromCGSize(UIAppDelegate.obj_FlurryAd.frame.size);
     
        /*
        UIAppDelegate.obj_FlurryAd = [[MPAdView alloc]
                                       initWithAdUnitId:MoPub_BANNER_AD_UNIT_ID_iPhone size:CGSizeMake(rect.size.width, 50)];
        
        UIAppDelegate.obj_FlurryAd.frame = CGRectMake(0.0,
                                                      rect.size.height-105,
                                                      rect.size.width,
                                                      50);
         */
    }
    else
    {
        UIAppDelegate.obj_FlurryAd = [[GADBannerView alloc]
                                      initWithFrame:CGRectMake(0.0,
                                                               rect.size.height-169,
                                                               rect.size.width,
                                                               70)];
        UIAppDelegate.obj_FlurryAd.adSize = GADAdSizeFromCGSize(UIAppDelegate.obj_FlurryAd.frame.size);
        
/*
        UIAppDelegate.obj_FlurryAd = [[MPAdView alloc]
                                      initWithAdUnitId:MoPub_BANNER_AD_UNIT_ID_iPad size:MOPUB_LEADERBOARD_SIZE];
        
        
        UIAppDelegate.obj_FlurryAd.frame = CGRectMake(0.0,
                                                      rect.size.height-169+20,
                                                      rect.size.width,
                                                      90);*/
    }
    
    //UIAppDelegate.obj_FlurryAd.backgroundColor = [UIColor blackColor];
//    UIAppDelegate.obj_FlurryAd.hidden = YES;
    
    UIAppDelegate.obj_FlurryAd.rootViewController = self.window.rootViewController;
    
    UIAppDelegate.obj_FlurryAd.adUnitID = ADMOB_ID;
    
    GADRequest *gadRequest = [GADRequest request];
     
#if (TARGET_IPHONE_SIMULATOR)
    
    gadRequest.testDevices = @[@"Simulator"];
    
#endif
    UIAppDelegate.obj_FlurryAd.delegate = self;
    [UIAppDelegate.obj_FlurryAd loadRequest:gadRequest];

//    UIAppDelegate.obj_FlurryAd.delegate = self;
//    [UIAppDelegate.obj_FlurryAd loadAd];

//    [FlurryAds setAdDelegate:self];
//    [FlurryAds fetchAndDisplayAdForSpace:FlurryBannerAdSpace view:UIAppDelegate.obj_FlurryAd  viewController:self.window.rootViewController size:BANNER_BOTTOM];
    

//    self.obj_FlurryAdBanner = [[FlurryAdBanner alloc] initWithSpace:FlurryBannerAdSpace];
//    self.obj_FlurryAdBanner.adDelegate = self;
//    [self.obj_FlurryAdBanner fetchAdForFrame:UIAppDelegate.obj_FlurryAd.frame];
}

-(void)adViewDidReceiveAd:(GADBannerView *)view
{
    if(![self isProUser])
    {
        UIAppDelegate.obj_FlurryAd.hidden = NO;
        UIAppDelegate.bannerIsVisible = YES;
        [self.window.rootViewController.view addSubview:UIAppDelegate.obj_FlurryAd];
        
        //\\[FlurryAds displayAdForSpace:FlurryBannerAdSpace onView:UIAppDelegate.obj_FlurryAd viewControllerForPresentation:self.window.rootViewController];
        [UIAppDelegate.obj_FlurryAdBanner displayAdInView:UIAppDelegate.obj_FlurryAd viewControllerForPresentation:UIAppDelegate.window.rootViewController];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BANNAR_AD_IS_VISIBLE" object:nil];
    }
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    /*
    CGSize size = [view adContentViewSize];
    CGFloat centeredX = (self.view.bounds.size.width - size.width) / 2;
    CGFloat bottomAlignedY = self.view.bounds.size.height - size.height;
    view.frame = CGRectMake(centeredX, bottomAlignedY, size.width, size.height);*/
    
    NSLog(@"%f",view.adContentViewSize.width);
    
    if(![self isProUser])
    {
        UIAppDelegate.obj_FlurryAd.hidden = NO;
        UIAppDelegate.bannerIsVisible = YES;
        [self.window.rootViewController.view addSubview:UIAppDelegate.obj_FlurryAd];
        
        //\\[FlurryAds displayAdForSpace:FlurryBannerAdSpace onView:UIAppDelegate.obj_FlurryAd viewControllerForPresentation:self.window.rootViewController];
        //[UIAppDelegate.obj_FlurryAdBanner displayAdInView:UIAppDelegate.obj_FlurryAd viewControllerForPresentation:UIAppDelegate.window.rootViewController];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BANNAR_AD_IS_VISIBLE" object:nil];
    }
}

#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return UIAppDelegate.window.rootViewController;
}

-(void)addFlurryInView:(UIView *)view
{
    [view addSubview:UIAppDelegate.obj_FlurryAd];
    
}

-(void)showFlurryAd
{
    [self.window.rootViewController.view addSubview:UIAppDelegate.obj_FlurryAd];
}

-(void)hideFlurryAd
{
    [UIAppDelegate.obj_FlurryAd removeFromSuperview];
    //[UIAppDelegate.obj_FlurryAd setHidden:YES];
}




-(void)adBannerDidFetchAd:(FlurryAdBanner *)bannerAd
{
    if(![self isProUser])
    {
        UIAppDelegate.obj_FlurryAd.hidden = NO;
        UIAppDelegate.bannerIsVisible = YES;
        [self.window.rootViewController.view addSubview:UIAppDelegate.obj_FlurryAd];
        
        //\\[FlurryAds displayAdForSpace:FlurryBannerAdSpace onView:UIAppDelegate.obj_FlurryAd viewControllerForPresentation:self.window.rootViewController];
        [UIAppDelegate.obj_FlurryAdBanner displayAdInView:UIAppDelegate.obj_FlurryAd viewControllerForPresentation:UIAppDelegate.window.rootViewController];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BANNAR_AD_IS_VISIBLE" object:nil];
    }
}

-(void)adBanner:(FlurryAdBanner *)bannerAd adError:(FlurryAdError)adError errorDescription:(NSError *)errorDescription
{
    NSLog(@"Error for Flurry Banner");
}

-(void)adInterstitialDidFetchAd:(FlurryAdInterstitial *)interstitialAd
{
    if(![self isProUser])
    {
        NSLog(@"Flurry Full Screen AD!!");
        [interstitialAd presentWithViewControler:UIAppDelegate.window.rootViewController];
        /*
         if(!UIAppDelegate.isFlurryAdVisible)
         {
         NSLog(@"Flurry Full Screen AD!!");
         [FlurryAds displayAdForSpace:@"INTERSTITIAL_MAIN_VIEW" onView:self.window.rootViewController.view viewControllerForPresentation:UIAppDelegate.window.rootViewController];
         
         UIAppDelegate.isFlurryCurrent = YES;
         UIAppDelegate.isFlurryAdVisible = YES;
         }
         */
    }
}

-(void)adInterstitial:(FlurryAdInterstitial *)interstitialAd adError:(FlurryAdError)adError errorDescription:(NSError *)errorDescription
{
    
}


/*
[FlurryAds fetchAndDisplayAdForSpace:@"BANNER_MAIN_VIEW" view:UIAppDelegate.obj_FlurryAd  viewController:self.window.rootViewController size:BANNER_BOTTOM];
*/

- (void) spaceDidReceiveAd:(NSString*)adSpace
{
    /*
    NSLog(@"spaceDidReceiveAd");
    // Show the ad if desired
    if([adSpace isEqualToString:FlurryBannerAdSpace])
    {
        if(![self isProUser])
        {
            UIAppDelegate.obj_FlurryAd.hidden = NO;
            UIAppDelegate.bannerIsVisible = YES;
            [self.window.rootViewController.view addSubview:UIAppDelegate.obj_FlurryAd];
        
            [FlurryAds displayAdForSpace:FlurryBannerAdSpace onView:UIAppDelegate.obj_FlurryAd viewControllerForPresentation:self.window.rootViewController];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BANNAR_AD_IS_VISIBLE" object:nil];
        }
    }
    else
    {
        if(![self isProUser])
        {
            NSLog(@"Flurry Full Screen AD!!");
            [FlurryAds displayAdForSpace:FlurryFullViewAdSpace onView:self.window.rootViewController.view viewControllerForPresentation:UIAppDelegate.window.rootViewController];
            
            
//            if(!UIAppDelegate.isFlurryAdVisible)
//            {
//                NSLog(@"Flurry Full Screen AD!!");
//                [FlurryAds displayAdForSpace:@"INTERSTITIAL_MAIN_VIEW" onView:self.window.rootViewController.view viewControllerForPresentation:UIAppDelegate.window.rootViewController];
//                
//                UIAppDelegate.isFlurryCurrent = YES;
//                UIAppDelegate.isFlurryAdVisible = YES;
//            }
            
        }
        
    }
    */
}

- (void) spaceDidFailToReceiveAd:(NSString*)adSpace error:(NSError *)error
{
    NSLog(@"spaceDidFailToReceiveAd");
    if([adSpace isEqualToString:FlurryBannerAdSpace])
    {
        if(![self isProUser])
        {
            // Handle failure to receive ad
            NSLog(@"Failed getting Ad. What to do??");
            UIAppDelegate.obj_FlurryAd.hidden = YES;
            UIAppDelegate.bannerIsVisible = NO;
        }
    }
}

/*
 *  It is recommended to pause app activities when an interstitial is shown.
 *  Listen to should display delegate.
 */
- (BOOL) spaceShouldDisplay:(NSString*)adSpace interstitial:(BOOL) interstitial
{
    NSLog(@"spaceShouldDisplay");
    if (interstitial)
    {
        // Pause app state here
    }
    
    if(![self isProUser])
    {
        // Continue ad display
        return YES;
    }
    else
    {
        return NO;
    }
    
}



/*
 *  Resume app state when the interstitial is dismissed.
 */
- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial
{
    NSLog(@"spaceDidDismiss");
}

-(void)reloadInterstitialAds
{
    NSLog(@"reloadInterstitialAds");
    //Check if already requesting ad
    if(![self isProUser])
    {
        
        /*
        if ([FlurryAds adReadyForSpace:FlurryFullViewAdSpace])
        {
            [FlurryAds displayAdForSpace:FlurryFullViewAdSpace onView:self.window.rootViewController.view viewControllerForPresentation:UIAppDelegate.window.rootViewController];
            UIAppDelegate.isFlurryAdVisible = YES;
            
//            if(!UIAppDelegate.isFlurryAdVisible)
//            {
//                
//            }
            
        }
        else
        {
            // Fetch an ad
            [FlurryAds fetchAdForSpace:FlurryFullViewAdSpace frame:[[UIScreen mainScreen] bounds] size:FULLSCREEN];
        }
        */
        
        
/*
        if([UIAppDelegate.obj_FlurryAdInterstitial ready])
        {
            [UIAppDelegate.obj_FlurryAdInterstitial presentWithViewControler:self.window.rootViewController];
            
        }
        else
        {
            UIAppDelegate.obj_FlurryAdInterstitial = nil;
            UIAppDelegate.obj_FlurryAdInterstitial.adDelegate = nil;
            UIAppDelegate.obj_FlurryAdInterstitial = [[FlurryAdInterstitial alloc] initWithSpace:FlurryFullViewAdSpace];
            UIAppDelegate.obj_FlurryAdInterstitial.adDelegate = self;
            [UIAppDelegate.obj_FlurryAdInterstitial fetchAd];
            
        }
  */
        
        if(UIAppDelegate.obj_GadInterstitial.isReady)
        {
            [UIAppDelegate.obj_GadInterstitial presentFromRootViewController:self.window.rootViewController];
        }
        else
        {
            UIAppDelegate.obj_GadInterstitial = nil;
            UIAppDelegate.obj_GadInterstitial.delegate = nil;
            UIAppDelegate.obj_GadInterstitial = [[GADInterstitial alloc] init];
            UIAppDelegate.obj_GadInterstitial.adUnitID = @"ca-app-pub-9152009225005926/7603657592";
            
            GADRequest *gadRequest = [GADRequest request];
#if (TARGET_IPHONE_SIMULATOR)
            
            gadRequest.testDevices = @[@"Simulator"];
            
#endif
            UIAppDelegate.obj_GadInterstitial.delegate = self;
            [UIAppDelegate.obj_GadInterstitial loadRequest:gadRequest];
            
        }
        
        /*
        if(UIAppDelegate.obj_GadInterstitial.ready)
        {
            [UIAppDelegate.obj_GadInterstitial showFromViewController:self.window.rootViewController];
        }
        else
        {
            UIAppDelegate.obj_GadInterstitial = nil;
            UIAppDelegate.obj_GadInterstitial.delegate = nil;
            UIAppDelegate.obj_GadInterstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:MoPub_INTERSTITIAL_AD_UNIT_ID];
            
            
            UIAppDelegate.obj_GadInterstitial.delegate = self;
            [UIAppDelegate.obj_GadInterstitial loadAd];
            
        }
        */
    }
}

#pragma mark MoPubInterstitialDelegate implementation

-(void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    if(![self isProUser])
    {
        //NSLog(@"Flurry Full Screen AD!!");
        if(interstitial.ready)
        {
            [interstitial showFromViewController:UIAppDelegate.window.rootViewController];
        }
        
        /*
         if(!UIAppDelegate.isFlurryAdVisible)
         {
         NSLog(@"Flurry Full Screen AD!!");
         [FlurryAds displayAdForSpace:@"INTERSTITIAL_MAIN_VIEW" onView:self.window.rootViewController.view viewControllerForPresentation:UIAppDelegate.window.rootViewController];
         
         UIAppDelegate.isFlurryCurrent = YES;
         UIAppDelegate.isFlurryAdVisible = YES;
         }
         */
    }
}

-(void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    NSLog(@"interstitialDidFailToReceiveAdWithError: ");
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial
{
    //[self pauseGame];
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
    //[self resumeGame];
}

#pragma mark GADInterstitialDelegate implementation

-(void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    if(![self isProUser])
    {
        //NSLog(@"Flurry Full Screen AD!!");
        [ad presentFromRootViewController:UIAppDelegate.window.rootViewController];
        /*
         if(!UIAppDelegate.isFlurryAdVisible)
         {
         NSLog(@"Flurry Full Screen AD!!");
         [FlurryAds displayAdForSpace:@"INTERSTITIAL_MAIN_VIEW" onView:self.window.rootViewController.view viewControllerForPresentation:UIAppDelegate.window.rootViewController];
         
         UIAppDelegate.isFlurryCurrent = YES;
         UIAppDelegate.isFlurryAdVisible = YES;
         }
         */
    }
}

- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
    
    if([UIAppDelegate.obj_FlurryAdInterstitial ready])
    {
        [UIAppDelegate.obj_FlurryAdInterstitial presentWithViewControler:self.window.rootViewController];
        
    }
    else
    {
        UIAppDelegate.obj_FlurryAdInterstitial = nil;
        UIAppDelegate.obj_FlurryAdInterstitial.adDelegate = nil;
        UIAppDelegate.obj_FlurryAdInterstitial = [[FlurryAdInterstitial alloc] initWithSpace:FlurryFullViewAdSpace];
        UIAppDelegate.obj_FlurryAdInterstitial.adDelegate = self;
        [UIAppDelegate.obj_FlurryAdInterstitial fetchAd];
        
    }
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    NSLog(@"interstitialDidDismissScreen");
    //[self startNewGame];
}

/*
 [FlurryAds setAdDelegate:self];
 
 // Check if ad is ready. If so, display the ad
 if ([FlurryAds adReadyForSpace:@"INTERSTITIAL_MAIN_VIEW"])
 {
 if(!UIAppDelegate.isFlurryAdVisible)
 {
 [FlurryAds displayAdForSpace:@"INTERSTITIAL_MAIN_VIEW" onView:self.window.rootViewController.view viewControllerForPresentation:UIAppDelegate.window.rootViewController];
 }
 
 }
 else
 {
 [FlurryAds fetchAdForSpace:@"INTERSTITIAL_MAIN_VIEW" frame:UIAppDelegate.flurryAdFullScreenView.frame size:FULLSCREEN];
 }
*/



#pragma mark - Other



-(NSString *)makeHashKey:(NSString *)aString
{
    const char *concat_str = [aString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

#pragma mark - Pro User
-(BOOL) isProUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //\\return  [defaults  boolForKey:[NSString stringWithFormat:@"%@_%@",userid,@"ADS"]];
    return  [defaults boolForKey:@"ADS"];
    // return YES;
}
-(void) setProUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //\\[defaults setBool:YES forKey:[NSString stringWithFormat:@"%@_%@",userid,@"ADS"]];
    [defaults setBool:YES forKey:@"ADS"];
    [defaults synchronize];
}

-(void) removeProUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //\\[defaults setBool:YES forKey:[NSString stringWithFormat:@"%@_%@",userid,@"ADS"]];
    [defaults setBool:NO forKey:@"ADS"];
    [defaults synchronize];
}

#pragma mark - isRetina Display
+ (BOOL) isRetinaDisplay
{
    int scale = 1.0;
    UIScreen *screen = [UIScreen mainScreen];
    if([screen respondsToSelector:@selector(scale)])
        scale = screen.scale;
    
    if(scale == 2.0f) return YES;
    else return NO;
}

#pragma mark - iCon Enable/Disable
-(void)enableFeature:(NSString *)feature :(BOOL)status
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:status forKey:[NSString stringWithFormat:@"%@",feature]];
    [defaults synchronize];
}
-(BOOL) isEnabled:(NSString *)feature{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults  boolForKey:[NSString stringWithFormat:@"%@",feature]];
}
-(void)enableAllFeatureOnDashBoard
{
    [self enableFeature:MEME_FOR_EVERYONE :YES];
    [self enableFeature:MOTIVATIONAL_INSPIRATIONAL :YES];
    [self enableFeature:RACY_MEMES :YES];
    [self enableFeature:SPIFFY_GIFS :YES];
    [self enableFeature:TRENDING_POPULAR :YES];
    [self enableFeature:UPLOAD_AWESOME_MEME :YES];
    [self enableFeature:SAVED_FAVORITES :YES];
    [self enableFeature:REMOVE_ADS :YES];
    [self enableFeature:SINGLE_DAD_LAUGHING :YES];
    
    [self enableFeature:MEME_FOR_EVERYONE_BADGE :YES];
    [self enableFeature:MOTIVATIONAL_INSPIRATIONAL_BADGE :YES];
    [self enableFeature:RACY_MEME_BADGE :YES];
    [self enableFeature:SPIFFY_GIFS_BADGE :YES];
}
-(NSMutableArray *)getEnabledFeature
{
    
    NSMutableArray *arry = [NSMutableArray array];
    if ([self isEnabled:MEME_FOR_EVERYONE]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"icon1.png" forKey:@"featureIcon"];
        [dict setValue:MEME_FOR_EVERYONE forKey:@"featureName"];
        [arry addObject:dict];
    }
    if ([self isEnabled:MOTIVATIONAL_INSPIRATIONAL]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"icon2.png" forKey:@"featureIcon"];
        [dict setValue:MOTIVATIONAL_INSPIRATIONAL forKey:@"featureName"];
        [arry addObject:dict];
    }
    if ([self isEnabled:RACY_MEMES]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"icon3.png" forKey:@"featureIcon"];
        [dict setValue:RACY_MEMES forKey:@"featureName"];
        [arry addObject:dict];
    }
    if ([self isEnabled:SPIFFY_GIFS] && false) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"icon4.png" forKey:@"featureIcon"];
        [dict setValue:SPIFFY_GIFS forKey:@"featureName"];
        [arry addObject:dict];
    }
    if ([self isEnabled:TRENDING_POPULAR]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"icon5.png" forKey:@"featureIcon"];
        [dict setValue:TRENDING_POPULAR forKey:@"featureName"];
        [arry addObject:dict];
    }
    if ([self isEnabled:UPLOAD_AWESOME_MEME]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"icon6.png" forKey:@"featureIcon"];
        [dict setValue:UPLOAD_AWESOME_MEME forKey:@"featureName"];
        [arry addObject:dict];
    }
    if ([self isEnabled:SAVED_FAVORITES]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"icon7.png" forKey:@"featureIcon"];
        [dict setValue:SAVED_FAVORITES forKey:@"featureName"];
        [arry addObject:dict];
    }
    if ([self isEnabled:REMOVE_ADS] && !self.isProUser) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"icon8.png" forKey:@"featureIcon"];
        [dict setValue:REMOVE_ADS forKey:@"featureName"];
        [arry addObject:dict];
    }
    if ([self isEnabled:SINGLE_DAD_LAUGHING]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"icon9.png" forKey:@"featureIcon"];
        [dict setValue:SINGLE_DAD_LAUGHING forKey:@"featureName"];
        [arry addObject:dict];
    }
    return arry;
}

@end

