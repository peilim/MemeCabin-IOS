//
//  ReportMemeVC.m
//  MemeCabin
//
//  Created by Himel on 1/2/15.
//  Copyright (c) 2015 appbd. All rights reserved.
//

#import "ReportMemeVC.h"

@interface ReportMemeVC ()

@end

@implementation ReportMemeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(resignAllKeyboards)];
    
    [self.view addGestureRecognizer:tap];
    
    
    NSLog(@"Reported Meme Id = %@",_reportedMemeId);
    _reportImageView.image = _reportedImage;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dismissButtonAction:(UIButton *)sender
{
    [UIAppDelegate.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)checkBoxButtonAction:(UIButton *)sender
{
    if([self.checkBoxButton isSelected])
    {
        [self.sendButton setEnabled:NO];
        [self.checkBoxButton setSelected:NO];
    }
    else
    {
        [self.sendButton setEnabled:YES];
        [self.checkBoxButton setSelected:YES];
    }
}

- (IBAction)sendButtonAction:(UIButton *)sender
{
    NSLog(@"sendButtonAction");
    
    if(![AppDelegate isNetworkAvailable])
    {
        [UIAppDelegate showAlertWithTitle:@"Connection Error!" message:@"No internet connection."];
        [self emptyTextFields];
        return;
    }
    
    [[GoogleAnalyticsCustom getSharedInstance] clickEventViewController:@"Report Send Button Clicked"];
    
    [self resignAllKeyboards];
    
    if ([self isFormDataValid])
    {
        NSString *email = _tf_emailAddress.text;
        NSString *text = _tv_moreDetails.text;
        NSString *memeId = self.reportedMemeId;
        NSString *name = _tf_fullName.text;
        
        NSString *urlString = MEME_REPORT;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *parameters = @{@"email": email, @"name": name, @"memeid": memeId, @"text":text};
        
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
                 
                 if ([[JSON objectForKey:@"status"] isEqualToString:@"1"])
                 {
                     [UIAppDelegate.navigationController dismissViewControllerAnimated:YES completion:nil];
                     
                     errorMessage = [JSON objectForKey:@"message"];
                     if (errorMessage.length > 0) {
                         UIAlertView *alert = [[UIAlertView alloc]
                                                                  initWithTitle:errorMessage
                                                                  message:nil
                                                                  delegate:nil
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:nil];
                         
                         [alert addButtonWithTitle:@"Okay"];
                         [alert show];
                         return;
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

- (void)resignAllKeyboards
{
    [_tf_fullName     resignFirstResponder];
    [_tf_emailAddress resignFirstResponder];
    [_tv_moreDetails  resignFirstResponder];
}

-(void)emptyTextFields
{
    [_tf_fullName     setText:nil];
    [_tf_emailAddress setText:nil];
    [_tv_moreDetails  setText:nil];
}

#pragma mark - TextView Delegates
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    CGPoint scrollPoint;
    
    if (IS_IPHONE)
    {
        if (IS_IPHONE_4INCHES)
        {
            if (textView == _tv_moreDetails)
            {
                scrollPoint = CGPointMake(0.0, 175);
            }
        }
        else
        {
            if (textView == _tv_moreDetails)
            {
                scrollPoint = CGPointMake(0.0, 160);
            }
        }
        
    }
    else
    {
        if (textView == _tv_moreDetails)
        {
            scrollPoint = CGPointMake(0.0, 220);
        }
    }
    [_myScrollView setContentOffset:scrollPoint animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_myScrollView setContentOffset:CGPointZero animated:YES];
    if (![textView hasText]) {
        self.lbl_moreDetails.hidden = NO;
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    if(![textView hasText]) {
        self.lbl_moreDetails.hidden = NO;
    }
    else{
        self.lbl_moreDetails.hidden = YES;
    }
}

#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    NSLog(@"textFieldDidBeginEditing");
    
    CGPoint scrollPoint;
    
    if (IS_IPHONE)
    {
        if (IS_IPHONE_4INCHES)
        {
            if (textField == _tf_emailAddress || textField == _tf_fullName)
            {
                scrollPoint = CGPointMake(0.0, 175);
            }
        }
        else
        {
            if (textField == _tf_emailAddress || textField == _tf_fullName)
            {
                scrollPoint = CGPointMake(0.0, 160);
            }
        }
        
    }
    else
    {
        if (textField == _tf_emailAddress || textField == _tf_fullName)
        {
            scrollPoint = CGPointMake(0.0, 220);
        }
    }
    [_myScrollView setContentOffset:scrollPoint animated:YES];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [_myScrollView setContentOffset:CGPointZero animated:YES];
    
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    if(textField== _tf_fullName)
    {
        [_tf_emailAddress becomeFirstResponder];
        return YES;
    }
    if(textField== _tf_emailAddress)
    {
        //[self doLogin];
        [_tv_moreDetails resignFirstResponder];
        return YES;
    }
    
    return YES;
}

-(BOOL)isFormDataValid
{
    NSString *errorMessage = nil;
    UITextField *errorField;
    
    if ([_tf_fullName.text isEqualToString:@""])
    {
        errorMessage = @"Please enter full name.";
        errorField = _tf_fullName;
    }
    else if ([_tf_emailAddress.text isEqualToString:@""])
    {
        errorMessage = @"Please enter email address.";
        errorField = _tf_emailAddress;
    }
    else if (![self validateEmail:_tf_emailAddress.text])
    {
        errorMessage = @"Please enter valid email.";
        errorField = _tf_emailAddress;
    }
    else if ([_tv_moreDetails.text isEqualToString:@""])
    {
        errorMessage = @"Please enter details.";
        //errorField = _tf_emailAddress;
    }
    
    
    if (errorMessage) {
        //Previous : Registration Failed!
        [UIAppDelegate showAlertWithTitle:errorMessage message:nil];
        [errorField becomeFirstResponder];
        return NO;
    }else{
        return YES;
    }
    
    
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

@end
