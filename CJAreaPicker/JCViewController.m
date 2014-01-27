//
//  JCViewController.m
//  CJAreaPicker
//
//  Created by 曹 景成 on 14-1-22.
//  Copyright (c) 2014年 JasonCao. All rights reserved.
//

#import "JCViewController.h"
#import "CJAreaPicker.h"

@interface JCViewController ()<CJAreaPickerDelegate>

@end

@implementation JCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickerButtonAction:(id)sender {
    CJAreaPicker *picker = [[CJAreaPicker alloc]initWithStyle:UITableViewStylePlain];
    picker.delegate = self;
    
    UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:picker];
    
    [self presentViewController:navc animated:YES completion:nil];
    
}

#pragma mark -- CJAreaPickerDelegate

- (void)areaPicker:(CJAreaPicker *)picker didSelectAddress:(NSString *)address {
    
    [self.placeButton setTitle:address forState:UIControlStateNormal];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
