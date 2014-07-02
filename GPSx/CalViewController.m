//
//  CalViewController.m
//  GPSx
//
//  Created by HeartNest on 08/06/14.
//  Copyright (c) 2014 asscubo. All rights reserved.
//

#import "CalViewController.h"

@interface CalViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelResult;
@property (weak, nonatomic) IBOutlet UILabel *labelDistance;
@property (weak, nonatomic) IBOutlet UITextField *textFieldULength;
@property (nonatomic)  float targetDistance;//distance from my location to friend's
@end

@implementation CalViewController

#pragma mark - UIViewController LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textFieldULength.delegate = self;
    self.labelDistance.text = [[NSString alloc]initWithFormat:@"%f" ,self.targetDistance];
}

#pragma mark - interactions -

//presse enter
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self calculate];
        return NO;
}
//press calculate
- (IBAction)tapCalculate:(id)sender {
    [self calculate];
}

#pragma mark - calculat

-(void)calculate{
    float unitLength = [self.textFieldULength.text floatValue];
    
    if (self.targetDistance != 0) {
        unsigned num = round(self.targetDistance / unitLength);
        self.labelResult.text = [[NSString alloc]initWithFormat:@"%d units",num];
    }else{
        self.labelResult.text = @"target distance not detected";
    }

    [self.textFieldULength resignFirstResponder];

}

@end
