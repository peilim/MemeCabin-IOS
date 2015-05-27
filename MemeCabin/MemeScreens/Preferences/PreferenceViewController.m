//
//  PreferenceViewController.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 31/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "PreferenceViewController.h"
#import "FavoriteViewController.h"
#import "HomeScreenViewController.h"
#import "AppDelegate.h"

@interface PreferenceViewController ()

@end

@implementation PreferenceViewController

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
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTextFieldImage) name:UITextFieldTextDidChangeNotification object:_myTextField];
    
    //MemeEveryOne On/Off Notification
    if ([UIAppDelegate isEnabled:MEME_FOR_EVERYONE_BADGE])
        [_memeEveryoneOnOffButton setSelected:YES];
    else
        [_memeEveryoneOnOffButton setSelected:NO];
    
    //Motivational On/Off Notification
    if ([UIAppDelegate isEnabled:MOTIVATIONAL_INSPIRATIONAL_BADGE])
        [_motivationOnOffButton setSelected:YES];
    else
        [_motivationOnOffButton setSelected:NO];
    
    //RecyMeme On/Off Notification
    if ([UIAppDelegate isEnabled:RACY_MEME_BADGE])
        [_racyMemeOnOffButton setSelected:YES];
    else
        [_racyMemeOnOffButton setSelected:NO];
    
    //SpiffyGifs On/Off Notification
    if ([UIAppDelegate isEnabled:SPIFFY_GIFS_BADGE])
        [_spiffyGifsOnOffButton setSelected:YES];
    else
        [_spiffyGifsOnOffButton setSelected:NO];
    
    // ***** SpiffyGifs Lock/Unlock ******
    if ([[NSUserDefaults standardUserDefaults] boolForKey:WILL_LOCK_RECY_MEME])
        [_racyMemeLockUnlockButton setSelected:YES];
    else
        [_racyMemeLockUnlockButton setSelected:NO];
    
    // Racy ***********
    if ([UIAppDelegate isEnabled:RACY_MEMES])
        [_racyMemeShowHideButton setSelected:YES];
    else
        [_racyMemeShowHideButton setSelected:NO];
    
    // Spiffy ***********
    if ([UIAppDelegate isEnabled:SPIFFY_GIFS])
        [_spiffyShowHideButton setSelected:YES];
    else
        [_spiffyShowHideButton setSelected:NO];
    
    // SDL ***********
    if ([UIAppDelegate isEnabled:SINGLE_DAD_LAUGHING])
        [_sdlShowHideButton setSelected:YES];
    else
        [_sdlShowHideButton setSelected:NO];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_myTextField];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIAppDelegate hideFlurryAd];
    
    [[GoogleAnalyticsCustom getSharedInstance] setCurrentScreenName:@"Preference Screen"];
    
    _changeYourPasswordView.hidden = YES;
    _popupView.hidden = YES;
    [_popupView addSubview:_changeYourPasswordView];
}


#pragma mark - Dismiss popup
- (IBAction)dismissPopup:(UIButton *)sender
{
    _popupView.hidden = YES;
    [self clearTextField];
    _myTextField.text = nil;
    
    [_myTextField resignFirstResponder];
    [_passwordOldTextfield resignFirstResponder];
    [_passwordNewTextfield resignFirstResponder];
    [_passwordRetypeTextfield resignFirstResponder];
}

-(void)clearTextField
{
    _pImage1.hidden = YES;
    _pImage2.hidden = YES;
    _pImage3.hidden = YES;
    _pImage4.hidden = YES;
}

-(void)changeTextColor
{
    _passwordViewLabel4.text = @"Re-Type your 4-digit code";
    _passwordViewLabel4.textColor = [UIColor blueColor];
}

