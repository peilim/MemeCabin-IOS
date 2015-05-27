//
//  MemesSwipeView.m
//  MemeCabin
//
//  Created by AAPBD Mac mini on 31/08/2014.
//  Copyright (c) 2014 appbd. All rights reserved.
//

#import "MemesSwipeView.h"
#import "SwipeCell.h"

@interface MemesSwipeView ()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation MemesSwipeView

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
    
    [self loadImages];
    [self setupCollectionView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
}

#pragma  mark UICollectionView methods

-(void)setupCollectionView
{
    [self.collectionView registerClass:[SwipeCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.dataArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier";
    SwipeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSString *imageName = [self.dataArray objectAtIndex:indexPath.row];
    [cell setImageName:imageName];
    [cell updateCell];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.frame.size;
}

#pragma mark Data methods
-(void)loadImages
{
    //NSString *str = [_img description];
    self.dataArray = [_imageArray copy];
}

#pragma mark Button Actions
- (IBAction)favoriteButtonAction:(UIButton *)sender
{
    
}

- (IBAction)shareButtonAction:(UIButton *)sender
{
    
}

- (IBAction)reloadButtonAction:(UIButton *)sender
{
    
}

- (IBAction)thumbButtonAction:(UIButton *)sender
{
    
}

- (IBAction)backToHomeButtonAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)backButtonAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end





















