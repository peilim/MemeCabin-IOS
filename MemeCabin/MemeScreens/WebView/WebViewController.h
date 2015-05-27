//
//  WebViewController.h
//  MemeCabin
//
//  Created by AAPBD Mac mini on 23/09/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (weak, nonatomic) IBOutlet UIImageView *topBar;
@property (strong, nonatomic) NSString *webURL;
@property (strong, nonatomic) NSString *titleForPage;
@property (assign) NSInteger controllerIdentifier;

- (IBAction)backButtonAction:(UIButton *)sender;

@end
