//
//  LoginWithEmailViewController.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 26/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "LoginViewController.h"

#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"

#import "Reachability.h"
#import "AppDelegate.h"


#define LOGIN_BUTTON_TAG 1
#define REGISTER_BUTTON_TAG 2
#define FORGOT_BUTTON_TAG 3
#define REGISTRATION_VERIFICATION_TAG 4
#define LOGIN_VERIFICATION_TAG 5

@interface LoginViewController ()

{
    
}


@end

@implementation LoginViewController

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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(resignAllKeyboards)];
    
    [self.view addGestureRecognizer:tap];
    
    [self loadInitialSettings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFacebookLoginSuccess:) name:@"FACEBOOK_LOGIN_SUCCESS" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAD) name:@"BANNAR_AD_IS_VISIBLE" object:nil];
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
    
    [self resignAllKeyboards];
    
    _vwLogin.alpha=0;
    _vwRegistration.alpha=0;
    _vwForgotPass.alpha = 0;
    _vwMenu.alpha=1;

}

#pragma mark - Custom methods
-(void)loadInitialSettings
{
    
    if (IS_IPHONE) {
        _lbl_DontWorryOnMenu.font = _lbl_DontWorryOnLogin.font = _lbl_DontWorryOnRegister.font = [UIFont fontWithName:@"HelveticaNeueLTPro-ThExO" size:11];
        
        _btn_RegisterOnMenu.titleLabel.font = _btn_FacebookOnMenu.titleLabel.font =_btn_MemberOnMenu.titleLabel.font = _btn_RegisterOnLogin.titleLabel.font = _btn_FacebookOnLogin.titleLabel.font = _btn_MemberOnRegister.titleLabel.font = _btn_FacebookOnRegister.titleLabel.font = _lbl_AlreadyMemberLoginOnLogin.font = _lbl_RegisterWithEmailOnRegister.font = _lbl_ForgotPaswordOnForgot.font = [ UIFont fontWithName:@"HelveticaNeueLTPro-ThEx" size:20];
        
        _tf_EmailForgotPassword.font = _tf_EmailLogin.font = _tf_EmailRegister.font = _tf_PasswordLogin.font = _tf_PasswordRegister.font = _tf_VerifyPasswordRegister.font = [ UIFont fontWithName:@"HelveticaNeueLTPro-ThEx" size:20];
        
        _btn_LoginOnLogin.titleLabel.font = _btn_RegisterOnRegister.titleLabel.font = [ UIFont fontWithName:@"HelveticaNeueLTPro-ThEx" size:20];
    }
    else
    {
        _lbl_DontWorryOnMenu.font = _lbl_DontWorryOnLogin.font = _lbl_DontWorryOnRegister.font = [UIFont fontWithName:@"HelveticaNeueLTPro-ThExO" size:18];
        
        _btn_RegisterOnMenu.titleLabel.font = _btn_FacebookOnMenu.titleLabel.font =_btn_MemberOnMenu.titleLabel.font = _btn_RegisterOnLogin.titleLabel.font = _btn_FacebookOnLogin.titleLabel.font = _btn_MemberOnRegister.titleLabel.font = _btn_FacebookOnRegister.titleLabel.font = _lbl_AlreadyMemberLoginOnLogin.font = _lbl_RegisterWithEmailOnRegister.font = _lbl_ForgotPaswordOnForgot.font = [ UIFont fontWithName:@"HelveticaNeueLTPro-ThEx" size:35];
        
        _tf_EmailForgotPassword.font = _tf_EmailLogin.font = _tf_EmailRegister.font = _tf_PasswordLogin.font = _tf_PasswordRegister.font = _tf_VerifyPasswordRegister.font = [ UIFont fontWithName:@"HelveticaNeueLTPro-ThEx" size:35];
        
        _btn_LoginOnLogin.titleLabel.font = _btn_RegisterOnRegister.titleLabel.font = [ UIFont fontWithName:@"HelveticaNeueLTPro-ThEx" size:35];
    }
    
    
}
- (void)resignAllKeyboards
{
    [_tf_EmailLogin             resignFirstResponder];
    [_tf_PasswordLogin          resignFirstResponder];
    [_tf_EmailRegister          resignFirstResponder];
    [_tf_PasswordRegister       resignFirstResponder];
    [_tf_VerifyPasswordRegister resignFirstResponder];
    [_tf_EmailForgotPassword    resignFirstResponder];
    
    /*
    if (_vwForgotPass.alpha == 1)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:1];
        
        _vwLogin.alpha=1;
        _vwRegistration.alpha=0;
        _vwForgotPass.alpha = 0;
        _vwMenu.alpha=0;
        
        [UIView commitAnimations];
        
        [_tf_EmailLogin becomeFirstResponder];
    }
    */
    
}

