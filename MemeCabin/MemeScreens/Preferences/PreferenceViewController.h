//
//  PreferenceViewController.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 31/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferenceViewController : UIViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

- (IBAction)backButtonAction:(UIButton *)sender;
- (IBAction)backToHomeButtonAction:(UIButton *)sender;
- (IBAction)favoriteButtonAction:(UIButton *)sender;



@property (weak, nonatomic) IBOutlet UIView *racyMemesView;
@property (weak, nonatomic) IBOutlet UIView *changeYourPasswordView;
- (IBAction)changePasswordDone:(UIButton *)sender;

//pop up password Textfield Outlets
@property (weak, nonatomic) IBOutlet UITextField *myTextField;

@property (weak, nonatomic) IBOutlet UIImageView *pImage1;
@property (weak, nonatomic) IBOutlet UIImageView *pImage2;
@property (weak, nonatomic) IBOutlet UIImageView *pImage3;
@property (weak, nonatomic) IBOutlet UIImageView *pImage4;

//TextField Outlets
@property (weak, nonatomic) IBOutlet UITextField *passwordOldTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordRetypeTextfield;

@property (strong, nonatomic) IBOutlet UIView *passcodePopupView;

@property (weak, nonatomic) IBOutlet UILabel *passwordViewLabel1;
@property (weak, nonatomic) IBOutlet UILabel *passwordViewLabel2;
@property (weak, nonatomic) IBOutlet UILabel *passwordViewLabel3;
@property (weak, nonatomic) IBOutlet UILabel *passwordViewLabel4;

//Dismiss popup
@property (strong, nonatomic) IBOutlet UIView *popupView;
- (IBAction)dismissPopup:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *memeEveryoneOnOffButton;
@property (weak, nonatomic) IBOutlet UIButton *motivationOnOffButton;
@property (weak, nonatomic) IBOutlet UIButton *racyMemeOnOffButton;
@property (weak, nonatomic) IBOutlet UIButton *spiffyGifsOnOffButton;
@property (weak, nonatomic) IBOutlet UIButton *racyMemeShowHideButton;
@property (weak, nonatomic) IBOutlet UIButton *spiffyShowHideButton;
@property (weak, nonatomic) IBOutlet UIButton *sdlShowHideButton;
@property (weak, nonatomic) IBOutlet UIButton *racyMemeLockUnlockButton;


- (IBAction)memeEveryoneOnOff:(UIButton *)sender;
- (IBAction)MotivationOnOff:(UIButton *)sender;
- (IBAction)RacyMemeOnOff:(UIButton *)sender;
- (IBAction)SpiffyGifsOnOff:(UIButton *)sender;
- (IBAction)RacyMemeShowHide:(UIButton *)sender;
- (IBAction)SpiffyShowHide:(UIButton *)sender;
- (IBAction)SDLappShowHide:(UIButton *)sender;
- (IBAction)RacyMemeLockUnlock:(UIButton *)sender;

- (IBAction)changePasswordButtonAction:(UIButton *)sender;

@end
