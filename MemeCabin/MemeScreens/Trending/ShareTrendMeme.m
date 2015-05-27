//
//  ShareTrendMeme.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 01/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "ShareTrendMeme.h"
#import "HomeScreenViewController.h"
#import "FavoriteViewController.h"

#import "MemePhoto.h"
#import "MenuView.h"
#import "AFNetworking.h"
//#import "UIImageView+AFNetworking.h"
#import "SwipeView.h"
#import "TrendingSwipeViewItem.h"
//#import "UIImageView+Scale.h"

#import "UIImage+Resizing.h"
#import "UIImageView+WebCache.h"

typedef NS_ENUM(NSInteger, ScrollDragType) {
    ScrollDragTypeNormal,
    ScrollDragTypePrev,
    ScrollDragTypeNext
};

@interface ShareTrendMeme () <SwipeViewDataSource, SwipeViewDelegate>

{
    MenuView *menuView;
    DBHelper *dbhelper;
    MemePhoto *photoo;
    int likeCount;
    int page;
    
    NSArray *allMemeArray;
    AppDelegate *appDelegate;
    UIView *savedToCameraRollView;
    BOOL isButtonClicked;
    UIView *rightSideView;
    
    int swipeCount;
    
    ScrollDragType dragType;
    int pageOffsetForDrag;
    
    CustomBadge *badgeForAllMeme;
    
    BOOL isLastIndex;
    UIImage *reportedImage;
}

@property (weak, nonatomic) IBOutlet UIView *swipeContainer;
@property (nonatomic, weak) IBOutlet SwipeView *swipeView;
@property (weak, nonatomic) IBOutlet UIScrollView *zoomScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *zoomableImageView;

@end

@implementation ShareTrendMeme
@synthesize galleryImages = galleryImages_;

#pragma mark - SwipeView

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    swipeView.alignment = SwipeViewAlignmentCenter;
    swipeView.currentItemIndex = _imageIndex;
    NSLog(@"imageIndex==%ld",(long)_imageIndex);
    return [self.galleryImages count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    
    TrendingSwipeViewItem *item = nil;
    if (!view || ![view isKindOfClass:[TrendingSwipeViewItem class]])
    {
        NSArray *arrayOfViews = [NSArray array];
        if ([UIAppDelegate isProUser])
        {
            arrayOfViews = [self loadNibForProUser];
        }
        else
        {
            arrayOfViews = [self loadNibForNormalUser];
        }
        for (UIView *view in arrayOfViews)
        {
            if ([view isKindOfClass:[TrendingSwipeViewItem class]]) {
                [view setBackgroundColor:[UIColor clearColor]];
                
//                UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(performLeft)];
//                [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
//                [view addGestureRecognizer:swipeLeft];
                
                item = (TrendingSwipeViewItem *)view;
                if (index == self.galleryImages.count - 1)
                {
                    /*
                    item.scrollViewTrendingSwipeItem.hidden = YES;
                    item.BGLike.hidden = YES;*/
                }
                [item.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
        }
    }
    else
    {
        item = (TrendingSwipeViewItem *)view;
    }
    
    if (item)
    {
        
        // Set Image
        MemePhoto *photo = [self.galleryImages objectAtIndex:index];
        item.imageView.image = nil;
        //\\item.scrollViewTrendingSwipeItem.delegate = self;
        
        /*
        if (index == self.galleryImages.count - 1) {
            //item.scrollViewTrendingSwipeItem.hidden = YES;
            //item.BGLike.hidden = YES;
        }
        else*/
        {
            [item.activityIndicatorView startAnimating];
            
            item.scrollViewTrendingSwipeItem.delegate = self;
            [item.imageView sd_setImageWithURL:[NSURL URLWithString:photo.photoURL] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                
                [item.activityIndicatorView stopAnimating];
                
                
                if(IS_IPAD)
                {
                    if (image.size.width > item.imageView.bounds.size.width ||
                        image.size.height > item.imageView.bounds.size.height) {
                        item.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        item.imageView.image = image;
                    }
                    else
                    {
                        //item.imageView.image = [self imageWithImage:image scaledToSize:CGSizeMake(748*0.75, 724*0.75)];
                        if([UIAppDelegate isProUser])
                        {
                            item.imageView.image = [image scaleToFitSize:CGSizeMake(748*0.75, 670*0.75)];
                        }
                        else
                        {
                            item.imageView.image = [image scaleToFitSize:CGSizeMake(748*0.75, 620*0.75)];
                        }
                        
                        item.imageView.contentMode = UIViewContentModeCenter;
                        
                    }
                    
                    
                }
                else
                {
                    if (image.size.width > item.imageView.bounds.size.width ||
                        image.size.height > item.imageView.bounds.size.height) {
                        item.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        item.imageView.image = image;
                    }
                    else
                    {
                        if(IS_IPHONE_4INCHES)
                        {
                            if([UIAppDelegate isProUser])
                            {
                                item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 370*0.75)];
                            }
                            else
                            {
                                item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 320*0.75)];
                            }
                        }
                        else
                        {
                            if([UIAppDelegate isProUser])
                            {
                                item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 282*0.75)];
                            }
                            else
                            {
                                item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 231*0.75)];
                            }
                        }
                        item.imageView.contentMode = UIViewContentModeCenter;
                        
                    }
                }
                
                
                
                //item.imageView.image = image;
                
                
                //[item.imageView setImageWithScaleDownOnly:image];
                
                
                
            }];
            
            
            
            
            item.numberLabel.text = [NSString stringWithFormat:@"#%d",index+1];
            
            item.todaysLikes.text = [NSString stringWithFormat:@"Likes Today (%@)",photo.daytotalLike];
            item.sevenDaysLikes.text = [NSString stringWithFormat:@"7 Days (%@)",photo.daySeventotalLike];
            item.thirtyDaysLikes.text = [NSString stringWithFormat:@"30 Days (%@)",photo.dayThirtytotalLike];
            item.totalLikes.text = [NSString stringWithFormat:@"Total Likes (%@)",photo.allLike];
            
            [self getUpdatedLikeWithMemeId:photo.photoID forItemIndex:index];
            
            //Check if Liked
            if ([photo.photoMyLike isEqualToString:@"1"]) {
                item.likeButton.tag = 100;
                [item.likeButton setImage:[UIImage imageNamed:@"like_white.png"] forState:UIControlStateNormal];
                
            }else
            {
                item.likeButton.tag = 101;
                [item.likeButton setImage:[UIImage imageNamed:@"qq_12.png"] forState:UIControlStateNormal];
            }
        }
        
        
        
    }
    
    
    
    return item;
    
}

-(void)performLeft
{
    NSLog(@"performLeft Called.");
    //self.swipeView.scrollEnabled = YES;
    
}

-(void)performRight
{
    isLastIndex = YES;
    NSLog(@"performRight Called.");
    self.swipeView.scrollEnabled = YES;
    
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeContainer.bounds.size;
}