-(void)emptyLoginTextFields
{
    [_tf_EmailLogin             setText:nil];
    [_tf_PasswordLogin          setText:nil];
}

-(void)emptyTextFields
{
    [_tf_EmailLogin             setText:nil];
    [_tf_PasswordLogin          setText:nil];
    [_tf_EmailRegister          setText:nil];
    [_tf_PasswordRegister       setText:nil];
    [_tf_VerifyPasswordRegister setText:nil];
    [_tf_EmailForgotPassword    setText:nil];
}

-(void)emptyRegistrationTextFields
{
    [_tf_EmailRegister          setText:nil];
    [_tf_PasswordRegister       setText:nil];
    [_tf_VerifyPasswordRegister setText:nil];
}


#pragma mark - Menu Button Actions
- (IBAction)menu_registerAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Register Button Clicked"];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:1];
    
    _vwLogin.alpha=0;
    _vwRegistration.alpha=1;
    _vwMenu.alpha=0;
    _vwForgotPass.alpha = 0;
    
    [UIView commitAnimations];
}
- (IBAction)menu_facebookAction:(UIButton *)sender
{
    if(![AppDelegate isNetworkAvailable])
        return;
    
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Facebook Button Clicked"];
    
    if([UIAppDelegate isFBSessionValid])
    {
        
    }
    else
    {
        NSLog(@"(![UIAppDelegate isFBSessionValid])");
        [UIAppDelegate signInWithFacebook];
    }
}
- (IBAction)menu_memberAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Login Button Clicked"];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:1];
    
    _vwLogin.alpha=1;
    _vwRegistration.alpha=0;
    _vwMenu.alpha=0;
    _vwForgotPass.alpha = 0;
    
    [UIView commitAnimations];
}

- (IBAction)skipButtonAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Skip Button Clicked"];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CHECK_FOR_IS_SKIPPED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    HomeScreenViewController *viewController = [[HomeScreenViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"HomeScreenViewController"] bundle:nil];
    
//    HomeScreenViewController *viewController = [[HomeScreenViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"TestDashBoardVC"] bundle:nil];
    
    if (UIAppDelegate.isFromFavourite || UIAppDelegate.isFromMemeSwipe || UIAppDelegate.isFromTrendingSwipe) {
        NSLog(@"Inside If");
        [self dismissViewControllerAnimated:YES completion:^{
            
            UIAppDelegate.isFromFavourite = NO;
            UIAppDelegate.isFromMemeSwipe = NO;
            UIAppDelegate.isFromTrendingSwipe = NO;

        }];
    } else {
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    
}

#pragma mark - Menu inner Button Actions

- (IBAction)forgotPasswordAction:(UIButton *)sender
{
    sender.tag = FORGOT_BUTTON_TAG;
    
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"ForgotPassword Button Clicked"];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:1];
    
    _vwLogin.alpha = 0;
    _vwRegistration.alpha = 0;
    _vwMenu.alpha = 0;
    _vwForgotPass.alpha = 1;
    
    [UIView commitAnimations];
    
    [_tf_EmailForgotPassword becomeFirstResponder];
}
- (IBAction)loginAction:(UIButton *)sender
{
    sender.tag = LOGIN_BUTTON_TAG;
    [self doLogin];
}
- (IBAction)registerAction:(UIButton *)sender
{
    sender.tag = REGISTER_BUTTON_TAG;
    [self doRegister];
}
- (IBAction)forgotPassSendAction:(UIButton *)sender
{
    sender.tag = FORGOT_BUTTON_TAG;
    [self retrivePassword];
}
- (IBAction)forgotPassCancelAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"ForgotPassword Calcel Button Clicked"];
    [self resignAllKeyboards];
    _tf_EmailForgotPassword.text = @"";
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:1];
    
    _vwLogin.alpha = 1;
    _vwRegistration.alpha = 0;
    _vwMenu.alpha = 0;
    _vwForgotPass.alpha = 0;
    
    [UIView commitAnimations];
    
    [_tf_EmailLogin becomeFirstResponder];
}


