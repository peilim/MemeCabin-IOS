//
//  WebViewController.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 23/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "WebViewController.h"
#import "AppDelegate.h"

@interface WebViewController ()

{
}

@end

@implementation WebViewController

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
    
    switch (_controllerIdentifier)
    {
        case 1:
            [_topBar setImage:[UIImage imageNamed:@"topbar_blue.png"]];
            break;
        case 2:
            [_topBar setImage:[UIImage imageNamed:@"topbar_yellow.png"]];
            break;
        case 3:
            [_topBar setImage:[UIImage imageNamed:@"topbar_red.png"]];
            break;
        case 4:
            [_topBar setImage:[UIImage imageNamed:@"topbar_green.png"]];
            break;
        case 5:
            [_topBar setImage:[UIImage imageNamed:@"topbar_purple.png"]];
            break;
            
        default:
            break;
    }
    _titleLabel.text = _titleForPage;
    
    [UIAppDelegate activityShow];
    
    
    NSString *urlAddress = _webURL;
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_myWebView loadRequest:requestObj];
    
}


#pragma mark - WebView Delegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIAppDelegate activityHide];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIAppDelegate activityHide];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self informError:error];
}

- (void)informError:(NSError *)error
{
    NSString* localizedDescription = [error localizedDescription];
    UIAlertView* alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Error", @"Title for error alert.")
                              message:localizedDescription delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK button in error alert.")
                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)backButtonAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
