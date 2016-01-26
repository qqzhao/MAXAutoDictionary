//
//  ViewController.m
//  MAXAutoDictionary
//
//  Created by golven on 15/11/5.
//  Copyright © 2015年 Max. All rights reserved.
//

#import "ViewController.h"
#import "MAXAutoDictionary.h"

@interface ViewController ()

@end

#pragma mark -
#pragma mark ViewController
//================================================================================================
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    MAXAutoDictionary *dict = [[MAXAutoDictionary alloc] init];
    dict.date = [NSDate date];
    dict.date = [NSDate date];//can work
    
//    dict.string = @"aa";//crash
//    [MAXAutoDictionary setClassString:@"bb"];//why crash?
    
    dict.number = @1;
    dict.view = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
