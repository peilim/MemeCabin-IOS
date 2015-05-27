//
//  FavoriteViewController.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 28/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "FavoriteViewController.h"
#import "HomeScreenViewController.h"
#import "PreferenceViewController.h"

#import "MemesSwipeView.h"
#import "Cell.h"
#import "MenuView.h"
#import "DBHelper.h"

#import "AFNetworking.h"
#import "DACircularProgressView.h"
#import "MemePhoto.h"
#import "UIImageView+WebCache.h"


@interface FavoriteViewController ()

{
    //NSMutableArray *photoArray;
    NSMutableArray *indexArray;
    
    int pageNum;
    NSInteger totalMeme;
    
    MenuView *menuView;
    DBHelper *dbhelper;
    UIRefreshControl *refreshControl;
    
    AppDelegate *appDelegate;
    BOOL isButtonClicked;
    UIView *rightSideView;
    
    CustomBadge *badgeForAllMeme;
}
@property (nonatomic, assign) CGPoint lastContentOffset;
@end

@implementation FavoriteViewController

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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dbhelper = [[DBHelper alloc] init];
    //favoriteArray = [NSMutableArray array];
    
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
    [_myCollectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"Cell"];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor darkGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    _myCollectionView.alwaysBounceVertical = YES;
    [refreshControl addTarget:self
                       action:@selector(loadImagesForPageNumber:)
             forControlEvents:UIControlEventValueChanged];
    
    refreshControl.tag = 1000;
    [_myCollectionView addSubview:refreshControl];
    
    MyFlowLayout *myFlowLayout=[[MyFlowLayout alloc] init];
    [_myCollectionView setCollectionViewLayout:myFlowLayout animated:YES];
    
    [self setFromRefreshController:NO];
    
    
    if([UIAppDelegate isProUser])
    {
        //hideAdMob];
        [UIAppDelegate hideFlurryAd];
    }
    else
    {
        [UIAppDelegate addFlurryInView:_myView];
    }
    
    [[GoogleAnalyticsCustom getSharedInstance] setCurrentScreenName:@"Meme Favourite Screen"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED])
    {
        _btn_noFav.userInteractionEnabled = YES;
        _lbl_noFav.text = @"Bad news bear. \nThis section is for logged-in users only!";
        
        UIImage *buttonImage = [UIImage imageNamed:@"topbar_green.png"];
        _btn_noFav.frame = CGRectMake(padFactor, 206*padFactor, 170*padFactor, 30*padFactor);
        _btn_noFav.center = CGPointMake(self.view.frame.size.width/2, 206*factorY);
        
        [_btn_noFav setBackgroundImage:buttonImage forState:UIControlStateNormal];
        
        [_btn_noFav setTitle:@"Take me to Login" forState:UIControlStateNormal];
        [_btn_noFav setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btn_noFav.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTPro-ThEx" size:18*padFactor];
        _btn_noFav.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        [self loadImagesForPageNumber:1];
    }
    
    
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
    
    /*
    if([UIAppDelegate isProUser])
    {
        //hideAdMob];
        [UIAppDelegate hideFlurryAd];
    }
    else
    {
        [UIAppDelegate addFlurryInView:_myView];
    }
    
    [[GoogleAnalyticsCustom getSharedInstance] setCurrentScreenName:@"Meme Favourite Screen"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED])
    {
        _btn_noFav.userInteractionEnabled = YES;
        _lbl_noFav.text = @"Bad news bear. \nThis section is for logged-in users only!";
        
        UIImage *buttonImage = [UIImage imageNamed:@"topbar_green.png"];
        _btn_noFav.frame = CGRectMake(padFactor, 206*padFactor, 170*padFactor, 30*padFactor);
        _btn_noFav.center = CGPointMake(self.view.frame.size.width/2, 206*factorY);
        
        [_btn_noFav setBackgroundImage:buttonImage forState:UIControlStateNormal];
        
        [_btn_noFav setTitle:@"Take me to Login" forState:UIControlStateNormal];
        [_btn_noFav setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btn_noFav.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTPro-ThEx" size:18*padFactor];
        _btn_noFav.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        [self loadImagesForPageNumber:1];
    }
     */
    
    if (UIAppDelegate.photoArray.count > 0)
    {
        [UIAppDelegate.photoArray removeLastObject];
    }
    
    [self updateBottomBadgeCount];
    //[UIAppDelegate showiAdInView:_myView Delegate:self];
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
            badgeString = [NSString stringWithFormat:@"%d",(UIAppDelegate.currentBadgeMemeEveryOne+UIAppDelegate.currentBadgeMemeMotiInsp+UIAppDelegate.currentBadgeMemeRacy+UIAppDelegate.currentBadgeMemeSpiffyGif)];
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

-(void)viewDidLayoutSubviews
{
    //NSLog(@"viewDidLayoutSubviews");
    
    if ([UIAppDelegate isProUser]) {
        CGFloat collectionViewHeight = 0;
        if (IS_IPHONE) {
            if (IS_IPHONE_4INCHES) {
                collectionViewHeight = 412; }
            else { collectionViewHeight = 325; }
        } else { collectionViewHeight = 743; }
        
        _myCollectionView.frame = CGRectMake(0,
                                             101*factorY,
                                             320*factorX, collectionViewHeight);
    }
}

#pragma mark CollectionView delegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSLog(@"UIAppDelegate.photoArray.count %lu",(unsigned long)UIAppDelegate.photoArray.count);
    
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
    
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"frame_photo.png"]];
    
    UILongPressGestureRecognizer *longPressGesture = [[ UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	longPressGesture.minimumPressDuration = 1.0;
    [cell addGestureRecognizer:longPressGesture];
    
    [cell.deleteButton addTarget:self action:@selector(deleteAlert:) forControlEvents:UIControlEventTouchUpInside];
    if (self.isEditMode) {
        cell.deleteButton.hidden = NO;
    }
    else {
        cell.deleteButton.hidden = YES;
    }
    //cell.deleteButton.tag = indexPath.item+1;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath");
    
    if ([self isEditMode])
    {
        NSLog(@"isEditMode TRUE");
        
        for (UIView *view in [_myCollectionView subviews])
        {
            if ([view isKindOfClass:[Cell class]])
            {
                Cell *cell = (Cell *)view;
                cell.deleteButton.hidden = YES;
                [_myCollectionView reloadData];
                [self setEditMode:NO];
            }
        }
        
    }
    else
    {
        [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Show Favourite Meme Details"];
        
        MemesSwipeView *swipeView = [[MemesSwipeView alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"MemesSwipeView"] bundle:nil];
        
        [swipeView setImageIndex:indexPath.row];
        
        MemePhoto *aPhoto = [UIAppDelegate.photoArray lastObject];
        [UIAppDelegate.photoArray addObject:aPhoto];
        
        [swipeView setPageNumber:pageNum];
        [swipeView setTotalMeme:totalMeme];
        [swipeView setImageArray:UIAppDelegate.photoArray];
        [swipeView setControllerIdentifier:4];
        
        [self.navigationController pushViewController:swipeView animated:YES];
    }
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
        if(!isLoadingMore)
        {
            isLoadingMore = YES;
            [self loadImagesForPageNumber:pageNum];
        }
    }
}

#pragma mark - Other
-(void) handleLongPress:(UILongPressGestureRecognizer *)recognizer  {
    
    [self setEditMode:YES];
    
    for (UIView *view in [_myCollectionView subviews])
    {
        if ([view isKindOfClass:[Cell class]])
        {
            Cell *cell = (Cell *)view;
            cell.deleteButton.hidden = NO;
        }
    }
    
}

-(void) deleteAlert:(UIButton *)sender
{
    
    Cell *cell = (Cell *)[[sender superview] superview];
    NSIndexPath *indexPath = [_myCollectionView indexPathForCell:cell];
    _findIndexPath = indexPath;
    NSLog(@"INDEXPATH=%ld",(long)indexPath.item);
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation!"
                                                    message:@"Do you want to delete!"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    [alert addButtonWithTitle:@"Ok"];
    [alert show];
}

#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    Cell *cell = (Cell *)[_myCollectionView cellForItemAtIndexPath:_findIndexPath];
    NSIndexPath *indexPath = [_myCollectionView indexPathForCell:cell];
    MemePhoto *memePhoto = [UIAppDelegate.photoArray objectAtIndex:indexPath.item];
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel");
            break;
        case 1:
            NSLog(@"Ok");
            
            [self updateMemeFavouriteAtIndex:indexPath ofMemeID:memePhoto.photoID];
            
            break;
            
        default:
            break;
    }
}

