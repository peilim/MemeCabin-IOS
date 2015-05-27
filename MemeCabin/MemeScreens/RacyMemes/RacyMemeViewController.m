//
//  RacyMemeViewController.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 28/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "RacyMemeViewController.h"
#import "HomeScreenViewController.h"
#import "PreferenceViewController.h"
#import "FavoriteViewController.h"

#import "AFNetworking.h"
#import "DACircularProgressView.h"
#import "UIImageView+WebCache.h"
#import "MemePhoto.h"

#import "MemesSwipeView.h"
#import "Cell.h"
#import "MenuView.h"

#import "DBHelper.h"

@interface RacyMemeViewController ()

{
    //NSMutableArray *photoArray;
    NSMutableArray *indexArray;
    
    int pageNum;
    NSInteger totalMeme;
    
    MenuView *menuView;
    
    DBHelper *dbhelper;
    
    AppDelegate *appdelegate;
    
    CustomBadge *badgeForRacyMeme;
    BOOL isButtonClicked;
    UIView *rightSideView;
    
    UIRefreshControl *refreshControl;
}
@property (nonatomic, assign) CGPoint lastContentOffset;

@end

@implementation RacyMemeViewController

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
    // Do any additional setup after loading the view from its nib.
    
//    if([UIAppDelegate isProUser])
//    {
//        [UIAppDelegate hideiAd];//hideAdMob];
//        [UIAppDelegate hideFlurryAd];
//    }
//    else
//    {
//        [UIAppDelegate ShowiAd];//ShowAdMob];
//        [UIAppDelegate showFlurryAd];
//    }
    
    isButtonClicked = NO;
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dbhelper = [[DBHelper alloc] init];
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
    
    UIAppDelegate.photoArray = [NSMutableArray array];
    indexArray = [NSMutableArray array];
    pageNum = 1;
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor darkGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    
    [refreshControl addTarget:self
                       action:@selector(loadRefreshedImages)
             forControlEvents:UIControlEventValueChanged];
    
    refreshControl.tag = 1000;
    [_myCollectionView addSubview:refreshControl];
    _myCollectionView.alwaysBounceVertical = YES;
    
    
    [self setFromRefreshController:NO];
    [self loadImagesForPageNumber:1];
    
    MyFlowLayout *myFlowLayout=[[MyFlowLayout alloc] init];
   [_myCollectionView setCollectionViewLayout:myFlowLayout animated:YES];
    
    [_myCollectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"Cell"];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
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
        //hideAdMob];
        [UIAppDelegate hideFlurryAd];
    }
    else
    {
        [UIAppDelegate addFlurryInView:_myView];
    }
    
    [[GoogleAnalyticsCustom getSharedInstance] setCurrentScreenName:@"Racy Meme Screen"];
    [_myCollectionView reloadData];
    
    if (UIAppDelegate.photoArray.count > 0) {
        [UIAppDelegate.photoArray removeLastObject];
    }
    
    [self updateBottomBadgeCount];
    //[UIAppDelegate showiAdInView:_myView Delegate:self];
}

-(void)updateBottomBadgeCount
{
    [badgeForRacyMeme removeFromSuperview];
    
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
        badgeForRacyMeme = [CustomBadge customBadgeWithString:badgeString
                                              withStringColor:[UIColor whiteColor]
                                               withInsetColor:[UIColor redColor]
                                               withBadgeFrame:YES
                                          withBadgeFrameColor:[UIColor whiteColor]
                                                    withScale:1.0
                                                  withShining:YES];
        
        [badgeForRacyMeme setFrame:
         CGRectMake(_backToHomeButton.frame.size.width-badgeForRacyMeme.frame.size.width/2,
                    -5,
                    badgeForRacyMeme.frame.size.width,
                    badgeForRacyMeme.frame.size.height)];
        [_backToHomeButton addSubview:badgeForRacyMeme];
    }
    else
        [badgeForRacyMeme removeFromSuperview];
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


