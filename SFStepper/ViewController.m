//
//  ViewController.m
//  SFStepper
//
//  Created by lee jaeeun on 2016/02/03.
//  Copyright © 2016年 sinfo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet SFStepper *stepper;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _stepper.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SFStepper delegate
- (NSString *)minimumValueInStepper {
    
    return @"110.000";
}

- (NSString *)maximumValueInStepper {
    return @"200.000";
}

- (NSInteger)fractionScaleInStepper {
    return 3;
}

- (NSString *)tickValueInStepper {
    return @"0.001";
}

- (NSString *)defaultValueInSFStepper {
    return @"150.000";
}

@end