#pragma mark Button Actions
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
    
    if (sender.tag == 100)
    {
        rightSideView.hidden = YES;
        _menuButton.tag = 101;
        [UIAppDelegate moveView1:menuView andView2:_myView moveLeft:YES];
        
        if ([UIAppDelegate isProUser])
        {
            //[UIAppDelegate.obj_iAd removeFromSuperview];
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
    
    PreferenceViewController *viewController = [[PreferenceViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"PreferenceViewController"] bundle:nil];
    
    UINavigationController *navContrl = [[UINavigationController alloc] initWithRootViewController:viewController];
    navContrl.navigationBarHidden = YES;
    
    [appDelegate.navigationController presentViewController:navContrl animated:YES completion:nil];
}

-(IBAction)btn_noFavAction:(UIButton *)sender
{
    appDelegate.isFromFavourite = YES;
    NSLog(@"btn_noFavAction");
    LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"LoginViewController"] bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - imageLoad
-(void)loadRefreshesImages
{
    if(![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!"];
        return;
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED]) {
        return;
    }
    
    NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
    NSString *userId = [userInfoDisct objectForKey:@"userId"];
    
    NSLog(@"userId=%@",userId);
    
    NSString *urlString = MEME_FAVOURITE_LIST;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //NSDictionary *parameters = @{@"userId": userId};
    NSDictionary *parameters = @{@"userID": userId, @"page_number" : @"1" , @"item_count" : [NSString stringWithFormat:@"%d",ITEMS_PER_PAGE]};
    
    if (![self isFromRefreshController]) {
        [UIAppDelegate activityShow];
        [self setFromRefreshController:YES];
    }
    
    if (![self isFromRefreshController]) {
        [UIAppDelegate activityShow];
        [self setFromRefreshController:YES];
    }
    pageNum = 1;
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
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
                /*
                if ([self isFromRefreshController]) {
                    [UIAppDelegate.photoArray removeAllObjects];
                }
                */
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
                    photo.photoLike = [listDic objectForKey:@"allLike"];
                    photo.baseURL = [JSON objectForKey:@"base_url"];
                    photo.photoMyFavorite = [listDic objectForKey:@"isMyFavorite"];
                    photo.photoMyLike = [listDic objectForKey:@"isMyLike"];
                    
                    photo.thumb100BaseURL = [JSON objectForKey:@"thumb100BaseUrl"];
                    photo.thumb250BaseURL = [JSON objectForKey:@"thumb250BaseUrl"];
                    photo.totalMeme = [[JSON objectForKey:@"total"] intValue];
                    
                    photo.thumb100URL = [photo.thumb100BaseURL stringByAppendingString:photo.url];
                    photo.thumb250URL = [photo.thumb250BaseURL stringByAppendingString:photo.url];
                    
                    photo.photoURL = [photo.baseURL stringByAppendingString:photo.url];
                    [UIAppDelegate.photoArray addObject:photo];
                    NSLog(@"photo.photoURL=%@",photo.photoURL);
                }
                
                _noFavouriteView.hidden = YES;
                
                
            }
            else
            {
                if ([[JSON objectForKey:@"message"] isEqualToString:@"ZERO_RESULT"]) {
                    _noFavouriteView.hidden = NO;
                    
                    NSLog(@"UIAppDelegate.photoArray.count < 1");
                    
                    _btn_noFav.userInteractionEnabled = NO;
                    _lbl_noFav.text = @"Tap this button at any time while you're swiping through memes to add memes to your favorites.";
                    UIImage *buttonImage = [UIImage imageNamed:@"star_green4.png"];
                    _btn_noFav.frame = CGRectMake(0, 206*padFactor, 86*padFactor, 86*padFactor);
                    _btn_noFav.center = CGPointMake(self.view.frame.size.width/2, 236*factorY);
                    [_btn_noFav setImage:buttonImage forState:UIControlStateNormal];
                }
            }
            
            //[_myCollectionView reloadData];
            //\\UIAppDelegate.userFavouriteNumber = UIAppDelegate.photoArray.count;
            NSInteger aFavCount = UIAppDelegate.photoArray.count;
            UIAppDelegate.userFavouriteNumber = ((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? ((aFavCount >= [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT]) ?  aFavCount : [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT]) : aFavCount;
            _favoriteCountLabel.text = [NSString stringWithFormat:@"Your saved Favorites (%lu)",(unsigned long)UIAppDelegate.photoArray.count];
            
            [[NSUserDefaults standardUserDefaults] setInteger:aFavCount forKey:MEME_FAVORITE_CURRENT_COUNT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"loadFavoriteMemes() userFavouriteNumber===%ld",(long)appDelegate.userFavouriteNumber);
            
            [self refresh:nil];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
        NSLog(@"Error: %@", error);
         isLoadingMore = NO;
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
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED]) {
        return;
    }
    
    NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
    NSString *userId = [userInfoDisct objectForKey:@"userId"];
    
    NSLog(@"userId=%@",userId);
    
    NSString *urlString = MEME_FAVOURITE_LIST;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //NSDictionary *parameters = @{@"userId": userId};
    NSDictionary *parameters = @{@"userID": userId, @"page_number" : [NSString stringWithFormat:@"%d",pageNumber] , @"item_count" : [NSString stringWithFormat:@"%d",ITEMS_PER_PAGE]};
    
    if (![self isFromRefreshController]) {
        [UIAppDelegate activityShow];
        [self setFromRefreshController:YES];
    }
    
    if (![self isFromRefreshController]) {
        [UIAppDelegate activityShow];
        [self setFromRefreshController:YES];
    }
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        //[UIAppDelegate activityHide];
        
        NSError *error = nil;
        NSDictionary *JSON = (NSDictionary *)responseObject;//[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"Error serializing %@", error);
            [self refresh:nil];
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
                    photo.photoLike = [listDic objectForKey:@"allLike"];
                    photo.baseURL = [JSON objectForKey:@"base_url"];
                    photo.photoMyFavorite = [listDic objectForKey:@"isMyFavorite"];
                    photo.photoMyLike = [listDic objectForKey:@"isMyLike"];
                    
                    photo.thumb100BaseURL = [JSON objectForKey:@"thumb100BaseUrl"];
                    photo.thumb250BaseURL = [JSON objectForKey:@"thumb250BaseUrl"];
                    photo.totalMeme = [[JSON objectForKey:@"total"] intValue];
                    
                    photo.thumb100URL = [photo.thumb100BaseURL stringByAppendingString:photo.url];
                    photo.thumb250URL = [photo.thumb250BaseURL stringByAppendingString:photo.url];
                    
                    photo.photoURL = [photo.baseURL stringByAppendingString:photo.url];
                    [UIAppDelegate.photoArray addObject:photo];
                    NSLog(@"photo.photoURL=%@",photo.photoURL);
                }
                
                 _noFavouriteView.hidden = YES;
                
                
            }
            else
            {
                if ([[JSON objectForKey:@"message"] isEqualToString:@"ZERO_RESULT"]) {
                    _noFavouriteView.hidden = NO;
                    
                    NSLog(@"UIAppDelegate.photoArray.count < 1");
                    
                    _btn_noFav.userInteractionEnabled = NO;
                    _lbl_noFav.text = @"Tap this button at any time while you're swiping through memes to add memes to your favorites.";
                    UIImage *buttonImage = [UIImage imageNamed:@"star_green4.png"];
                    _btn_noFav.frame = CGRectMake(0, 206*padFactor, 86*padFactor, 86*padFactor);
                    _btn_noFav.center = CGPointMake(self.view.frame.size.width/2, 236*factorY);
                    [_btn_noFav setImage:buttonImage forState:UIControlStateNormal];
                }
            }
            
            //[_myCollectionView reloadData];
            //\\UIAppDelegate.userFavouriteNumber = UIAppDelegate.photoArray.count;
            NSInteger aFavCount = UIAppDelegate.photoArray.count;
            UIAppDelegate.userFavouriteNumber = ((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? ((aFavCount >= [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT]) ?  aFavCount : [[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT]) : aFavCount;
            _favoriteCountLabel.text = [NSString stringWithFormat:@"Your saved Favorites (%lu)",(unsigned long)UIAppDelegate.photoArray.count];
            
            [[NSUserDefaults standardUserDefaults] setInteger:aFavCount forKey:MEME_FAVORITE_CURRENT_COUNT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"loadFavoriteMemes() userFavouriteNumber===%ld",(long)appDelegate.userFavouriteNumber);
            
            [self refresh:nil];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        isLoadingMore = NO;
        [UIAppDelegate activityHide];
    }];
}