#pragma mark - Text field delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
//    [keyboardDoneButtonView sizeToFit];
//    
//    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
//                                                                   style:UIBarButtonItemStyleBordered target:self action:@selector(doneClicked)];
//    
//    
//    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
//    textField.inputAccessoryView = keyboardDoneButtonView;
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    NSLog(@"textFieldDidBeginEditing");
    
    CGPoint scrollPoint;
    
    if (IS_IPHONE) 
    {
        if (IS_IPHONE_4INCHES)
        {
            if (textField == _tf_EmailLogin || textField == _tf_PasswordLogin) {
                scrollPoint = CGPointMake(0.0, 215);
            } else if (textField == _tf_EmailForgotPassword) {
                scrollPoint = CGPointMake(0.0, 120);
            }
            else {
                scrollPoint = CGPointMake(0.0, 110);
            }
        }
        else
        {
            if (textField == _tf_EmailLogin || textField == _tf_PasswordLogin) {
                scrollPoint = CGPointMake(0.0, 205);
            } else if (textField == _tf_EmailForgotPassword) {
                scrollPoint = CGPointMake(0.0, 120);
            }
            else {
                scrollPoint = CGPointMake(0.0, 110);
            }
        }
        
    }
    else
    {
        if (textField == _tf_EmailLogin || textField == _tf_PasswordLogin) {
            scrollPoint = CGPointMake(0.0, 220);
        } else {
            scrollPoint = CGPointMake(0.0, 198);
        }
    }
    [_myScrollView setContentOffset:scrollPoint animated:YES];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [_myScrollView setContentOffset:CGPointZero animated:YES];
    
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    if(textField== _tf_EmailLogin)
    {
        [_tf_PasswordLogin becomeFirstResponder];
        return YES;
    }
    if(textField== _tf_PasswordLogin)
    {
        [self doLogin];
        [_tf_PasswordLogin resignFirstResponder];
        return YES;
    }
    if(textField== _tf_EmailRegister)
    {
        [_tf_PasswordRegister becomeFirstResponder];
        return YES;
    }
    if(textField== _tf_PasswordRegister)
    {
        [_tf_VerifyPasswordRegister becomeFirstResponder];
        return YES;
    }
    if(textField== _tf_VerifyPasswordRegister)
    {
        [self doRegister];
        [_tf_VerifyPasswordRegister resignFirstResponder];
        return YES;
    }
    if(textField== _tf_EmailForgotPassword)
    {
        NSLog(@"textField== _tf_EmailForgotPassword");
        [self retrivePassword];
        [_tf_EmailForgotPassword resignFirstResponder];
        return YES;
    }
    return YES;
}