#pragma mark - Textfield delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    //NSLog(@"textFieldDidBeginEditing");
    if (textField == _passwordOldTextfield || textField == _passwordNewTextfield || textField == _passwordRetypeTextfield)
    {
        CGPoint scrollPoint;
        if (IS_IPHONE) {
            if (IS_IPHONE_4INCHES) {
                scrollPoint = CGPointMake(0.0, 69);
            } else {
                scrollPoint = CGPointMake(0.0, 198);
            }
        }
        else {
            scrollPoint = CGPointMake(0.0, 10);
        }
        
        [_myScrollView setContentOffset:scrollPoint animated:YES];
    }
    else
    {
        _myTextField.text = nil;
        [self clearTextField];
        _myTextField.tag = 1;
        
        _passwordViewLabel4.text = @"Type your 4-digit code";
        _passwordViewLabel4.textColor = [UIColor blackColor];
        
        [_passcodePopupView setFrame:CGRectMake(_popupView.frame.size.width/2-_passcodePopupView.frame.size.width/2,
                                                _popupView.frame.size.height/2-_passcodePopupView.frame.size.height/1.37,
                                                _passcodePopupView.frame.size.width, _passcodePopupView.frame.size.height)];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    //NSLog(@"textFieldDidEndEditing");
    if (textField == _passwordOldTextfield || textField == _passwordNewTextfield || textField == _passwordRetypeTextfield)
    {
        [_myScrollView setContentOffset:CGPointZero animated:YES];
    }
    else
    {
        [_passcodePopupView setFrame:CGRectMake(_popupView.frame.size.width/2-_passcodePopupView.frame.size.width/2,
                                                100+4,
                                                _passcodePopupView.frame.size.width, _passcodePopupView.frame.size.height)];
    }
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    NSLog(@"textFieldShouldReturn");
    if (textField == _passwordOldTextfield || textField == _passwordNewTextfield || textField ==_passwordRetypeTextfield)
    {
        [_passwordOldTextfield resignFirstResponder];
        [_passwordNewTextfield resignFirstResponder];
        [_passwordRetypeTextfield resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _myTextField)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        return ([newString stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceCharacterSet]].length<=4);
    }
    else
        return YES;
}


-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    NSLog(@"textFieldShouldClear");
    return YES;
}


-(void)changeTextFieldImage
{
    NSInteger number = [[_myTextField.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceCharacterSet]] length];
    
    _myTextField.text = [_myTextField.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceCharacterSet]];
    
    NSLog(@"TEXT :: %@",_myTextField.text);
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:WILL_LOCK_RECY_MEME])
    {
        if (_myTextField.tag == 1)
        {
            switch (number)
            {
                case 0:
                    [self clearTextField];
                    break;
                case 1:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = YES;
                    _pImage3.hidden = YES;
                    _pImage4.hidden = YES;
                    break;
                case 2:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = YES;
                    _pImage4.hidden = YES;
                    break;
                case 3:
                    
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = NO;
                    _pImage4.hidden = YES;
                    break;
                case 4:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = NO;
                    _pImage4.hidden = NO;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:_myTextField.text forKey:@"password"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    _myTextField.tag = 2;
                    _myTextField.text = nil;
                    [self performSelector:@selector(clearTextField) withObject:nil afterDelay:0.5];
                    [self performSelector:@selector(changeTextColor) withObject:nil afterDelay:0.5];
                    
                    
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            switch (number)
            {
                case 0:
                    [self clearTextField];
                    break;
                case 1:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = YES;
                    _pImage3.hidden = YES;
                    _pImage4.hidden = YES;
                    break;
                case 2:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = YES;
                    _pImage4.hidden = YES;
                    break;
                case 3:
                    
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = NO;
                    _pImage4.hidden = YES;
                    break;
                case 4:
                    _pImage1.hidden = NO;
                    _pImage2.hidden = NO;
                    _pImage3.hidden = NO;
                    _pImage4.hidden = NO;
                    if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"password"] isEqualToString:_myTextField.text])
                    {
                        //_racyMemeLockUnlockButton.tag = 100;
                        //[_racyMemeLockUnlockButton setImage:[UIImage imageNamed:@"switch_unlocked.png"] forState:UIControlStateNormal];
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                        message:@"Password didn't mached."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles: nil];
                        [alert show];
                    }
                    else
                    {
                        //_racyMemeLockUnlockButton.tag = 101;
                        //[_racyMemeLockUnlockButton setImage:[UIImage imageNamed:@"switch_locked.png"] forState:UIControlStateNormal];
                        
                        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:WILL_LOCK_RECY_MEME];
                        //[[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:_myTextField.text forKey:RECY_MEME_LOCK_UNLOCK_PASSWORD];
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WILL_LOCK_RECY_MEME];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [_racyMemeLockUnlockButton setSelected:YES];
                        
                        _popupView.hidden = YES;
                        _passcodePopupView.hidden = YES;
                        
                        
                        [_myTextField resignFirstResponder];
                        
                    }
                    _myTextField.text = nil;
                    _myTextField.tag = 1;
                    [self clearTextField];
                    _passwordViewLabel4.text = @"Type your 4-digit code";
                    _passwordViewLabel4.textColor = [UIColor blackColor];
                    break;
                    
                default:
                    break;
            }
        }
    }
    else
    {
        switch (number)
        {
            case 0:
                [self clearTextField];
                break;
            case 1:
                _pImage1.hidden = NO;
                _pImage2.hidden = YES;
                _pImage3.hidden = YES;
                _pImage4.hidden = YES;
                break;
            case 2:
                _pImage1.hidden = NO;
                _pImage2.hidden = NO;
                _pImage3.hidden = YES;
                _pImage4.hidden = YES;
                break;
            case 3:
                
                _pImage1.hidden = NO;
                _pImage2.hidden = NO;
                _pImage3.hidden = NO;
                _pImage4.hidden = YES;
                break;
            case 4:
                _pImage1.hidden = NO;
                _pImage2.hidden = NO;
                _pImage3.hidden = NO;
                _pImage4.hidden = NO;
                
                if ([_myTextField.text isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:RECY_MEME_LOCK_UNLOCK_PASSWORD]])
                {
                    _popupView.hidden = YES;
                    _passcodePopupView.hidden = YES;
                    [_myTextField resignFirstResponder];
                    
                    //_racyMemeLockUnlockButton.tag = 100;
                    //[_racyMemeLockUnlockButton setImage:[UIImage imageNamed:@"switch_unlocked.png"] forState:UIControlStateNormal];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:WILL_LOCK_RECY_MEME];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [_racyMemeLockUnlockButton setSelected:NO];
                }
                else
                {
                    
                    //_racyMemeLockUnlockButton.tag = 101;
                    //[_racyMemeLockUnlockButton setImage:[UIImage imageNamed:@"switch_locked.png"] forState:UIControlStateNormal];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WILL_LOCK_RECY_MEME];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [_racyMemeLockUnlockButton setSelected:YES];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops! That wasn't quite right."
                                                                    message:@"Please enter the correct password."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles: nil];
                    [alert show];
                }
                
                _myTextField.text = nil;
                [self performSelector:@selector(clearTextField) withObject:nil afterDelay:0.5];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark Button Actions : Badge On/Off

