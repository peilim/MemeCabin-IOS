//
//  MemesSwipeView.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 31/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "MemesSwipeView.h"
#import "MemePhoto.h"
#import "DBHelper.h"
#import "AFNetworking.h"
//#import "UIImageView+AFNetworking.h"
#import "MCHTTPManager.h"
#import "SwipeViewItem.h"

#import "DACircularProgressView.h"
#import "UIImage+GIF.h"

//#import "UIImageView+Scale.h"
#import "UIImage+Resizing.h"
#import "UIImageView+WebCache.h"

#import "FHSTwitterEngine.h"


typedef NS_ENUM(NSInteger, ScrollDragType) {
    ScrollDragTypeNormal,
    ScrollDragTypePrev,
    ScrollDragTypeNext
};

@interface MemesSwipeView ()<SwipeViewDataSource, SwipeViewDelegate, UIScrollViewDelegate,FHSTwitterEngineAccessTokenDelegate>
{
    DBHelper *dbhelper;
    MemePhoto *photoo;
    int likeCount;
    long page;
    UIView *savedToCameraRollView;
    int swipeCount;
    BOOL SHOW_ADD;
    BOOL isLoadingMore;
    
    ScrollDragType dragType;
    int pageOffsetForDrag;
    
    CustomBadge *badgeForAllMeme;
    
    BOOL isRollingBack;
    UIImage *reportedImage;
    
    NSInteger bookMarkIndex;
    UILabel *_titleLabel;
    
    BOOL likeViewHidden;
    GADInterstitial  *interstitial_;
    
    BOOL isSingleTab;
    
}

@property (weak, nonatomic) IBOutlet UIView *swipeContainer;
@property (nonatomic, weak) IBOutlet SwipeView *swipeView;
@property (weak, nonatomic) IBOutlet UIScrollView *zoomScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *zoomableImageView;

@end