-(BOOL)isFormDataValidWithTag:(int)formTag
{
    NSString *errorMessage = nil;
    UITextField *errorField;
    
    switch (formTag)
    {
        case 1:
            if ([_tf_EmailLogin.text isEqualToString:@""])
            {
                errorMessage = @"Please enter email address.";
                errorField = _tf_EmailLogin;
            }
            else if ([_tf_PasswordLogin.text isEqualToString:@""])
            {
                errorMessage = @"Please enter password.";
                errorField = _tf_PasswordLogin;
            }
            else if (![self validateEmail:_tf_EmailLogin.text])
            {
                errorMessage = @"Please enter valid email.";
                errorField = _tf_EmailLogin;
            }
            break;
        case 2:
            if ([_tf_EmailRegister.text isEqualToString:@""])
            {
                errorMessage = @"Please enter email address.";
                errorField = _tf_EmailRegister;
            }
            else if ([_tf_PasswordRegister.text isEqualToString:@""])
            {
                errorMessage = @"Please enter password.";
                errorField = _tf_PasswordRegister;
            }
            else if ([_tf_VerifyPasswordRegister.text isEqualToString:@""])
            {
                errorMessage = @"Please verify password.";
                errorField = _tf_VerifyPasswordRegister;
            }
            else if (![self validateEmail:_tf_EmailRegister.text])
            {
                errorMessage = @"Please enter valid email.";
                errorField = _tf_EmailRegister;
            }
            else if (![_tf_PasswordRegister.text isEqualToString:_tf_VerifyPasswordRegister.text])
            {
                //Previous : Password missmach.
                errorMessage = @"Oops! Your passwords don't match.";
                errorField = _tf_PasswordRegister;
            }
            break;
        case 3:
            NSLog(@"case 3");
            if ([_tf_EmailForgotPassword.text isEqualToString:@""])
            {
                errorMessage = @"Please enter email address.";
                errorField = _tf_EmailForgotPassword;
            }
            else if (![self validateEmail:_tf_EmailForgotPassword.text])
            {
                errorMessage = @"Please enter valid email.";
                errorField = _tf_EmailForgotPassword;
            }
            break;
            
        default:
            break;
    }
    
    if (errorMessage)
    {
        //Previous : Registration Failed!
        [UIAppDelegate showAlertWithTitle:errorMessage message:nil];
        [errorField becomeFirstResponder];
        return NO;
    }
    else
    {
        return YES;
    }
     
    
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}


#pragma mark - Facebook
#pragma mark - handleFBSessionStateChangeWithNotification

-(void)onFacebookLoginSuccess:(NSNotification *)notification
{
    NSLog(@"onFacebookLoginSuccess");
    [self proceedLoginViaFacebook:notification.object];
}

- (void)proceedLoginViaFacebook:(NSDictionary*)result
{
    NSLog(@"proceedLoginViaFacebook");
    
    NSLog(@"result=%@",result);
    
    [self registerFBWithFbId:[result objectForKey:@"id"]];//id
}

#pragma mark - API Call Method
-(void) registerFBWithFbId:(NSString *)fbId
{
    NSMutableDictionary *UserInfoDict = [NSMutableDictionary dictionary];
    
    NSString *urlString = MEME_SIGN_UP;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"email": fbId, @"password":@"", @"type":@"facebook"};
    
    [UIAppDelegate activityShow];NSLog(@"registerFBWithFbId");
    
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Sample logic to check login status
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [UIAppDelegate activityHide];
        
        NSError *error = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"Error serializing %@", error);
        }
        else
        {
            
            
            NSString *userId = [JSON objectForKey:@"userID"];
            
            if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
            {
                [UserInfoDict setValue:userId forKey:@"userId"];
                [UserInfoDict setValue:fbId forKey:@"userEmail"];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CHECK_FOR_LOGIN];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CHECK_FOR_IS_SKIPPED];
                [[NSUserDefaults standardUserDefaults] setObject:UserInfoDict forKey:CHECK_FOR_USER_INFO];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                
                NSLog(@"message:Success");
                HomeScreenViewController *viewController = [[HomeScreenViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"HomeScreenViewController"] bundle:nil];
                
                if (UIAppDelegate.isFromFavourite || UIAppDelegate.isFromMemeSwipe || UIAppDelegate.isFromTrendingSwipe) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        NSLog(@"dismissViewControllerAnimated");
                        
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CHECK_FOR_IS_SKIPPED];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }];
                } else {
                    [self.navigationController pushViewController:viewController animated:YES];
                }
                
            }
            else
            {
                NSString *errorMessage = [JSON objectForKey:@"message"];
                if (errorMessage.length > 0)
                {
                    [[FBSession activeSession] closeAndClearTokenInformation];
                    [UIAppDelegate showAlertWithTitle:errorMessage message:nil];
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [UIAppDelegate activityHide];
    }];
}

