//
//  MemesViewController.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 27/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "MemesViewController.h"
#import "HomeScreenViewController.h"
#import "PreferenceViewController.h"
#import "FavoriteViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "MemePhoto.h"
#import "DBHelper.h"
#import "MemesSwipeView.h"
#import "Cell.h"
#import "MenuView.h"
#import "AFNetworking.h"
#import "DACircularProgressView.h"
#import "UIImageView+WebCache.h"


@interface MemesViewController ()
{
    //NSMutableArray *photoArray;
    NSArray *userPhotoArray;
    NSMutableArray *danMessageArray;
    NSMutableArray *indexArray;
    
    int pageNum;
    NSInteger totalMeme;
    
    DBHelper *dbhelper;
    MenuView *menuView;
    CustomBadge *badgeForEveryoneMeme;
    
    BOOL isButtonClicked;
    UIView *rightSideView;
    
    UIRefreshControl *refreshControl;
}
@property (readwrite, getter = isFromRefreshController) BOOL fromRefreshController;
@property (nonatomic, assign) CGPoint lastContentOffset;
@property (strong, nonatomic) UIImage *grayFrame;
@property (strong, nonatomic) UIImage *normalFrame;
@property (strong, nonatomic) GADBannerView  *bannerView;

@end

@implementation MemesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIAppDelegate.pageNumberRequest = 0;
    
    isButtonClicked = NO;
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
    
    dbhelper = [[DBHelper alloc] init];
    UIAppDelegate.photoArray = [NSMutableArray array];
    indexArray = [NSMutableArray array];
    pageNum = 1;
    
    [self setFromRefreshController:NO];
    [self loadImagesForPageNumber:1];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor darkGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    _myCollectionView.alwaysBounceVertical = YES;
    [refreshControl addTarget:self
                       action:@selector(loadRefreshedImages)
             forControlEvents:UIControlEventValueChanged];
    
    refreshControl.tag = 1000;
    [_myCollectionView addSubview:refreshControl];
    
    
    MyFlowLayout *myFlowLayout=[[MyFlowLayout alloc] init];
    [_myCollectionView setCollectionViewLayout:myFlowLayout animated:YES];
    
    [_myCollectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"Cell"];
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [UIAppDelegate activityHide];
    UIAppDelegate.pageNumberRequest = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( UIAppDelegate.pageNumberRequest >= pageNum)
    {
        pageNum = UIAppDelegate.pageNumberRequest;
    }
    
    if([UIAppDelegate isProUser])
    {
        [UIAppDelegate hideFlurryAd];
        
        CGFloat collectionViewHeight = 0;
        if (IS_IPHONE) {
            if (IS_IPHONE_4INCHES) { collectionViewHeight = 296; } else { collectionViewHeight = 208; }
        } else { collectionViewHeight = 575; }
        
        _myCollectionView.frame = CGRectMake(0,
                                             167*factorY,
                                             320*factorX, collectionViewHeight);
    }
    else
    {
        [UIAppDelegate addFlurryInView:_myView];
    }
    
    
    if (UIAppDelegate.photoArray.count > 0) {
        [UIAppDelegate.photoArray removeLastObject];
    }
    NSLog(@"PHotoArray Count = %d",UIAppDelegate.photoArray.count);
    
    [[GoogleAnalyticsCustom getSharedInstance] setCurrentScreenName:@"Meme EveryOne Screen"];
    [_myCollectionView reloadData];
    
    
    [self updateBottomBadgeCount];
    //[UIAppDelegate showiAdInView:_myView Delegate:self];
}