//test selector method
-(void)test
{
    
    [_swipeView scrollToItemAtIndex:_swipeView.currentItemIndex-1 duration:0.10];
    //self.swipeView.currentItemIndex = self.swipeView.currentItemIndex-1;
}
- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    if (swipeView.currentItemIndex == self.galleryImages.count - 1) {
        [self showEndMemePopUp];
        //[swipeView scrollToItemAtIndex:swipeView.currentItemIndex-1 duration:0.0];
        [self performSelector:@selector(test) withObject:nil afterDelay:0.05];
        
    }
    else
    {
        MemePhoto *photo = [self.galleryImages objectAtIndex:swipeView.currentItemIndex];
        //[dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
        
        
        
        if(swipeCount==0)
        {
            
            swipeCount++;
        }
        else
        {
            swipeCount++;
            if(swipeCount%20==0) // 7 to 9 to 20
            {
                [self callFullScreenAd];
            }
        }
        
        
        
        //Check if Favorite
        if ([photo.photoMyFavorite isEqualToString:@"1"]) {
            _favoriteButton.tag = 100;
            [_favoriteButton setImage:[UIImage imageNamed:@"star_purple3.png"] forState:UIControlStateNormal];
            
        }else{
            _favoriteButton.tag = 101;
            [_favoriteButton setImage:[UIImage imageNamed:@"star_purple2.png"] forState:UIControlStateNormal];
        }
    }
    
    
    
    
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    [UIAppDelegate activityShow];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   
                                   completionBlock(YES,image);
                               } else{
                                   [UIAppDelegate activityShow];
                                   completionBlock(NO,nil);
                               }
                           }];
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

///////

- (void)swipeViewDidScroll:(SwipeView *)swipeView
{
    //NSLog(@"swipeViewDidScroll");
}
/*
- (void)scrollByNumberOfItems:(NSInteger)itemCount duration:(NSTimeInterval)duration
{
    NSLog(@"scrollByNumberOfItems");
}
- (void)swipeViewWillBeginDragging:(SwipeView *)swipeView
{
    NSLog(@"swipeViewWillBeginDragging");
}
- (void)swipeViewDidEndDragging:(SwipeView *)swipeView willDecelerate:(BOOL)decelerate
{
    NSLog(@"swipeViewDidEndDragging");
}
- (void)swipeViewWillBeginDecelerating:(SwipeView *)swipeView
{
    NSLog(@"swipeViewWillBeginDecelerating");
}
- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView
{
    NSLog(@"swipeViewDidEndDecelerating");
}
- (void)swipeViewDidEndScrollingAnimation:(SwipeView *)swipeView
{
    NSLog(@"swipeViewDidEndScrollingAnimation");
}
*/


#pragma mark - ViewController LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([UIAppDelegate isProUser])
    {
        [UIAppDelegate hideFlurryAd];
        
        if (IS_IPHONE)
        {
            if (IS_IPHONE_4INCHES)
            {
                self.swipeContainer.frame = CGRectMake(0, 84, 320, 429);
                self.swipeView.frame = CGRectMake(-320, 2, 960, 425);
                self.zoomScrollView.frame = CGRectMake(0, 84, 320, 429);
                self.zoomableImageView.frame = CGRectMake(0, 0, 320, 429);
            }
            else
            {
                self.swipeContainer.frame = CGRectMake(0, 84, 320, 341);
                self.swipeView.frame = CGRectMake(-320, 2, 960, 337);
                self.zoomScrollView.frame = CGRectMake(0, 84, 320, 341);
                self.zoomableImageView.frame = CGRectMake(0, 0, 320, 341);
            }
        }
        else
        {
            self.swipeContainer.frame = CGRectMake(0, 151, 768, 774);
            self.swipeView.frame = CGRectMake(-768, 2, 2304, 770);
            self.zoomScrollView.frame = CGRectMake(0, 151, 768, 774);
            self.zoomableImageView.frame = CGRectMake(0, 0, 768, 774);
        }
    }
    else
    {
        [UIAppDelegate addFlurryInView:_myView];
        
        if(_imageIndex==0)
        {
            [UIAppDelegate reloadInterstitialAds];
        }
    }
    
    
    
    self.zoomScrollView.hidden = YES;
    
    UITapGestureRecognizer *doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleGesture.numberOfTapsRequired = 2;
    [self.swipeView addGestureRecognizer:doubleGesture];
    
    UITapGestureRecognizer *doubleGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleGesture2.numberOfTapsRequired = 2;
    [self.zoomScrollView addGestureRecognizer:doubleGesture2];
    
    /*
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(performLeft)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.swipeView addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(performRight)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.swipeView addGestureRecognizer:swipeRight];
    
    */
     
    
    /*
    //New add
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.zoomScrollView addGestureRecognizer:pinchGesture];*/
    
    //swipeView end
    
    //swipeView end
    
    if(_imageIndex == 0)
    {
        swipeCount = 0;
    }
    else
    {
        swipeCount = -1;
    }
    //swipeCount = -1;//0;
    
    _activity_like.hidden = YES;
    isButtonClicked = NO;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
    
    
    _titleLbl.text = _titleStr;
    
    
//    _todaysLikeslabel.text = [NSString stringWithFormat:@"Likes Today (%@)",_todaysLikeStr];
//    _sevenDaysLikeslabel.text = [NSString stringWithFormat:@"7 Days (%@)",_sevenDaysLikeStr];
//    _thirtyDaysLikeslabel.text = [NSString stringWithFormat:@"30 Days (%@)",_thirtyDaysLikeStr];
//    _totalLikeslabel.text = [NSString stringWithFormat:@"Total Likes (%@)",_totalLikeStr];
    
    self.galleryImages = [NSMutableArray arrayWithArray:_imageArray];
    //[self setupSwipeView];
    
    dbhelper = [[DBHelper alloc] init];
    photoo = [self.galleryImages objectAtIndex:_imageIndex];
    //_totalLikeslabel.text = [NSString stringWithFormat:@"Total Likes (%@)",photoo.photoLike];
    
    
    //swipeView start
//    if (_imageIndex == 0)
//    {
//        _numberLabel.text = [NSString stringWithFormat:@"#%ld",_imageIndex+1];
//        
//        _todaysLikeslabel.text = [NSString stringWithFormat:@"Likes Today (%@)",photoo.daytotalLike];
//        _sevenDaysLikeslabel.text = [NSString stringWithFormat:@"7 Days (%@)",photoo.daySeventotalLike];
//        _thirtyDaysLikeslabel.text = [NSString stringWithFormat:@"30 Days (%@)",photoo.dayThirtytotalLike];
//        _totalLikeslabel.text = [NSString stringWithFormat:@"Total Likes (%@)",photoo.allLike];
//        
//        //Check if Favorite
//        if ([photoo.photoMyFavorite isEqualToString:@"1"]) {
//            _favoriteButton.tag = 100;
//            [_favoriteButton setImage:[UIImage imageNamed:@"star_purple3.png"] forState:UIControlStateNormal];
//            
//        }else{
//            _favoriteButton.tag = 101;
//            [_favoriteButton setImage:[UIImage imageNamed:@"star_purple2.png"] forState:UIControlStateNormal];
//        }
//        
//        //Check if Liked
//        if ([photoo.photoMyLike isEqualToString:@"1"]) {
//            _thumbButton.tag = 100;
//            [_thumbButton setImage:[UIImage imageNamed:@"like_white.png"] forState:UIControlStateNormal];
//            
//        }else
//        {
//            _thumbButton.tag = 101;
//            [_thumbButton setImage:[UIImage imageNamed:@"qq_12.png"] forState:UIControlStateNormal];
//        }
//
//    }
    
    
    //    _swipeView.pagingEnabled = YES;
    //    _swipeView.itemsPerPage = 1;
    