- (IBAction)memeEveryoneOnOff:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"MemeCabin On/Off Button Clicked"];
    
    if ([_memeEveryoneOnOffButton isSelected])
    {
        [_memeEveryoneOnOffButton setSelected:NO];
        [UIAppDelegate enableFeature:MEME_FOR_EVERYONE_BADGE :NO];
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MEME_EVERYONE_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [_memeEveryoneOnOffButton setSelected:YES];
        [UIAppDelegate enableFeature:MEME_FOR_EVERYONE_BADGE :YES];
    }
}
- (IBAction)MotivationOnOff:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Motivation On/Off Button Clicked"];
    if ([_motivationOnOffButton isSelected])
    {
        [_motivationOnOffButton setSelected:NO];
        [UIAppDelegate enableFeature:MOTIVATIONAL_INSPIRATIONAL_BADGE :NO];
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MEME_MOTI_INSP_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [_motivationOnOffButton setSelected:YES];
        [UIAppDelegate enableFeature:MOTIVATIONAL_INSPIRATIONAL_BADGE :YES];
    }
}
- (IBAction)RacyMemeOnOff:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"RacyMeme On/Off Button Clicked"];
    
    if ([_racyMemeOnOffButton isSelected])
    {
        [_racyMemeOnOffButton setSelected:NO];
        [UIAppDelegate enableFeature:RACY_MEME_BADGE :NO];
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MEME_RACY_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [_racyMemeOnOffButton setSelected:YES];
        [UIAppDelegate enableFeature:RACY_MEME_BADGE :YES];
    }
}

- (IBAction)SpiffyGifsOnOff:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"SpiffyGifs On/Off Button Clicked"];
    if ([_spiffyGifsOnOffButton isSelected])
    {
        [_spiffyGifsOnOffButton setSelected:NO];
        [UIAppDelegate enableFeature:SPIFFY_GIFS_BADGE :NO];
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MEME_SPIFFY_GIF_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [_spiffyGifsOnOffButton setSelected:YES];
        [UIAppDelegate enableFeature:SPIFFY_GIFS_BADGE :YES];
    }
}