//#pragma mark - TouchBegan
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    // Enumerate over all the touches and draw a red dot on the screen where the touches were
//    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
//        // Get a single touch and it's location
//        UITouch *touch = obj;
//        CGPoint touchPoint = [touch locationInView:self.view];
//        
//        NSLog(@"touchPoint");
//    }];
//}

#pragma mark - Register & Login API Call
-(void)doRegister
{
    if(![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Connection Error!" message:@"No internet connection."];
        [self emptyTextFields];
        return;
    }
    
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Register Button Clicked"];
    
    NSMutableDictionary *UserInfoDict = [NSMutableDictionary dictionary];
    [self resignAllKeyboards];
    
    if ([self isFormDataValidWithTag:REGISTER_BUTTON_TAG])
    {
        NSString *email = _tf_EmailRegister.text;
        NSString *password = _tf_PasswordRegister.text;
        
        NSString *urlString = MEME_SIGN_UP;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *parameters = @{@"email": email, @"password": password, @"type": @"normal"};
        
        [UIAppDelegate activityShow];
        
        [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
             
             [UIAppDelegate activityHide];
             
             NSString *errorMessage = nil;
             NSError *error = nil;
             NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
             if (error) {
                 NSLog(@"Error serializing %@", error);
             }
             else
             {
                 NSString *userId = [JSON objectForKey:@"userID"];
                 
                 if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
                 {
                     errorMessage = [JSON objectForKey:@"message"];
                     if (errorMessage.length > 0) {
                         UIAlertView *registrationSuccessAlert = [[UIAlertView alloc]
                                                                  initWithTitle:errorMessage
                                                                  message:nil
                                                                  delegate:self
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:nil];
                         
                         [registrationSuccessAlert addButtonWithTitle:@"Resend"];
                         [registrationSuccessAlert addButtonWithTitle:@"Okay"];
                         
                         registrationSuccessAlert.tag = 1;
                         [registrationSuccessAlert show];
                         return;
                     }
                     
                     [UserInfoDict setValue:userId forKey:@"userId"];
                     [UserInfoDict setValue:email forKey:@"userEmail"];
                     
                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CHECK_FOR_LOGIN];
                     [[NSUserDefaults standardUserDefaults] setObject:UserInfoDict forKey:CHECK_FOR_USER_INFO];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     
                     [self emptyTextFields];
                     
                     [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Registration Succeeded"];
                     
                     
                     
                     
                     HomeScreenViewController *viewController = [[HomeScreenViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"HomeScreenViewController"] bundle:nil];
                     
                     if (UIAppDelegate.isFromFavourite || UIAppDelegate.isFromMemeSwipe || UIAppDelegate.isFromTrendingSwipe) {
                         [self dismissViewControllerAnimated:YES completion:^{
                             NSLog(@"dismissViewControllerAnimated");
                             
                             UIAppDelegate.isFromFavourite = NO;
                             UIAppDelegate.isFromMemeSwipe = NO;
                             UIAppDelegate.isFromTrendingSwipe = NO;
                             
                             [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CHECK_FOR_IS_SKIPPED];
                             [[NSUserDefaults standardUserDefaults] synchronize];
                         }];
                     } else {
                         [self.navigationController pushViewController:viewController animated:YES];
                     }
                     
                 }
                 else
                 {
                     errorMessage = [JSON objectForKey:@"message"];
                     if (errorMessage.length > 0) {
                         [UIAppDelegate showAlertWithTitle:errorMessage message:nil];
                     }
                 }
                 
                 
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [UIAppDelegate activityHide];
         }];
    }
}

-(void)doLogin
{
    if(![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Connection Error!" message:@"No internet connection."];
        [self emptyTextFields];
        return;
    }
    
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Login Button Clicked"];
    [self resignAllKeyboards];
    
    NSMutableDictionary *UserInfoDict = [NSMutableDictionary dictionary];
    
    if ([self isFormDataValidWithTag:LOGIN_BUTTON_TAG])
    {
        NSString *email = _tf_EmailLogin.text;
        NSString *password = _tf_PasswordLogin.text;
        
        NSString *urlString = MEME_SIGN_IN;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *parameters = @{@"email": email, @"password": password, @"type": @"normal"};
        
        [UIAppDelegate activityShow];
        
        [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            [UIAppDelegate activityHide];
            
            NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            NSString *errorMessage = nil;
            NSError *error = nil;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                NSLog(@"Error serializing %@", error);
            }
            else
            {
                [self emptyRegistrationTextFields];
                
                NSString *userId = [JSON objectForKey:@"userID"];
                if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
                {
                    [UserInfoDict setValue:userId forKey:@"userId"];
                    [UserInfoDict setValue:email forKey:@"userEmail"];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CHECK_FOR_LOGIN];
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CHECK_FOR_IS_SKIPPED];
                    [[NSUserDefaults standardUserDefaults] setObject:UserInfoDict forKey:CHECK_FOR_USER_INFO];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self emptyTextFields];
                    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Registration Succeeded"];
                    
                    //NSLog(@"isFromFavourite:%hhd",UIAppDelegate.isFromFavourite);
                    HomeScreenViewController *viewController = [[HomeScreenViewController alloc] initWithNibName:[AppResources getProperXibNameAccordingToScreen:@"HomeScreenViewController"] bundle:nil];
                    
                    if (UIAppDelegate.isFromFavourite || UIAppDelegate.isFromMemeSwipe || UIAppDelegate.isFromTrendingSwipe) {
                        [self dismissViewControllerAnimated:YES completion:^{
                            NSLog(@"dismissViewControllerAnimated");
                            
                            UIAppDelegate.isFromFavourite = NO;
                            UIAppDelegate.isFromMemeSwipe = NO;
                            UIAppDelegate.isFromTrendingSwipe = NO;
                            
                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CHECK_FOR_IS_SKIPPED];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }];
                    } else {
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                }
                else if ([[JSON objectForKey:@"status"] isEqualToString:@"2"])
                {
                    
                    errorMessage = [JSON objectForKey:@"message"];
                    UIAlertView *verificationAlert = [[UIAlertView alloc]
                                                             initWithTitle:errorMessage
                                                             message:nil
                                                             delegate:self
                                                             cancelButtonTitle:nil
                                                             otherButtonTitles:nil];
                    
                    [verificationAlert addButtonWithTitle:@"Resend Verification"];
                    [verificationAlert addButtonWithTitle:@"Okay"];
                    
                    verificationAlert.tag = 3;
                    [verificationAlert show];
                    return;
                }
                else
                {
                    errorMessage = [JSON objectForKey:@"message"];
                    if (errorMessage.length > 0) {
                        [UIAppDelegate showAlertWithTitle:errorMessage message:nil];
                    }
                }
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [UIAppDelegate activityHide];
        }];
    }
}
-(void)retrivePassword
{
    if(![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Connection Error!" message:@"No internet connection."];
        [self emptyTextFields];
        return;
    }
    
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"ForgotPassword Send Button Clicked"];
    [self resignAllKeyboards];
    
    if ([self isFormDataValidWithTag:FORGOT_BUTTON_TAG])
    {
        NSString *email = _tf_EmailForgotPassword.text;
        
        NSString *urlString = MEME_FORGOT_PASSWORD;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *parameters = @{@"email": email};
        
        [UIAppDelegate activityShow];
        
        [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [UIAppDelegate activityHide];
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
                     NSString *errorMessage = [JSON objectForKey:@"message"];
                     if (errorMessage.length > 0) {
                         UIAlertView *retrivePasswordSuccessAlert = [[UIAlertView alloc]
                                                                  initWithTitle:errorMessage
                                                                  message:nil
                                                                  delegate:self
                                                                  cancelButtonTitle:@"Ok"
                                                                  otherButtonTitles:nil];
                         retrivePasswordSuccessAlert.tag = 2;
                         [retrivePasswordSuccessAlert show];
                         return;
                     }
                     
                     [self emptyTextFields];
                     
                     [UIView beginAnimations:nil context:NULL];
                     [UIView setAnimationBeginsFromCurrentState:YES];
                     [UIView setAnimationDuration:1];
                     
                     _vwLogin.alpha=1;
                     _vwRegistration.alpha=0;
                     _vwMenu.alpha=0;
                     _vwForgotPass.alpha = 0;
                     
                     [UIView commitAnimations];
                     
                     [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"ForgotPassword Action Succeeded"];
                     
                     
                 }
                 else
                 {
                     NSString *errorMessage = [JSON objectForKey:@"message"];
                     if (errorMessage.length > 0) {
                         [UIAppDelegate showAlertWithTitle:errorMessage message:nil];
                     }
                 }
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [UIAppDelegate activityHide];
         }];
    }
}