//    page = _imageIndex;
//    
//    //Check if Favorite
//    if ([photoo.photoMyFavorite isEqualToString:@"1"]) {
//        _favoriteButton.tag = 100;
//        [_favoriteButton setImage:[UIImage imageNamed:@"star_purple3.png"] forState:UIControlStateNormal];
//        
//    }else{
//        _favoriteButton.tag = 101;
//        [_favoriteButton setImage:[UIImage imageNamed:@"star_purple2.png"] forState:UIControlStateNormal];
//    }
//    
//    //Check if Liked
//    if ([photoo.photoMyLike isEqualToString:@"1"]) {
//        _thumbButton.tag = 100;
//        [_thumbButton setImage:[UIImage imageNamed:@"like_white.png"] forState:UIControlStateNormal];
//        
//    }else
//    {
//        _thumbButton.tag = 101;
//        [_thumbButton setImage:[UIImage imageNamed:@"qq_12.png"] forState:UIControlStateNormal];
//    }
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[GoogleAnalyticsCustom getSharedInstance] setCurrentScreenName:@"Trending Swipe Screen"];
    
    _popupView.hidden = YES;
    _addedToFavouriteView.hidden = YES;
    
    [self updateBottomBadgeCount];
}

-(void)viewDidLayoutSubviews
{
    //NSLog(@"viewDidLayoutSubviews");
    
    if([UIAppDelegate isProUser])
    {
        if (IS_IPHONE)
        {
            if (IS_IPHONE_4INCHES)
            {
                self.swipeContainer.frame = CGRectMake(0, 84, 320, 429);
                self.swipeView.frame = CGRectMake(-320, 2, 960, 425);
                self.zoomScrollView.frame = CGRectMake(0, 84, 320, 429);
                self.zoomableImageView.frame = CGRectMake(0, 0, 320, 429);
            }
            else
            {
                self.swipeContainer.frame = CGRectMake(0, 84, 320, 341);
                self.swipeView.frame = CGRectMake(-320, 2, 960, 337);
                self.zoomScrollView.frame = CGRectMake(0, 84, 320, 341);
                self.zoomableImageView.frame = CGRectMake(0, 0, 320, 341);
            }
        }
        else
        {
            self.swipeContainer.frame = CGRectMake(0, 151, 768, 774);
            self.swipeView.frame = CGRectMake(-768, 2, 2304, 770);
            self.zoomScrollView.frame = CGRectMake(0, 151, 768, 774);
            self.zoomableImageView.frame = CGRectMake(0, 0, 768, 774);
        }
    }
}

-(void) setupSwipeView
{
    self.imageHostScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.imageHostScrollView.frame)*[self.galleryImages count], CGRectGetHeight(self.imageHostScrollView.frame));
    
    //self.imageHostScrollView.delegate = self;
    self.imageHostScrollView.pagingEnabled = YES;
    
    //self.imageHostScrollView.minimumZoomScale = 1;
    //self.imageHostScrollView.maximumZoomScale = 2.5;
    
    CGRect rect = CGRectZero;
    CGFloat imageHost_W = self.imageHostScrollView.frame.size.width;
    CGFloat imageHost_H = self.imageHostScrollView.frame.size.height;
    rect = CGRectMake(0, 0, imageHost_W, imageHost_H);
    
    NSLog(@"imageHostScrollView.frame IN_SETUP =%@",NSStringFromCGRect(_imageHostScrollView.frame));
    
//    if (IS_IPHONE)
//    {
//        if (IS_IPHONE_4INCHES) {
//            rect = CGRectMake(0, 0, 320, 323);
//        } else {
//            rect = CGRectMake(0, 0, 320, 230);
//        }
//    }
//    else
//        rect = CGRectMake(0, 0, 768, 610);
//    //int padding = 10;
    
    for (int i = 0; i < [self.galleryImages count]; i++)
    {
        rect.origin.x = CGRectGetWidth(self.imageHostScrollView.frame)*i;
        UIScrollView *scrView = [[UIScrollView alloc] initWithFrame:rect];
        [self.imageHostScrollView addSubview:scrView];
        
        photoo = [self.galleryImages objectAtIndex:i];
        
        CGRect imageViewRect;
        if (IS_IPHONE)
        {
            if (IS_IPHONE_4INCHES) {
                imageViewRect = CGRectMake(10, 0, 300, scrView.frame.size.height);
            } else {
                imageViewRect = CGRectMake(10, 0, 300, scrView.frame.size.height);
            }
        }
        else
            imageViewRect = CGRectMake(10, 0, 748, scrView.frame.size.height);
        //[self.imageHostScrollView setContentOffset:contentOffY];
        
        UIImageView *prevView = [[UIImageView alloc] init];
        
        [prevView sd_setImageWithURL:[NSURL URLWithString:photoo.photoURL]];
        
        if (prevView.image.size.width > scrView.bounds.size.width || prevView.image.size.height > scrView.bounds.size.height)
            prevView.contentMode = UIViewContentModeScaleAspectFit;
        else
            prevView.contentMode = UIViewContentModeCenter;
        
        prevView.frame = imageViewRect;
        
        scrView.tag = i;
        
        scrView.delegate = self;
        [scrView addSubview:prevView];
        
        scrView.minimumZoomScale = 1.0;
        scrView.maximumZoomScale = 5.5;
        //prevView.frame = scrView.bounds;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [scrView addGestureRecognizer:doubleTap];
        
    }
    
    [self.imageHostScrollView scrollRectToVisible:CGRectMake(self.imageHostScrollView.frame.size.width*_imageIndex+20,
                                                             CGRectGetHeight(self.imageHostScrollView.frame)/2,
                                                             CGRectGetWidth(self.imageHostScrollView.frame)-20,
                                                             CGRectGetHeight(self.imageHostScrollView.frame))
                                         animated:NO];
    
}


#pragma mark - UIScrollView methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if(scrollView.tag==1000)
    {
        UIView *aView = [scrollView viewWithTag:1001];
        return aView;
    }
    else
    {
        return self.zoomableImageView;
    }
    
    
    //    for (UIView *subView in self.imageHostScrollView.subviews)
    //    {
    //        for (UIImageView *imgView in subView.subviews)
    //        {
    //            if (imgView.superview == scrollView)
    //            {
    //                return imgView;
    //            }
    //        }
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    if(scrollView.tag==1000)
    {
        
    }
    else
    {
        if(scale == 1){
            scrollView.hidden = YES;
            self.swipeView.hidden = NO;
            
            if (pageOffsetForDrag != 0) {
                [self.swipeView scrollByNumberOfItems:pageOffsetForDrag duration:0.5];
                pageOffsetForDrag = 0;
            }
        }
    }
    
}



//- (void)scrollViewDidZoom:(UIScrollView *)scrollView
//{
//    //NSLog(@"scrollViewDidZoom");
//    
//    UIView *subView = [scrollView.subviews objectAtIndex:0];
//    
//    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
//    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
//    
//    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
//    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
//    
//    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
//                                 scrollView.contentSize.height * 0.5 + offsetY);
//}


//- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
//{
//    //NSLog(@"scrollViewDidEndDecelerating");
//    if (!(sender.zoomScale > 1))
//    {
//        CGFloat pageWidth = sender.frame.size.width;
//        page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//        
//        swipeCount++;
//        if(swipeCount%7==0)
//        {
//            [self callFullScreenAd];
//        }
//        
//        photoo = [self.galleryImages objectAtIndex:page];
//        
//        NSLog(@"MemeID = %@",photoo.photoID);
//        [dbhelper updateMemeView:@"1" withMemeID:photoo.photoID];
//        
//        [self getUpdatedLikeWithMemeId:photoo.photoID];
//        
//        _numberLabel.text = [NSString stringWithFormat:@"#%d",page+1];
//        
//        for (UIView *subView in self.imageHostScrollView.subviews)
//        {
//            for (UIImageView *imgView in subView.subviews)
//            {
//                UIScrollView *scrollView = (UIScrollView *)imgView.superview;
//                scrollView.zoomScale = 1.0;
//            }
//        }
//    }
//    
//    
//    //Check if Favourite
//    if ([photoo.photoMyFavorite isEqualToString:@"1"]) {
//        _favoriteButton.tag = 100;
//        [_favoriteButton setImage:[UIImage imageNamed:@"star_purple3.png"] forState:UIControlStateNormal];
//        
//    }else{
//        _favoriteButton.tag = 101;
//        [_favoriteButton setImage:[UIImage imageNamed:@"star_purple2.png"] forState:UIControlStateNormal];
//    }
//    
//    //Check if Liked
//    if ([photoo.photoMyLike isEqualToString:@"1"]){
//        _thumbButton.tag = 100;
//        [_thumbButton setImage:[UIImage imageNamed:@"like_white.png"] forState:UIControlStateNormal];
//    }
//    else{
//        _thumbButton.tag = 101;
//        [_thumbButton setImage:[UIImage imageNamed:@"qq_12.png"] forState:UIControlStateNormal];
//    }
    
    //NSLog(@"PAGE_NO==%d, _imageArray.count==%d",page,_imageArray.count);
    
