//
//  MemesSwipeView.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 31/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Accounts/Accounts.h>
#import "FavoriteViewController.h"
#import "HomeScreenViewController.h"
#import "ReportMemeVC.h"
#import "SwipeView.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "AnimatedGIFImageSerialization.h"

//#import "UIImageView+WebCache.h"
#import "FLAnimatedImage+Resizing.h"
#import "CMPopTipView.h"



@interface MemesSwipeView : UIViewController <UIScrollViewDelegate,UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate, UIAlertViewDelegate,CMPopTipViewDelegate, GADInterstitialDelegate>

//Scroll
{
@private
    NSMutableArray *galleryImages_;
}

@property (weak, nonatomic) IBOutlet UIView *myView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activity_like;

@property (nonatomic, weak)IBOutlet UIView *likeRoundView;

@property (nonatomic, weak) IBOutlet UIView *addedToFavouriteView;
@property (nonatomic, weak) IBOutlet UILabel *addOrRemoveText;

@property(nonatomic, retain)NSMutableArray *galleryImages;
@property(nonatomic, retain) IBOutlet UIScrollView *imageHostScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *prevView;

//from other
@property (assign, nonatomic) NSInteger imageIndex;
@property (strong, nonatomic) NSArray *imageArray;

@property (assign, nonatomic) NSInteger totalMeme;
@property (assign, nonatomic) int pageNumber;

@property (assign) NSInteger controllerIdentifier;
@property (strong, nonatomic) NSString *totalLikes;

//Top bar
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIImageView *topBarbg;
@property (weak, nonatomic) IBOutlet UIImageView *topBarText;
@property (weak, nonatomic) IBOutlet UIImageView *topBarRightImage;

@property (weak, nonatomic) UIImageView *shareImageView;

- (IBAction)backButtonAction:(UIButton *)sender;

//Middle
@property (weak, nonatomic) IBOutlet UILabel *totalLikesLabel;
@property (weak, nonatomic) IBOutlet UIButton *thumbButton;

- (IBAction)likeButtonAction:(UIButton *)sender;

//Lower bar
@property (weak, nonatomic) IBOutlet UIImageView *bottomBarbg;

@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

- (IBAction)favoriteButtonAction:(UIButton *)sender;
- (IBAction)shareButtonAction:(UIButton *)sender;
- (IBAction)reloadButtonAction:(UIButton *)sender;
- (IBAction)backToHomeButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *backToHomeButton;

- (IBAction)bookMarkButtonAction:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIView *popupView;
- (IBAction)dismissPopup:(UIButton *)sender;


//Share Popup
@property (strong, nonatomic) IBOutlet UIView *popupShareView;
@property(nonatomic,strong)AFHTTPRequestOperationManager *manager;

- (IBAction)saveButtonAction:(UIButton *)sender;
- (IBAction)facebookShareAction:(UIButton *)sender;
- (IBAction)twitterShareAction:(UIButton *)sender;
- (IBAction)emailShareAction:(UIButton *)sender;
- (IBAction)smsShareAction:(UIButton *)sender;
- (IBAction)reportButtonAction:(UIButton *)sender;

@end