#pragma mark Button Actions : Icon Show/Hide
- (IBAction)RacyMemeShowHide:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"RacyMeme Show/Hide Button Clicked"];
    
    if ([UIAppDelegate isEnabled:RACY_MEMES])
    {
        [_racyMemeShowHideButton setSelected:NO];
        [UIAppDelegate enableFeature:RACY_MEMES :NO];
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MEME_RACY_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [_racyMemeShowHideButton setSelected:YES];
        [UIAppDelegate enableFeature:RACY_MEMES :YES];
    }
}

- (IBAction)SpiffyShowHide:(UIButton *)sender
{
    if([_spiffyShowHideButton isSelected])
    {
        [_spiffyShowHideButton setSelected:NO];
        [UIAppDelegate enableFeature:SPIFFY_GIFS :NO];
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MEME_SPIFFY_GIF_CURRENT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [_spiffyShowHideButton setSelected:YES];
        [UIAppDelegate enableFeature:SPIFFY_GIFS :YES];
    }
}

- (IBAction)SDLappShowHide:(UIButton *)sender
{
    if([_sdlShowHideButton isSelected])
    {
        [_sdlShowHideButton setSelected:NO];
        [UIAppDelegate enableFeature:SINGLE_DAD_LAUGHING :NO];
    }
    else
    {
        [_sdlShowHideButton setSelected:YES];
        [UIAppDelegate enableFeature:SINGLE_DAD_LAUGHING :YES];
    }
}

#pragma mark Button Actions : Lock/Unlock
- (IBAction)RacyMemeLockUnlock:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"RacyMeme Lock/Unlock Button Clicked"];
    
    if ([_racyMemeLockUnlockButton isSelected])
    {
        _passwordViewLabel1.text = @"Set a passcode to view content in the Racy Memes section.";
        if (IS_IPAD) {
            _passwordViewLabel1.frame = CGRectMake(20, 46, 414, 60);
            _passwordViewLabel1.font = [UIFont systemFontOfSize:20];
        } else {
            _passwordViewLabel1.frame = CGRectMake(8, 21, 256, 51);
            _passwordViewLabel1.font = [UIFont systemFontOfSize:14];
        }
        
        
        _passwordViewLabel2.text = nil;
        _passwordViewLabel3.text = @"Probably a good idea.";
        _passwordViewLabel4.text = @"Type your 4-digit code.";
        
        _changeYourPasswordView.hidden = YES;
        _popupView.hidden = NO;
        _passcodePopupView.hidden = NO;
        [_passcodePopupView setFrame:CGRectMake(_popupView.frame.size.width/2-_passcodePopupView.frame.size.width/2,
                                                _popupView.frame.size.height/2-_passcodePopupView.frame.size.height,
                                                _passcodePopupView.frame.size.width, _passcodePopupView.frame.size.height)];
        [_popupView addSubview:_passcodePopupView];
        [_myTextField becomeFirstResponder];
    }
    else
    {
        if (IS_IPAD) {
            _passwordViewLabel1.frame = CGRectMake(20, 46, 414, 37);
            _passwordViewLabel1.font = [UIFont systemFontOfSize:20];
            _passwordViewLabel2.frame = CGRectMake(20, 77, 414, 41);
            _passwordViewLabel2.font = [UIFont systemFontOfSize:33];
        } else {
            _passwordViewLabel1.frame = CGRectMake(9, 20, 257, 23);
            _passwordViewLabel1.font = [UIFont systemFontOfSize:12];
        }
        
        _passwordViewLabel1.text = @"Type your 4-digit code to permanently unlock";
        _passwordViewLabel2.text = @"RACY MEMES";
        _passwordViewLabel3.text = @"You can lock it again at any time.";
        _passwordViewLabel4.text = @"Type your 4-digit code.";
        
        _changeYourPasswordView.hidden = YES;
        _popupView.hidden = NO;
        _passcodePopupView.hidden = NO;
        [_passcodePopupView setFrame:CGRectMake(_popupView.frame.size.width/2-_passcodePopupView.frame.size.width/2,
                                                _popupView.frame.size.height/2-_passcodePopupView.frame.size.height,
                                                _passcodePopupView.frame.size.width, _passcodePopupView.frame.size.height)];
        [_popupView addSubview:_passcodePopupView];
        [_myTextField becomeFirstResponder];
    }
}