//    
//}

#pragma mark - GestureRecognizer methods
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"handleDoubleTap:(%@)", [gestureRecognizer.view class]);
    
    if(gestureRecognizer.view == self.zoomScrollView)
    {
        [self.zoomScrollView setZoomScale:1 animated:YES];
    }
    else
    {
        TrendingSwipeViewItem *view = (TrendingSwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
        if([view.scrollViewTrendingSwipeItem zoomScale]==1)
        {
            if([view.imageView image])
            {
                self.zoomableImageView.image = view.imageView.image;
                self.zoomScrollView.hidden = NO;
                [self.zoomScrollView setZoomScale:3 animated:YES];
            }
            self.swipeView.hidden = YES;
        }
        else
        {
            [view.scrollViewTrendingSwipeItem setZoomScale:1 animated:YES];
        }
        
    }
    
    /*UIScrollView *scrollView = (UIScrollView *) gestureRecognizer.view;
     if (scrollView) {
     if(scrollView.zoomScale > scrollView.minimumZoomScale){
     [scrollView setZoomScale:scrollView.minimumZoomScale animated:YES];
     }
     else{
     [scrollView setZoomScale:scrollView.maximumZoomScale animated:YES];
     }
     }*/
    /*
     CGPoint pointInView = [gestureRecognizer locationInView:self.prevView];
     
     // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
     CGFloat newZoomScale = self.imageHostScrollView.zoomScale * 1.5f;
     newZoomScale = MIN(newZoomScale, self.imageHostScrollView.maximumZoomScale);
     
     // Figure out the rect we want to zoom to, then zoom to it
     CGSize scrollViewSize = self.imageHostScrollView.bounds.size;
     
     CGFloat w = scrollViewSize.width / newZoomScale;
     CGFloat h = scrollViewSize.height / newZoomScale;
     CGFloat x = pointInView.x - (w / 2.0f);
     CGFloat y = pointInView.y - (h / 2.0f);
     
     CGRect rectToZoomTo = CGRectMake(x, y, w, h);
     
     [self.imageHostScrollView zoomToRect:rectToZoomTo animated:YES];
     
     //    for (UIView *subView in self.imageHostScrollView.subviews)
     //    {
     //        if ([subView.subviews isKindOfClass:[UIImageView class]])
     //        {
     //            for (UIImageView *imgView in subView.subviews)
     //            {
     //
     //            }
     //        }
     //
     //    }
     
     
     */
}



//-(void)handlePinchGesture:(UIGestureRecognizer *)gestureRecongnizer
//{
//    if (gestureRecongnizer.state == UIGestureRecognizerStateBegan) {
//        lastScale = 1.0;
//        lastPoint = [sender locationInView:self];
//    }
//    
//    // Scale
//    CGFloat scale = 1.0 - (lastScale - sender.scale);
//    [self.layer setAffineTransform:
//     CGAffineTransformScale([self.layer affineTransform],
//                            scale,
//                            scale)];
//    lastScale = sender.scale;
//    
//    // Translate
//    CGPoint point = [sender locationInView:self];
//    [self.layer setAffineTransform:
//     CGAffineTransformTranslate([self.layer affineTransform],
//                                point.x - lastPoint.x,
//                                point.y - lastPoint.y)];
//    lastPoint = [sender locationInView:self];
//}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDragging");
    
    if(scrollView.tag==1000)
    {
        if (scrollView.contentOffset.x == 0) {
            dragType = ScrollDragTypePrev;
        } else if(scrollView.contentSize.width - scrollView.contentOffset.x  == scrollView.frame.size.width){
            dragType = ScrollDragTypeNext;
        } else {
            dragType = ScrollDragTypeNormal;
        }
    }
    else
    {
        if (scrollView.contentOffset.x == 0) {
            dragType = ScrollDragTypePrev;
        } else if(scrollView.contentSize.width - scrollView.contentOffset.x  == scrollView.frame.size.width){
            dragType = ScrollDragTypeNext;
        } else {
            dragType = ScrollDragTypeNormal;
        }
    }
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"scrollViewDidEndDragging:willDecelerate");
    
    if(scrollView.tag==1000)
    {
        if (decelerate)
        {
            int pageOffset = 0;
            if (dragType == ScrollDragTypeNext) {
                pageOffset = 1;
            } else if(dragType == ScrollDragTypePrev){
                pageOffset = -1;
            }
            
            if(pageOffset != 0){
                pageOffsetForDrag = pageOffset;
                [scrollView setZoomScale:1 animated:YES];
            }
        }
    }
    else
    {
        if (decelerate)
        {
            int pageOffset = 0;
            if (dragType == ScrollDragTypeNext) {
                pageOffset = 1;
            } else if(dragType == ScrollDragTypePrev){
                pageOffset = -1;
            }
            
            if(pageOffset != 0){
                pageOffsetForDrag = pageOffset;
                [self.zoomScrollView setZoomScale:1 animated:YES];
            }
        }
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
            
            [self.view setNeedsDisplayInRect:_imageHostScrollView.bounds];
        }
    }
    else
    {
        rightSideView.hidden = NO;
        _menuButton.tag = 100;
        [UIAppDelegate moveView1:menuView andView2:_myView moveLeft:NO];
    }
}

- (IBAction)likeButtonAction:(UIButton *)sender
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED])
    {
        DanMessagePopup *alert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self label1:@"Oops!" label2:@"You need to be logged-in to like or favorite memes on MemeCabin." button1stTitle:@"Got it, take me to login." button2ndTitle:@"Eek. No thanks." button3rdTitle:nil button4thTitle:nil  showTopBlackBar:NO];
        alert.tag = 3;
        [alert show];
        return;
    }
    
    photoo = [self.galleryImages objectAtIndex:page];
    if (sender.tag == 100)
    {
        [self updateMemeLike:0 buttonTag:100];
        //[dbhelper updateMemeLike:@"0" withMemeID:photoo.photoID];
    }
    else
    {
        
        [self updateMemeLike:1 buttonTag:101];
        //[dbhelper updateMemeLike:@"1" withMemeID:photoo.photoID];
    }
    
    NSLog(@"Button Tag:%ld",(long)sender.tag);
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

- (IBAction)reloadButtonAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Reload Button Clicked"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_SWIPE_SCREEN_LAST_INDEX_POPUP]) {
        [self.imageHostScrollView scrollRectToVisible:CGRectMake(self.imageHostScrollView.frame.size.width*0+0,
                                                                 CGRectGetHeight(self.imageHostScrollView.frame)/2,
                                                                 CGRectGetWidth(self.imageHostScrollView.frame)-20,
                                                                 CGRectGetHeight(self.imageHostScrollView.frame))
                                             animated:YES];
    } else {
        [self showReloadPopUp];
    }
}