-(void)updateBottomBadgeCount
{
    [badgeForEveryoneMeme removeFromSuperview];
    
    NSString *badgeString = nil;
    if ((UIAppDelegate.currentBadgeMemeEveryOne+UIAppDelegate.currentBadgeMemeMotiInsp+UIAppDelegate.currentBadgeMemeRacy+UIAppDelegate.currentBadgeMemeSpiffyGif) > 0)
    {
        if ((UIAppDelegate.currentBadgeMemeEveryOne+UIAppDelegate.currentBadgeMemeMotiInsp+UIAppDelegate.currentBadgeMemeRacy+UIAppDelegate.currentBadgeMemeSpiffyGif) > 99)
        {
            badgeString = @"99+";
        }
        else
        {
            badgeString = [NSString stringWithFormat:@"%d",(UIAppDelegate.currentBadgeMemeEveryOne+UIAppDelegate.currentBadgeMemeMotiInsp+UIAppDelegate.currentBadgeMemeRacy+UIAppDelegate.currentBadgeMemeSpiffyGif)];
        }
        badgeForEveryoneMeme = [CustomBadge customBadgeWithString:badgeString
                                                  withStringColor:[UIColor whiteColor]
                                                   withInsetColor:[UIColor redColor]
                                                   withBadgeFrame:YES
                                              withBadgeFrameColor:[UIColor whiteColor]
                                                        withScale:1.0
                                                      withShining:YES];
        
        [badgeForEveryoneMeme setFrame:
         CGRectMake(_backToHomeButton.frame.size.width-badgeForEveryoneMeme.frame.size.width/2,
                    -5,
                    badgeForEveryoneMeme.frame.size.width,
                    badgeForEveryoneMeme.frame.size.height)];
        [_backToHomeButton addSubview:badgeForEveryoneMeme];
    }
    else
        [badgeForEveryoneMeme removeFromSuperview];
}

-(void)viewDidLayoutSubviews
{
    //NSLog(@"viewDidLayoutSubviews");
    
    if ([UIAppDelegate isProUser]) {
        CGFloat collectionViewHeight = 0;
        if (IS_IPHONE) {
            if (IS_IPHONE_4INCHES) {
                collectionViewHeight = 346; }
            else { collectionViewHeight = 258; }
        } else { collectionViewHeight = 625; }
        
        _myCollectionView.frame = CGRectMake(0,
                                             167*factorY,
                                             320*factorX, collectionViewHeight);
    }
}


#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return UIAppDelegate.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"Cell";
    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    MemePhoto *photo = [UIAppDelegate.photoArray objectAtIndex:indexPath.item];
    
    //******* Change Date: 9-Feb-2015 *********
    DACircularProgressView *_loadingIndicator = (DACircularProgressView *)[cell.imageView viewWithTag:123];
    if(!_loadingIndicator)
    {
        _loadingIndicator = [self addCircularProgressView];
        [cell.imageView addSubview:_loadingIndicator];
        _loadingIndicator.tag = 123;
    }
    
    _loadingIndicator.progress = 0;
    _loadingIndicator.hidden = NO;

    //******* Change Date: 9-Feb-2015 *********
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:(IS_IPAD?photo.thumb250URL:photo.thumb100URL)]
                      placeholderImage:[UIImage imageNamed: IS_IPAD ? @"place_holder_ipad" : @"place_holder.png"]
                               options:0
                              progress:^(NSInteger receivedSize, NSInteger expectedSize)
    {
                                  if (expectedSize > 0)
                                  {
                                      float progress = receivedSize / (float)expectedSize;
                                      _loadingIndicator.progress = MAX(MIN(1, progress), 0);
                                  }
                                  
                              } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  _loadingIndicator.hidden = YES;
                                  cell.imageView.image = image;
                                  
                              }];
    cell.deleteButton.hidden = YES;
    
    [cell setViewed:[dbhelper isViewed:photo.photoID]];
    
