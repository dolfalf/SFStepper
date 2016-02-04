//
//  SFStepper.h
//  Common
//
//  Created by j.lee on 2016/02/03.
//  Copyright (c) 2016年 Sinfo-Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFStepperDelegate;

IB_DESIGNABLE
@interface SFStepper : UIControl

@property (nonatomic, assign) IBOutlet id<SFStepperDelegate> delegate;

@property (nonatomic, strong) UIImage *downButtonImage;     // use in preference to text
@property (nonatomic, strong) UIImage *upButtonImage;       // use in preference to text
@property (nonatomic, strong) NSString *downButtonTitle;    // default is '-'
@property (nonatomic, strong) NSString *upButtonTitle;      // default is '+'

@property (nonatomic, strong, readonly) NSString *formattedValue;   // display value
@property (nonatomic, strong) IBInspectable NSString *value;                      // no formatted value (comma, +, -)
@property (nonatomic, assign) IBInspectable NSInteger maximumLength;              // default is 11
@property (nonatomic, assign) IBInspectable CGFloat repeatSpeed;                    //long pressed update text
@property (nonatomic, assign) IBInspectable CGFloat fontSize;
@property (nonatomic, assign) IBInspectable NSTextAlignment centerTextAlignment;
@property (nonatomic, strong) IBInspectable UIColor *tintColor;
@end

@protocol SFStepperDelegate <UITextFieldDelegate>

@required
- (NSString *)minimumValueInStepper;
- (NSString *)maximumValueInStepper;
- (NSInteger)fractionScaleInStepper;
- (NSString *)tickValueInStepper;       //step

@optional
- (NSString *)defaultValueInSFStepper;  // default is 0


@end
