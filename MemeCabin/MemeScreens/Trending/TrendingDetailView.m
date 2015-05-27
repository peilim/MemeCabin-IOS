//
//  TrendingDetailView.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 01/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "TrendingDetailView.h"
#import "ShareTrendMeme.h"
#import "HomeScreenViewController.h"
#import "PreferenceViewController.h"
#import "FavoriteViewController.h"
#import "MenuView.h"
#import "TableCell.h"
#import "MemePhoto.h"
#import "DBHelper.h"

#import "AFNetworking.h"
#import "DACircularProgressView.h"
#import "UIImageView+WebCache.h"

@interface TrendingDetailView ()
{
    MenuView *menuView;
    NSMutableArray *photoArray;
    DBHelper *dbhelper;
    MemePhoto *photo;
    
    UIRefreshControl *refreshControl;
    BOOL isButtonClicked;
    UIView *rightSideView;
    
    UIView *tableHederView;
    
    CustomBadge *badgeForAllMeme;
}


@end

@implementation TrendingDetailView

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
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor purpleColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self
                       action:@selector(loadImagesWithDay)
             forControlEvents:UIControlEventValueChanged];
    
    refreshControl.tag = 1000;
    [_myTableView addSubview:refreshControl];
    _myTableView.alwaysBounceVertical = YES;
    
    _myTableView.tableHeaderView = [self addTableHeaderView];
    
    _tableViewTitle.text = _titleStr;
    
    NSLog(@"_titleStr=======%@",_titleStr);
    
    [self setFromRefreshController:NO];
    [self loadImagesWithDay];
    //[self.myTableView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellReuseIdentifier:@"testCell"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[GoogleAnalyticsCustom getSharedInstance] setCurrentScreenName:@"Trending Details Screen"];
    //[UIAppDelegate showiAdInView:_myView Delegate:self];
    
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
    
    if (photoArray.count > 0) {
        [photoArray removeLastObject];
    }
}

-(void)viewDidLayoutSubviews
{
    //NSLog(@"viewDidLayoutSubviews");
    
    if ([UIAppDelegate isProUser]) {
        CGFloat collectionViewHeight = 0;
        if (IS_IPHONE) {
            if (IS_IPHONE_4INCHES) {
                collectionViewHeight = 334; }
            else { collectionViewHeight = 248; }
        } else { collectionViewHeight = 606; }
        
        _myTableView.frame = CGRectMake(0,
                                             (179*factorY)-factorMinus,
                                             320*factorX, collectionViewHeight);
    }
}