#pragma mark CollectionView delegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return UIAppDelegate.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"Cell";
    
    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    MemePhoto *photo = [UIAppDelegate.photoArray objectAtIndex:indexPath.item];
    
    //******* Change Date: 9-Feb-2015 *********
    DACircularProgressView *_loadingIndicator = (DACircularProgressView *)[cell.imageView viewWithTag:123];
    if(!_loadingIndicator){
        _loadingIndicator = [self addCircularProgressView];
        [cell.imageView addSubview:_loadingIndicator];
        _loadingIndicator.tag = 123;
    }
    
    _loadingIndicator.progress = 0;
    _loadingIndicator.hidden = NO;
    
    //******* Change Date: 9-Feb-2015 *********
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:photo.thumb100URL]
                      placeholderImage:[UIImage imageNamed: IS_IPAD ? @"place_holder_ipad" : @"place_holder.png"]
                               options:0
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
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
//        NSLog(@"TRUE");
//        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frame_photo_grey.png"]];
//    }
//    else{
//        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frame_photo.png"]];
//    }
    
    
    //NSLog(@"x_%f_y_%f_%f_%f",cell.frame.origin.x,cell.frame.origin.y,cell.frame.size.height,cell.frame.size.width);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MemesSwipeView *swipeView = [[MemesSwipeView alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"MemesSwipeView"] bundle:nil];
    
    MemePhoto *memePhoto = [UIAppDelegate.photoArray objectAtIndex:indexPath.item];
    
    //Update Badge Count
    if ([dbhelper isViewed:memePhoto.photoID])
    {
        appdelegate.badgeRacyMeme = appdelegate.badgeRacyMeme;
        NSLog(@"if-appdelegate.badgeEveryoneMeme = %d",appdelegate.badgeRacyMeme);
    }
    else
    {
        /*
        appdelegate.badgeRacyMeme = appdelegate.badgeRacyMeme - 1;
        NSInteger numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
        numberOfBadges -=1;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
        NSLog(@"else-appdelegate.badgeEveryoneMeme = %d",appdelegate.badgeRacyMeme);*/
        
        if(indexPath.item==0)
        {
            UIAppDelegate.currentBadgeMemeRacy = UIAppDelegate.currentBadgeMemeRacy - 1;
            [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeRacy forKey:MEME_RACY_CURRENT_COUNT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [UIAppDelegate setAllBadgesCountForApplication];
            
            //Update Database ViewCount
            [dbhelper updateMemeView:@"1" withMemeID:memePhoto.photoID];
            [self updateBottomBadgeCount];
        }
        
        
    }
    
    /*
    if ((appdelegate.badgeEveryoneMeme+appdelegate.badgeMotivationalMeme+appdelegate.badgeRacyMeme) < 1) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }*/
    
    
    
    
    NSLog(@"Recymeme didSelect ID = %@",memePhoto.photoID);
    
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Show RacyMeme Details"];
    
    Cell *cell = (Cell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frame_photo_grey.png"]];
    
    MemePhoto *aPhoto = [UIAppDelegate.photoArray lastObject];
    [UIAppDelegate.photoArray addObject:aPhoto];
    
    [swipeView setPageNumber:pageNum];
    [swipeView setTotalMeme:totalMeme];
    [swipeView setImageIndex:indexPath.row];
    [swipeView setImageArray:UIAppDelegate.photoArray];
    [swipeView setControllerIdentifier:3];
    
    [self.navigationController pushViewController:swipeView animated:YES];
}

#pragma mark - ScrollView Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDragging");
    
    _lastContentOffset.x = scrollView.contentOffset.x;
    _lastContentOffset.y = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height)
    {
        [self setFromRefreshController:NO];
        if(!isloadingMore)
        {
            isloadingMore = YES;
            [self loadImagesForPageNumber:pageNum];
        }
        
    }
}

#pragma mark Button Actions
- (IBAction)backButtonAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

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
        
        [alert show];
    }
    else
    {
        for (MemePhoto *photo in UIAppDelegate.photoArray){
            [dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
            
            /*NSInteger numberOfBadges;
            UIAppDelegate.badgeRacyMeme = UIAppDelegate.badgeRacyMeme - 1;
            numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
            numberOfBadges -=1;
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];*/
        }
        //userUIAppDelegate.photoArray = [dbhelper getAllMemes];
        [_myCollectionView reloadData];
        //_popupView.hidden = YES;
        
        UIAppDelegate.currentBadgeMemeRacy = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeRacy forKey:MEME_RACY_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [UIAppDelegate setAllBadgesCountForApplication];
        [self updateBottomBadgeCount];
    }
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
}

- (IBAction)favoriteButtonAction:(UIButton *)sender
{
}