- (void)refresh:(id)sender {
    //NSLog(@"Refreshing");
    dispatch_async(dispatch_get_main_queue(), ^{
        [_myCollectionView reloadData];
        isLoadingMore = NO;
        [UIAppDelegate activityHide];
    });
    
    // End the refreshing
    if (refreshControl) {
        
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
    NSLog(@"FavouriteViewController dismissSlideMenu tapped!!");
    
    if (isButtonClicked) {
        isButtonClicked = NO;
        return;
    }
    
    _menuButton.tag = 101;
    rightSideView.hidden = YES;
    [UIAppDelegate moveView1:menuView andView2:_myView moveLeft:YES];
    
    if ([UIAppDelegate isProUser])
    {
        //[UIAppDelegate.obj_iAd removeFromSuperview];
        [UIAppDelegate.obj_FlurryAd removeFromSuperview];
        
        [self.view setNeedsDisplayInRect:_myCollectionView.bounds];
    }
}

#pragma mark - updateMemeFavourite
-(void)updateMemeFavouriteAtIndex:(NSIndexPath *)indexPath ofMemeID:(NSString *)memeId
{
    if(![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Failure" message:@"No internet connection!"];
        return;
    }
    
    Cell *cell = (Cell *)[_myCollectionView cellForItemAtIndexPath:indexPath];
    //NSIndexPath *indexPath = [_myCollectionView indexPathForCell:cell];
    //MemePhoto *memePhoto = [UIAppDelegate.photoArray objectAtIndex:indexPath.item];
    
    NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
    
    NSString *memeid = memeId;
    NSString *userId = [userInfoDisct objectForKey:@"userId"];
    
    
    NSString *urlString;
    urlString = MEME_MAKE_UNFAVOURITE;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //\\NSDictionary *parameters = @{@"userid":userId, @"memeid":memeid};
    NSDictionary *parameters = @{@"userID":userId, @"memeid":memeid};
    [UIAppDelegate activityShow];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
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
                NSLog(@"Status : 1");
                cell.deleteButton.hidden = YES;
                [UIAppDelegate.photoArray removeObjectAtIndex:indexPath.item];
                [cell removeFromSuperview];
                [_myCollectionView reloadData];
                
                _favoriteCountLabel.text = [NSString stringWithFormat:@"Your saved Favorites (%lu)",(unsigned long)UIAppDelegate.photoArray.count];
                
                //\\UIAppDelegate.userFavouriteNumber = [UIAppDelegate.photoArray count];
                UIAppDelegate.userFavouriteNumber = ((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? ([[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT] - 1) : 0;
                [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.userFavouriteNumber forKey:MEME_FAVORITE_CURRENT_COUNT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                 NSLog(@"updateFavoriteMemes() userFavouriteNumber===%ld",(long)appDelegate.userFavouriteNumber);
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [UIAppDelegate activityHide];
    }];
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