-(void)resendVerificationLinkWithTag:(int)tag
{
    if(![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Connection Error!"
                                  message:@"No internet connection."];
        [self emptyTextFields];
        return;
    }
    [self resignAllKeyboards];
    
    int formValidationTag = (tag == REGISTRATION_VERIFICATION_TAG) ? REGISTER_BUTTON_TAG : LOGIN_BUTTON_TAG;
    
    if ([self isFormDataValidWithTag:formValidationTag])
    {
        NSString *email = (tag == REGISTRATION_VERIFICATION_TAG) ? _tf_EmailRegister.text : _tf_EmailLogin.text;
        
        NSLog(@"EMAIL ==== %@",email);
        
        NSString *urlString = MEME_VERIFICATION_LINK;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *parameters = @{@"email": email};
        
        [UIAppDelegate activityShow];
        
        [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [UIAppDelegate activityHide];
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
                     NSString *errorMessage = [JSON objectForKey:@"message"];
                     if (tag == REGISTRATION_VERIFICATION_TAG)
                     {
                         if (errorMessage.length > 0) {
                             UIAlertView *alert = [[UIAlertView alloc]
                                                   initWithTitle:errorMessage
                                                   message:nil
                                                   delegate:self
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
                             alert.tag = 4;
                             [alert show];
                             return;
                         }
                     }
                     else
                     {
                         if (errorMessage.length > 0) {
                             [UIAppDelegate showAlertWithTitle:errorMessage message:nil];
                             return;
                         }
                     }
                     
                 }
                 else
                 {
                     NSString *errorMessage = [JSON objectForKey:@"message"];
                     if (errorMessage.length > 0) {
                         [UIAppDelegate showAlertWithTitle:errorMessage message:nil];
                     }
                 }
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [UIAppDelegate activityHide];
         }];
    }
}

