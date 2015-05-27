//
//  LoginWithEmailViewController.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 26/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>



@interface LoginViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

//View
@property (weak, nonatomic)IBOutlet UIView *vwLogin;
@property (weak, nonatomic)IBOutlet UIView *vwRegistration;
@property (weak, nonatomic)IBOutlet UIView *vwMenu;
@property (weak, nonatomic)IBOutlet UIView *vwForgotPass;

//TextField
@property (weak, nonatomic) IBOutlet UITextField *tf_EmailLogin;
@property (weak, nonatomic) IBOutlet UITextField *tf_PasswordLogin;

@property (weak, nonatomic) IBOutlet UITextField *tf_EmailRegister;
@property (weak, nonatomic) IBOutlet UITextField *tf_PasswordRegister;
@property (weak, nonatomic) IBOutlet UITextField *tf_VerifyPasswordRegister;

@property (weak, nonatomic) IBOutlet UITextField *tf_EmailForgotPassword;

//Menu
@property (weak, nonatomic)IBOutlet UIButton *btn_RegisterOnMenu;
@property (weak, nonatomic)IBOutlet UIButton *btn_FacebookOnMenu;
@property (weak, nonatomic)IBOutlet UIButton *btn_MemberOnMenu;

@property (weak, nonatomic)IBOutlet UIButton *btn_RegisterOnLogin;
@property (weak, nonatomic)IBOutlet UIButton *btn_FacebookOnLogin;
@property (weak, nonatomic)IBOutlet UIButton *btn_LoginOnLogin;

@property (weak, nonatomic)IBOutlet UIButton *btn_RegisterOnRegister;
@property (weak, nonatomic)IBOutlet UIButton *btn_FacebookOnRegister;
@property (weak, nonatomic)IBOutlet UIButton *btn_MemberOnRegister;

@property (weak, nonatomic)IBOutlet UILabel *lbl_DontWorryOnMenu;
@property (weak, nonatomic)IBOutlet UILabel *lbl_DontWorryOnRegister;
@property (weak, nonatomic)IBOutlet UILabel *lbl_DontWorryOnLogin;

@property (weak, nonatomic)IBOutlet UILabel *lbl_AlreadyMemberLoginOnLogin;
@property (weak, nonatomic)IBOutlet UILabel *lbl_RegisterWithEmailOnRegister;
@property (weak, nonatomic)IBOutlet UILabel *lbl_ForgotPaswordOnForgot;


@end
