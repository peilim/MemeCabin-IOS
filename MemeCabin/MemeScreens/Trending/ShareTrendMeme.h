//
//  ShareTrendMeme.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 01/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>
#import "TrendingDetailView.h"
#import "FlurryAdDelegate.h"
#import <iAd/iAd.h>
#import "ReportMemeVC.h"


@interface ShareTrendMeme : UIViewController <UIScrollViewDelegate,UIGestureRecognizerDelegate,UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, weak) TrendingDetailView *trendingDetailView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activity_like;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (nonatomic, weak) IBOutlet UIView *addedToFavouriteView;
@property (nonatomic, weak) IBOutlet UILabel *addOrRemoveText;

@property(nonatomic, retain) NSMutableArray *galleryImages;
@property(nonatomic, retain) IBOutlet UIScrollView *imageHostScrollView;

@property (strong, nonatomic) IBOutlet UIView *popupView;
- (IBAction)dismissPopup:(UIButton *)sender;



//End meme Popup


//First Meme Popup


//Share Popup
@property (strong, nonatomic) IBOutlet UIView *popupShareView;

- (IBAction)saveButtonAction:(UIButton *)sender;
- (IBAction)facebookShareAction:(UIButton *)sender;
- (IBAction)twitterShareAction:(UIButton *)sender;
- (IBAction)emailShareAction:(UIButton *)sender;
- (IBAction)smsShareAction:(UIButton *)sender;
- (IBAction)reportButtonAction:(UIButton *)sender;


//Top
- (IBAction)backButtonAction:(UIButton *)sender;
- (IBAction)menuButtonAction:(UIButton *)sender;

- (IBAction)likeButtonAction:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UIView *myView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

//Middle
@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) NSString *numberLabelStr;
@property (strong, nonatomic) NSString *todaysLikeStr;
@property (strong, nonatomic) NSString *sevenDaysLikeStr;
@property (strong, nonatomic) NSString *thirtyDaysLikeStr;
@property (strong, nonatomic) NSString *totalLikeStr;
@property (assign) NSInteger  imageIndex;
@property (strong, nonatomic) NSMutableArray *imageArray;

@property (weak, nonatomic) IBOutlet UIButton *thumbButton;


@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *todaysLikeslabel;
@property (weak, nonatomic) IBOutlet UILabel *sevenDaysLikeslabel;
@property (weak, nonatomic) IBOutlet UILabel *thirtyDaysLikeslabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLikeslabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;


//Lower
- (IBAction)backToHomeButtonAction:(UIButton *)sender;
- (IBAction)reloadButtonAction:(UIButton *)sender;
- (IBAction)shareButtonAction:(UIButton *)sender;
- (IBAction)favoriteButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *backToHomeButton;


@end
