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
@property (nonatomic, strong) UITextField *centerTextfield;
@property (nonatomic, strong) UIButton *downButton;
@property (nonatomic, strong) UIButton *upButton;

@property (nonatomic, strong) NSTimer *sTimer;		// Press and hold processing of a button
@end

@implementation SFStepper

@dynamic value;

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect myFrame = self.bounds;
    
    //left button
    CGContextSetStrokeColorWithColor(context,_tintColor.CGColor);
    CGContextSetLineWidth(context, 1.f);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, myFrame.size.height, 0);
    CGContextAddLineToPoint(context, myFrame.size.height, myFrame.size.height);
    CGContextAddLineToPoint(context, 0, myFrame.size.height);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextStrokePath(context);
    
    //center textfield
    CGRectInset(myFrame, 1,1);
    UIRectFrame(myFrame);
    
    //right button
    CGContextMoveToPoint(context, myFrame.size.width - myFrame.size.height, 0);
    CGContextAddLineToPoint(context, myFrame.size.width, 0);
    CGContextAddLineToPoint(context, myFrame.size.width, myFrame.size.height);
    CGContextAddLineToPoint(context, myFrame.size.width - myFrame.size.height, myFrame.size.height);
    CGContextAddLineToPoint(context, myFrame.size.width - myFrame.size.height, 0);
    CGContextStrokePath(context);

#if TARGET_INTERFACE_BUILDER
    //draw text
#if 1
    CGContextSetLineWidth(context, 2.f);
    CGContextMoveToPoint(context, myFrame.size.height/2.f - 8.f, myFrame.size.height/2.f);
    CGContextAddLineToPoint(context, myFrame.size.height/2.f + 8.f, myFrame.size.height/2.f);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, (myFrame.size.width - myFrame.size.height/2.f) - 8.f, myFrame.size.height/2.f);
    CGContextAddLineToPoint(context, (myFrame.size.width - myFrame.size.height/2.f) + 8.f, myFrame.size.height/2.f);
    CGContextStrokePath(context);
    CGContextMoveToPoint(context, (myFrame.size.width - myFrame.size.height/2.f), myFrame.size.height/2.f - 8.f);
    CGContextAddLineToPoint(context, (myFrame.size.width - myFrame.size.height/2.f), myFrame.size.height/2.f + 8.f);
    CGContextStrokePath(context);
#else
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment= NSTextAlignmentCenter;
    
    NSDictionary *stringAttributes = @{NSForegroundColorAttributeName:_tintColor,
                                       NSFontAttributeName:[UIFont systemFontOfSize:_fontSize],
                                       NSParagraphStyleAttributeName:paragraphStyle};
    
    NSAttributedString *minusString = [[NSAttributedString alloc] initWithString:@"-" attributes:stringAttributes];
    [minusString drawInRect:CGRectMake(0,
                                       0,
                                       myFrame.size.height,
                                       myFrame.size.height)];
    
    NSAttributedString *plusString = [[NSAttributedString alloc] initWithString:@"+" attributes:stringAttributes];
    [plusString drawInRect:CGRectMake((myFrame.size.width - myFrame.size.height),
                                      0,
                                      myFrame.size.height,
                                      myFrame.size.height)];
#endif
    