//    if ([dbhelper isViewed:photo.photoID]) {
//        //NSLog(@"TRUE");
//        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frame_photo_grey.png"]];
//    }
//    else{
//        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frame_photo.png"]];
//    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MemesSwipeView *swipeView = [[MemesSwipeView alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"MemesSwipeView"] bundle:nil];
    
    MemePhoto *memePhoto = [UIAppDelegate.photoArray objectAtIndex:indexPath.item];
    
    NSInteger numberOfBadges;
    //Update Badge Count
    if ([dbhelper isViewed:memePhoto.photoID])
    {
        UIAppDelegate.badgeEveryoneMeme = UIAppDelegate.badgeEveryoneMeme;
        
    }
    else
    {
        /*
        UIAppDelegate.badgeEveryoneMeme = UIAppDelegate.badgeEveryoneMeme - 1;
        numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
        numberOfBadges -=1;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
        NSLog(@"else-appdelegate.badgeEveryoneMeme = %ld",(long)UIAppDelegate.badgeEveryoneMeme);*/
        
        if(indexPath.item==0)
        {
            UIAppDelegate.currentBadgeMemeEveryOne = UIAppDelegate.currentBadgeMemeEveryOne - 1;
            [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeEveryOne forKey:MEME_EVERYONE_CURRENT_COUNT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [UIAppDelegate setAllBadgesCountForApplication];
            
            //Update Database ViewCount
            [dbhelper updateMemeView:@"1" withMemeID:memePhoto.photoID];
            
            [self updateBottomBadgeCount];
        }
        
    }
    
    /*
    if ((UIAppDelegate.badgeEveryoneMeme+UIAppDelegate.badgeMotivationalMeme+UIAppDelegate.badgeRacyMeme) < 1) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }*/
    
    
    
    NSLog(@"Everyone didSelect ID = %@",memePhoto.photoID);
    
    Cell *cell = (Cell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frame_photo_grey.png"]];
    
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Show Everyone Meme Details"];
    
    [swipeView setImageIndex:indexPath.item];
    
    
    MemePhoto *aPhoto = [UIAppDelegate.photoArray lastObject];
    [UIAppDelegate.photoArray addObject:aPhoto];
     
    
    [swipeView setPageNumber:pageNum];
    [swipeView setTotalMeme:totalMeme];
    [swipeView setImageArray:UIAppDelegate.photoArray];
    [swipeView setControllerIdentifier:1];
    
    [self.navigationController pushViewController:swipeView animated:YES];
    
}

#pragma mark - ScrollView Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDragging");
    
    _lastContentOffset.x = scrollView.contentOffset.x;
    _lastContentOffset.y = scrollView.contentOffset.y;
}

/*
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"scrollViewDidEndDragging");
    
    if (_lastContentOffset.y < (int)scrollView.contentOffset.y)
    {
        NSLog(@"up");
        [indexArray removeAllObjects];
        for (NSIndexPath *indexPath in [self.myCollectionView indexPathsForVisibleItems]) {
            [indexArray addObject:[NSNumber numberWithInteger:[indexPath item]]];
        }
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
        int arrayLastIndex = [[[indexArray sortedArrayUsingDescriptors:@[sort]]lastObject] intValue];
        //int pageNum = (photoArray.count / ITEMS_PER_PAGE) + 1;
        
        if (arrayLastIndex+1 == photoArray.count) {
            [self setFromRefreshController:NO];
            [self loadImagesForPageNumber:ITEMS_PER_PAGE pageNumber:++pageNum];
        }
    }
} 
*/

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height)
    {
        [self setFromRefreshController:NO];
        if(!isLoadingMore)
        {
            isLoadingMore = YES;
            [self loadImagesForPageNumber:pageNum];
        }
        
    }
}

#pragma mark - MainView Button Actios
- (IBAction)markAallButtonAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"MarkAall Button Clicked"];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_MARKALL_POPUP_FOR_EVERYONE_MEME])
    {
        DanMessagePopup *alert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self
                                                                    label1:@"MARK ALL MEMES AS READ"
                                                                    label2:@"Are you sure you want to do that? (it can't be undone)"
                                                            button1stTitle:@"Yep, Do it!"
                                                            button2ndTitle:@"Yep, and don't ask again."
                                                            button3rdTitle:@"No. Take me back!"
                                                            button4thTitle:nil 
                                                           showTopBlackBar:NO];
        
        alert.tag = 1;
        [alert show];
    }
    else
    {
        for (MemePhoto *photo in UIAppDelegate.photoArray){
            [dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
            
            /*
            NSInteger numberOfBadges;
            UIAppDelegate.badgeEveryoneMeme = UIAppDelegate.badgeEveryoneMeme - 1;
            numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
            numberOfBadges -=1;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];*/
        }
        userPhotoArray = [dbhelper getAllMemes];
        [_myCollectionView reloadData];
        
        UIAppDelegate.currentBadgeMemeEveryOne = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeEveryOne forKey:MEME_EVERYONE_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [UIAppDelegate setAllBadgesCountForApplication];
        [self updateBottomBadgeCount];
    }
    
}