#pragma mark - imageLoad
-(void)loadRefreshedImages
{
    if(![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!"];
        return;
    }
    
    NSString *userId;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED]) {
        userId = @"";
    }
    else
    {
        NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
        userId = [userInfoDisct objectForKey:@"userId"];
    }
    
    NSString *urlString = MEME_RACY;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //NSDictionary *parameters = @{@"userID": userId};
    NSDictionary *parameters = @{@"userID": userId, @"page_number" : @"1" , @"item_count" : [NSString stringWithFormat:@"%d",ITEMS_PER_PAGE]};
    
    
    if (![self isFromRefreshController]) {
        [UIAppDelegate activityShow];
        [self setFromRefreshController:YES];
    }
    pageNum = 1;
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //[UIAppDelegate activityHide];
         
         NSError *error = nil;
         NSDictionary *JSON = (NSDictionary *)responseObject;//[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
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
                 if(listArray.count>0)
                     pageNum = pageNum + 1;
                 
                 totalMeme = [[JSON objectForKey:@"total"] intValue];
                 
                 for (NSDictionary *listDic in listArray)
                 {
                     
                     MemePhoto *photo = [[MemePhoto alloc] init];
                     
                     photo.photoID = [listDic objectForKey:@"id"];
                     photo.photoCategory = [listDic objectForKey:@"category"];
                     photo.url = [listDic objectForKey:@"url"];
                     photo.photoUploadby = [listDic objectForKey:@"upload_by"];
                     photo.photoUploaddate = [listDic objectForKey:@"upload_date"];
                     photo.photoLike = [listDic objectForKey:@"like"];
                     photo.photoViewCount = [listDic objectForKey:@"view"];
                     photo.baseURL = [JSON objectForKey:@"base_url"];
                     photo.photoStatus = [listDic objectForKey:@"status"];
                     photo.photoMyFavorite = [listDic objectForKey:@"isMyFavorite"];
                     photo.photoMyLike = [listDic objectForKey:@"isMyLike"];
                     
                     photo.thumb100BaseURL = [JSON objectForKey:@"thumb100BaseUrl"];
                     photo.thumb250BaseURL = [JSON objectForKey:@"thumb250BaseUrl"];
                     photo.totalMeme = [[JSON objectForKey:@"total"] intValue];
                     
                     photo.thumb100URL = [photo.thumb100BaseURL stringByAppendingString:photo.url];
                     photo.thumb250URL = [photo.thumb250BaseURL stringByAppendingString:photo.url];
                     
                     photo.photoURL = [photo.baseURL stringByAppendingString:photo.url];
                     
                     BOOL test = [dbhelper isMemeIdExist:photo.photoID];
                     if (!test)
                     {
                         [dbhelper insertWithMemeID:photo.photoID
                                          likeCount:photo.photoLike withCategory:@"3"];
                     }
                     
                     [UIAppDelegate.photoArray addObject:photo];
                     
                     //NSLog(@"Recymeme_server_PhotoID = %@",photo.photoID);
                 }
                 
                 //userUIAppDelegate.photoArray = [dbhelper getAllMemes];
                 //[_myCollectionView reloadData];
                 NSLog(@"UIAppDelegate.photoArray.count%lu",(unsigned long)UIAppDelegate.photoArray.count);
                 [self refresh:nil];
             }
             else
             {
                 NSLog(@"UIAppDelegate.photoArray.count%lu",(unsigned long)UIAppDelegate.photoArray.count);
                 [self refresh:nil];
             }
             
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         isloadingMore = NO;
         [UIAppDelegate activityHide];
     }];
}

-(void)loadImagesForPageNumber:(int)pageNumber
{
    pageNumber = (pageNumber == 0) ? 1 : pageNumber;
    
    if(![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!"];
        return;
    }
    
    NSString *userId;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED]) {
        userId = @"";
    }
    else
    {
        NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
        userId = [userInfoDisct objectForKey:@"userId"];
    }
    
    NSString *urlString = MEME_RACY;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //NSDictionary *parameters = @{@"userID": userId};
    NSDictionary *parameters = @{@"userID": userId, @"page_number" : [NSString stringWithFormat:@"%d",pageNumber] , @"item_count" : [NSString stringWithFormat:@"%d",ITEMS_PER_PAGE]};
    
    if (![self isFromRefreshController]) {
        [UIAppDelegate activityShow];
        [self setFromRefreshController:YES];
    }
    
    if (![self isFromRefreshController]) {
        [UIAppDelegate activityShow];
        [self setFromRefreshController:YES];
    }
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //[UIAppDelegate activityHide];
         
         NSError *error = nil;
         NSDictionary *JSON = (NSDictionary *)responseObject;//[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
         if (error)
         {
             NSLog(@"Error serializing %@", error);
         }
         else
         {
             if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
             {
                 /*
                 if ([self isFromRefreshController]) {
                     [UIAppDelegate.photoArray removeAllObjects];
                 }*/
                 
                 
                 NSArray *listArray = [JSON objectForKey:@"result"];
                 if(listArray.count>0)
                     pageNum = pageNum + 1;
                 
                 totalMeme = [[JSON objectForKey:@"total"] intValue];
                 
                 for (NSDictionary *listDic in listArray)
                 {
                     
                     MemePhoto *photo = [[MemePhoto alloc] init];
                     
                     photo.photoID = [listDic objectForKey:@"id"];
                     photo.photoCategory = [listDic objectForKey:@"category"];
                     photo.url = [listDic objectForKey:@"url"];
                     photo.photoUploadby = [listDic objectForKey:@"upload_by"];
                     photo.photoUploaddate = [listDic objectForKey:@"upload_date"];
                     photo.photoLike = [listDic objectForKey:@"like"];
                     photo.photoViewCount = [listDic objectForKey:@"view"];
                     photo.baseURL = [JSON objectForKey:@"base_url"];
                     photo.photoStatus = [listDic objectForKey:@"status"];
                     photo.photoMyFavorite = [listDic objectForKey:@"isMyFavorite"];
                     photo.photoMyLike = [listDic objectForKey:@"isMyLike"];
                     
                     photo.thumb100BaseURL = [JSON objectForKey:@"thumb100BaseUrl"];
                     photo.thumb250BaseURL = [JSON objectForKey:@"thumb250BaseUrl"];
                     photo.totalMeme = [[JSON objectForKey:@"total"] intValue];
                     
                     photo.thumb100URL = [photo.thumb100BaseURL stringByAppendingString:photo.url];
                     photo.thumb250URL = [photo.thumb250BaseURL stringByAppendingString:photo.url];
                     
                     photo.photoURL = [photo.baseURL stringByAppendingString:photo.url];
                     
                     BOOL test = [dbhelper isMemeIdExist:photo.photoID];
                     if (!test) {
                         [dbhelper insertWithMemeID:photo.photoID
                                          likeCount:photo.photoLike withCategory:@"3"];
                     }
                     
                     [UIAppDelegate.photoArray addObject:photo];
                     
                     //NSLog(@"Recymeme_server_PhotoID = %@",photo.photoID);
                 }
                 
                 //userUIAppDelegate.photoArray = [dbhelper getAllMemes];
                 //[_myCollectionView reloadData];
                 NSLog(@"UIAppDelegate.photoArray.count%lu",(unsigned long)UIAppDelegate.photoArray.count);
                 [self refresh:nil];
             }
             else
             {
                 NSLog(@"UIAppDelegate.photoArray.count%lu",(unsigned long)UIAppDelegate.photoArray.count);
                 [self refresh:nil];
             }
             
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         isloadingMore = NO;
         [UIAppDelegate activityHide];
     }];
} 