#endif

}

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
    _centerTextfield.font = [UIFont systemFontOfSize:_fontSize];
    
    self.downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _downButton.frame = CGRectMake(0,
                                   0,
                                   self.frame.size.height,
                                   self.frame.size.height);
    
    [_downButton setTitle:@"-" forState:UIControlStateNormal];
    [_downButton setTitleColor:_tintColor forState:UIControlStateNormal];
    _downButton.titleLabel.font = [UIFont systemFontOfSize:_fontSize];
    
    [_downButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchDown];
    [_downButton addTarget:self action:@selector(buttonCanceled:) forControlEvents:UIControlEventTouchCancel];
    [_downButton addTarget:self action:@selector(buttonCanceled:) forControlEvents:UIControlEventTouchDragOutside];
    [_downButton addTarget:self action:@selector(buttonCanceled:) forControlEvents:UIControlEventTouchUpInside];
    
    self.upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _upButton.frame = CGRectMake(_centerTextfield.frame.origin.x + _centerTextfield.frame.size.width,
                                 0,
                                 self.frame.size.height,
                                 self.frame.size.height);
    
    [_upButton setTitle:@"+" forState:UIControlStateNormal];
    [_upButton setTitleColor:_tintColor forState:UIControlStateNormal];
    _upButton.titleLabel.font = [UIFont systemFontOfSize:_fontSize];
    [_upButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchDown];
    [_upButton addTarget:self action:@selector(buttonCanceled:) forControlEvents:UIControlEventTouchCancel];
    [_upButton addTarget:self action:@selector(buttonCanceled:) forControlEvents:UIControlEventTouchDragOutside];
    [_upButton addTarget:self action:@selector(buttonCanceled:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_centerTextfield];
    [self addSubview:_downButton];
    [self addSubview:_upButton];
    
    //debug code.
//    _centerTextfield.backgroundColor = [UIColor yellowColor];
//    _downButton.backgroundColor = [UIColor greenColor];
//    _upButton.backgroundColor = [UIColor orangeColor];
}

- (void)initValues {
    self.maximumLength = kDefaultMaxLength;
    self.repeatSpeed = 0.3f;
    
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
        //initialize is awakeFromNib.
    }
    return self;
}

- (void)awakeFromNib {
    [self initUIs];
    [self initValues];
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

- (void)repeatAction:(NSTimer *)timer {
    
    NSDecimalNumber *tmp_value = [NSDecimalNumber zero];
    
    NSString *default_value = @"0";
    if ([_delegate respondsToSelector:@selector(defaultValueInSFStepper)]) {
        default_value = [_delegate defaultValueInSFStepper];
    }
    if ([_centerTextfield.text isEqualToString:@""]) {
        _centerTextfield.text = default_value;
    }
    
    NSDecimalNumber *origin_value = [NSDecimalNumber decimalNumberWithString:_centerTextfield.text];
    NSDecimalNumber *tick_value = [NSDecimalNumber decimalNumberWithString:[_delegate tickValueInStepper]];
    
    if (timer.userInfo == _downButton) {
        tmp_value = [origin_value decimalNumberBySubtracting:tick_value];
    }else if (timer.userInfo == _upButton) {
        tmp_value = [origin_value decimalNumberByAdding:tick_value];
    }else {
        return;
    }
    
    NSDecimalNumber *maximum_value = [NSDecimalNumber decimalNumberWithString:[_delegate maximumValueInStepper]];
    NSDecimalNumber *minimum_value = [NSDecimalNumber decimalNumberWithString:[_delegate minimumValueInStepper]];
    
    if([tmp_value compare:maximum_value] == NSOrderedDescending) {
        tmp_value = maximum_value;
    }else if([tmp_value compare:minimum_value] == NSOrderedAscending) {
        tmp_value = minimum_value;
    }
    
    self.value = tmp_value.stringValue;
}


#pragma mark - Action
- (void)buttonTouched:(UIButton *)sender {
    
    if (_sTimer) {
        [_sTimer invalidate];
    }
    
    self.sTimer = [NSTimer scheduledTimerWithTimeInterval:_repeatSpeed target:self selector:@selector(repeatAction:) userInfo:sender repeats:YES];
    
    [_sTimer fire];
}

- (void)buttonCanceled:(UIButton *)sender {
    
    if(_sTimer) {
        [_sTimer invalidate];
    }
}

#pragma mark - helper methods
- (NSString* )formatString {
    NSInteger scale = [_delegate fractionScaleInStepper];
    return  [NSString stringWithFormat:@"%@%ld%@", @"%0.0", (long)scale, @"f"];
}

@end