- (IBAction)backButtonAction:(UIButton *)sender
{
    //NSLog(@"backButtonAction");
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
    
    if (isButtonClicked) {
        isButtonClicked = NO;
    }
    
    if (sender.tag == 100) {
        rightSideView.hidden = YES;
        _menuButton.tag = 101;
        [UIAppDelegate moveView1:menuView andView2:_myView moveLeft:YES];
        
        if ([UIAppDelegate isProUser])
        {
            [UIAppDelegate.obj_FlurryAd removeFromSuperview];
            
            [self.view setNeedsDisplayInRect:_myCollectionView.bounds];
        }
    }
    else
    {
        rightSideView.hidden = NO;
        _menuButton.tag = 100;
        [UIAppDelegate moveView1:menuView andView2:_myView moveLeft:NO];
    }
}



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
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Preference Button Clicked"];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PreferenceViewController *viewController = [[PreferenceViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"PreferenceViewController"] bundle:nil];
    
    UINavigationController *navContrl = [[UINavigationController alloc] initWithRootViewController:viewController];
    navContrl.navigationBarHidden = YES;
    
    [appDelegate.navigationController presentViewController:navContrl animated:YES completion:nil];
    
    //[self.navigationController pushViewController:viewController animated:YES];
    //[self presentViewController:self.navigationController animated:YES completion:nil];
}

- (IBAction)favoriteButtonAction:(UIButton *)sender
{
    /*FavoriteViewController *viewController = [[FavoriteViewController alloc] initWithNibName:@"FavoriteViewController" bundle:nil];
     
     [self.navigationController pushViewController:viewController animated:YES];*/
}

//loadImagesForPageNumber
#pragma mark - imageLoad

-(void)loadRefreshedImages
{
    if(![AppDelegate isNetworkAvailable]) {
        [UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!"];
        return;
    }
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED] ? @"" : [[[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO] objectForKey:@"userId"];
    
    
    NSString *urlString = MEME_EVERYONE;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"userID": userId, @"page_number" : @"1" , @"item_count" : [NSString stringWithFormat:@"%d",ITEMS_PER_PAGE]};
    
    if (![self isFromRefreshController]) {
        [UIAppDelegate activityShow];
        [self setFromRefreshController:YES];
    }
    
    NSLog(@"Started..");
    pageNum = 1;
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSError *error = nil;
         NSDictionary *JSON =(NSDictionary*)responseObject;
         
         if (error) {
             NSLog(@"Error serializing %@", error);
         }
         else
         {
             if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
             {
                 if(UIAppDelegate.photoArray.count>0)
                     [UIAppDelegate.photoArray removeAllObjects];
                 
                 NSArray *listArray = [JSON objectForKey:@"result"];
                 if(listArray.count > 0)
                     pageNum = pageNum + 1;
                 
                 totalMeme = [[JSON objectForKey:@"total"] intValue];
                 
                 for (NSDictionary *listDic in listArray)
                 {
                     MemePhoto *memePhoto = [[MemePhoto alloc] init];
                     
                     memePhoto.photoID = [listDic objectForKey:@"id"];
                     memePhoto.photoCategory = [listDic objectForKey:@"category"];
                     memePhoto.url = [listDic objectForKey:@"url"];
                     memePhoto.photoUploadby = [listDic objectForKey:@"upload_by"];
                     memePhoto.photoUploaddate = [listDic objectForKey:@"upload_date"];
                     memePhoto.photoLike = [listDic objectForKey:@"like"];
                     memePhoto.photoViewCount = [listDic objectForKey:@"view"];
                     memePhoto.baseURL = [JSON objectForKey:@"base_url"];
                     
                     memePhoto.photoStatus = [listDic objectForKey:@"status"];
                     memePhoto.photoMyFavorite = [listDic objectForKey:@"isMyFavorite"];
                     memePhoto.photoMyLike = [listDic objectForKey:@"isMyLike"];
                     
                     memePhoto.thumb100BaseURL = [JSON objectForKey:@"thumb100BaseUrl"];
                     memePhoto.thumb250BaseURL = [JSON objectForKey:@"thumb250BaseUrl"];
                     memePhoto.totalMeme = [[JSON objectForKey:@"total"] intValue];
                     
                     memePhoto.thumb100URL = [memePhoto.thumb100BaseURL stringByAppendingString:memePhoto.url];
                     memePhoto.thumb250URL = [memePhoto.thumb250BaseURL stringByAppendingString:memePhoto.url];
                     
                     memePhoto.photoURL = [memePhoto.baseURL stringByAppendingString:memePhoto.url];
                     
                     
                     BOOL test = [dbhelper isMemeIdExist:memePhoto.photoID];
                     if (!test)
                     {
                         [dbhelper insertWithMemeID:memePhoto.photoID
                                          likeCount:memePhoto.photoLike withCategory:@"1"];
                     }
                     
                     [UIAppDelegate.photoArray addObject:memePhoto];
                     
                     //NSLog(@"Everyone_server_PhotoID = %@",memePhoto.photoID);
                     
                 }
                 //NSLog(@"ended..");
                 //userPhotoArray = [dbhelper getAllMemes];
                 //[_myCollectionView reloadData];
                 
                 //[self performSelector:@selector(refresh:) withObject:nil afterDelay:1.0f];
                 [self refresh:nil];
                 NSLog(@"photoArray.count%lu",(unsigned long)UIAppDelegate.photoArray.count);
                 
             }
             else
             {
                 [self refresh:nil];
                 NSLog(@"photoArray.count%lu",(unsigned long)UIAppDelegate.photoArray.count);
             }
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         isLoadingMore = NO;
         [UIAppDelegate activityHide];
     }];
}