#pragma mark - Start&End pop
-(void)showReloadPopUp
{
    DanMessagePopup *alert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self
                                                                label1:@"You sure you want to go back to very first meme?"
                                                                label2:@"We just want to make sure."
                                                        button1stTitle:@"Yep, take me."
                                                        button2ndTitle:@"Yep, don't show this again."
                                                        button3rdTitle:@"Um. Cancel that."
                                                        button4thTitle:nil
                                                       showTopBlackBar:NO];
    alert.tag = 1;
    [alert show];
}

-(void)showEndMemePopUp
{
    DanMessagePopup *alert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self
                                                                label1:@"Wow, you've reached  the end of the memes!"
                                                                label2:@"What do you want to do next?"
                                                        button1stTitle:@"Keep me here"
                                                        button2ndTitle:@"Back to First Meme"
                                                        button3rdTitle:@"View My Favorites"
                                                        button4thTitle:nil
                                                       showTopBlackBar:NO];
    alert.tag = 2;
    [alert show];
}


#pragma mark - Button Actions
- (IBAction)shareButtonAction:(UIButton *)sender
{
    
    
    NSString *filePath = [self documentsPathForFileName:@"sharedImage.png"];
    /*
    UIImage *pngImage = [self getCapturedImage];
    NSData *pngData = UIImageJPEGRepresentation(pngImage, 1.0);
    [pngData writeToFile:filePath atomically:NO];*/
    
    photoo = [self.galleryImages objectAtIndex:self.swipeView.currentItemIndex];//[self.galleryImages objectAtIndex:page];
    [self downloadImageWithURL:[NSURL URLWithString:photoo.photoURL] completionBlock:^(BOOL succeeded, UIImage *image)
    {
        if (image)
        {
            reportedImage = image;
            /////
            [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Share Button Clicked"];
            
            _popupView.hidden = NO;
            _popupShareView.hidden = NO;
            
            [_popupShareView setFrame:CGRectMake(_popupView.frame.size.width/2-_popupShareView.frame.size.width/2,
                                                 _popupView.frame.size.height/2-_popupShareView.frame.size.height/2,
                                                 _popupShareView.frame.size.width,
                                                 _popupShareView.frame.size.height)];
            
            [_popupView addSubview:_popupShareView];
            //////
            
            float bottomImgW;
            float bottomImgH;
            if (image.size.width < 200)
            {
                bottomImgW = 45;
                bottomImgH = 12;
            }
            else if (image.size.width >= 200 && image.size.width <= 300)
            {
                bottomImgW = 56;
                bottomImgH = 15; //if H=20 then W=75
            }
            else if (image.size.width > 300 && image.size.width <= 400)
            {
                bottomImgW = 75;
                bottomImgH = 20; //if H=20 then W=75
            }
            else
            {
                bottomImgW = 113;
                bottomImgH = 30;
            }
            
            float topPadding = 5;
            float leftPadding = 5;
            
            UIImageView *mainImageView = [[UIImageView alloc] initWithFrame:
                                          CGRectMake(topPadding, leftPadding, image.size.width-10, image.size.height-10)];
            
            mainImageView.image = image;
            mainImageView.contentMode = UIViewContentModeScaleAspectFit;
            
            UIView *templateView = [[UIView alloc] initWithFrame:
                                    CGRectMake(0, 0, image.size.width,
                                               image.size.height+bottomImgH)];
            templateView.backgroundColor = [UIColor blackColor];
            
            
            
            UIImageView *bottomImageView = [[UIImageView alloc] initWithFrame:
                                            CGRectMake(templateView.frame.size.width-bottomImgW*1.1,
                                                       templateView.frame.size.height-(bottomImgH+topPadding),
                                                       bottomImgW,
                                                       bottomImgH)];
            bottomImageView.image = [UIImage imageNamed:@"meme-footer.png"];
            
            
            [templateView addSubview:mainImageView];
            [templateView addSubview:bottomImageView];
            
            CGRect rect = [templateView bounds];
            UIGraphicsBeginImageContextWithOptions(rect.size,YES,1.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [templateView.layer renderInContext:context];
            UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData *pngData = UIImageJPEGRepresentation(capturedImage, 1.0);
            [pngData writeToFile:filePath atomically:NO];
            [UIAppDelegate activityHide];
        }
        
    }];
}

- (IBAction)favoriteButtonAction:(UIButton *)sender
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED])
    {
        DanMessagePopup *alert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self label1:@"Oops!" label2:@"You need to be logged-in to like or favorite memes on MemeCabin." button1stTitle:@"Got it, take me to login." button2ndTitle:@"Eek. No thanks." button3rdTitle:nil button4thTitle:nil showTopBlackBar:NO];
        alert.tag = 4;
        [alert show];
        return;
    }
    
    photoo = [self.galleryImages objectAtIndex:page];
    if (sender.tag == 100)
    {
        //[dbhelper updateMemeFavorite:@"0" withMemeID:photoo.photoID];
        [self updateMemeFavourite:2 buttonTag:100];
    }
    else
    {
        //[dbhelper updateMemeFavorite:@"1" withMemeID:photoo.photoID];
        [self updateMemeFavourite:1 buttonTag:101];
    }
    
    //appDelegate.savedFavourites = [dbhelper getSavedFavourites];
}

-(void)dismissSlideMenuButtonAction
{
    NSLog(@"ShareMeme dismissSlideMenu tapped!!");
    
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
        
        [self.view setNeedsDisplayInRect:_imageHostScrollView.bounds];
    }
}



#pragma mark - Dismiss Popup
- (IBAction)dismissPopup:(UIButton *)sender
{
    _popupView.hidden = YES;
    [savedToCameraRollView removeFromSuperview];
}

#pragma mark - Document Path
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