@implementation MemesSwipeView
@synthesize galleryImages = galleryImages_;

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - SwipeView

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    swipeView.alignment = SwipeViewAlignmentCenter;
    if (!isLoadingMore)
        swipeView.currentItemIndex = _imageIndex;
    
    
    NSLog(@"Arr Count = %lu",(unsigned long)UIAppDelegate.photoArray.count);
    return [UIAppDelegate.photoArray count];
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    NSLog(@"Entered!! & index: %ld",(long)index);
    SwipeViewItem *item = nil;
    if (!view || ![view isKindOfClass:[SwipeViewItem class]])
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
            if ([view isKindOfClass:[SwipeViewItem class]]) {
                [view setBackgroundColor:[UIColor clearColor]];
                item = (SwipeViewItem *)view;
                
                if (index == UIAppDelegate.photoArray.count - 1)
                {
                    /*
                    item.scrollViewSwipeItem.hidden = YES;
                    item.likeBG.hidden = YES;
                    item.titleBG.hidden = YES;*/
                    
                }
                
                [item.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                if (_controllerIdentifier == 5)
                {
                    /*
                    if (IS_IPAD) {
                        item.likeBG.frame = CGRectMake(10, 6, 748, item.likeBG.frame.size.height+5);
                    } else {
                        item.likeBG.frame = CGRectMake(10, 6, 300, item.likeBG.frame.size.height+5);
                    }
                    
                    
                    UILabel *titleLabel = [[UILabel alloc] init];
                    
                    if (IS_IPAD) {
                        titleLabel.frame = CGRectMake(2, 6, 600, 85);
                    } else {
                        titleLabel.frame = CGRectMake(2, 3, 210, 48);
                    }
                    [titleLabel setFont:[UIFont boldSystemFontOfSize:15*padFactor]];
                    [titleLabel setTextAlignment:NSTextAlignmentCenter];
                    [titleLabel setTextColor:[UIColor whiteColor]];
                    _titleLabel = titleLabel;
                    _titleLabel.text = @"";
                    [titleLabel setTag:2]; 
                    [item.likeBG addSubview:titleLabel];
                    
                    if (IS_IPAD) {
                        item.likesLabel.frame = CGRectMake(610, 12, 63, 77);
                        item.likeButton.frame = CGRectMake(610+item.likesLabel.frame.size.width+5, 25 , 57, 53);
                    } else {
                        item.likesLabel.frame = CGRectMake(218, 5, 38, 46);
                        item.likeButton.frame = CGRectMake(218+item.likesLabel.frame.size.width+5, 10, 34, 32);
                    }
                    */
                }
                
                break;
            }
        }
    }
    else
    {
        item = (SwipeViewItem *)view;
    }
    
    if (item)
    {
        
        
        // Set Image
        MemePhoto *photo = [UIAppDelegate.photoArray objectAtIndex:index];
        if(item.imageView.image)
            item.imageView.image = nil;
        //\\item.scrollViewSwipeItem.delegate = self;
        
        /*
        if (index == UIAppDelegate.photoArray.count - 1)
        {
            //item.scrollViewTrendingSwipeItem.hidden = YES;
            //item.BGLike.hidden = YES;
            NSLog(@"You will see blank!!");
        }
        else*/
        {
            item.scrollViewSwipeItem.delegate = self;
            
            if (_controllerIdentifier == 5)
            {
                
                
                /*[UIAppDelegate activityShow];
                item.imageView.contentMode = UIViewContentModeCenter;
                [self downloadImageWithURL:[NSURL URLWithString:photo.photoURL] completionBlock:^(BOOL succeeded, UIImage *image) {
                    [UIAppDelegate activityHide];
                    if(image)
                    {
                        item.imageView.image = image;
                    }
                }];*/
                if(item.imageView.animatedImage)
                    item.imageView.animatedImage = nil;
                
                //item.imageView.contentMode = UIViewContentModeCenter;
                [item.activityIndicatorView startAnimating];
                
                [item.imageView sd_setImageWithURL:[NSURL URLWithString:photo.photoURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
                                //item.imageView.image = [image scaleToFitSize:CGSizeMake(748*0.75, 824*0.75)];
                                item.imageView.image = image;
                            }
                            else
                            {
                                //item.imageView.image = [image scaleToFitSize:CGSizeMake(748*0.75, 778*0.75)];
                                item.imageView.image = image;
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
                                    //item.imageView.frame = CGRectMake(item.imageView.frame.origin.x, item.imageView.frame.origin.y,300*0.75, 456*0.75);
                                    //item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 456*0.75)];
                                    item.imageView.image = image;
                                }
                                else
                                {
                                    //item.imageView.frame = CGRectMake(item.imageView.frame.origin.x, item.imageView.frame.origin.y,300*0.75, 406*0.75);
                                    //item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 406*0.75)];
                                    item.imageView.image = image;
                                }
                            }
                            else
                            {
                                if([UIAppDelegate isProUser])
                                {
                                    //item.imageView.frame = CGRectMake(item.imageView.frame.origin.x, item.imageView.frame.origin.y,300*0.75, 368*0.75);
                                    //item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 368*0.75)];
                                    //item.imageView.image = [image sd_animatedImageByScalingAndCroppingToSize:CGSizeMake(300*0.75, 368*0.75)];
                                    
                                    item.imageView.image = image;
                                }
                                else
                                {
                                    //item.imageView.frame = CGRectMake(item.imageView.frame.origin.x, item.imageView.frame.origin.y,300*0.75, 318*0.75);
                                    //item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 318*0.75)];
                                    //item.imageView.image = [image sd_animatedImageByScalingAndCroppingToSize:CGSizeMake(300*0.75, 318*0.75)];
                                    
                                    item.imageView.image = image;
                                    
                                    //item.imageView.frame = CGRectMake(10, 40, 200, 200);
                                    
                                    //NSLog(@"item.imageView.frame = %@",NSStringFromCGRect(item.imageView.frame));
                                }
                            }
                            item.imageView.contentMode = UIViewContentModeCenter;
                            
                        }
                    }

                }];
                
                /*
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data1 = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo.photoURL]];
                    //FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data1];
                    UIImage *image = [UIImage sd_animatedGIFWithData:data1];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //item.imageView.animatedImage = animatedImage1;
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
                                    item.imageView.image = [image scaleToFitSize:CGSizeMake(748*0.65, 824*0.65)];
                                }
                                else
                                {
                                    item.imageView.image = [image scaleToFitSize:CGSizeMake(748*0.65, 778*0.65)];
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
                                        item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.65, 456*0.65)];
                                        //item.imageView.image = image;
                                    }
                                    else
                                    {
                                        item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.65, 406*0.65)];
                                        //item.imageView.animatedImage = image;
                                    }
                                }
                                else
                                {
                                    if([UIAppDelegate isProUser])
                                    {
                                        item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.65, 368*0.65)];
                                        //item.imageView.animatedImage = image;
                                    }
                                    else
                                    {
                                        item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.65, 318*0.65)];
                                        //item.imageView.animatedImage = image;
                                        
                                        //item.imageView.frame = CGRectMake(10, 40, 200, 200);
                                        
                                        //NSLog(@"item.imageView.frame = %@",NSStringFromCGRect(item.imageView.frame));
                                    }
                                }
                                item.imageView.contentMode = UIViewContentModeCenter;
                                
                            }
                        }
                    });
                });*/
                
                
            }
            else
            {
                [item.activityIndicatorView startAnimating];
                
                /*[item.imageView setImageWithURLRequest:
                 [NSURLRequest requestWithURL:[NSURL URLWithString:photo.photoURL]]
                                      placeholderImage:nil
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)*/
                
                [item.imageView sd_setImageWithURL:[NSURL URLWithString:photo.photoURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                 {
                     if(image)
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
                                 item.imageView.image = [image scaleToFitSize:CGSizeMake(748*0.75, 824*0.75)];
                             }
                             else
                             {
                                 item.imageView.image = [image scaleToFitSize:CGSizeMake(748*0.75, 778*0.75)];
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
                                     item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 456*0.75)];
                                 }
                                 else
                                 {
                                     
                                     item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 406*0.75)];
                                     
                                     
                                 }
                             }
                             else
                             {
                                 if([UIAppDelegate isProUser])
                                 {
                                     item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 368*0.75)];
                                 }
                                 else
                                 {
                                     item.imageView.image = [image scaleToFitSize:CGSizeMake(300*0.75, 318*0.75)];
                                 }
                             }
                             item.imageView.contentMode = UIViewContentModeCenter;
                             
                         }
                     }
                     
                     
                     //[item.imageView setImageWithScaleDownOnly:image];
                     
                     
                     
                     
                 }]; /*failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                     //
                 }];*/
            }
            
            
            
            //NSLog(@"imageView Frame=%@, ForIndex=%ld",NSStringFromCGRect(item.imageView.frame),(long)index);
            //NSLog(@"image W=%f, H=%f, ForIndex=%ld",item.imageView.image.size.width,item.imageView.image.size.height,(long)index);
            
            if (photo.photoLike.length > 0) {
                item.likesLabel.text = [NSString stringWithFormat:@"Total Likes (%@)",photo.photoLike];
            }
            else {
                item.likesLabel.text = [NSString stringWithFormat:@"Total Likes (0)"];
            }
            if (_controllerIdentifier == 5)
            {
                if (index == 0) {
                    if (photo.photoTitle.length > 0) {
                        item.titleBG.hidden = NO;
                        [item.titleLabel setText:photo.photoTitle];
                    }
                    else {
                        item.titleBG.hidden = YES;
                        [item.titleLabel setText:@""];
                    }
                }
            }
            else
                item.titleBG.hidden = YES;
            
            
            [self getUpdatedLikeWithMemeId:photo.photoID forItemIndex:index];
            
            //Check if Liked
            if ([photo.photoMyLike isEqualToString:@"1"])
            {
                item.likeButton.tag = 100;
                switch (_controllerIdentifier)
                {
                    case 1:
                        [item.likeButton setImage:[UIImage imageNamed:@"like_blue.png"] forState:UIControlStateNormal];
                        break;
                    case 2:
                        [item.likeButton setImage:[UIImage imageNamed:@"like_yellow.png"] forState:UIControlStateNormal];
                        break;
                    case 3:
                        [item.likeButton setImage:[UIImage imageNamed:@"like_red.png"] forState:UIControlStateNormal];
                        break;
                    case 4:
                        [item.likeButton setImage:[UIImage imageNamed:@"like_green.png"] forState:UIControlStateNormal];
                        break;
                    case 5:
                        [item.likeButton setImage:[UIImage imageNamed:@"like_purple.png"] forState:UIControlStateNormal];
                        break;
                        
                    default:
                        break;
                }
            }
            else
            {
                item.likeButton.tag = 101;
                [item.likeButton setImage:[UIImage imageNamed:@"like_grey.png"] forState:UIControlStateNormal];
            }
            
        }
        
        
        
    }
    
    
    
    return item;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeContainer.bounds.size;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    if (isRollingBack)
    {
        if (swipeView.currentItemIndex == 0)
        {
            isRollingBack = NO;
        }
        else
        {
            return;
        }
    }
    
    
    if (_controllerIdentifier == 5)
    {
        MemePhoto *photo = [UIAppDelegate.photoArray objectAtIndex:swipeView.currentItemIndex];
        SwipeViewItem *viewItem = (SwipeViewItem *)[_swipeView itemViewAtIndex:_swipeView.currentItemIndex];
        
        if (photo.photoTitle.length > 0) {
            viewItem.titleBG.hidden = NO;
            [viewItem.titleLabel setText:photo.photoTitle];
        }
        else {
            viewItem.titleBG.hidden = YES;
            [viewItem.titleLabel setText:@""];
        }
        
        
    }
    
    NSLog(@"swipeViewCurrentItemIndexDidChange Called");
    
    if (swipeView.currentItemIndex == UIAppDelegate.photoArray.count - 1)
    {
        if (swipeView.currentItemIndex == self.totalMeme - 1)
        {
            [self showEndMemePopUp];
            //[swipeView scrollToItemAtIndex:swipeView.currentItemIndex-1 duration:0.0];
            [self performSelector:@selector(test) withObject:nil afterDelay:0.05];
        }
        else
        {
            [self loadImagesForPageNumber:self.pageNumber andIdentifier:_controllerIdentifier];
        }
    }
    else
    {
        MemePhoto *photo = [UIAppDelegate.photoArray objectAtIndex:swipeView.currentItemIndex];
        //\\[dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
        
        /*
        if (swipeView.currentItemIndex == UIAppDelegate.photoArray.count - 1)
        {
            [self showEndMemePopUp];
        }*/
        
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
        NSLog(@"page Count==%ld",page);
        
        switch (_controllerIdentifier)
        {
            case 1:
                
                if ([dbhelper isViewed:photo.photoID])
                {
                    
                }
                else
                {
                    UIAppDelegate.currentBadgeMemeEveryOne = UIAppDelegate.currentBadgeMemeEveryOne - 1;
                    NSLog(@"Index***===:%ld",(long)swipeView.currentItemIndex);
                    if(!(UIAppDelegate.currentBadgeMemeEveryOne < 0))
                    {
                        [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeEveryOne forKey:MEME_EVERYONE_CURRENT_COUNT];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [UIAppDelegate setAllBadgesCountForApplication];
                        [self updateBottomBadgeCount];
                    }
                    [dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
                }
                
                break;
                
            case 2:
                if ([dbhelper isViewed:photo.photoID])
                {
                    
                }
                else
                {
                    UIAppDelegate.currentBadgeMemeMotiInsp = UIAppDelegate.currentBadgeMemeMotiInsp - 1;
                    
                    if(!(UIAppDelegate.currentBadgeMemeMotiInsp < 0))
                    {
                        [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeMotiInsp forKey:MEME_MOTI_INSP_CURRENT_COUNT];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [UIAppDelegate setAllBadgesCountForApplication];
                        [self updateBottomBadgeCount];
                    }
                    [dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
                }
                
                break;
                
            case 3:
                if ([dbhelper isViewed:photo.photoID])
                {
                    
                }
                else
                {
                    UIAppDelegate.currentBadgeMemeRacy = UIAppDelegate.currentBadgeMemeRacy - 1;
                    if(!(UIAppDelegate.currentBadgeMemeRacy < 0))
                    {
                        [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeRacy forKey:MEME_RACY_CURRENT_COUNT];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [UIAppDelegate setAllBadgesCountForApplication];
                        [self updateBottomBadgeCount];
                    }
                    [dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
                }
                
                break;
                
                /*
            case 5:
                if ([dbhelper isViewed:photo.photoID]) {
                    
                }
                else
                {
                    UIAppDelegate.currentBadgeMemeSpiffyGif = UIAppDelegate.currentBadgeMemeSpiffyGif - 1;
                    if (!(UIAppDelegate.currentBadgeMemeSpiffyGif < 0))
                    {
                        [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeSpiffyGif forKey:MEME_SPIFFY_GIF_CURRENT_COUNT];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [UIAppDelegate setAllBadgesCountForApplication];
                        [self updateBottomBadgeCount];
                    }
                    [dbhelper updateMemeView:@"1" withMemeID:photo.photoID];
                }
                
                break;
                */
                 
            default:
                break;
        }
        
        
        /// favorite ///
        
        if ([photo.photoMyFavorite isEqualToString:@"1"])
        {
            _favoriteButton.tag = 100;
            switch (_controllerIdentifier)
            {
                case 1:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_blue3.png"] forState:UIControlStateNormal];
                    break;
                case 2:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow3.png"] forState:UIControlStateNormal];
                    break;
                case 3:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_red3.png"] forState:UIControlStateNormal];
                    break;
                case 4:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_green3.png"] forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            _favoriteButton.tag = 101;
            switch (_controllerIdentifier)
            {
                case 1:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_blue2.png"] forState:UIControlStateNormal];
                    break;
                case 2:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow2.png"] forState:UIControlStateNormal];
                    break;
                case 3:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_red2.png"] forState:UIControlStateNormal];
                    break;
                case 4:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_green2.png"] forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
            
        }
    }
    
    SwipeViewItem *swipeviewItem = (SwipeViewItem *)[_swipeView itemViewAtIndex:_swipeView.currentItemIndex];
    [swipeviewItem.likeBG setAlpha:1];

}

-(void)test
{
    
    [_swipeView scrollToItemAtIndex:_swipeView.currentItemIndex-1 duration:0.10];
    //self.swipeView.currentItemIndex = self.swipeView.currentItemIndex-1;
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

#pragma mark - ViewController LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"2AFq1kLxU3ClwDNRC80gqNOEI" andSecret:@"rxkZoABENHB0tGiLbFIAMv6dfao6aOZGMOYHqDB5oY42M1YFpl"];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    [[FHSTwitterEngine sharedEngine]loadAccessToken];
    
    //swipeView start
    
    
    
    //    _swipeView.pagingEnabled = YES;
    //    _swipeView.itemsPerPage = 1;
    
    self.zoomScrollView.hidden = YES;
    
    if (_controllerIdentifier != 5)
    {
        UITapGestureRecognizer *doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleGesture.numberOfTapsRequired = 2;
        [self.swipeView addGestureRecognizer:doubleGesture];
        
        UITapGestureRecognizer *doubleGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleGesture2.numberOfTapsRequired = 2;
        [self.zoomScrollView addGestureRecognizer:doubleGesture2];
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlesingleTap:)];
        singleTapGesture.numberOfTapsRequired = 1;
        [self.swipeView addGestureRecognizer:singleTapGesture];
    }
    else
    {
    
        /*
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlesingleTap:)];
        singleTapGesture.numberOfTapsRequired = 1;
        [self.swipeView addGestureRecognizer:singleTapGesture];
         */
        
        UIAppDelegate.currentBadgeMemeSpiffyGif = 0;
        
        if(!(UIAppDelegate.currentBadgeMemeSpiffyGif < 0))
        {
            [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeSpiffyGif forKey:MEME_SPIFFY_GIF_CURRENT_COUNT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [UIAppDelegate setAllBadgesCountForApplication];
            [self updateBottomBadgeCount];
        }
    }
    
    //swipeView end
    
    if(_imageIndex == 0)
    {
        swipeCount = 0;
    }
    else
    {
        swipeCount = 0; // Jin change -1 to 0
    }
    //swipeCount = -1;//0;
    if([UIAppDelegate isProUser])
    {
        //hideAdMob];
        [UIAppDelegate hideFlurryAd];
        
        if (IS_IPHONE)
        {
            if (IS_IPHONE_4INCHES)
            {
                if (_controllerIdentifier == 5)
                {
                    self.swipeContainer.frame = CGRectMake(0, 79, 320, 386);
                    self.swipeView.frame = CGRectMake(-320, 2, 960, 382);
                    self.zoomScrollView.frame = CGRectMake(0, 79, 320, 386);
                    self.zoomableImageView.frame = CGRectMake(0, 0, 320, 386);
                }
                else
                {
                    self.swipeContainer.frame = CGRectMake(0, 54, 320, 460);
                    self.swipeView.frame = CGRectMake(-320, 2, 960, 456);
                    self.zoomScrollView.frame = CGRectMake(0, 54, 320, 460);
                    self.zoomableImageView.frame = CGRectMake(0, 0, 320, 460);
                }
                
            }
            else
            {
                self.swipeContainer.frame = CGRectMake(0, 54, 320, 372);
                self.swipeView.frame = CGRectMake(-320, 2, 960, 368);
                self.zoomScrollView.frame = CGRectMake(0, 54, 320, 372);
                self.zoomableImageView.frame = CGRectMake(0, 0, 320, 372);
            }
        }
        else
        {
            self.swipeContainer.frame = CGRectMake(0, 97, 768, 828);
            self.swipeView.frame = CGRectMake(-768, 2, 2304, 824);
            self.zoomScrollView.frame = CGRectMake(0, 97, 768, 828);
            self.zoomableImageView.frame = CGRectMake(0, 0, 768, 828);
        }
        
        
    }
    else
    {
        [UIAppDelegate addFlurryInView:_myView];
        [UIAppDelegate reloadInterstitialAds];
        
        if(_imageIndex==0)
        {
            
        }
        
    }
    
    
    _activity_like.hidden = YES;
    
    // Do any additional setup after loading the view, typically from a nib.
    //appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //self.galleryImages = [NSMutableArray arrayWithArray:_imageArray];
    
    //NSLog(@"self.galleryImages%lu",(unsigned long)self.galleryImages.count);
    page = _imageIndex;
    
    [[NSUserDefaults standardUserDefaults] setInteger:page forKey:@"previousPageNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    dbhelper = [[DBHelper alloc] init];
    photoo = [UIAppDelegate.photoArray objectAtIndex:_imageIndex];
    
    if (_controllerIdentifier != 5)
    {
        [self setupUIWithIdentifier:_controllerIdentifier];
        
        if ([photoo.photoMyFavorite isEqualToString:@"1"])
        {
            _favoriteButton.tag = 100;
            switch (_controllerIdentifier)
            {
                case 1:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_blue3.png"] forState:UIControlStateNormal];
                    break;
                case 2:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow3.png"] forState:UIControlStateNormal];
                    break;
                case 3:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_red3.png"] forState:UIControlStateNormal];
                    break;
                case 4:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_green3.png"] forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            _favoriteButton.tag = 101;
            switch (_controllerIdentifier)
            {
                case 1:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_blue2.png"] forState:UIControlStateNormal];
                    break;
                case 2:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow2.png"] forState:UIControlStateNormal];
                    break;
                case 3:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_red2.png"] forState:UIControlStateNormal];
                    break;
                case 4:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_green2.png"] forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
            
        }
    }
    else
    {
        if ([dbhelper isViewed:photoo.photoID])
        {
            UIAppDelegate.badgeSpiffyGifs = UIAppDelegate.badgeSpiffyGifs;
        }
        else
        {
            if(_imageIndex==0)
            {
                UIAppDelegate.currentBadgeMemeSpiffyGif = UIAppDelegate.currentBadgeMemeSpiffyGif - 1;
                [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.currentBadgeMemeSpiffyGif forKey:MEME_SPIFFY_GIF_CURRENT_COUNT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [UIAppDelegate setAllBadgesCountForApplication];
                
                //Update Database ViewCount
                [dbhelper updateMemeView:@"1" withMemeID:photoo.photoID];
                [self updateBottomBadgeCount];
            }
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [UIAppDelegate.popTipView dismissAnimated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[GoogleAnalyticsCustom getSharedInstance] setCurrentScreenName:@"Meme Swipe Screen"];
    
    _addedToFavouriteView.hidden = YES;
    _popupView.hidden = YES;
    
    //\\[_swipeView reloadData];
    //\\_swipeView.currentItemIndex = _imageIndex;
    
    [self updateBottomBadgeCount];
    self.navigationController.navigationBarHidden = YES;
    
    
    UIImageView *contentView = [[UIImageView alloc] initWithFrame:CGRectZero];
    UIView *aView = [[UIView alloc] initWithFrame:CGRectZero];
    if(IS_IPAD)
    {
        contentView.frame= CGRectMake(200, 200, 303,150);
        contentView.image = [UIImage imageNamed:@"btn_pop_box.png"];
        aView.frame = CGRectMake(314, 960, 0, 0);
        [UIAppDelegate.window.rootViewController.view addSubview:aView];
    }
    else
    {
        if(IS_IPHONE_4INCHES)
        {
            contentView.frame= CGRectMake(200, 200, 200,99);
            contentView.image = [UIImage imageNamed:@"btn_pop_box.png"];
            aView.frame = CGRectMake(146, 546, 0,0);
            
            [UIAppDelegate.window.rootViewController.view addSubview:aView];
        }
        else
        {
            contentView.frame= CGRectMake(200, 200, 173,86);
            contentView.image = [UIImage imageNamed:@"btn_pop_box.png"];
            aView.frame = CGRectMake(146, 460, 0, 0);
            [UIAppDelegate.window.rootViewController.view addSubview:aView];
        }
    }
    
    if(_controllerIdentifier == 5)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if(![defaults boolForKey:@"tip_view"])
        {
            UIAppDelegate.popTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
            UIAppDelegate.popTipView.delegate = self;
            UIAppDelegate.popTipView.dismissTapAnywhere = NO;
            UIAppDelegate.popTipView.disableTapToDismiss = NO;
            //popTipView.frame = CGRectMake(40, 200, 200, 100);
            UIAppDelegate.popTipView.backgroundColor = [UIColor clearColor];
            UIAppDelegate.popTipView.borderWidth = 0;
            UIAppDelegate.popTipView.has3DStyle = NO;
            UIAppDelegate.popTipView.hasShadow = NO;
            //[UIAppDelegate.popTipView autoDismissAnimated:YES atTimeInterval:5.0];
            
            [UIAppDelegate.popTipView presentPointingAtView:aView inView:UIAppDelegate.window.rootViewController.view animated:YES];
            
            
            
        }
    }
    
}

#pragma mark - CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [popTipView dismissAnimated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIAppDelegate.popTipView = nil;
    
    [defaults setBool:YES forKey:@"tip_view"];
    [defaults synchronize];
}




-(void)viewDidLayoutSubviews
{
    //NSLog(@"viewDidLayoutSubviews");
    
    if ([UIAppDelegate isProUser]) {
        CGFloat collectionViewHeight = 0;
        if (IS_IPHONE) {
            if (IS_IPHONE_4INCHES) {
                collectionViewHeight = 460; }
            else { collectionViewHeight = 373; }
        } else { collectionViewHeight = 828; }
        
        _imageHostScrollView.frame = CGRectMake(0,
                                                54*factorY,
                                                320*factorX, collectionViewHeight);
    }
}


#pragma mark - UI Setup

-(void)setupUIWithIdentifier:(NSInteger)identifier
{
    NSLog(@"identifier=%ld",(long)identifier);
    
    switch (identifier) {
        case 1:
            [_topBarbg setImage:[UIImage imageNamed:@"topbar_blue.png"]];
            [_topBarText setImage:[UIImage imageNamed:@"text_find_laugh.png"]];
            [_topBarRightImage setImage:[UIImage imageNamed:@"logo_meme_small.png"]];
            
            _totalLikesLabel.text = [NSString stringWithFormat:@"Total Likes (%d)",likeCount];
            /*[_thumbButton setImage:[UIImage imageNamed:@"like_grey.png"]
             forState:UIControlStateNormal];*/
            
            [_bottomBarbg setImage:[UIImage imageNamed:@"lower_blue.png"]];
            [_reloadButton setImage:[UIImage imageNamed:@"reload_blue.png"]
                           forState:UIControlStateNormal];
            /*[_favoriteButton setImage:[UIImage imageNamed:@"star_blue2.png"]
             forState:UIControlStateNormal];*/
            break;
        case 2:
            [_topBarbg setImage:[UIImage imageNamed:@"topbar_yellow.png"]];
            [_topBarText setImage:[UIImage imageNamed:@"text_find_laugh.png"]];
            [_topBarRightImage setImage:[UIImage imageNamed:@"logo_motivational_small.png"]];
            
            _totalLikesLabel.text = [NSString stringWithFormat:@"Total Likes (%d)",likeCount];
            /*[_thumbButton setImage:[UIImage imageNamed:@"like_grey.png"]
             forState:UIControlStateNormal];*/
            
            [_bottomBarbg setImage:[UIImage imageNamed:@"lower_yellow.png"]];
            [_reloadButton setImage:[UIImage imageNamed:@"reload_yellow.png"]
                           forState:UIControlStateNormal];
            /*[_favoriteButton setImage:[UIImage imageNamed:@"star_yellow2.png"]
             forState:UIControlStateNormal];*/
            break;
        case 3:
            [_topBarbg setImage:[UIImage imageNamed:@"topbar_red.png"]];
            [_topBarText setImage:[UIImage imageNamed:@"text_find_laugh.png"]];
            [_topBarRightImage setImage:[UIImage imageNamed:@"logo_racymeme_small.png"]];
            
            _totalLikesLabel.text = [NSString stringWithFormat:@"Total Likes (%d)",likeCount];
            /*[_thumbButton setImage:[UIImage imageNamed:@"like_grey.png"]
             forState:UIControlStateNormal];*/
            
            [_bottomBarbg setImage:[UIImage imageNamed:@"lower_red.png"]];
            [_reloadButton setImage:[UIImage imageNamed:@"reload_red.png"]
                           forState:UIControlStateNormal];
            /*[_favoriteButton setImage:[UIImage imageNamed:@"star_red2.png"]
             forState:UIControlStateNormal];*/
            break;
        case 4:
            [_topBarbg setImage:[UIImage imageNamed:@"topbar_green.png"]];
            [_topBarText setImage:[UIImage imageNamed:@"text_find_laugh.png"]];
            [_topBarRightImage setImage:[UIImage imageNamed:@"star_green2.png"]];
            
            _totalLikesLabel.text = [NSString stringWithFormat:@"Total Likes (%d)",likeCount];
            /*[_thumbButton setImage:[UIImage imageNamed:@"like_grey.png"]
             forState:UIControlStateNormal];*/
            
            [_bottomBarbg setImage:[UIImage imageNamed:@"lower_green.png"]];
            [_reloadButton setImage:[UIImage imageNamed:@"reload_green.png"]
                           forState:UIControlStateNormal];
            /*[_favoriteButton setImage:[UIImage imageNamed:@"star_green2.png"]
             forState:UIControlStateNormal];*/
            break;
            
        default:
            break;
    }
}

-(void)initialSwipeViewSetup
{
    _likeRoundView.layer.cornerRadius = 10;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(performLeft)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(performRight)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.imageHostScrollView addGestureRecognizer:swipeLeft];
    [self.imageHostScrollView addGestureRecognizer:swipeRight];
    
    //self.imageHostScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.imageHostScrollView.frame), CGRectGetHeight(self.imageHostScrollView.frame));
    
    self.imageHostScrollView.delegate = self;
    
    
    //self.imageHostScrollView.pagingEnabled = YES;
    self.imageHostScrollView.scrollEnabled = YES;
    
    self.imageHostScrollView.minimumZoomScale = 1;
    self.imageHostScrollView.maximumZoomScale = 5.5;
    
    
    [_prevView sd_setImageWithURL:[NSURL URLWithString:photoo.photoURL]];
    
    if (_prevView.image.size.width < self.imageHostScrollView.bounds.size.width)
        _prevView.contentMode = UIViewContentModeCenter;
    else
        _prevView.contentMode = UIViewContentModeScaleAspectFit;
    
    //self.imageHostScrollView.frame = _prevView.frame;
    
    //[self.imageHostScrollView addSubview:_prevView];
    
    self.prevView.frame = CGRectMake(0, 0, _prevView.image.size.width, _prevView.image.size.height);
    self.imageHostScrollView.contentSize = _prevView.image.size;
    
    NSLog(@"prevView.frame===%@, Img_ID=%@",NSStringFromCGRect(_prevView.frame),photoo.photoID);
    
    
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.imageHostScrollView addGestureRecognizer:doubleTap];
    
    
    _totalLikesLabel.text = [NSString stringWithFormat:@"Total Likes (%@)",photoo.photoLike];
    
    //Check if Favorite
    if ([photoo.photoMyFavorite isEqualToString:@"1"])
    {
        _favoriteButton.tag = 100;
        switch (_controllerIdentifier)
        {
            case 1:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_blue3.png"] forState:UIControlStateNormal];
                break;
            case 2:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow3.png"] forState:UIControlStateNormal];
                break;
            case 3:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_red3.png"] forState:UIControlStateNormal];
                break;
            case 4:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_green3.png"] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
    }
    else
    {
        _favoriteButton.tag = 101;
        [_favoriteButton setImage:[UIImage imageNamed:@"star_grey.png"] forState:UIControlStateNormal];
    }
    
    [_favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //Check if Liked
    if ([photoo.photoMyLike isEqualToString:@"1"])
    {
        _thumbButton.tag = 100;
        switch (_controllerIdentifier)
        {
            case 1:
                [_thumbButton setImage:[UIImage imageNamed:@"like_blue.png"] forState:UIControlStateNormal];
                break;
            case 2:
                [_thumbButton setImage:[UIImage imageNamed:@"like_yellow.png"] forState:UIControlStateNormal];
                break;
            case 3:
                [_thumbButton setImage:[UIImage imageNamed:@"like_red.png"] forState:UIControlStateNormal];
                break;
            case 4:
                [_thumbButton setImage:[UIImage imageNamed:@"like_green.png"] forState:UIControlStateNormal];
                break;
            case 5:
                [_thumbButton setImage:[UIImage imageNamed:@"like_purple.png"] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
    }
    else
    {
        _thumbButton.tag = 101;
        [_thumbButton setImage:[UIImage imageNamed:@"like_grey.png"] forState:UIControlStateNormal];
    }
    
    [_thumbButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imageHostScrollView scrollRectToVisible:CGRectMake(self.imageHostScrollView.frame.size.width*_imageIndex+20,
                                                             CGRectGetHeight(self.imageHostScrollView.frame)/2,
                                                             CGRectGetWidth(self.imageHostScrollView.frame)-20,
                                                             CGRectGetHeight(self.imageHostScrollView.frame))
                                         animated:NO];
    
}

#pragma mark - Swipe Left & Right

-(void)performLeft
{
    if (_imageIndex != UIAppDelegate.photoArray.count-1)
    {
        _imageIndex++;
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.prevView.layer addAnimation:transition forKey:nil];
        
        NSLog(@"index : %ld",(long)_imageIndex);
        photoo = [UIAppDelegate.photoArray objectAtIndex:_imageIndex];
        [_prevView setImage:[UIImage imageNamed:nil]];
        //[_prevView setImageWithURL:[NSURL URLWithString:photoo.photoURL] placeholderImage:[UIImage imageNamed:photoo.photoURL]];
        
        [_prevView sd_setImageWithURL:[NSURL URLWithString:photoo.photoURL] placeholderImage:[UIImage imageNamed:photoo.photoURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            _prevView.image = image;
            if (_prevView.image.size.width < self.imageHostScrollView.bounds.size.width)
                _prevView.contentMode = UIViewContentModeCenter;
            else
                _prevView.contentMode = UIViewContentModeScaleAspectFit;
        }];
        
        
        
        
        [dbhelper updateMemeView:@"1" withMemeID:photoo.photoID];
        //[self getUpdatedLikeWithMemeId:photoo.photoID];
        
    }
}

-(void)performRight
{
    if (_imageIndex != 0)
    {
        _imageIndex--;
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.prevView.layer addAnimation:transition forKey:nil];
        
        NSLog(@"index : %ld",(long)_imageIndex);
        photoo = [UIAppDelegate.photoArray objectAtIndex:_imageIndex];
        [_prevView setImage:[UIImage imageNamed:nil]];
        //[_prevView setImageWithURL:[NSURL URLWithString:photoo.photoURL] placeholderImage:[UIImage imageNamed:photoo.photoURL]];
        
        [_prevView sd_setImageWithURL:[NSURL URLWithString:photoo.photoURL] placeholderImage:[UIImage imageNamed:photoo.photoURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            _prevView.image = image;
            if (_prevView.image.size.width < self.imageHostScrollView.bounds.size.width)
                _prevView.contentMode = UIViewContentModeCenter;
            else
                _prevView.contentMode = UIViewContentModeScaleAspectFit;
        }];
        
        
        [dbhelper updateMemeView:@"1" withMemeID:photoo.photoID];
        //[self getUpdatedLikeWithMemeId:photoo.photoID];
        
    }
}


-(void) setupSwipeView
{
    //self.imageHostScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.imageHostScrollView.frame)*[UIAppDelegate.photoArray count], CGRectGetHeight(self.imageHostScrollView.frame));
    
    self.imageHostScrollView.delegate = self;
    self.imageHostScrollView.pagingEnabled = YES;
    
    self.imageHostScrollView.minimumZoomScale = 1;
    self.imageHostScrollView.maximumZoomScale = 5.5;
    
    CGRect rect = CGRectZero;
    CGFloat imageHost_W = self.imageHostScrollView.frame.size.width;
    CGFloat imageHost_H = self.imageHostScrollView.frame.size.height;
    rect = CGRectMake(0, 0, imageHost_W, imageHost_H);
    
    //    CGRect rect = CGRectZero;
    //    if (IS_IPHONE){
    //        if (IS_IPHONE_4INCHES){
    //            rect = CGRectMake(0, 0, 320, 407);
    //        }
    //        else{
    //            rect = CGRectMake(0, 0, 320, 325);
    //        }
    //    }
    //    else{
    //        rect = CGRectMake(0, 0, 768, 750);
    //    }
    //int padding = 10;
    
    for (int i = 0; i < [UIAppDelegate.photoArray count]; i++)
    {
        rect.origin.x = CGRectGetWidth(self.imageHostScrollView.frame)*i;
        UIScrollView *scrView = [[UIScrollView alloc] initWithFrame:rect];
        [self.imageHostScrollView addSubview:scrView];
        photoo = [UIAppDelegate.photoArray objectAtIndex:i];
        
        UIImageView *prevView = [[UIImageView alloc] init];
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
        
        [prevView sd_setImageWithURL:[NSURL URLWithString:photoo.photoURL]];
        
        if (prevView.image.size.width > scrView.bounds.size.width || prevView.image.size.height > scrView.bounds.size.height)
            prevView.contentMode = UIViewContentModeScaleAspectFit;
        else
            prevView.contentMode = UIViewContentModeCenter;
        
        prevView.frame = imageViewRect;
        scrView.tag = i;
        scrView.delegate = self;
        scrView.pagingEnabled = YES;
        [scrView addSubview:prevView];
        
        scrView.minimumZoomScale = 1.0;
        scrView.maximumZoomScale = 5.5;
        //prevView.frame = scrView.bounds;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [scrView addGestureRecognizer:doubleTap];
        
        _totalLikesLabel.text = [NSString stringWithFormat:@"Total Likes (%@)",photoo.photoLike];
        
        //Check if Favorite
        if ([photoo.photoMyFavorite isEqualToString:@"1"]) {
            _favoriteButton.tag = 100;
            switch (_controllerIdentifier)
            {
                case 1:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_blue3.png"] forState:UIControlStateNormal];
                    break;
                case 2:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow3.png"] forState:UIControlStateNormal];
                    break;
                case 3:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_red3.png"] forState:UIControlStateNormal];
                    break;
                case 4:
                    [_favoriteButton setImage:[UIImage imageNamed:@"star_green3.png"] forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            _favoriteButton.tag = 101;
            [_favoriteButton setImage:[UIImage imageNamed:@"star_grey.png"] forState:UIControlStateNormal];
        } 
        
        [_favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //Check if Liked
        if ([photoo.photoMyLike isEqualToString:@"1"]) {
            _thumbButton.tag = 100;
            switch (_controllerIdentifier)
            {
                case 1:
                    [_thumbButton setImage:[UIImage imageNamed:@"like_blue.png"] forState:UIControlStateNormal];
                    break;
                case 2:
                    [_thumbButton setImage:[UIImage imageNamed:@"like_yellow.png"] forState:UIControlStateNormal];
                    break;
                case 3:
                    [_thumbButton setImage:[UIImage imageNamed:@"like_red.png"] forState:UIControlStateNormal];
                    break;
                case 4:
                    [_thumbButton setImage:[UIImage imageNamed:@"like_green.png"] forState:UIControlStateNormal];
                    break;
                case 5:
                    [_thumbButton setImage:[UIImage imageNamed:@"like_purple.png"] forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            _thumbButton.tag = 101;
            [_thumbButton setImage:[UIImage imageNamed:@"like_grey.png"] forState:UIControlStateNormal];
        }
        
        [_thumbButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _likeRoundView.layer.cornerRadius = 10;
        [scrView addSubview:_likeRoundView];
        
        //        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        //        [singleTap setNumberOfTapsRequired:1];
        //        [singleTap requireGestureRecognizerToFail:doubleTap];
        //        [scrView addGestureRecognizer:singleTap];
    }
    
    [self.imageHostScrollView scrollRectToVisible:CGRectMake(self.imageHostScrollView.frame.size.width*_imageIndex+20,
                                                             CGRectGetHeight(self.imageHostScrollView.frame)/2,
                                                             CGRectGetWidth(self.imageHostScrollView.frame)-20,
                                                             CGRectGetHeight(self.imageHostScrollView.frame))
                                         animated:NO];
    
    NSLog(@"UIAppDelegate.photoArray count=%ld",(unsigned long)[UIAppDelegate.photoArray count]);
    
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
    
    
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if(scrollView.tag==1000)
    {
        
    }
    else
    {
        if(scale == 1)
        {
            scrollView.hidden = YES;
            self.swipeView.hidden = NO;
            
            if (pageOffsetForDrag != 0) {
                [self.swipeView scrollByNumberOfItems:pageOffsetForDrag duration:0.5];
                pageOffsetForDrag = 0;
            }
        }
    }
    
}

//return  nil;//_prevView;
//}

//- (void)scrollViewDidZoom:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewDidZoom");
//
//
//    if (scrollView.zoomScale != 1) {
//        scrollView.scrollEnabled = YES;
//    } else {
//        scrollView.scrollEnabled = NO;
//    }
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
//
//
//
//
//}

//  3/12/2014 -----START-------
/*
 - (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
 {
 //NSLog(@"scrollViewDidEndDecelerating");
 
 if (!(sender.zoomScale > 1))
 {
 CGFloat pageWidth = sender.frame.size.width;
 page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
 
 if (page != [[NSUserDefaults standardUserDefaults] integerForKey:@"previousPageNumber"])
 {
 swipeCount++;
 NSLog(@"swipeCount==%d",swipeCount);
 }
 NSLog(@"page Count==%ld",page);
 
 if(swipeCount%7==0)
 {
 [self callFullScreenAd];
 }
 
 
 photoo = [UIAppDelegate.photoArray objectAtIndex:page];
 [dbhelper updateMemeView:@"1" withMemeID:photoo.photoID];
 [self getUpdatedLikeWithMemeId:photoo.photoID];
 
 for (UIView *subView in self.imageHostScrollView.subviews)
 {
 for (UIImageView *imgView in subView.subviews)
 {
 UIScrollView *scrollView = (UIScrollView *)imgView.superview;
 scrollView.zoomScale = 1.0;
 }
 }
 }
 
 
 
 //_totalLikesLabel.text = [NSString stringWithFormat:@"Total Likes (%@)",photoo.photoLike];
 
 for (UIScrollView *scrollView in self.imageHostScrollView.subviews)
 {
 UIScrollView *subScrollView = (UIScrollView *)[scrollView viewWithTag:page];
 if ([[scrollView viewWithTag:page] isKindOfClass:[UIScrollView class]])
 {
 NSArray *imaViewArr = [subScrollView subviews];
 UIImageView *appImageView = [imaViewArr objectAtIndex:0];
 //NSLog(@"imgW=%f,imgH=%f",appImageView.image.size.width,appImageView.image.size.width);
 }
 }*/

//NSLog(@"MemeID = %@",photoo.photoID);


/*
 NSInteger numberOfBadges;
 switch (_controllerIdentifier) {
 case 1:
 appDelegate.badgeEveryoneMeme = appDelegate.badgeEveryoneMeme - 1;
 numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
 numberOfBadges -=1;
 [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
 break;
 case 2:
 appDelegate.badgeMotivationalMeme = appDelegate.badgeMotivationalMeme - 1;
 numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
 numberOfBadges -=1;
 [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
 break;
 case 3:
 appDelegate.badgeRacyMeme = appDelegate.badgeRacyMeme - 1;
 numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
 numberOfBadges -=1;
 [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
 break;
 
 default:
 break;
 }
 
 if ((appDelegate.badgeEveryoneMeme+appDelegate.badgeMotivationalMeme+appDelegate.badgeRacyMeme) < 1) {
 [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
 }
 
 //    //Check if Favourite
 //    if ([photoo.photoMyFavorite isEqualToString:@"1"]) {
 //        //NSLog(@"aaaaaaaaa");
 //        _favoriteButton.tag = 100;
 //        switch (_controllerIdentifier)
 //        {
 //            case 1:
 //                [_favoriteButton setImage:[UIImage imageNamed:@"star_blue3.png"] forState:UIControlStateNormal];
 //                break;
 //            case 2:
 //                [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow3.png"] forState:UIControlStateNormal];
 //                break;
 //            case 3:
 //                [_favoriteButton setImage:[UIImage imageNamed:@"star_red3.png"] forState:UIControlStateNormal];
 //                break;
 //            case 4:
 //                [_favoriteButton setImage:[UIImage imageNamed:@"star_green3.png"] forState:UIControlStateNormal];
 //                break;
 //
 //            default:
 //                break;
 //        }
 //    } else {
 //        //NSLog(@"bbbbbbbb");
 //        _favoriteButton.tag = 101;
 //
 //        switch (_controllerIdentifier)
 //        {
 //            case 1:
 //                [_favoriteButton setImage:[UIImage imageNamed:@"star_blue2.png"] forState:UIControlStateNormal];
 //                break;
 //            case 2:
 //                [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow2.png"] forState:UIControlStateNormal];
 //                break;
 //            case 3:
 //                [_favoriteButton setImage:[UIImage imageNamed:@"star_red2.png"] forState:UIControlStateNormal];
 //                break;
 //            case 4:
 //                [_favoriteButton setImage:[UIImage imageNamed:@"star_green2.png"] forState:UIControlStateNormal];
 //                break;
 //
 //            default:
 //                break;
 //        }
 //    }
 //
 //    //Check if Liked
 //    if ([photoo.photoMyLike isEqualToString:@"1"])
 //    {
 //        //NSLog(@"ccccccc");
 //        _thumbButton.tag = 100;
 //        switch (_controllerIdentifier)
 //        {
 //            case 1:
 //                [_thumbButton setImage:[UIImage imageNamed:@"like_blue.png"] forState:UIControlStateNormal];
 //                break;
 //            case 2:
 //                [_thumbButton setImage:[UIImage imageNamed:@"like_yellow.png"] forState:UIControlStateNormal];
 //                break;
 //            case 3:
 //                [_thumbButton setImage:[UIImage imageNamed:@"like_red.png"] forState:UIControlStateNormal];
 //                break;
 //            case 4:
 //                [_thumbButton setImage:[UIImage imageNamed:@"like_green.png"] forState:UIControlStateNormal];
 //                break;
 //
 //            default:
 //                break;
 //        }
 //    }else
 //    {
 //        //NSLog(@"dddddddd");
 //        _thumbButton.tag = 101;
 //        [_thumbButton setImage:[UIImage imageNamed:@"like_grey.png"] forState:UIControlStateNormal];
 //    }
 
 
 //NSLog(@"PAGE_NO==%d, _imageArray.count==%d",page,_imageArray.count);
 
 
 
 }
 */
//  3/12/2014 -----START-------

#pragma mark - GestureRecognizer methods

- (void)handlesingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"handlesingleTap");
    
    isSingleTab = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(hideLikeBg) userInfo:nil repeats:NO];
    /*
    if (!likeViewHidden)
    {
        viewItem.likeBG.hidden = YES;
        viewItem.titleBG.hidden = YES;
        likeViewHidden = NO;
    }
    else
    {
        viewItem.likeBG.hidden = NO;
        viewItem.titleBG.hidden = NO;
        likeViewHidden = YES;
    }
     */
    
}

- (void)hideLikeBg {
    if(isSingleTab) {
        SwipeViewItem *viewItem = (SwipeViewItem *)[_swipeView itemViewAtIndex:_swipeView.currentItemIndex];
        
        if(viewItem.likeBG.alpha == 0) {
            [viewItem.likeBG setAlpha:1];
        } else {
            [viewItem.likeBG setAlpha:0];
        }
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"handleDoubleTap:(%@)", [gestureRecognizer.view class]);
    
    if(gestureRecognizer.view == self.zoomScrollView)
    {
        [self.zoomScrollView setZoomScale:1 animated:YES];
    }
    else
    {
        isSingleTab = NO;
        SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
        
        if([view.scrollViewSwipeItem zoomScale]==1)
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
            [view.scrollViewSwipeItem setZoomScale:1 animated:YES];
        }
        
        
    }
    
}

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



#pragma mark - Button Actions
- (IBAction)favoriteButtonAction:(UIButton *)sender
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED])
    {
        DanMessagePopup *alert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self label1:@"Oops!" label2:@"You need to be logged-in to like or favorite memes on MemeCabin." button1stTitle:@"Got it, take me to login." button2ndTitle:@"Eek. No thanks." button3rdTitle:nil button4thTitle:nil showTopBlackBar:NO];
        alert.tag = 4;
        [alert show];
        return;
    }
    
    photoo = [UIAppDelegate.photoArray objectAtIndex:page];
    
    
    if (sender.tag == 100)
    {
        [self updateMemeFavourite:2 buttonTag:100];
    }
    else
    {
        [self updateMemeFavourite:1 buttonTag:101];
    }
}

- (IBAction)shareButtonAction:(UIButton *)sender
{
    
    if (_controllerIdentifier ==5)
    {
        [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Share Button Clicked"];
        
        _popupView.hidden = NO;
        _popupShareView.hidden = NO;
        
        [_popupShareView setFrame:CGRectMake(_popupView.frame.size.width/2-_popupShareView.frame.size.width/2,
                                             _popupView.frame.size.height/2-_popupShareView.frame.size.height/2,
                                             _popupShareView.frame.size.width,
                                             _popupShareView.frame.size.height)];
        
        [_popupView addSubview:_popupShareView];
        return;
    }
    
    NSString *filePath = [self documentsPathForFileName:@"sharedImage.png"];
    
    
    SwipeViewItem *item = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
    
    //UIImage *pngImage = [self getCapturedImage];
    photoo = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
    [self downloadImageWithURL:[NSURL URLWithString:photoo.photoURL] completionBlock:^(BOOL succeeded, UIImage *image) {
        
        if(image)
        {
            reportedImage = image;
            
            //////
            [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Share Button Clicked"];
            
            _popupView.hidden = NO;
            _popupShareView.hidden = NO;
            
            [_popupShareView setFrame:CGRectMake(_popupView.frame.size.width/2-_popupShareView.frame.size.width/2,
                                                 _popupView.frame.size.height/2-_popupShareView.frame.size.height/2,
                                                 _popupShareView.frame.size.width,
                                                 _popupShareView.frame.size.height)];
            
            [_popupView addSubview:_popupShareView];
            ///////
            
            float bottomImgW;
            float bottomImgH;
            if (image.size.width < 150)
            {
                bottomImgW = 26;
                bottomImgH = 7;
            }
            else if (image.size.width < 200 && image.size.width >= 150)
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
            
            if (_controllerIdentifier == 5) {
                mainImageView.image = item.imageView.image;
            }
            else {
                mainImageView.image = image;
            }
            
            
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
        else
        {
            NSLog(@"ERROR");
        }
        
    }];
                         
//    NSData *pngData = UIImageJPEGRepresentation(pngImage, 1.0);
//    [pngData writeToFile:filePath atomically:NO];
}

- (IBAction)reloadButtonAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Reload Button Clicked"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:WILL_SHOW_SWIPE_SCREEN_LAST_INDEX_POPUP]) {
        
        [self.swipeView scrollToItemAtIndex:0 duration:0.5];
        //        [self.imageHostScrollView scrollRectToVisible:CGRectMake(self.imageHostScrollView.frame.size.width*0+0,
        //                                                                 CGRectGetHeight(self.imageHostScrollView.frame)/2,
        //                                                                 CGRectGetWidth(self.imageHostScrollView.frame)-20,
        //                                                                 CGRectGetHeight(self.imageHostScrollView.frame))
        //                                             animated:YES];
    } else {
        [self showReloadPopUp];
    }
    
}

- (IBAction)bookMarkButtonAction:(UIButton *)sender
{
    DanMessagePopup *alert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self
                                                                label1:@"Spiffy Gifs"
                                                                label2:nil
                                                        button1stTitle:@"Move Bookmark Here"
                                                        button2ndTitle:@"Go to Bookmark"
                                                        button3rdTitle:@"Cancel"
                                                        button4thTitle:nil
                                                       showTopBlackBar:NO];
    alert.tag = 5;
    [alert show];
}

- (IBAction)likeButtonAction:(UIButton *)sender
{
    NSLog(@"likeButton Tag = %ld",self.swipeView.currentItemIndex);
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED])
    {
        DanMessagePopup *alert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self label1:@"Oops!" label2:@"You need to be logged-in to like or favorite memes on MemeCabin." button1stTitle:@"Got it, take me to login." button2ndTitle:@"Eek. No thanks." button3rdTitle:nil button4thTitle:nil showTopBlackBar:NO];
        alert.tag = 3;
        [alert show];
        return;
    }
    
    photoo = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
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
    
    NSLog(@"Button Tag:%ld",(long)self.swipeView.currentItemIndex);
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
- (IBAction)backButtonAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Get Image From Document Path
-(UIImage *)getCapturedImage
{
    photoo = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
    
    
    
    
    UIImageView *appImageView;
    
    
    SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
    appImageView = view.imageView;
    
    /*
     for (UIScrollView *scrollView in self.imageHostScrollView.subviews)
     {
     UIScrollView *subScrollView = (UIScrollView *)[scrollView viewWithTag:page];
     if ([[scrollView viewWithTag:page] isKindOfClass:[UIScrollView class]])
     {
     NSArray *imaViewArr = [subScrollView subviews];
     appImageView = [imaViewArr objectAtIndex:0];
     }
     }*/
    
    
    //NSLog(@"appImageView Frame = %@",NSStringFromCGRect(appImageView.frame));
    NSLog(@"appImageView-Image Frame = %lf ,%lf",appImageView.image.size.width,appImageView.image.size.height);
    
    float bottomImgW;
    float bottomImgH;
    if (appImageView.image.size.width < 150)
    {
        bottomImgW = 26;
        bottomImgH = 7;
    }
    else if (appImageView.image.size.width < 200 && appImageView.image.size.width >= 150)
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

#pragma mark - Start&End pop
-(void)showReloadPopUp
{
    DanMessagePopup *alert = [[DanMessagePopup alloc] initWithDelegate:(id<DanMessagePopupDelegate>)self
                                                                label1:@"You sure you want to go back to very first meme?"
                                                                label2:@"We just want to make sure."
                                                        button1stTitle:@"Yep, take me."
                                                        button2ndTitle:@"Yep, don't show this again."
                                                        button3rdTitle:@"Um. Cancel that." button4thTitle:nil
                                                       showTopBlackBar:NO];
    alert.tag = 1;
    [alert show];
}

-(void)showEndMemePopUp
{
    DanMessagePopup *alert;
    if (_controllerIdentifier == 5) {
        alert = [[DanMessagePopup alloc] initWithDelegate:self
                                           label1:@"Wow, you've reached  the end of the memes!"
                                           label2:@"What do you want to do next?"
                                   button1stTitle:@"Keep me here"
                                   button2ndTitle:@"Back to First Meme"
                                   button3rdTitle:nil
                                   button4thTitle:nil
                                  showTopBlackBar:NO];
    }
    else {
        alert = [[DanMessagePopup alloc] initWithDelegate:self
                                           label1:@"Wow, you've reached  the end of the memes!"
                                           label2:@"What do you want to do next?"
                                   button1stTitle:@"Keep me here"
                                   button2ndTitle:@"Back to First Meme"
                                   button3rdTitle:@"View My Favorites"
                                   button4thTitle:nil
                                  showTopBlackBar:NO];
    }
    
    
    alert.tag = 2;
    [alert show];
}

#pragma mark - ShareButton Actions
- (IBAction)saveButtonAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Save Button Clicked"];
    
    NSData *pngData =[NSData dataWithContentsOfFile:[self documentsPathForFileName:@"sharedImage.png"]];
    
    
    UIImage *image;// = [UIImage imageWithData:pngData];
    NSData *flImageData;
    if (_controllerIdentifier != 5) {
        image = [UIImage imageWithData:pngData];
    }
    else
    {
        [UIAppDelegate activityShow];
        SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
        flImageData = [AnimatedGIFImageSerialization animatedGIFDataWithImage:view.imageView.image error:nil];
         //flImage = item.imageView.animatedImage;
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:flImageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            [self performSelector:@selector(image:didFinishSavingWithError:contextInfo:) withObject:nil];
        }];
    }
    
    
    if(image)
    {
        
        [UIAppDelegate activityShow];
        
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
}

- (void)               image: (UIImage *) image
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo
{
    NSLog(@"didFinishSavingWithError");
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
    
    if (_controllerIdentifier != 5)
    {
        [controller addImage:image];
    } else {
        SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
        [controller addImage:view.imageView.image];
    }
    
    
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (IBAction)twitterShareAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Twitter Share Button Clicked"];
    
    if(_controllerIdentifier == 5)
    {
        if(FHSTwitterEngine.sharedEngine.isAuthorized)
        {
            SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
            NSData *imageData = [AnimatedGIFImageSerialization animatedGIFDataWithImage:view.imageView.image error:nil];
            //NSData *imageData = UIImageJPEGRepresentation(view.imageView.image, 1.0);;
            //id returnData = [[FHSTwitterEngine sharedEngine] uploadImageToTwitPic:imageData withMessage:@"message" twitPicAPIKey:@"key"];
            [UIAppDelegate activityShow];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    
                    [[FHSTwitterEngine sharedEngine] postTweet:@"Sharing this from the MemeCabin app! (Get it on Android and iOS!)" withImageData:imageData];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        @autoreleasepool {
                            // Update UI
                            [UIAppDelegate activityHide];
                        }
                    });
                }
            });
            
        }
        else
        {
            UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
                NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
                if(success)
                {
                    SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
                    NSData *imageData = [AnimatedGIFImageSerialization animatedGIFDataWithImage:view.imageView.image error:nil];
                    [UIAppDelegate activityShow];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        @autoreleasepool {
                            
                            [[FHSTwitterEngine sharedEngine] postTweet:@"Sharing this from the MemeCabin app! (Get it on Android and iOS!)" withImageData:imageData];
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                @autoreleasepool {
                                    // Update UI
                                    [UIAppDelegate activityHide];
                                }
                            });
                        }
                    });
                }
            }];
            [self presentViewController:loginController animated:YES completion:nil];
        }
        
    }
    else
    {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        NSData *pngData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:@"sharedImage.png"]];
        UIImage *image = [UIImage imageWithData:pngData];
        
        [controller setInitialText:@"Sharing this from the MemeCabin app! (Get it on Android and iOS!)"];
        if (_controllerIdentifier != 5) {
            [controller addImage:image];
        } else {
            SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
            [controller addImage:view.imageView.image];
        }
        
        
        
        [self presentViewController:controller animated:YES completion:Nil];
    }
    
    
    
}