-(void)loadImagesForPageNumber:(int)pageNumber
{
    pageNumber = (pageNumber == 0) ? 1 : pageNumber;
    
    //if(pageNumber==1)
        //pageNum = 1;
    
    if(![AppDelegate isNetworkAvailable]) {
        [UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!"];
        return;
    }
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED] ? @"" : [[[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO] objectForKey:@"userId"];
    
    
    NSString *urlString = MEME_EVERYONE;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"userID": userId, @"page_number" : [NSString stringWithFormat:@"%d",pageNumber] , @"item_count" : [NSString stringWithFormat:@"%d",ITEMS_PER_PAGE]};
    
    if (![self isFromRefreshController]) {
        [UIAppDelegate activityShow];
        [self setFromRefreshController:YES];
    }
    
    NSLog(@"Started..");
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSError *error = nil;
         NSDictionary *JSON =(NSDictionary*)responseObject;
         
         if (error) {
             NSLog(@"Error serializing %@", error);
         }
         else
         {
             if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
             {
                 /*
                 if ([self isFromRefreshController])
                 {
                     [photoArray removeAllObjects];
                 }*/
                 
                 NSArray *listArray = [JSON objectForKey:@"result"];
                 if(listArray.count)
                     pageNum = pageNum + 1;
                 
                 totalMeme = [[JSON objectForKey:@"total"] intValue];
                 
                 for (NSDictionary *listDic in listArray)
                 {
                     MemePhoto *memePhoto = [[MemePhoto alloc] init];
                     
                     memePhoto.photoID = [listDic objectForKey:@"id"];
                     memePhoto.photoCategory = [listDic objectForKey:@"category"];
                     memePhoto.url = [listDic objectForKey:@"url"];
                     memePhoto.photoUploadby = [listDic objectForKey:@"upload_by"];
                     memePhoto.photoUploaddate = [listDic objectForKey:@"upload_date"];
                     memePhoto.photoLike = [listDic objectForKey:@"like"];
                     memePhoto.photoViewCount = [listDic objectForKey:@"view"];
                     memePhoto.baseURL = [JSON objectForKey:@"base_url"];
                     
                     memePhoto.photoStatus = [listDic objectForKey:@"status"];
                     memePhoto.photoMyFavorite = [listDic objectForKey:@"isMyFavorite"];
                     memePhoto.photoMyLike = [listDic objectForKey:@"isMyLike"];
                     
                     memePhoto.thumb100BaseURL = [JSON objectForKey:@"thumb100BaseUrl"];
                     memePhoto.thumb250BaseURL = [JSON objectForKey:@"thumb250BaseUrl"];
                     memePhoto.totalMeme = [[JSON objectForKey:@"total"] intValue];
                     
                     memePhoto.thumb100URL = [memePhoto.thumb100BaseURL stringByAppendingString:memePhoto.url];
                     memePhoto.thumb250URL = [memePhoto.thumb250BaseURL stringByAppendingString:memePhoto.url];
                     
                     memePhoto.photoURL = [memePhoto.baseURL stringByAppendingString:memePhoto.url];
                     
                     
                     BOOL test = [dbhelper isMemeIdExist:memePhoto.photoID];
                     if (!test)
                     {
                         [dbhelper insertWithMemeID:memePhoto.photoID
                                          likeCount:memePhoto.photoLike withCategory:@"1"];
                     }
                     
                     [UIAppDelegate.photoArray addObject:memePhoto];
                     
                     //NSLog(@"Everyone_server_PhotoID = %@",memePhoto.photoID);
                     
                 }
                 //NSLog(@"ended..");
                 //userPhotoArray = [dbhelper getAllMemes];
                 //[_myCollectionView reloadData];
                 
                 //[self performSelector:@selector(refresh:) withObject:nil afterDelay:1.0f];
                 [self refresh:nil];
                 NSLog(@"photoArray.count%lu",(unsigned long)UIAppDelegate.photoArray.count);
                 
             }
             else
             {
                 [self refresh:nil];
                 NSLog(@"photoArray.count%lu",(unsigned long)UIAppDelegate.photoArray.count);
             }
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         isLoadingMore = NO;
         [UIAppDelegate activityHide];
     }];
}

