//
//  SFStepper.m
//  Common
//
//  Created by j.lee on 2016/02/03.
//  Copyright (c) 2016年 Sinfo-Inc. All rights reserved.
//

#import "SFStepper.h"

#define ACCEPTABLE_CHARECTERS @"0123456789.+-"

static int kDefaultMaxLength = 11;

@interface SFStepper() <UITextFieldDelegate>

//UIControls
@property (nonatomic, strong)  UITextField *centerTextfield;
@property (nonatomic, strong)  UIButton *downButton;
@property (nonatomic, strong)  UIButton *upButton;

@property (nonatomic, strong) NSTimer *sTimer;		// Press and hold processing of a button
@end

@implementation SFStepper

@dynamic value;

#pragma mark - getter, setter
- (BOOL)isEnabled {
    return super.enabled;
}

- (void)setEnabled:(BOOL)enabled {
    
    super.enabled = enabled;
}

- (NSString *)value {
    
    return _centerTextfield.text;
}

- (void)setValue:(NSString*)value {
    
    _centerTextfield.text = [NSString stringWithFormat:[self formatString], value.doubleValue];
}

#pragma mark - Initialize
-(void)initUIs {
    
    self.centerTextfield = [[UITextField alloc] initWithFrame:CGRectMake(self.frame.size.height,
                                                                         0,
                                                                         self.frame.size.width - (self.frame.size.height*2.f),
                                                                         self.frame.size.height)];
    _centerTextfield.delegate = self;
    _centerTextfield.textAlignment = NSTextAlignmentCenter;
    
    self.downButton = [UIButton buttonWithType:UIButtonTypeCustom];

    _downButton.frame = CGRectMake(0,
                                   0,
                                   self.frame.size.height,
                                   self.frame.size.height);
    
    [_downButton setTitle:@"-" forState:UIControlStateNormal];
    [_downButton addTarget:self action:@selector(downButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _upButton.frame = CGRectMake(_centerTextfield.frame.origin.x + _centerTextfield.frame.size.width,
                                 0,
                                 self.frame.size.height,
                                 self.frame.size.height);
    
    [_upButton setTitle:@"+" forState:UIControlStateNormal];
    [_upButton addTarget:self action:@selector(upButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_centerTextfield];
    [self addSubview:_downButton];
    [self addSubview:_upButton];
    
    //debug code.
    _centerTextfield.backgroundColor = [UIColor yellowColor];
    _downButton.backgroundColor = [UIColor greenColor];
    _upButton.backgroundColor = [UIColor orangeColor];
}

- (void)initValues {
    self.maximumLength = kDefaultMaxLength;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUIs];
        [self initValues];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initUIs];
        [self initValues];        
    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setValue:textField.text];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    //check number
    if (![string isEqualToString:filtered]) {
        return NO;
    }
    
    //display text
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
    
    //check blank
    if (text == nil || [text isEqualToString:@""]) {
        return YES;
    }
    
    //check length
    if (_maximumLength < text.length) {
        return NO;
    }
    
    //check string patten1
    NSRange searchResultPlus = [text rangeOfString:@"+"];
    NSRange searchResultMinus = [text rangeOfString:@"-"];
    if((searchResultPlus.location != NSNotFound && searchResultPlus.location != 0) &&
       (searchResultMinus.location != NSNotFound && searchResultPlus.location != 0)) {
        //If + over string in addition to the top is in display,
        return NO;
    }
    
    //check string patten1
    NSRange searchResultPlusPoint = [text rangeOfString:@"+."];
    NSRange searchResultMinusPoint = [text rangeOfString:@"-."];
    if(searchResultPlusPoint.location != NSNotFound ||searchResultMinusPoint.location != NSNotFound ) {
        return NO;
    }
    
    //multiple sign check
    int dot_count = 0;
    int plus_count = 0;
    int minus_count = 0;
    
    for (int position=0; position < [text length]; position++) {
        unichar ch = [text characterAtIndex:position];
        
        if (ch == '.'){
            dot_count++;
        }
        if (ch == '+') {
            plus_count++;
        }
        if (ch == '-') {
            minus_count++;
        }
        
        if (dot_count > 1
            || plus_count > 1
            || minus_count > 1) {
            
            return NO;
            break;
        }
    }
    
    //Number is also in the middle "+", - if there is a ""
    if (text.length > 1 && ([text hasSuffix:@"-"] || [text hasSuffix:@"+"])) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Action
- (void)downButtonTouched:(UIButton *)sender {
    
    NSDecimalNumber *down_value = [NSDecimalNumber zero];
    
    NSString *default_value = @"0";
    if ([_delegate respondsToSelector:@selector(defaultValueInSFStepper)]) {
        default_value = [_delegate defaultValueInSFStepper];
    }
    if ([_centerTextfield.text isEqualToString:@""]) {
        _centerTextfield.text = default_value;
    }
    
    NSDecimalNumber *origin_value = [NSDecimalNumber decimalNumberWithString:_centerTextfield.text];
    NSDecimalNumber *tick_value = [NSDecimalNumber decimalNumberWithString:[_delegate tickValueInStepper]];
    
    down_value = [origin_value decimalNumberBySubtracting:tick_value];
    
    NSDecimalNumber *maximum_value = [NSDecimalNumber decimalNumberWithString:[_delegate maximumValueInStepper]];
    NSDecimalNumber *minimum_value = [NSDecimalNumber decimalNumberWithString:[_delegate minimumValueInStepper]];
    
    if(down_value.doubleValue > maximum_value.doubleValue) {
        down_value = maximum_value;
    }else if(down_value.doubleValue < minimum_value.doubleValue) {
        down_value = minimum_value;
    }
    
    self.value = down_value.stringValue;
}

- (void)upButtonTouched:(UIButton *)sender {
    
    NSDecimalNumber *down_value = [NSDecimalNumber zero];
    
    NSString *default_value = @"0";
    if ([_delegate respondsToSelector:@selector(defaultValueInSFStepper)]) {
        default_value = [_delegate defaultValueInSFStepper];
    }
    if ([_centerTextfield.text isEqualToString:@""]) {
        _centerTextfield.text = default_value;
    }
    
    NSDecimalNumber *origin_value = [NSDecimalNumber decimalNumberWithString:_centerTextfield.text];
    NSDecimalNumber *tick_value = [NSDecimalNumber decimalNumberWithString:[_delegate tickValueInStepper]];
    
    down_value = [origin_value decimalNumberByAdding:tick_value];
    
    NSDecimalNumber *maximum_value = [NSDecimalNumber decimalNumberWithString:[_delegate maximumValueInStepper]];
    NSDecimalNumber *minimum_value = [NSDecimalNumber decimalNumberWithString:[_delegate minimumValueInStepper]];
    
    if(down_value.doubleValue > maximum_value.doubleValue) {
        down_value = maximum_value;
    }else if(down_value.doubleValue < minimum_value.doubleValue) {
        down_value = minimum_value;
    }
    
    self.value = down_value.stringValue;
}

#pragma mark - helper methods
- (NSString* )formatString {
    NSInteger scale = [_delegate fractionScaleInStepper];
    return  [NSString stringWithFormat:@"%@%ld%@", @"%0.0", (long)scale, @"f"];
}

#if 0

#pragma mark - IBAction
-(IBAction)onTap:(id)sender {
    UIButton* targetB = (UIButton*)sender;
    if (!targetB.enabled) {
        return;
    }
    targetB.enabled = NO;
}

- (IBAction)buttonRepeatCancel:(id)sender {
	if(_sTimer) {
		[_sTimer invalidate];
		self.sTimer = nil;
	}
}

- (IBAction)buttonRepeatePlus:(id)sender {
	[self actionButtonPlus:sender];
	
	if(_sTimer) {
		[_sTimer invalidate];
	}
	self.sTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(actionButtonPlus:) userInfo:sender repeats:YES];
}

- (IBAction)buttonRepeateMinus:(id)sender {
	[self actionButtonMinus:sender];
	
	if(_sTimer) {
		[_sTimer invalidate];
	}
	self.sTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(actionButtonMinus:) userInfo:sender repeats:YES];
}
#endif
@end