#pragma mark - Get Image From Document Path
-(UIImage *)getCapturedImage
{
    photoo = [self.galleryImages objectAtIndex:page];
    
    UIImageView *appImageView;
    for (UIScrollView *scrollView in self.imageHostScrollView.subviews)
    {
        UIScrollView *subScrollView = (UIScrollView *)[scrollView viewWithTag:page];
        if ([[scrollView viewWithTag:page] isKindOfClass:[UIScrollView class]])
        {
            NSArray *imaViewArr = [subScrollView subviews];
            appImageView = [imaViewArr objectAtIndex:0];
        }
    }
    
    float bottomImgW;
    float bottomImgH;
    if (appImageView.image.size.width < 200)
    {
        bottomImgW = 45;
        bottomImgH = 12;
    }
    else if (appImageView.image.size.width >= 200 && appImageView.image.size.width <= 300)
    {
        bottomImgW = 56;
        bottomImgH = 15; //if H=20 then W=75
    }
    else if (appImageView.image.size.width > 300 && appImageView.image.size.width <= 400)
    {
        bottomImgW = 75;
        bottomImgH = 20; //if H=20 then W=75
    }
    else
    {
        bottomImgW = 113;
        bottomImgH = 30;
    }
    
    float topPadding = 5;
    float leftPadding = 5;
    
    UIImageView *mainImageView = [[UIImageView alloc] initWithFrame:
                                  CGRectMake(topPadding, leftPadding, appImageView.image.size.width-10, appImageView.image.size.height-10)];
    
    mainImageView.image = appImageView.image;
    mainImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIView *templateView = [[UIView alloc] initWithFrame:
                            CGRectMake(0, 0, appImageView.image.size.width,
                                                                    appImageView.image.size.height+bottomImgH)];
    templateView.backgroundColor = [UIColor blackColor];
    
    
    
    UIImageView *bottomImageView = [[UIImageView alloc] initWithFrame:
                                    CGRectMake(templateView.frame.size.width-bottomImgW*1.1,
                                               templateView.frame.size.height-(bottomImgH+topPadding),
                                               bottomImgW,
                                               bottomImgH)];
    bottomImageView.image = [UIImage imageNamed:@"meme-footer.png"];
    
    
    [templateView addSubview:mainImageView];
    [templateView addSubview:bottomImageView];
    
    CGRect rect = [templateView bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [templateView.layer renderInContext:context];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return capturedImage;
    
}

#pragma mark - ShareButton Actions
- (IBAction)saveButtonAction:(UIButton *)sender
{
    NSData *pngData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:@"sharedImage.png"]];
    UIImage *image = [UIImage imageWithData:pngData];
    
    if(image) {
        [UIAppDelegate activityShow];
        
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)               image: (UIImage *) image
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo
{
    [UIAppDelegate activityHide];
    
    //272,78 popup_white_bar.png
    UIImage *img = [UIImage imageNamed:@"popup_white_bar.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 272, 78)];
    [imgView setImage:img];
    
    UILabel *lbl_savedToCameraRoll = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 272, 35)];
    lbl_savedToCameraRoll.textAlignment = NSTextAlignmentCenter;
    lbl_savedToCameraRoll.text = @"Saved to Camera Roll.";
    lbl_savedToCameraRoll.font = [UIFont systemFontOfSize:20];
    
    savedToCameraRollView = [[UIView alloc] init];
    savedToCameraRollView.frame = CGRectMake(self.view.frame.size.width/2-imgView.frame.size.width/2,
                                             self.view.frame.size.height/2-imgView.frame.size.height/2,
                                             272, 78);
    [savedToCameraRollView setBackgroundColor:[UIColor whiteColor]];
    [savedToCameraRollView addSubview:imgView];
    
    [savedToCameraRollView addSubview:lbl_savedToCameraRoll];
    [self.view addSubview:savedToCameraRollView];
    
    [self.view bringSubviewToFront:savedToCameraRollView];
    savedToCameraRollView.alpha = 1.0;
    
    [self performSelector:@selector(showSavedToCameraRollAnimation) withObject:nil afterDelay:1.5];
}

-(void)showSavedToCameraRollAnimation
{
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         savedToCameraRollView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         savedToCameraRollView.alpha = 1.0;
                         [savedToCameraRollView removeFromSuperview];
                     }];
}

- (IBAction)facebookShareAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Facebook Share Button Clicked"];
    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    NSData *pngData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:@"sharedImage.png"]];
    UIImage *image = [UIImage imageWithData:pngData];
    
    [controller setInitialText:@""];//@"Sharing this from the MemeCabin app! (Get it on Android and iOS!)"];
    [controller addImage:image];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)twitterShareAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Twitter Share Button Clicked"];
    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    NSData *pngData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:@"sharedImage.png"]];
    UIImage *image = [UIImage imageWithData:pngData];
    
    [controller setInitialText:@"Sharing this from the MemeCabin app! (Get it on Android and iOS!)"];
    [controller addImage:image];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)emailShareAction:(UIButton *)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"An amazing meme from the MemeCabin app!"];
        NSArray *toRecipients = [NSArray arrayWithObject:@"mail@example.com"];
        [mailer setToRecipients:toRecipients];
        
        NSData *pngData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:@"sharedImage.png"]];
        [mailer addAttachmentData:pngData mimeType:@"image/png" fileName:@"userfile"];
        
        NSString *emailBody = @"I sent you this from the MemeCabin app! Download it today for Apple and Android phones and tablets at www.memecabin.com!";
        [mailer setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:mailer animated:YES completion:NULL];
        
    }
    else
        [UIAppDelegate showAlertWithTitle:@"Failure" message:@"Your device doesn't support the composer sheet"];
}

- (IBAction)smsShareAction:(UIButton *)sender
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        photoo = [self.galleryImages objectAtIndex:page];
        
        controller.body = @"Just wanted to share this meme from the MemeCabin app!";
        //controller.recipients = [NSArray arrayWithObjects:@"", nil];
        controller.messageComposeDelegate = self;
        
        
        NSData *pngData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:@"sharedImage.png"]];
        //UIImage *image = [UIImage imageWithData:pngData];
        
        [controller addAttachmentData:pngData typeIdentifier:(NSString *)kUTTypePNG filename:@"sharedImage.png"];
        
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (IBAction)reportButtonAction:(UIButton *)sender
{
    ReportMemeVC *reportVC = [[ReportMemeVC alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"ReportMemeVC"] bundle:nil];
    
    photoo = [self.galleryImages objectAtIndex:self.swipeView.currentItemIndex];
    reportVC.reportedImage = reportedImage;
    reportVC.reportedMemeId = photoo.photoID;
    
    UINavigationController *navContrl = [[UINavigationController alloc] initWithRootViewController:reportVC];
    navContrl.navigationBarHidden = YES;
    
    [UIAppDelegate.navigationController presentViewController:navContrl animated:YES completion:nil];
}