#pragma mark Button Actions : Others
- (IBAction)changePasswordButtonAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"ChangePassword Button Clicked"];
    //NSLog(@"changePasswordButtonAction");
    
    _changeYourPasswordView.hidden = NO;
    _passcodePopupView.hidden = YES;
    _popupView.hidden = NO;
    [_passwordOldTextfield becomeFirstResponder];
}

- (IBAction)changePasswordDone:(UIButton *)sender
{
    //NSLog(@"changePasswordDone");
    NSDictionary *UserInfoDict = [NSDictionary dictionary];
    UserInfoDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CHECK_FOR_USER_INFO];
    
    [_passwordOldTextfield resignFirstResponder];
    [_passwordNewTextfield resignFirstResponder];
    [_passwordRetypeTextfield resignFirstResponder];
    
    if (![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Failed!" message:@"No internet connection!"];
        _passwordOldTextfield.text = nil;
        _passwordNewTextfield.text = nil;
        _passwordRetypeTextfield.text = nil;
        return;
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CHECK_FOR_IS_SKIPPED])
    {
        [UIAppDelegate showAlertWithTitle:@"Warning!" message:@"You need to login to change password!"];
        _passwordOldTextfield.text = nil;
        _passwordNewTextfield.text = nil;
        _passwordRetypeTextfield.text = nil;
        return;
    }
    
    if ([self isFormDataValid])
    {
        NSString *old_password = _passwordOldTextfield.text;
        NSString *new_password = _passwordNewTextfield.text;
        NSString *userId = [UserInfoDict objectForKey:@"userId"];
        
        NSString *urlString = MEME_CHANGE_PASSWORD;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *parameters = @{@"userID":userId,@"old_password": old_password, @"new_password": new_password};
        
        [UIAppDelegate activityShow];
        [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            [UIAppDelegate activityHide];
            //NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            NSError *error = nil;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                NSLog(@"Error serializing %@", error);
            }
            else
            {
                if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
                {
                    _passwordOldTextfield.text = nil;
                    _passwordNewTextfield.text = nil;
                    _passwordRetypeTextfield.text = nil;
                    
                    _changeYourPasswordView.hidden = YES;
                    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Change Password Succeeded"];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Email Sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                else
                {
                    NSString *errorMessage = [JSON objectForKey:@"message"];
                    if (errorMessage.length > 0)
                    {
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

-(BOOL)isFormDataValid{
    
    NSString *errorMessage = nil;
    UITextField *errorField;
    
    if([_passwordOldTextfield.text isEqualToString:@""] || [_passwordNewTextfield.text isEqualToString:@""] || [_passwordRetypeTextfield.text isEqualToString:@""])
    {
        if ([_passwordOldTextfield.text isEqualToString:@""])
        {
            errorMessage = @"Please enter email address.";
            errorField = _passwordOldTextfield;
        }
        else if ([_passwordNewTextfield.text isEqualToString:@""])
        {
            errorMessage = @"Please enter password.";
            errorField = _passwordNewTextfield;
        }
        else if ([_passwordRetypeTextfield.text isEqualToString:@""])
        {
            errorMessage = @"Please verify password.";
            errorField = _passwordRetypeTextfield;
        }
    }
    else
    {
        if (![_passwordNewTextfield.text isEqualToString:_passwordRetypeTextfield.text])
        {
            errorMessage = @"Oops! Your passwords don't match.";
            errorField = _passwordNewTextfield;
        }
    }
    
    if (errorMessage) {
        [UIAppDelegate showAlertWithTitle:errorMessage message:nil];
        [errorField becomeFirstResponder];
        return NO;
    }else{
        return YES;
    }
}

- (IBAction)backButtonAction:(UIButton *)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backToHomeButtonAction:(UIButton *)sender
{
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Home Button Clicked"];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    
    for (UIViewController *controller in [appDelegate.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[HomeScreenViewController class]])
        {
            //[self.navigationController popToViewController:controller animated:YES];
            [appDelegate.navigationController popToViewController:controller animated:NO];
            break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)favoriteButtonAction:(UIButton *)sender
{
}

@end