- (void)refresh:(id)sender {
    //NSLog(@"Refreshing");
    dispatch_async(dispatch_get_main_queue(), ^{
        [_myCollectionView reloadData];
        isloadingMore = NO;
        [UIAppDelegate activityHide];
    });
    
    // End the refreshing
    if (refreshControl)
    {
        //[_myCollectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
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

#pragma mark - SlideMenu Actions
-(void)rateButtonAction
{
    
}

-(void)disableAdButtonAction
{
    
}

-(void)getSDLButtonAction
{
    
    
    /*
     SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
     
     // Configure View Controller
     [storeProductViewController setDelegate:self];
     [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : @"767995612"} completionBlock:^(BOOL result, NSError *error) {
     if (error) {
     NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
     
     } else {
     // Present Store Product View Controller
     [self presentViewController:storeProductViewController animated:YES completion:nil];
     }
     }];
     */
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissSlideMenuButtonAction
{
    NSLog(@"RacyViewController dismissSlideMenu tapped!!");
    
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


//#pragma mark - iAd & Flurry Delegate
//- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
//{
//    [UIAppDelegate.iAdBannerView removeFromSuperview];
//    [UIAppDelegate showFlurryAdInView:_myView Delegate:self viewController:self];
//}
//- (void)spaceDidFailToReceiveAd:(NSString *)adSpace error:(NSError *)error
//{
//    if ([adSpace isEqualToString:FlurryBannerAdName]) {
//        [UIAppDelegate.flurryBannerView removeFromSuperview];
//        [UIAppDelegate showiAdInView:_myView Delegate:self];
//    }
//}

#pragma mark - Custom Rating AlertView
-(void)danMessagePopupView:(DanMessagePopup *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            for (MemePhoto *photo in UIAppDelegate.photoArray){
                [dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
                
                /*
                NSInteger numberOfBadges;
                UIAppDelegate.badgeRacyMeme = UIAppDelegate.badgeRacyMeme - 1;
                numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
                numberOfBadges -=1;
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];*/
            }
            //\\[self viewWillAppear:YES];
            [_myCollectionView reloadData];
            //_popupView.hidden = YES;
            
            
            UIAppDelegate.currentBadgeMemeRacy = 0;
            [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeRacy forKey:MEME_RACY_CURRENT_COUNT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [UIAppDelegate setAllBadgesCountForApplication];
            [self updateBottomBadgeCount];
            break;
        case 1:
            for (MemePhoto *photo in UIAppDelegate.photoArray){
                [dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
                
            }
            //userUIAppDelegate.photoArray = [dbhelper getAllMemes];
            [_myCollectionView reloadData];
            //_popupView.hidden = YES;
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WILL_SHOW_MARKALL_POPUP_FOR_EVERYONE_MEME];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIAppDelegate.currentBadgeMemeRacy = 0;
            [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeRacy forKey:MEME_RACY_CURRENT_COUNT];
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

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