#pragma mark - EmailCompose delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - SMSCompose delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            [UIAppDelegate showAlertWithTitle:@"Error" message:@"Failed to send SMS!"];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - updateMemeLike
-(void)updateMemeLike:(int)param buttonTag:(int)tag
{
    TrendingSwipeViewItem *view = (TrendingSwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
    MemePhoto *pho = [self.galleryImages objectAtIndex:self.swipeView.currentItemIndex];
    
    if (tag == 100)
    {
        [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Dislike Button Clicked"];
        //_thumbButton.tag = 101;
        
        
        [view.likeButton setImage:[UIImage imageNamed:@"qq_12.png"] forState:UIControlStateNormal];
        
        int todaysLikes = [pho.daytotalLike intValue];
        int sevenDaysLikes = [pho.daySeventotalLike intValue];
        int thirtyDaysLikes = [pho.dayThirtytotalLike intValue];
        int totalLikes = [pho.allLike intValue];
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
        
        view.todaysLikes.text = [NSString stringWithFormat:@"Likes Today (%d)",todaysLikes];
        view.sevenDaysLikes.text = [NSString stringWithFormat:@"7 Days (%d)",sevenDaysLikes];
        view.thirtyDaysLikes.text = [NSString stringWithFormat:@"30 Days (%d)",thirtyDaysLikes];
        view.totalLikes.text = [NSString stringWithFormat:@"Total Likes (%d)",totalLikes];
    }
    else
    {
        [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Like Button Clicked"];
        //_thumbButton.tag = 100;
        [view.likeButton setImage:[UIImage imageNamed:@"like_white.png"] forState:UIControlStateNormal];
        
        int todaysLikes = [pho.daytotalLike intValue];
        int sevenDaysLikes = [pho.daySeventotalLike intValue];
        int thirtyDaysLikes = [pho.dayThirtytotalLike intValue];
        int totalLikes = [pho.allLike intValue];
        todaysLikes = todaysLikes + 1;
        sevenDaysLikes = sevenDaysLikes + 1;
        thirtyDaysLikes = thirtyDaysLikes + 1;
        totalLikes = totalLikes + 1;
        
        view.todaysLikes.text = [NSString stringWithFormat:@"Likes Today (%d)",todaysLikes];
        view.sevenDaysLikes.text = [NSString stringWithFormat:@"7 Days (%d)",sevenDaysLikes];
        view.thirtyDaysLikes.text = [NSString stringWithFormat:@"30 Days (%d)",thirtyDaysLikes];
        view.totalLikes.text = [NSString stringWithFormat:@"Total Likes (%d)",totalLikes];
        
    }
    
    NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
    photoo = [self.galleryImages objectAtIndex:self.swipeView.currentItemIndex];
    NSString *memeid = photoo.photoID;
    NSString *userId = [userInfoDisct objectForKey:@"userId"];
    
    //[dbhelper updateCategory:photoo.photoCategory withMemeID:photoo.photoID];
    
    NSString *urlString;
    if (param == 1) {
        urlString = MEME_LIKE;
    }else{
        urlString = MEME_DISLIKE;
    }
    //[UIAppDelegate activityShow];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //\\NSDictionary *parameters = @{@"memeid":memeid, @"userid":userId};
    NSDictionary *parameters = @{@"memeid":memeid, @"userID":userId};
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        //[UIAppDelegate activityHide];
        
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
                
                BOOL isLikeClicked = (tag != 100);
                
                [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:[NSString stringWithFormat:@"%@ Button Clicked", isLikeClicked?@"Like":@"Dislike"]];
                
                view.likeButton.tag = isLikeClicked? 100:101;
                [view.likeButton setImage:[UIImage imageNamed:isLikeClicked? @"like_white.png":@"qq_12.png"] forState:UIControlStateNormal];
                
                MemePhoto *pho = [self.galleryImages objectAtIndex:self.swipeView.currentItemIndex];
                
                pho.photoMyLike = isLikeClicked? @"1":@"0";
                pho.daytotalLike = daytotalLike;
                pho.daySeventotalLike = day7totalLike;
                pho.dayThirtytotalLike = day30totalLike;
                pho.dayNinetytotalLike = day90totalLike;
                pho.allLike = totalLike;
                
                
                [self.galleryImages replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
                [self.imageArray replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
                
//                [self.trendingDetailView.myTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.swipeView.currentItemIndex inSection:0]]
//                                                           withRowAnimation:UITableViewRowAnimationNone];
                [self.trendingDetailView.myTableView reloadData];
                
                //NSString *day90totalLike = [JSON objectForKey:@"90daytotalLike"];
                
                view.todaysLikes.text = [NSString stringWithFormat:@"Likes Today (%@)",daytotalLike];
                view.sevenDaysLikes.text = [NSString stringWithFormat:@"7 Days (%@)",day7totalLike];
                view.thirtyDaysLikes.text = [NSString stringWithFormat:@"30 Days (%@)",day30totalLike];
                view.totalLikes.text = [NSString stringWithFormat:@"Total Likes (%@)",totalLike];
                
            }
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //[UIAppDelegate activityHide];
        
    }];
}

#pragma mark - updateMemeFavourite
-(void)updateMemeFavourite:(int)param buttonTag:(int)tag
{
    if (tag == 100)
    {
        UIAppDelegate.userFavouriteNumber = ((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? ([[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT] + 1) : 0;
        [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.userFavouriteNumber forKey:MEME_FAVORITE_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"UnFavourite Button Clicked"];
        [_addedToFavouriteView.layer removeAllAnimations];
        _favoriteButton.userInteractionEnabled = NO;
        _addedToFavouriteView.hidden = NO;
        [_myView bringSubviewToFront:_addedToFavouriteView];
        _addOrRemoveText.text = @"Removed from Favorites";
        [UIView animateWithDuration:1.2
                              delay:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             _addedToFavouriteView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             _addedToFavouriteView.alpha = 1.0;
                             _addedToFavouriteView.hidden = YES;
                             //_favoriteButton.tag = 101;
                             _favoriteButton.userInteractionEnabled = YES;
                         }];
        
        [_favoriteButton setImage:[UIImage imageNamed:@"star_purple2.png"] forState:UIControlStateNormal];
        
    }
    else
    {
        UIAppDelegate.userFavouriteNumber = ((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? ([[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT] - 1) : 0;
        [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.userFavouriteNumber forKey:MEME_FAVORITE_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Favourite Button Clicked"];
        [_addedToFavouriteView.layer removeAllAnimations];
        
        _favoriteButton.userInteractionEnabled = NO;
        _addedToFavouriteView.hidden = NO;
        [_myView bringSubviewToFront:_addedToFavouriteView];
        _addOrRemoveText.text = @"Added to Favorites";
        [UIView animateWithDuration:1.2
                              delay:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             _addedToFavouriteView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             _addedToFavouriteView.alpha = 1.0;
                             _addedToFavouriteView.hidden = YES;
                             //_favoriteButton.tag = 100;
                             _favoriteButton.userInteractionEnabled = YES;
                         }];
        
        [_favoriteButton setImage:[UIImage imageNamed:@"star_purple3.png"] forState:UIControlStateNormal];
        
    }
    
    NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
    photoo = [self.galleryImages objectAtIndex:self.swipeView.currentItemIndex];
    NSString *memeid = photoo.photoID;
    NSString *userId = [userInfoDisct objectForKey:@"userId"];
    
    
    NSString *urlString;
    if (param == 1) {
        urlString = MEME_MAKE_FAVOURITE;
    }else{
        urlString = MEME_MAKE_UNFAVOURITE;
    }
    
    //[UIAppDelegate activityShow];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //\\NSDictionary *parameters = @{@"userid":userId, @"memeid":memeid};
    NSDictionary *parameters = @{@"userID":userId, @"memeid":memeid};
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        //[UIAppDelegate activityHide];
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
                if (tag == 100)
                {
                    _favoriteButton.tag = 101;
                    MemePhoto *pho = [self.galleryImages objectAtIndex:self.swipeView.currentItemIndex];
                    //NSLog(@"BEfore Update pho=%@",pho.photoMyLike);
                    pho.photoMyFavorite = @"0";
                    //NSLog(@"After Update pho=%@",pho.photoMyLike);
                    [self.galleryImages replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
                    //[self.imageHostScrollView reloadInputViews];
                }
                else
                {
                    _favoriteButton.tag = 100;
                    MemePhoto *pho = [self.galleryImages objectAtIndex:self.swipeView.currentItemIndex];
                    //NSLog(@"BEfore Update pho=%@",pho.photoMyLike);
                    pho.photoMyFavorite = @"1";
                    //NSLog(@"After Update pho=%@",pho.photoMyLike);
                    [self.galleryImages replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
                    //[self.imageHostScrollView reloadInputViews];
                }
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [UIAppDelegate activityHide];
    }];
}

#pragma mark - get Updated Like
-(void)getUpdatedLikeWithMemeId:(NSString *)memeId forItemIndex:(NSInteger)itemIndex
{
    NSLog(@"getUpdatedLikeWithMemeId Called....");
    
    NSString *userId;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED]) {
        userId = @"";
    }
    else
    {
        NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
        userId = [userInfoDisct objectForKey:@"userId"];
    }
    
    NSString *urlString = MEME_UPDATE_LIKE;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"memeId": memeId, @"userID":userId};
    
    //_activity_like.hidden = NO;
    //[_activity_like startAnimating];
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Sample logic to check login status
        
        NSError *error = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"Error serializing %@", error);
        }
        else {
            if ([[JSON objectForKey:@"status"] isEqualToString:@"1"]) {
                NSArray *listArray = [JSON objectForKey:@"result"];
                for (NSDictionary *listDic in listArray)
                {
                    NSString *totalLike = [listDic objectForKey:@"allLike"];
                    NSString *daytotalLike = [listDic objectForKey:@"daytotalLike"];
                    NSString *day7totalLike = [listDic objectForKey:@"7daytotalLike"];
                    NSString *day30totalLike = [listDic objectForKey:@"30daytotalLike"];
                    NSString *day90totalLike = [listDic objectForKey:@"90daytotalLike"];
                    NSString *MyFavorite = [listDic objectForKey:@"isMyFavorite"];
                    NSString *MyLike = [listDic objectForKey:@"isMyLike"];
                    NSString *photoID = [listDic objectForKey:@"id"];
                    
                    
                    
                    TrendingSwipeViewItem *view = (TrendingSwipeViewItem *)[self.swipeView itemViewAtIndex:itemIndex];
                    
                    MemePhoto *pho = [self.galleryImages objectAtIndex:itemIndex];
                    
                    pho.allLike = totalLike;
                    pho.daytotalLike = daytotalLike;
                    pho.daySeventotalLike = day7totalLike;
                    pho.dayThirtytotalLike = day30totalLike;
                    pho.dayNinetytotalLike = day90totalLike;
                    pho.photoMyFavorite = MyFavorite;
                    pho.photoMyLike = MyLike;
                    pho.photoID = photoID;
                    
                    [self.galleryImages replaceObjectAtIndex:itemIndex withObject:pho];
                    
                    view.todaysLikes.text = [NSString stringWithFormat:@"Likes Today (%@)",daytotalLike];
                    view.sevenDaysLikes.text = [NSString stringWithFormat:@"7 Days (%@)",day7totalLike];
                    view.thirtyDaysLikes.text = [NSString stringWithFormat:@"30 Days (%@)",day30totalLike];
                    view.totalLikes.text = [NSString stringWithFormat:@"Total Likes (%@)",totalLike];
                    
                    MemePhoto *pho1 = [self.galleryImages objectAtIndex:_swipeView.currentItemIndex];
                    //Check if Favourite
                    if ([pho1.photoMyFavorite isEqualToString:@"1"]) {
                        _favoriteButton.tag = 100;
                        [_favoriteButton setImage:[UIImage imageNamed:@"star_purple3.png"] forState:UIControlStateNormal];
                        
                    }else{
                        _favoriteButton.tag = 101;
                        [_favoriteButton setImage:[UIImage imageNamed:@"star_purple2.png"] forState:UIControlStateNormal];
                    }
                    
                    //Check if Liked
                    if ([pho.photoMyLike isEqualToString:@"1"]){
                        view.likeButton.tag = 100;
                        [view.likeButton setImage:[UIImage imageNamed:@"like_white.png"] forState:UIControlStateNormal];
                    }
                    else{
                        view.likeButton.tag = 101;
                        [view.likeButton setImage:[UIImage imageNamed:@"qq_12.png"] forState:UIControlStateNormal];
                    }
                    
                    
                }
            }
        }
        
        //[_activity_like stopAnimating];
        //_activity_like.hidden = YES;
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //[_activity_like stopAnimating];
        //_activity_like.hidden = YES;
    }];
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
    TrendingSwipeViewItem *view = (TrendingSwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
    
    NSArray *vcArr;
    UIViewController *vc;
    LoginViewController *viewController;
    
    switch (alertView.tag)
    {
        case 1:
            switch (buttonIndex)
            {
                case 0:
                    
                    [self.swipeView scrollToItemAtIndex:0 duration:0.5];
                    
                    view.numberLabel.text = [NSString stringWithFormat:@"#%ld",self.swipeView.currentItemIndex+1];
                    
                    view.todaysLikes.text = [NSString stringWithFormat:@"Likes Today (%@)",photoo.daytotalLike];
                    view.sevenDaysLikes.text = [NSString stringWithFormat:@"7 Days (%@)",photoo.daySeventotalLike];
                    view.thirtyDaysLikes.text = [NSString stringWithFormat:@"30 Days (%@)",photoo.dayThirtytotalLike];
                    view.totalLikes.text = [NSString stringWithFormat:@"Total Likes (%@)",photoo.allLike];
                    
                    break;
                case 1:
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WILL_SHOW_SWIPE_SCREEN_LAST_INDEX_POPUP];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self.swipeView scrollToItemAtIndex:0 duration:0.5];
                    
                    view.numberLabel.text = [NSString stringWithFormat:@"#%ld",self.swipeView.currentItemIndex+1];
                    
                    view.todaysLikes.text = [NSString stringWithFormat:@"Likes Today (%@)",photoo.daytotalLike];
                    view.sevenDaysLikes.text = [NSString stringWithFormat:@"7 Days (%@)",photoo.daySeventotalLike];
                    view.thirtyDaysLikes.text = [NSString stringWithFormat:@"30 Days (%@)",photoo.dayThirtytotalLike];
                    view.totalLikes.text = [NSString stringWithFormat:@"Total Likes (%@)",photoo.allLike];
                    break;
                case 2:
                    
                    NSLog(@"tag = 1 buttonIndex = 2");
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
            switch (buttonIndex)
            {
                case 0:
                    //[irate rate];
                    NSLog(@"tag = 2 buttonIndex = 0");
                    break;
                case 1:
                    [self.swipeView scrollToItemAtIndex:0 duration:0.5];
                    
                    view.numberLabel.text = [NSString stringWithFormat:@"#%ld",self.swipeView.currentItemIndex+1];
                    
                    view.todaysLikes.text = [NSString stringWithFormat:@"Likes Today (%@)",photoo.daytotalLike];
                    view.sevenDaysLikes.text = [NSString stringWithFormat:@"7 Days (%@)",photoo.daySeventotalLike];
                    view.thirtyDaysLikes.text = [NSString stringWithFormat:@"30 Days (%@)",photoo.dayThirtytotalLike];
                    view.totalLikes.text = [NSString stringWithFormat:@"Total Likes (%@)",photoo.allLike];
                    break;
                case 2:
                    vcArr = [self.navigationController viewControllers];
                    vc = (UIViewController*)[vcArr objectAtIndex:0];
                    
                    if ([vcArr containsObject:[FavoriteViewController class]])
                    {
                        [self.navigationController popToViewController:vc animated:YES];
                        return;
                    }else
                    {
                        FavoriteViewController *viewController = [[FavoriteViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"FavoriteViewController"] bundle:nil];
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                    NSLog(@"tag = 2 buttonIndex = 2");
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 3:
        case 4:
            switch (buttonIndex) {
                case 0:
                    appDelegate.isFromMemeSwipe = YES;
                    viewController = [[LoginViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"LoginViewController"] bundle:nil];
                    [self presentViewController:viewController animated:YES completion:nil];
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - callFullScreenAd
-(void)callFullScreenAd
{
    if(![UIAppDelegate isProUser])
    {
        [UIAppDelegate reloadInterstitialAds];
        swipeCount = 0;
    }
}

#pragma mark - Load Nib
-(NSArray *)loadNibForProUser
{
    NSArray *arrayOfViews;
    if(IS_IPAD)
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TrendingSwipeViewItem_iPad_pro" owner:self options:nil];
    }
    else if(IS_IPHONE_4INCHES)
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TrendingSwipeViewItem_pro" owner:self options:nil];
        
    }
    else
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TrendingSwipeViewItem_iPhone_pro" owner:self options:nil];
    }
    return arrayOfViews;
}

-(NSArray *)loadNibForNormalUser
{
    NSArray *arrayOfViews;
    if(IS_IPAD)
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TrendingSwipeViewItem_iPad" owner:self options:nil];
    }
    else if(IS_IPHONE_4INCHES)
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TrendingSwipeViewItem" owner:self options:nil];
        
    }
    else
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TrendingSwipeViewItem_iPhone" owner:self options:nil];
    }
    return arrayOfViews;
}


#pragma mark Memory managment
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
