- (IBAction)emailShareAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Email Share Button Clicked"];
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"An amazing meme from the MemeCabin app!"];
        //NSArray *toRecipients = [NSArray arrayWithObject:@"mail@example.com"];
        //[mailer setToRecipients:toRecipients];
        
        //photoo = [UIAppDelegate.photoArray objectAtIndex:page];
        
        NSData *pngData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:@"sharedImage.png"]];
        //UIImage *image = [UIImage imageWithData:pngData];
        if (_controllerIdentifier == 5)
        {
            SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
            NSData *imageData = [AnimatedGIFImageSerialization animatedGIFDataWithImage:view.imageView.image error:nil];
            [mailer addAttachmentData:imageData mimeType:@"image/gif" fileName:@"userfile"];
        }
        else {
            [mailer addAttachmentData:pngData mimeType:@"image/png" fileName:@"userfile"];
        }
        
        
        NSString *emailBody = @"I sent you this from the MemeCabin app! Download it today for Apple and Android phones and tablets at www.memecabin.com!";
        [mailer setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:mailer animated:YES completion:NULL];
        
    }
    else
        [UIAppDelegate showAlertWithTitle:@"Failure" message:@"Your device doesn't support the composer sheet"];
}

- (IBAction)smsShareAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"MMS Share Button Clicked"];
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        //photoo = [UIAppDelegate.photoArray objectAtIndex:page];
        
        controller.body = @"Just wanted to share this meme from the MemeCabin app!";
        //controller.recipients = [NSArray arrayWithObjects:@"", nil];
        controller.messageComposeDelegate = self;
        
        
        //UIImage *image = [UIImage imageWithData:pngData];
        
        if (_controllerIdentifier == 5)
        {
            SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
            NSData *imageData = [AnimatedGIFImageSerialization animatedGIFDataWithImage:view.imageView.image error:nil];
            [controller addAttachmentData:imageData typeIdentifier:(NSString *)kUTTypeGIF filename:@"sharedImage.gif"];
        }
        else {
            NSData *pngData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:@"sharedImage.png"]];
            [controller addAttachmentData:pngData typeIdentifier:(NSString *)kUTTypeMessage filename:@"sharedImage.png"];
        }
        
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (IBAction)reportButtonAction:(UIButton *)sender
{
    ReportMemeVC *reportVC = [[ReportMemeVC alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"ReportMemeVC"] bundle:nil];
    
    
    
    photoo = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
    
    if (_controllerIdentifier != 5) {
        reportVC.reportedImage = reportedImage;
    } else {
        SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
        reportVC.reportedImage = view.imageView.image;
    }
    
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
    SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
    MemePhoto *pho = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
    
    if (tag == 100)
    {
        [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Dislike Button Clicked"];
        
        
        //view.likeButton.tag = 101;
        [view.likeButton setImage:[UIImage imageNamed:@"like_grey.png"] forState:UIControlStateNormal];
        
        int count1 = [pho.photoLike intValue];
        if (count1 > 0) {
            count1 = count1 - 1;
        }
        view.likesLabel.text = [NSString stringWithFormat:@"Total Likes (%d)",count1];
        //
        //        MemePhoto *pho = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
        //        //NSLog(@"BEfore Update pho=%@",pho.photoMyLike);
        //        pho.photoMyLike = @"0";
        //        pho.photoLike = like;
        //        //NSLog(@"After Update pho=%@",pho.photoMyLike);
        //        //[UIAppDelegate.photoArray replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
    }
    else
    {
        [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Like Button Clicked"];
        //view.likeButton.tag = 100;
        switch (_controllerIdentifier) {
            case 1:
                [view.likeButton setImage:[UIImage imageNamed:@"like_blue.png"] forState:UIControlStateNormal];
                break;
            case 2:
                [view.likeButton setImage:[UIImage imageNamed:@"like_yellow.png"] forState:UIControlStateNormal];
                break;
            case 3:
                [view.likeButton setImage:[UIImage imageNamed:@"like_red.png"] forState:UIControlStateNormal];
                break;
            case 4:
                [view.likeButton setImage:[UIImage imageNamed:@"like_green.png"] forState:UIControlStateNormal];
                break;
            case 5:
                [view.likeButton setImage:[UIImage imageNamed:@"like_purple.png"] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        
        int count1 = [pho.photoLike intValue];
        count1 = count1 + 1;
        
        view.likesLabel.text = [NSString stringWithFormat:@"Total Likes (%d)",count1];
        
        //        MemePhoto *pho = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
        //        //NSLog(@"BEfore Update pho=%@",pho.photoMyLike);
        //        pho.photoMyLike = @"1";
        //        pho.photoLike = like;
        //        //NSLog(@"After Update pho=%@",pho.photoMyLike);
        //        [UIAppDelegate.photoArray replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
    }
    
    
    NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
    photoo = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
    NSString *memeid = photoo.photoID;
    NSString *userId = [userInfoDisct objectForKey:@"userId"];
    
    
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
                //NSLog(@"SUCCESS");
                
                NSString *like = [JSON objectForKey:@"totalLike"];
                
                SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:self.swipeView.currentItemIndex];
                
                if (tag == 100)
                {
                    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Dislike Button Clicked"];
                    view.likeButton.tag = 101;
                    [view.likeButton setImage:[UIImage imageNamed:@"like_grey.png"] forState:UIControlStateNormal];
                    
                    MemePhoto *pho = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
                    //NSLog(@"BEfore Update pho=%@",pho.photoMyLike);
                    pho.photoMyLike = @"0";
                    pho.photoLike = like;
                    //NSLog(@"After Update pho=%@",pho.photoMyLike);
                    [UIAppDelegate.photoArray replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
                }
                else
                {
                    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Like Button Clicked"];
                    view.likeButton.tag = 100;
                    switch (_controllerIdentifier) {
                        case 1:
                            [view.likeButton setImage:[UIImage imageNamed:@"like_blue.png"] forState:UIControlStateNormal];
                            break;
                        case 2:
                            [view.likeButton setImage:[UIImage imageNamed:@"like_yellow.png"] forState:UIControlStateNormal];
                            break;
                        case 3:
                            [view.likeButton setImage:[UIImage imageNamed:@"like_red.png"] forState:UIControlStateNormal];
                            break;
                        case 4:
                            [view.likeButton setImage:[UIImage imageNamed:@"like_green.png"] forState:UIControlStateNormal];
                            break;
                        case 5:
                            [view.likeButton setImage:[UIImage imageNamed:@"like_purple.png"] forState:UIControlStateNormal];
                            break;
                            
                            
                        default:
                            break;
                    }
                    
                    MemePhoto *pho = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
                    //NSLog(@"BEfore Update pho=%@",pho.photoMyLike);
                    pho.photoMyLike = @"1";
                    pho.photoLike = like;
                    //NSLog(@"After Update pho=%@",pho.photoMyLike);
                    [UIAppDelegate.photoArray replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
                }
                
                
                view.likesLabel.text = [NSString stringWithFormat:@"Total Likes (%@)",like];
                //likeCount = [[NSString stringWithFormat:@"%@",like] integerValue];
                
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
    /// Favorite Image change ////
    
    if (tag == 101)
    {
        //Favorite count
        UIAppDelegate.userFavouriteNumber = ((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? ([[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT] + 1) : 0;
        [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.userFavouriteNumber forKey:MEME_FAVORITE_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Favourite Button Clicked"];
        _favoriteButton.userInteractionEnabled = NO;
        
        [_addedToFavouriteView.layer removeAllAnimations];
        _addedToFavouriteView.hidden = NO;
        [_myView bringSubviewToFront:_addedToFavouriteView];
        _addOrRemoveText.text = @"Added to Favorites";
        [UIView animateWithDuration:1.2
                              delay:0.1
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^ {
                             _addedToFavouriteView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             _addedToFavouriteView.alpha = 1.0;
                             _addedToFavouriteView.hidden = YES;
                             //_favoriteButton.tag = 100;
                             _favoriteButton.userInteractionEnabled = YES;
                         }];
        
        switch (_controllerIdentifier)
        {
            case 1:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_blue3.png"] forState:UIControlStateNormal];
                break;
            case 2:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow3.png"] forState:UIControlStateNormal];
                break;
            case 3:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_red3.png"] forState:UIControlStateNormal];
                break;
            case 4:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_green3.png"] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        
        //        MemePhoto *pho = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
        //        //NSLog(@"BEfore Update pho=%@",pho.photoMyLike);
        //        pho.photoMyFavorite = @"1";
        //        //NSLog(@"After Update pho=%@",pho.photoMyLike);
        //        [UIAppDelegate.photoArray replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
        
    }
    else
    {
         UIAppDelegate.userFavouriteNumber = ((NSNull*)[[NSUserDefaults standardUserDefaults] objectForKey:MEME_FAVORITE_CURRENT_COUNT] != [NSNull null]) ? ([[NSUserDefaults standardUserDefaults] integerForKey:MEME_FAVORITE_CURRENT_COUNT] - 1) : 0;
        [[NSUserDefaults standardUserDefaults] setInteger:UIAppDelegate.userFavouriteNumber forKey:MEME_FAVORITE_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"UnFavourite Button Clicked"];
        _favoriteButton.userInteractionEnabled = NO;
        
        [_addedToFavouriteView.layer removeAllAnimations];
        _addedToFavouriteView.hidden = NO;
        [_myView bringSubviewToFront:_addedToFavouriteView];
        _addOrRemoveText.text = @"Removed from Favorites";
        [UIView animateWithDuration:1.2
                              delay:0.1
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^ {
                             _addedToFavouriteView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             _addedToFavouriteView.alpha = 1.0;
                             _addedToFavouriteView.hidden = YES;
                             //_favoriteButton.tag = 101;
                             _favoriteButton.userInteractionEnabled = YES;
                         }];
        
        switch (_controllerIdentifier)
        {
            case 1:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_blue2.png"] forState:UIControlStateNormal];
                break;
            case 2:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow2.png"] forState:UIControlStateNormal];
                break;
            case 3:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_red2.png"] forState:UIControlStateNormal];
                break;
            case 4:
                [_favoriteButton setImage:[UIImage imageNamed:@"star_green2.png"] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        
        //        MemePhoto *pho = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
        //        //NSLog(@"BEfore Update pho=%@",pho.photoMyLike);
        //        pho.photoMyFavorite = @"0";
        //        //NSLog(@"After Update pho=%@",pho.photoMyLike);
        //        [UIAppDelegate.photoArray replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
    }
    
    ///
    
    
    NSDictionary *userInfoDisct = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
    photoo = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
    NSString *memeid = photoo.photoID;
    NSString *userId = [userInfoDisct objectForKey:@"userId"];
    
    
    NSString *urlString;
    if (param == 1) {
        urlString =  @"makeFavourite"; //MEME_MAKE_FAVOURITE;
    }else{
        urlString = @"makeUnFavourite"; //MEME_MAKE_UNFAVOURITE;
    }
    
    //[UIAppDelegate activityShow];
    
    _manager = [MCHTTPManager manager];
    //_manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //\\NSDictionary *parameters = @{@"userid":userId, @"memeid":memeid};
    NSDictionary *parameters = @{@"userID":userId, @"memeid":memeid};
    
    [_manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response: %@", responseObject);//[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        //[UIAppDelegate activityHide];
        
        NSError *error = nil;
        NSDictionary *JSON = responseObject;//[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"Error serializing %@", error);
        }
        else
        {
            if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
            {
                NSLog(@"Status : 1");
                if (tag == 101)
                {
                    //                    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Favourite Button Clicked"];
                    //                    _favoriteButton.userInteractionEnabled = NO;
                    //
                    //                    [_addedToFavouriteView.layer removeAllAnimations];
                    //                    _addedToFavouriteView.hidden = NO;
                    //                    [_myView bringSubviewToFront:_addedToFavouriteView];
                    //                    _addOrRemoveText.text = @"Added to Favorites";
                    //                    [UIView animateWithDuration:1.2
                    //                                          delay:0.1
                    //                                        options:UIViewAnimationOptionBeginFromCurrentState
                    //                                     animations:^ {
                    //                                         _addedToFavouriteView.alpha = 0.0;
                    //                                     }
                    //                                     completion:^(BOOL finished) {
                    //                                         _addedToFavouriteView.alpha = 1.0;
                    //                                         _addedToFavouriteView.hidden = YES;
                    //                                         _favoriteButton.tag = 100;
                    //                                         _favoriteButton.userInteractionEnabled = YES;
                    //                                     }];
                    
                    _favoriteButton.tag = 100;
                    
                    
                    
                    switch (_controllerIdentifier)
                    {
                        case 1:
                            [_favoriteButton setImage:[UIImage imageNamed:@"star_blue3.png"] forState:UIControlStateNormal];
                            break;
                        case 2:
                            [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow3.png"] forState:UIControlStateNormal];
                            break;
                        case 3:
                            [_favoriteButton setImage:[UIImage imageNamed:@"star_red3.png"] forState:UIControlStateNormal];
                            break;
                        case 4:
                            [_favoriteButton setImage:[UIImage imageNamed:@"star_green3.png"] forState:UIControlStateNormal];
                            break;
                            
                        default:
                            break;
                    }
                    
                    MemePhoto *pho = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
                    //NSLog(@"BEfore Update pho=%@",pho.photoMyLike);
                    pho.photoMyFavorite = @"1";
                    //NSLog(@"After Update pho=%@",pho.photoMyLike);
                    [UIAppDelegate.photoArray replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
                    
                }
                else
                {
                    //                    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"UnFavourite Button Clicked"];
                    //                    _favoriteButton.userInteractionEnabled = NO;
                    //
                    //                    [_addedToFavouriteView.layer removeAllAnimations];
                    //                    _addedToFavouriteView.hidden = NO;
                    //                    [_myView bringSubviewToFront:_addedToFavouriteView];
                    //                    _addOrRemoveText.text = @"Removed from Favorites";
                    //                    [UIView animateWithDuration:1.2
                    //                                          delay:0.1
                    //                                        options:UIViewAnimationOptionBeginFromCurrentState
                    //                                     animations:^ {
                    //                                         _addedToFavouriteView.alpha = 0.0;
                    //                                     }
                    //                                     completion:^(BOOL finished) {
                    //                                         _addedToFavouriteView.alpha = 1.0;
                    //                                         _addedToFavouriteView.hidden = YES;
                    //                                         _favoriteButton.tag = 101;
                    //                                         _favoriteButton.userInteractionEnabled = YES;
                    //                                     }];
                    _favoriteButton.tag = 101;
                    
                    switch (_controllerIdentifier)
                    {
                        case 1:
                            [_favoriteButton setImage:[UIImage imageNamed:@"star_blue2.png"] forState:UIControlStateNormal];
                            break;
                        case 2:
                            [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow2.png"] forState:UIControlStateNormal];
                            break;
                        case 3:
                            [_favoriteButton setImage:[UIImage imageNamed:@"star_red2.png"] forState:UIControlStateNormal];
                            break;
                        case 4:
                            [_favoriteButton setImage:[UIImage imageNamed:@"star_green2.png"] forState:UIControlStateNormal];
                            break;
                            
                        default:
                            break;
                    }
                    
                    MemePhoto *pho = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
                    //NSLog(@"BEfore Update pho=%@",pho.photoMyLike);
                    pho.photoMyFavorite = @"0";
                    //NSLog(@"After Update pho=%@",pho.photoMyLike);
                    [UIAppDelegate.photoArray replaceObjectAtIndex:self.swipeView.currentItemIndex withObject:pho];
                }
                
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //[UIAppDelegate activityHide];
    }];
}


#pragma mark - get Updated Like
-(void)getUpdatedLikeWithMemeId:(NSString *)memeId forItemIndex:(NSInteger)itemIndex
{
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
                    NSString *like = [listDic objectForKey:@"allLike"];
                    NSString *MyFavorite = [listDic objectForKey:@"isMyFavorite"];
                    NSString *MyLike = [listDic objectForKey:@"isMyLike"];
                    NSString *photoID = [listDic objectForKey:@"id"];
                    
                    SwipeViewItem *view = (SwipeViewItem *)[self.swipeView itemViewAtIndex:itemIndex];
                    
                    MemePhoto *pho = [UIAppDelegate.photoArray objectAtIndex:itemIndex];
                    
                    pho.photoLike = like;
                    pho.photoID = photoID;
                    pho.photoMyFavorite = MyFavorite;
                    pho.photoMyLike = MyLike;
                    
                    [UIAppDelegate.photoArray replaceObjectAtIndex:itemIndex withObject:pho];
                    
                    view.likesLabel.text = [NSString stringWithFormat:@"Total Likes (%@)",like];
                    
                    //NSLog(@"likeInfo:index= %ld, MemeId=%@, Likes=%@\n",itemIndex,pho.photoID,like);
                    
                    MemePhoto *pho1 = [UIAppDelegate.photoArray objectAtIndex:_swipeView.currentItemIndex];
                    //NSLog(@"CurrentItemIndex=%ld, CurrentMemeId=%@, CurrentLike=%@",_swipeView.currentItemIndex,pho1.photoID,like);
                    
                    //Check if Favourite
                    if ([pho1.photoMyFavorite isEqualToString:@"1"])
                    {
                        _favoriteButton.tag = 100;
                        switch (_controllerIdentifier)
                        {
                            case 1:
                                [_favoriteButton setImage:[UIImage imageNamed:@"star_blue3.png"] forState:UIControlStateNormal];
                                break;
                            case 2:
                                [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow3.png"] forState:UIControlStateNormal];
                                break;
                            case 3:
                                [_favoriteButton setImage:[UIImage imageNamed:@"star_red3.png"] forState:UIControlStateNormal];
                                break;
                            case 4:
                                [_favoriteButton setImage:[UIImage imageNamed:@"star_green3.png"] forState:UIControlStateNormal];
                                break;
                                
                            default:
                                break;
                        }
                    }
                    else
                    {
                        _favoriteButton.tag = 101;
                        switch (_controllerIdentifier)
                        {
                            case 1:
                                [_favoriteButton setImage:[UIImage imageNamed:@"star_blue2.png"] forState:UIControlStateNormal];
                                break;
                            case 2:
                                [_favoriteButton setImage:[UIImage imageNamed:@"star_yellow2.png"] forState:UIControlStateNormal];
                                break;
                            case 3:
                                [_favoriteButton setImage:[UIImage imageNamed:@"star_red2.png"] forState:UIControlStateNormal];
                                break;
                            case 4:
                                [_favoriteButton setImage:[UIImage imageNamed:@"star_green2.png"] forState:UIControlStateNormal];
                                break;
                                
                            default:
                                break;
                        }
                    }
                    
                    //Check if Liked
                    if ([pho.photoMyLike isEqualToString:@"1"])
                    {
                        //NSLog(@"ccccccc");
                        view.likeButton.tag = 100;
                        switch (_controllerIdentifier)
                        {
                            case 1:
                                [view.likeButton setImage:[UIImage imageNamed:@"like_blue.png"] forState:UIControlStateNormal];
                                break;
                            case 2:
                                [view.likeButton setImage:[UIImage imageNamed:@"like_yellow.png"] forState:UIControlStateNormal];
                                break;
                            case 3:
                                [view.likeButton setImage:[UIImage imageNamed:@"like_red.png"] forState:UIControlStateNormal];
                                break;
                            case 4:
                                [view.likeButton setImage:[UIImage imageNamed:@"like_green.png"] forState:UIControlStateNormal];
                                break;
                            case 5:
                                [view.likeButton setImage:[UIImage imageNamed:@"like_purple.png"] forState:UIControlStateNormal];
                                break;
                                
                            default:
                                break;
                        }
                    }else
                    {
                        view.likeButton.tag = 101;
                        [view.likeButton setImage:[UIImage imageNamed:@"like_grey.png"] forState:UIControlStateNormal];
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

#pragma mark - Custom Rating AlertView
-(void)danMessagePopupView:(DanMessagePopup *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
                break;
            case 1:
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WILL_SHOW_SWIPE_SCREEN_LAST_INDEX_POPUP];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //
                [self.swipeView scrollToItemAtIndex:0 duration:0.5];
                [self.swipeView reloadData];
                break;
            case 2:
                
                NSLog(@"tag = 1 buttonIndex = 2");
                break;
                
            default:
                break;
                
        }//End case 1
            break;
            
        case 2:
            switch (buttonIndex)
        {
            case 0:
                //[irate rate];
                NSLog(@"tag = 2 buttonIndex = 0");
                break;
            case 1:
                
                isRollingBack = YES;
                [self.swipeView scrollToItemAtIndex:0 duration:0.5];
                
                
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
        }//End case 2
            break;
            
        case 3:
        case 4:
            switch (buttonIndex) {
                case 0:
                    UIAppDelegate.isFromMemeSwipe = YES;
                    viewController = [[LoginViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"LoginViewController"] bundle:nil];
                    [self presentViewController:viewController animated:YES completion:nil];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 5:
            switch (buttonIndex) {
                case 0:
                    [self moveBookmarkHere];
                    break;
                case 1:
                    [self gotoBookmark];
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
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"SwipeViewItem_iPad_pro" owner:self options:nil];
    }
    else if(IS_IPHONE_4INCHES)
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"SwipeViewItem_pro" owner:self options:nil];
        
    }
    else
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"SwipeViewItem_iPhone_pro" owner:self options:nil];
    }
    return arrayOfViews;
}

-(NSArray *)loadNibForNormalUser
{
    NSArray *arrayOfViews;
    if(IS_IPAD)
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"SwipeViewItem_iPad" owner:self options:nil];
    }
    else if(IS_IPHONE_4INCHES)
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"SwipeViewItem" owner:self options:nil];
        
    }
    else
    {
        arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"SwipeViewItem_iPhone" owner:self options:nil];
    }
    return arrayOfViews;
}

#pragma mark - Bookmark Methods
-(void)moveBookmarkHere
{
    MemePhoto *mp = [UIAppDelegate.photoArray objectAtIndex:self.swipeView.currentItemIndex];
    if (mp) {
        [[NSUserDefaults standardUserDefaults] setObject:mp.photoID forKey:BookmarkIndexKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void)gotoBookmark
{
    //NSString *memeID = [[NSUserDefaults standardUserDefaults] stringForKey:BookmarkIndexKey];
    if ([self isMemeIdContainsInGalleryImageArray]) {
        [self.swipeView scrollToItemAtIndex:bookMarkIndex duration:0.5];
    }
}

-(BOOL)isMemeIdContainsInGalleryImageArray
{
    NSString *memeID = [[NSUserDefaults standardUserDefaults] stringForKey:BookmarkIndexKey];
    if (memeID.length > 0)
    {
        for (MemePhoto *mp in UIAppDelegate.photoArray)
        {
            if ([mp.photoID isEqualToString:memeID]) {
                bookMarkIndex = [UIAppDelegate.photoArray indexOfObject:mp];
                return YES;
                break;
            }
        }
    }
    return NO;
}

#pragma mark - Load More
-(void)loadImagesForPageNumber:(int)pageNumber andIdentifier:(int)aIdentifier
{
    
    
    //if(pageNumber==1)
    //pageNum = 1;
    
    if(![AppDelegate isNetworkAvailable]) {
        [UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!"];
        return;
    }
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED] ? @"" : [[[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO] objectForKey:@"userId"];
    
    NSString *urlString;// = MEME_EVERYONE;
    switch (aIdentifier) {
        case 1:
            urlString = MEME_EVERYONE;
            break;
        case 2:
            urlString = MEME_MOTIVATIONAL;
            break;
        case 3:
            urlString = MEME_RACY;
            break;
        case 4:
            urlString = MEME_FAVOURITE_LIST;
            break;
        case 5:
            urlString = MEME_GIFS;
            break;
            
        default:
            break;
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"userID": userId, @"page_number" : [NSString stringWithFormat:@"%d",pageNumber] , @"item_count" : _controllerIdentifier == 5 ? [NSString stringWithFormat:@"%d",ITEMS_SPIFFY_PER_PAGE] : [NSString stringWithFormat:@"%d",ITEMS_PER_PAGE]};
    
    [UIAppDelegate activityShow];
    
    NSLog(@"Started..");
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSError *error = nil;
         NSDictionary *JSON =(NSDictionary*)responseObject;
         
         if (error)
         {
             NSLog(@"Error serializing %@", error);
         }
         else
         {
             if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
             {
                 
                 
                 NSArray *listArray = [JSON objectForKey:@"result"];
                 if(listArray.count)
                 {
                     isLoadingMore = YES;
                     self.pageNumber++;
                     UIAppDelegate.pageNumberRequest = self.pageNumber;
                     [UIAppDelegate.photoArray removeLastObject];
                     [self.swipeView reloadData];
                 }
                 
                 self.totalMeme = [[JSON objectForKey:@"total"] intValue];
                 
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
                                          likeCount:memePhoto.photoLike withCategory:[NSString stringWithFormat:@"%d",aIdentifier]];
                     }
                     
                     [UIAppDelegate.photoArray addObject:memePhoto];
                     
                     //NSLog(@"Everyone_server_PhotoID = %@",memePhoto.photoID);
                     
                 }
                 
                 if(listArray.count)
                     [UIAppDelegate.photoArray addObject:[UIAppDelegate.photoArray lastObject]];
                 
                 [self.swipeView reloadData];
                 NSLog(@"photoArray.count%lu",(unsigned long)UIAppDelegate.photoArray.count);
                 [UIAppDelegate activityHide];
             }
             
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         //isLoadingMore = NO;
         [UIAppDelegate activityHide];
     }];
}

#pragma mark Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end





