-(void)hideAD
{
    NSLog(@"UIAppDelegate.bannerIsVisible=%hhd",UIAppDelegate.bannerIsVisible);
    [UIAppDelegate hideFlurryAd];
}

#pragma mark - Registration Success Alert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
            if (buttonIndex == 0)
            {
                NSLog(@"clickedButtonAtIndex=%d",buttonIndex);
                [self resendVerificationLinkWithTag:REGISTRATION_VERIFICATION_TAG];
            }
            else
            {
                NSLog(@"clickedButtonAtIndex=%d",buttonIndex);
                [self emptyTextFields];
                [self menu_memberAction:nil];
                [_tf_EmailLogin becomeFirstResponder];
            }
            break;
        case 2:
            if (buttonIndex == 0)
            {
                [self emptyTextFields];
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationBeginsFromCurrentState:YES];
                [UIView setAnimationDuration:1];
                
                _vwLogin.alpha=1;
                _vwRegistration.alpha=0;
                _vwMenu.alpha=0;
                _vwForgotPass.alpha = 0;
                
                [UIView commitAnimations];
                
                [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"ForgotPassword Action Succeeded"];
            }
            break;
        case 3:
            if (buttonIndex == 0)
            {
                NSLog(@"clickedButtonAtIndex=%d",buttonIndex);
                [self resendVerificationLinkWithTag:LOGIN_VERIFICATION_TAG];
            }
            else
            {
                NSLog(@"clickedButtonAtIndex=%d",buttonIndex);
            }
            break;
            
        case 4:
            if (buttonIndex == 0)
            {
                NSLog(@"clickedButtonAtIndex=%d",buttonIndex);
                [self emptyTextFields];
                [self menu_memberAction:nil];
                [_tf_EmailLogin becomeFirstResponder];
            }
            else
            {
                NSLog(@"clickedButtonAtIndex=%d",buttonIndex);
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end






















