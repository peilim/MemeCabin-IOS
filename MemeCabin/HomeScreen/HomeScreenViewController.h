//
//  HomeScreenViewController.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 27/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <StoreKit/StoreKit.h>

#import "CustomBadge.h"
#import "AppDelegate.h"
#import "MemesSwipeView.h"
#import "MemePhoto.h"
#import "MenuView.h"
#import "MKStoreKit.h"
#import "SVProgressHUD.h"

#import "DanMessageNew.h"
#import "DanMessagePopupNew.h"

#import "AnimatedGIFImageSerialization.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface HomeScreenViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, SKStoreProductViewControllerDelegate,DanMessagePopupNewViewDelegate, GADInterstitialDelegate>
{
    BOOL isHomeLoaded;
}
@property (nonatomic, retain) DanMessagePopup *danMessagePopup;
@property (nonatomic, retain) DanMessagePopup *danRatePopup;

@property(nonatomic,strong)DanMessagePopupNew *danMessagePopupNew;
@property(nonatomic,strong)DanMessageNew *danMessageNew;

@property (strong, nonatomic) NSString *imageExtention;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSData *imageDATA;

//Pop Up View outlets
@property (strong, nonatomic) IBOutlet UIView *popupView;
@property (strong, nonatomic) IBOutlet UIView *menuPopupView;
@property (strong, nonatomic) IBOutlet UIView *passcodePopupView;
@property (strong, nonatomic) IBOutlet UIView *unloackRacyPopupView;
@property (strong, nonatomic) IBOutlet UIView *capturePopupView;
@property (strong, nonatomic) IBOutlet UIView *gotItPopupView;

//Icon View outlets
@property (strong, nonatomic) IBOutlet UIView *memeForEveryOneView;
@property (strong, nonatomic) IBOutlet UIView *motivationalView;
@property (strong, nonatomic) IBOutlet UIView *racyMemeView;
@property (strong, nonatomic) IBOutlet UIView *trendingView;
@property (strong, nonatomic) IBOutlet UIView *uploadView;
@property (strong, nonatomic) IBOutlet UIView *favoriteView;
@property (strong, nonatomic) IBOutlet UIView *singleDadView;
@property (strong, nonatomic) IBOutlet UIView *spiffyGifsView;
@property (strong, nonatomic) IBOutlet UIView *removeAdsView;


//Icon Actions
- (IBAction)memeEveryoneButtonAction:(UIButton *)sender;
- (IBAction)motivationalButtonAction:(UIButton *)sender;
- (IBAction)recyMemeButtonAction:(UIButton *)sender;
- (IBAction)spiffyGifsButtonAction:(UIButton *)sender;
- (IBAction)trendingButtonAction:(UIButton *)sender;
- (IBAction)shareButtonAction:(UIButton *)sender;
- (IBAction)favoriteButtonAction:(UIButton *)sender;
- (IBAction)removeAdsButtonAction:(UIButton *)sender;
- (IBAction)commingSoonButtonAction:(UIButton *)sender;
- (IBAction)preferenceButtonAction:(UIButton *)sender;
- (IBAction)logoutButtonAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *commingSoonImageView;
@property (weak, nonatomic) IBOutlet UILabel *commingSoonAppNameLabel;

//@property (weak, nonatomic) IBOutlet UILabel *passwordViewLabel17;
@property (weak, nonatomic) IBOutlet UILabel *passwordViewLabel;
//@property (weak, nonatomic) IBOutlet UILabel *passwordViewTopLabel;
//@property (weak, nonatomic) IBOutlet UILabel *passwordViewProbablyLabel;
//@property (weak, nonatomic) IBOutlet UILabel *passwordViewDisableLabel;

@property (assign, nonatomic, getter = isFirstPassword) BOOL firstPassword;

//Saved favourite label
@property (weak, nonatomic) IBOutlet UILabel *savedFavouriteLabel;

//PopUp View Actions
- (IBAction)setPasscodeButtonAction:(UIButton *)sender;
- (IBAction)dontShowButtonAction:(UIButton *)sender;
- (IBAction)noWarriesButtonAction:(UIButton *)sender;
- (IBAction)getMeOutButtonAction:(UIButton *)sender;



//pop up password Textfield Outlets
@property (weak, nonatomic) IBOutlet UITextField *myTextField;

@property (weak, nonatomic) IBOutlet UIImageView *pImage1;
@property (weak, nonatomic) IBOutlet UIImageView *pImage2;
@property (weak, nonatomic) IBOutlet UIImageView *pImage3;
@property (weak, nonatomic) IBOutlet UIImageView *pImage4;


@property (weak, nonatomic) IBOutlet UIImageView *unImage1;
@property (weak, nonatomic) IBOutlet UIImageView *unImage2;
@property (weak, nonatomic) IBOutlet UIImageView *unImage3;
@property (weak, nonatomic) IBOutlet UIImageView *unImage4;

//dismiss popup
- (IBAction)dismissPopUp:(UIButton *)sender;


//Capture Popup outlets & Actions
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
- (IBAction)cameraButtonAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;
- (IBAction)sendButtonAction:(UIButton *)sender;

-(void)updateBadges;
@end
