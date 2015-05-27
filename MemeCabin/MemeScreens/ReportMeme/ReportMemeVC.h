//
//  ReportMemeVC.h
//  MemeCabin
//
//  Created by Himel on 1/2/15.
//  Copyright (c) 2015 appbd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportMemeVC : UIViewController <UITextFieldDelegate, UITextViewDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

- (IBAction)dismissButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *tf_fullName;
@property (weak, nonatomic) IBOutlet UITextField *tf_emailAddress;
@property (weak, nonatomic) IBOutlet UITextView *tv_moreDetails;
@property (weak, nonatomic) IBOutlet UILabel *lbl_moreDetails;

- (IBAction)checkBoxButtonAction:(UIButton *)sender;
- (IBAction)sendButtonAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *checkBoxButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIImageView *reportImageView;
@property (strong, nonatomic) NSString *reportedMemeId;
@property (strong, nonatomic) UIImage *reportedImage;


@end