- (void)refresh:(id)sender
{
    //NSLog(@"Refreshing");
    
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        [_myCollectionView reloadData];
        isLoadingMore = NO;
        [UIAppDelegate activityHide];
    });*/
    
    [_myCollectionView reloadData];
    isLoadingMore = NO;
    [UIAppDelegate activityHide];
    NSLog(@"isLoadingMore = NO");
    
    // End the refreshing
    if (refreshControl)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
        
        [refreshControl endRefreshing];
    }
}


-(void)dismissSlideMenuButtonAction
{
    NSLog(@"MemeViewController dismissSlideMenu tapped!!");
    
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
        
        [self.view setNeedsDisplayInRect:_myCollectionView.bounds];
    }
}

#pragma mark - Custom Rating AlertView
-(void)danMessagePopupView:(DanMessagePopup *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DanMessage *dan = [danMessageArray objectAtIndex:0];
    switch (alertView.tag) {
        case 1:
            switch (buttonIndex) {
                case 0:
                    NSLog(@"buttonIndex=%ld",(long)buttonIndex);
                    for (MemePhoto *photo in UIAppDelegate.photoArray)
                    {
                        [dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
                        
                        /*
                        NSInteger numberOfBadges;
                        UIAppDelegate.badgeEveryoneMeme = UIAppDelegate.badgeEveryoneMeme - 1;
                        numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
                        numberOfBadges -=1;
                        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];*/
                    }
                    userPhotoArray = [dbhelper getAllMemes];
                    //\\[self viewWillAppear:YES];??
                    [_myCollectionView reloadData];
                    //_popupView.hidden = YES;
                    
                    
                    UIAppDelegate.currentBadgeMemeEveryOne = 0;
                    [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeEveryOne forKey:MEME_EVERYONE_CURRENT_COUNT];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [UIAppDelegate setAllBadgesCountForApplication];
                    [self updateBottomBadgeCount];
                    break;
                case 1:
                    for (MemePhoto *photo in UIAppDelegate.photoArray)
                    {
                        [dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
                        
                    }
                    userPhotoArray = [dbhelper getAllMemes];
                    [_myCollectionView reloadData];
                    //_popupView.hidden = YES;
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WILL_SHOW_MARKALL_POPUP_FOR_EVERYONE_MEME];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                    UIAppDelegate.currentBadgeMemeEveryOne = 0;
                    [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeEveryOne forKey:MEME_EVERYONE_CURRENT_COUNT];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [UIAppDelegate setAllBadgesCountForApplication];
                    [self updateBottomBadgeCount];
                    break;
                case 2:
                    //_popupView.hidden = YES;
                    break;
                    
                default:
                    break;
            }
            break;
        case 2:
            
            switch (buttonIndex) {
                case 0:
                    
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:dan.dan_url]])
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dan.dan_url]];
                    
                    break;
                case 1:
                    
                    break;
                case 2:
                    
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Add DACircular ProgressView
-(DACircularProgressView *)addCircularProgressView
{
    // Loading indicator
    CGRect frame = IS_IPAD ? CGRectMake(35.0f, 35.0f, 70.0f, 70.0f) : CGRectMake(15.0f, 15.0f, 40.0f, 40.0f);
    DACircularProgressView *progressView = [[DACircularProgressView alloc] initWithFrame:frame];
    progressView.userInteractionEnabled = NO;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        progressView.thicknessRatio = 0.1;
        progressView.roundedCorners = NO;
    } else {
        progressView.thicknessRatio = 0.2;
        progressView.roundedCorners = YES;
    }
    progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    
    return progressView;
}

#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end





