#pragma mark TableView delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [photoArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"cellTest";
    
    TableCell *cell =(TableCell*) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    [[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];
    //cell.backgroundColor = [UIColor clearColor];
    
    if (cell == nil) {
        cell = [[TableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TableCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    ///
    
    photo = [photoArray objectAtIndex:indexPath.row];
    
    
    //******* Change Date: 9-Feb-2015 *********
    DACircularProgressView *_loadingIndicator = (DACircularProgressView *)[cell.imageView viewWithTag:123];
    if(!_loadingIndicator){
        _loadingIndicator = [self addCircularProgressView];
        [cell.leftImageView addSubview:_loadingIndicator];
        _loadingIndicator.tag = 123;
    }
    
    _loadingIndicator.progress = 0;
    _loadingIndicator.hidden = NO;
    
    //******* Change Date: 9-Feb-2015 *********
    
    [cell.leftImageView sd_setImageWithURL:[NSURL URLWithString:IS_IPAD ? photo.thumb250URL : photo.thumb100URL]
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
                                  cell.leftImageView.image = image;
                                  
                              }];
    
    cell.leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.totalLikesLabel.text = [NSString stringWithFormat:@"Total Likes (%@)",photo.allLike];
    cell.numberLabel.text = [NSString stringWithFormat:@"#%ld",indexPath.row+1];
    
    //Check if Liked
    if ([photo.photoMyLike isEqualToString:@"1"]){
        [cell.rightButton setImage:[UIImage imageNamed:@"like_white.png"] forState:UIControlStateNormal];
        cell.rightButton.tag = 100;
    }else{
        [cell.rightButton setImage:[UIImage imageNamed:@"qq_12.png"] forState:UIControlStateNormal];
        cell.rightButton.tag = 101;
    }
    
    //Like button action
    [cell.rightButton addTarget:self action:@selector(deleteButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    //cell.rightButton.tag = indexPath.row;
    
    switch (_topMemeByDays)
    {
        case 1:
            cell.trendingLikesLabel.text = [NSString stringWithFormat:@"Today's Likes (%@)",photo.daytotalLike];
            break;
        case 7:
            cell.trendingLikesLabel.text = [NSString stringWithFormat:@"7 Day's Likes (%@)",photo.daySeventotalLike];
            break;
        case 30:
            cell.trendingLikesLabel.text = [NSString stringWithFormat:@"30 Day's Likes (%@)",photo.dayThirtytotalLike];
            break;
        case 90:
            cell.trendingLikesLabel.text = [NSString stringWithFormat:@"90 Day's Likes (%@)",photo.dayNinetytotalLike];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)deleteButtonTapped:(UIControl *)button withEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [_myTableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView:_myTableView]];
    
    if (indexPath == nil) {
        return;
    }
    
    photo = [photoArray objectAtIndex:indexPath.row];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED])
    {
        DanMessagePopup *alert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self label1:@"Oops!" label2:@"You need to be logged-in to like or favorite memes on MemeCabin." button1stTitle:@"Got it, take me to login." button2ndTitle:@"Eek. No thanks." button3rdTitle:nil button4thTitle:nil  showTopBlackBar:NO];
        [alert show];
        return;
    }
    
    if (button.tag == 100)
    {
        [self updateMemeLike:0 indexPath:indexPath];
        //[dbhelper updateMemeLike:@"0" withMemeID:photo.photoID];
    }
    else
    {
        [self updateMemeLike:1 indexPath:indexPath];
        //[dbhelper updateMemeLike:@"1" withMemeID:photo.photoID];
        
        button.tag = 100;
        [(UIButton *)button setImage:[UIImage imageNamed:@"like_white.png"] forState:UIControlStateNormal];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Show Trending Details"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    ShareTrendMeme *viewController = [[ShareTrendMeme alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"ShareTrendMeme"] bundle:nil];
    
    TableCell *cell = (TableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    photo = [photoArray objectAtIndex:indexPath.row];
    
    MemePhoto *pho = [photoArray  objectAtIndex:indexPath.row];
    
    viewController.trendingDetailView = self;
    [viewController setTitleStr:_titleStr];
    [viewController setNumberLabelStr:cell.numberLabel.text];
    [viewController setTodaysLikeStr:photo.daytotalLike];
    [viewController setSevenDaysLikeStr:photo.daySeventotalLike];
    [viewController setThirtyDaysLikeStr:photo.dayThirtytotalLike];
    [viewController setTotalLikeStr:photo.dayNinetytotalLike];
    
    [photoArray addObject:pho];
    
    [viewController setImageArray:photoArray];
    [viewController setImageIndex:indexPath.row];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 54.0*factorY;
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return [self addTableHeaderView];
//}

#pragma mark ButtonActions
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
            
            [self.view setNeedsDisplayInRect:_myTableView.bounds];
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
    //    FavoriteViewController *viewController = [[FavoriteViewController alloc] initWithNibName:@"FavoriteViewController" bundle:nil];
    //
    //    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - updateMemeLike
-(void)updateMemeLike:(int)param indexPath:(NSIndexPath *)indexPath
{
    photo = [photoArray objectAtIndex:indexPath.row];
    TableCell *cell = (TableCell *)[_myTableView cellForRowAtIndexPath:indexPath];
    
    int todaysLikes = [photo.daytotalLike intValue];
    int sevenDaysLikes = [photo.daySeventotalLike intValue];
    int thirtyDaysLikes = [photo.dayThirtytotalLike intValue];
    int ninetyDaysLikes = [photo.dayNinetytotalLike intValue];
    int totalLikes = [photo.allLike intValue];
    
    if (param == 0)
    {
        [cell.rightButton setImage:[UIImage imageNamed:@"qq_12.png"] forState:UIControlStateNormal];
        
        if (todaysLikes > 0) {
            todaysLikes = todaysLikes - 1;
        }
        if (sevenDaysLikes > 0) {
            sevenDaysLikes = sevenDaysLikes - 1;
        }
        if (thirtyDaysLikes > 0) {
            thirtyDaysLikes = thirtyDaysLikes - 1;
        }
        if (totalLikes > 0) {
            totalLikes = totalLikes - 1;
        }
        if (ninetyDaysLikes > 0) {
            ninetyDaysLikes = ninetyDaysLikes - 1;
        }

        
    }
    else
    {
        [cell.rightButton setImage:[UIImage imageNamed:@"like_white.png"] forState:UIControlStateNormal];
        
        todaysLikes = todaysLikes + 1;
        sevenDaysLikes = sevenDaysLikes + 1;
        thirtyDaysLikes = thirtyDaysLikes + 1;
        totalLikes = totalLikes + 1;
        ninetyDaysLikes = ninetyDaysLikes + 1;

    }
    
    switch (_topMemeByDays)
    {
        case 1:
            cell.trendingLikesLabel.text = [NSString stringWithFormat:@"Today's Likes (%d)",todaysLikes];
            break;
        case 7:
            cell.trendingLikesLabel.text = [NSString stringWithFormat:@"7 Day's Likes (%d)",sevenDaysLikes];
            break;
        case 30:
            cell.trendingLikesLabel.text = [NSString stringWithFormat:@"30 Day's Likes (%d)",thirtyDaysLikes];
            break;
        case 90:
            cell.trendingLikesLabel.text = [NSString stringWithFormat:@"90 Day's Likes (%d)",ninetyDaysLikes];
            break;
            
        default:
            break;
    }
    cell.totalLikesLabel.text = [NSString stringWithFormat:@"Total Likes (%d)",totalLikes];
    
    NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
    
    NSString *memeid = photo.photoID;
    NSString *userId = [userInfoDisct objectForKey:@"userId"];
    
    NSLog(@"memeid=%@, userId=%@",memeid,userId);
    
    [dbhelper updateCategory:photo.photoCategory withMemeID:photo.photoID];
    
    NSString *urlString;
    if (param == 1) {
        urlString = MEME_LIKE;
    }else{
        urlString = MEME_DISLIKE;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //\\NSDictionary *parameters = @{@"memeid":memeid, @"userid":userId};
    NSDictionary *parameters = @{@"memeid":memeid, @"userID":userId};
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        NSError *error = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"Error serializing %@", error);
        }
        else
        {
            if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
            {
                NSString *totalLike = [JSON objectForKey:@"totalLike"];
                NSString *daytotalLike = [JSON objectForKey:@"daytotalLike"];
                NSString *day7totalLike = [JSON objectForKey:@"7daytotalLike"];
                NSString *day30totalLike = [JSON objectForKey:@"30daytotalLike"];
                NSString *day90totalLike = [JSON objectForKey:@"90daytotalLike"];
                
                TableCell *cell = (TableCell *)[_myTableView cellForRowAtIndexPath:indexPath];
                if (param == 0)
                {
                    [cell.rightButton setImage:[UIImage imageNamed:@"qq_12.png"] forState:UIControlStateNormal];
                     cell.rightButton.tag = 101;
                    
                    MemePhoto *pho = [photoArray objectAtIndex:indexPath.row];
                    
                    pho.photoMyLike = @"0";
                    pho.allLike = totalLike;
                    pho.daytotalLike = daytotalLike;
                    pho.daySeventotalLike = day7totalLike;
                    pho.dayThirtytotalLike = day30totalLike;
                    pho.dayNinetytotalLike = day90totalLike;
                    
                    [photoArray replaceObjectAtIndex:indexPath.row withObject:pho];
                }
                else
                {
                    [cell.rightButton setImage:[UIImage imageNamed:@"like_white.png"] forState:UIControlStateNormal];
                    cell.rightButton.tag = 100;
                    
                    MemePhoto *pho = [photoArray objectAtIndex:indexPath.row];
                    
                    pho.photoMyLike = @"1";
                    pho.allLike = totalLike;
                    pho.daytotalLike = daytotalLike;
                    pho.daySeventotalLike = day7totalLike;
                    pho.dayThirtytotalLike = day30totalLike;
                    pho.dayNinetytotalLike = day90totalLike;
                    
                    [photoArray replaceObjectAtIndex:indexPath.row withObject:pho];
                }
                
                
                switch (_topMemeByDays)
                {
                    case 1:
                        cell.trendingLikesLabel.text = [NSString stringWithFormat:@"Today's Likes (%@)",daytotalLike];
                        break;
                    case 7:
                        cell.trendingLikesLabel.text = [NSString stringWithFormat:@"7 Day's Likes (%@)",day7totalLike];
                        break;
                    case 30:
                        cell.trendingLikesLabel.text = [NSString stringWithFormat:@"30 Day's Likes (%@)",day30totalLike];
                        break;
                    case 90:
                        cell.trendingLikesLabel.text = [NSString stringWithFormat:@"90 Day's Likes (%@)",day90totalLike];
                        break;
                        
                    default:
                        break;
                }
                cell.totalLikesLabel.text = [NSString stringWithFormat:@"Total Likes (%@)",totalLike];
                
                
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


-(void)dismissSlideMenuButtonAction
{
    NSLog(@"TrendingDetail dismissSlideMenu tapped!!");
    
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
        
        [self.view setNeedsDisplayInRect:_myTableView.bounds];
    }
}


#pragma mark - imageLoad
-(void)loadImagesWithDay
{
    [refreshControl endRefreshing];
    
    if(![AppDelegate isNetworkAvailable]) {
        [UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!" ];
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
    
    NSString *day = [NSString stringWithFormat:@"%ld",(long)_topMemeByDays];
    
    NSLog(@"_topMemeByDays====%ld",(long)_topMemeByDays);
    
    NSString *urlString = MEME_TOPLIST;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"days":day,@"userID":userId};
    
    if (![self isFromRefreshController]) {
        [UIAppDelegate activityShow];
        [self setFromRefreshController:YES];
    }
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
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
                 photoArray = [NSMutableArray array];
                 
                 NSArray *listArray = [JSON objectForKey:@"result"];
                 for (NSDictionary *listDic in listArray)
                 {
                     photo = [[MemePhoto alloc] init];
                     
                     photo.photoID = [listDic objectForKey:@"id"];
                     photo.url = [listDic objectForKey:@"url"];
                     photo.baseURL = [JSON objectForKey:@"base_url"];
                     photo.allLike = [listDic objectForKey:@"allLike"];
                     photo.daytotalLike = [listDic objectForKey:@"daytotalLike"];
                     photo.daySeventotalLike = [listDic objectForKey:@"7daytotalLike"];
                     photo.dayThirtytotalLike = [listDic objectForKey:@"30daytotalLike"];
                     photo.dayNinetytotalLike = [listDic objectForKey:@"90daytotalLike"];
                     photo.photoCategory = [listDic objectForKey:@"category"];
                     photo.photoMyFavorite = [listDic objectForKey:@"isMyFavorite"];
                     photo.photoMyLike = [listDic objectForKey:@"isMyLike"];
                     
                     photo.thumb100BaseURL = [JSON objectForKey:@"thumb100BaseUrl"];
                     photo.thumb250BaseURL = [JSON objectForKey:@"thumb250BaseUrl"];
                     photo.totalMeme = [[JSON objectForKey:@"total"] intValue];
                     
                     photo.thumb100URL = [photo.thumb100BaseURL stringByAppendingString:photo.url];
                     photo.thumb250URL = [photo.thumb250BaseURL stringByAppendingString:photo.url];
                     
                     photo.photoURL = [photo.baseURL stringByAppendingString:photo.url];
                     
                     if ([[NSUserDefaults standardUserDefaults] boolForKey:WILL_LOCK_RECY_MEME])
                     {
                         if (![photo.photoCategory isEqualToString:@"3"])
                         {
                             [photoArray addObject:photo];
                         }
                     }
                     else
                     {
                         [photoArray addObject:photo];
                     }
                     
//                     BOOL test = [dbhelper isMemeIdExist:photo.photoID];int cnt = 1;
//                     if (!test) {
//                         [dbhelper insertWithMemeID:photo.photoID
//                                          likeCount:photo.allLike withCategory:nil];
//                         NSLog(@"CNT=%i",cnt++);
//                     }
                     
                     
                     
                 }
                 [self performSelector:@selector(refresh:) withObject:nil];
                 //[self performSelectorOnMainThread:@selector(refresh:) withObject:nil waitUntilDone:NO];
                 
                 //[_myTableView reloadData];
                 //[refreshControl endRefreshing];
                 NSLog(@"photoArray.count%lu",(unsigned long)photoArray.count);
             }
             
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         [UIAppDelegate activityHide];
     }];
}

- (void)refresh:(id)sender { 
    //NSLog(@"Refreshing");
    [_myTableView reloadData];
    [UIAppDelegate activityHide];
    
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

#pragma mark - ThumbAlertDelegate
- (void)danMessagePopupView:(DanMessagePopup *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    LoginViewController *viewController;
    switch (buttonIndex) {
        case 0:
            UIAppDelegate.isFromTrendingSwipe = YES;
            viewController = [[LoginViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"LoginViewController"] bundle:nil];
            [self presentViewController:viewController animated:YES completion:nil];
            break;
            
        default:
            break;
    }
}

#pragma maek - Table Header View for iPhone4s
-(UIView *)addTableHeaderView
{
    tableHederView = [[UIView alloc] init];
    tableHederView.frame = CGRectMake(0, 0, 320*factorX, 54*factorY);
    
    UIImageView *imgV1 = [[UIImageView alloc] init];
    imgV1.frame = CGRectMake(0, 0, 320*factorX, 54*factorY);
    imgV1.image = [UIImage imageNamed:@"qq_17.png"];
    
    UILabel *lbl = [[UILabel alloc] init];
    [lbl setBackgroundColor:[UIColor clearColor]];
    lbl.frame = CGRectMake(20*factorX, 4, 280*factorX, 21*factorY);
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = [UIFont systemFontOfSize:20*padFactor];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setText:_titleStr];
    
    UIImageView *imgV2 = [[UIImageView alloc] init];
    imgV2.frame = CGRectMake(0, 28*factorX, 320*factorX, 26*factorY);
    imgV2.image = [UIImage imageNamed:@"text_openany_meme.png"];
    
    [tableHederView addSubview:imgV1];
    [tableHederView addSubview:lbl];
    [tableHederView addSubview:imgV2];
    
    return tableHederView; 
}

#pragma mark - Add DACircular ProgressView
-(DACircularProgressView *)addCircularProgressView
{
    // Loading indicator
    CGRect frame = IS_IPAD ? CGRectMake(25.0f, 25.0f, 70.0f, 70.0f) : CGRectMake(15.0f, 15.0f, 40.0f, 40.0f);
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

#pragma mark Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


