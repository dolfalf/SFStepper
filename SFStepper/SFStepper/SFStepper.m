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

@property (nonatomic, strong) NSTimer *sTimer;		// ボタンの押し続ける処理。
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
        //先頭以外に＋ー文字列が表示中の場合、
        return NO;
    }
    
    //check string patten1
    NSRange searchResultPlusPoint = [text rangeOfString:@"+."];
    NSRange searchResultMinusPoint = [text rangeOfString:@"-."];
    if(searchResultPlusPoint.location != NSNotFound ||searchResultMinusPoint.location != NSNotFound ) {
        return NO;
    }
    
    //複数チェック
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
    
    //数字も真ん中に「+」、「-」が存在する場合
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

#pragma mark - Private Method
- (void)actionButtonPlus:(id)sender {
    
	[self desciptionParmeterLog];
	
    NSString* correctedPrice = [self getCorrectedValue:NO];
	double  poweredUnitPrice = _tick;
	//システムデフォルト値
	double  result =  _defaultValue;
	if (![StringUtil isEmptyIgnoreNull:correctedPrice]) {
		
        double  nCorrectedPrice =  correctedPrice.doubleValue;
		result = nCorrectedPrice + poweredUnitPrice;

		if(result   > _maxValue) {
			result = _maxValue;
		} else if(result   < _minValue) {
			result = _minValue;
		}
	}
    

    [self setValueLocal:result];
	
	if ([_target respondsToSelector:_action]) {
		[HomeUtil performAction:_target selector:_action param:self];
	}
}

- (void)actionButtonMinus:(id)sender {
	[self desciptionParmeterLog];
	
	NSString* originalPrice = [self getNormalValue];
    NSString* correctedPrice = [self getCorrectedValue:YES];
	double  nUnitPrice = _tick;
	
	//システムデフォルト値
	double  result =  _defaultValue;
	if (![StringUtil isEmptyIgnoreNull:correctedPrice]) {
		
		double  nOriginPrice = originalPrice.doubleValue;
		double  nCorrectedPrice =  correctedPrice.doubleValue;
		
		result = nOriginPrice - nUnitPrice;
		if (nOriginPrice != nCorrectedPrice) {
			result = nCorrectedPrice ;
		}
		if(result   > _maxValue) {
			result = _maxValue;
		} else if(result   < _minValue) {
			result = _minValue;
		}
	}
    
    [self setValueLocal:result];
	
	if ([_target respondsToSelector:_action]) {
		[HomeUtil performAction:_target selector:_action param:self];
	}
}

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

#pragma mark - display 

- (void) setValueLocal:(double) value {
    
    NSString* strFormatter = [self customStringFormatter];
    [self setValue:[NSString stringWithFormat:strFormatter, value ]];
    
}
// 入力値を設定する
-(void)setValue:(NSString*)txt {
    //NSLog(@"parent setValue : %@", txt);
    if ([StringUtil isEmptyIgnoreNull:txt]) {
        _textFld.text = @"";
        return;
    }
    //textFld.text = [CommonUtil stringFixedPointCommaStyleByNumber:txt fractionDigits:_maxScale roundType:NSNumberFormatterRoundHalfUp allowSign:NO];
    
    NSString* strFormatter = [self customStringFormatter];
    
    _textFld.text = [NSString stringWithFormat:strFormatter, txt.doubleValue ];
}

// コンマ付きの数量を取得する
-(NSString*)getFormattedValue {
    return _textFld.text;
}

// コンマなしの数量を取得する
-(NSString*)getNormalValue {
    return [CommonUtil removeCommaFromNumberString:_textFld.text];
}

// tickで補正された数量を取得する
-(NSString*)getCorrectedValue:(BOOL) bMinus
{
    NSString* originalPrice =  [self getNormalValue];
    
    NSString* resultStr = originalPrice;
    if (![StringUtil isEmptyIgnoreNull:originalPrice]) {

//       NSDecimalNumber* nTickVal = [NSDecimalNumber decimalNumberWithString:tickStr];
//       NSDecimalNumber* nResult = [nCurrentVal decimalNumberByDividingBy:nTickVal];
//        
//        double  nPoweredOriginPrice = originalPrice.doubleValue;
//        double  nMod =  [self calculateReminderVal:originalPrice];
//        double  nResult = nPoweredOriginPrice - (round(nMod));
        

        if(!bMinus && [self checkEqualToMaxValue:originalPrice ]) {
            return originalPrice;
        }
        
        NSString* strFormatter = [NSString stringWithFormat:@"%@%ld%@", @"%.", (long)_maxScale, @"f"];
        NSDecimalNumber* nOriginalPrice = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:strFormatter, originalPrice.doubleValue]];
        
        NSString* modStr =  [self calculateReminderVal:originalPrice withCheck:NO];
        NSDecimalNumber* nMod = [NSDecimalNumber decimalNumberWithString:modStr];
        NSDecimalNumber* nResult2 = [nOriginalPrice decimalNumberBySubtracting:nMod];
        NSDecimalNumber* nResult = nil;
        if (nOriginalPrice.doubleValue < 0  && bMinus ) {
            NSDecimalNumber* nTickStr = [NSDecimalNumber decimalNumberWithString:_tickStr];
            nResult = [nResult2 decimalNumberBySubtracting:nTickStr];
        } else {
            nResult = nResult2;
        }
        
        NSLog(@"getCorrectedValue org[%f] corrected [%f] mod [%f]", nOriginalPrice.doubleValue ,nResult.doubleValue , nMod.doubleValue);

        //resultStr = [NSString stringWithFormat:strFormatter, nResult.doubleValue ];
        resultStr = nResult.stringValue;
    }
    
    return resultStr;
}

- (BOOL) checkEqualToMaxValue:(NSString*) orgPrice
{
    if (_maxValStr.doubleValue > 0) {
        if (orgPrice.doubleValue == _maxValStr.doubleValue ) {
            return YES;
        }
    }
    
    return NO;

}

#pragma mark - custom
// 入力パーツ活性化
-(void)setActive:(BOOL)active {
    if (active) {
        _lbInput.backgroundColor = [UIColor whiteColor];
        _lbInput.hidden = NO;
        _btnTap.userInteractionEnabled = YES;
        _btnPlus.enabled = _btnMinus.enabled = YES;
        _textFld.enabled = YES;
        _textFld.textColor = COLOR_TEXT_NORMAL;
        
    } else {
        _lbInput.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:1.0];
        _lbInput.hidden = NO;
        _btnTap.userInteractionEnabled = NO;
        _btnPlus.enabled = _btnMinus.enabled = NO;
        //初期化
        _textFld.enabled = NO;
        _textFld.textColor = COLOR_TEXT_DISABLE;

    }
}
//活性化可否チェック
-(BOOL)checkActiveStatus
{
    if (_textFld.enabled) {
        return YES;
    }
    return NO;
}

//最小値又は最大値チェック
-(NSString*) checkMinMaxValue:(NSString*) checkItem
{
  return  [self checkMinMaxValue:checkItem withIgnoreActiveStatus:NO];
}
//最小値又は最大値チェック
-(NSString*) checkMinMaxValue:(NSString*) checkItem withIgnoreActiveStatus:(BOOL) bIgnoreActiveStatus
{
    //活性化状態無視チェック
    if (!bIgnoreActiveStatus) {
        
        //現在活性化されてない場合
        if (![self checkActiveStatus]) {
            return @"";
        }
    }
    
    //@"EC0038" {0}は{1}〜{2}の範囲で変更してください。
    NSString* errorMsgStr = [MessageMst messageForKey: @"EC0038" params: checkItem, _minValStr, _maxValStr, nil];
    
    NSString* currentVal = [self getNormalValue];
    //YES扱い
    if ([StringUtil isEmptyIgnoreNull:currentVal]) {
        return @"";
    }
    
    if( [StringUtil isEmptyIgnoreNull:_minValStr]||
        [StringUtil isEmptyIgnoreNull:_maxValStr]) {
        return @"";
    }
    
    NSDecimalNumber* nCurrentVal = [NSDecimalNumber decimalNumberWithString:currentVal];
    NSDecimalNumber* nMinVal = [NSDecimalNumber decimalNumberWithString:_minValStr];
    NSDecimalNumber* nMaxVal = [NSDecimalNumber decimalNumberWithString:_maxValStr];
    NSLog(@"checkMinMaxValue nCurrentVal[%@] , nMinVal[%@]nMaxVal[%@]  ",nCurrentVal , nMinVal, nMaxVal);
    
    NSComparisonResult resultMin = [nCurrentVal compare:nMinVal];
    
    NSComparisonResult resultMax = [nCurrentVal compare:nMaxVal];
    
    if (resultMin == NSOrderedAscending  ||  resultMax == NSOrderedDescending ) {
        
        NSLog(@"nCurrentVal > nMaxVal || nCurrentVal < nMinVal ");
        
    } else {
        return @"";
    }
    

    return errorMsgStr;

}

//呼び値チェック
- (NSString*) checkTickValue:(NSString*) checkItem
{
    //現在活性化されてない場合
    if (![self checkActiveStatus]) {
        return @"";
    }
    
    NSString* originalPrice = [self getNormalValue];
    if ([StringUtil isEmptyIgnoreNull:originalPrice]
        || [StringUtil isEmptyIgnoreNull:_checkTickStr]) {
        return @""; //YES扱い
    }
    
    //@"EU21122" web
    //@"EC0023" {0}は{0}単位で入力してください。
    NSString* errorMsgStr = [MessageMst messageForKey:@"EC0023"   params: checkItem, self.checkTickStr, nil];
    
//    NSDecimalNumber* nCurrentVal = [NSDecimalNumber decimalNumberWithString:currentVal];
//    NSDecimalNumber* nTickVal = [NSDecimalNumber decimalNumberWithString:tickStr];
//    NSDecimalNumber* nResult = [nCurrentVal decimalNumberByDividingBy:nTickVal];
    NSString* resultStr =  [self calculateReminderVal:originalPrice withCheck:YES];
    
    if ([resultStr isEqualToString:@"0.0"]) {
        return @"";
    }

    return errorMsgStr;
}

//cal reminder
- (NSString* ) calculateReminderVal:(NSString*)originalPrice withCheck:(BOOL) bCheck
{
    NSString* tickVal = _tickStr;
    if (bCheck) {
        tickVal = _checkTickStr;
    }
    
    double  nPoweredOriginPrice  = originalPrice.doubleValue;
    
    //NSDecimalNumber* nResult = [nCurrentVal decimalNumberByDividingBy:nTickVal];
    double nResult =  fmod(nPoweredOriginPrice  , tickVal.doubleValue);
    
    NSString* strFormatter = [NSString stringWithFormat:@"%@%ld%@", @"%.", (long)_maxScale, @"f"];
    NSString* resultStr = [NSString stringWithFormat:strFormatter, nResult];

    if (resultStr.doubleValue == 0.0f || fabs(resultStr.doubleValue) == tickVal.doubleValue ) {
        return @"0.0";
    }
    
    return resultStr;
}

//コピー及びテスト不可
- (id)targetForAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:) || action == @selector(copy:)) {
        return nil;
    }
    return [super targetForAction:action withSender:sender];
}




#pragma mark - keyboard
// Call this method somewhere in your view controller setup code.
- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void) removeForKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double duration = [(NSNumber *)[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [(NSNumber *)[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    UIEdgeInsets contentInset = _scrollView.contentInset;
    UIEdgeInsets scrollInset = _scrollView.scrollIndicatorInsets;
    CGFloat offset = 45.0f;
    contentInset.bottom = kbSize.height - offset;
    scrollInset.bottom = kbSize.height - offset;
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:curve
                     animations:^{
                         _scrollView.contentInset = contentInset;
                         _scrollView.scrollIndicatorInsets = scrollInset;
                     }
                     completion:nil];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    double duration = [(NSNumber *)[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    unsigned int curve = [(NSNumber *)[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    
    UIEdgeInsets contentInset = _scrollView.contentInset;
    UIEdgeInsets scrollInset = _scrollView.scrollIndicatorInsets;
    contentInset.bottom = 0;
    scrollInset.bottom = 0;
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:curve
                     animations:^{
                         _scrollView.contentInset = contentInset;
                         _scrollView.scrollIndicatorInsets = scrollInset;
                     }
                     completion:nil];
}

#pragma mark - debug
- (void) desciptionParmeterLog
{
    NSLog(@"\n[tag %ld]\n maxValStr[%@]\n minValStr[%@]\n maxScaleStr[%@]\n tickStr[%@]\n defaultValStr[%@]",
          (long)_textFld.tag , _maxValStr ,_minValStr, _maxScaleStr, _tickStr,_defaultValStr);
}
@end

#pragma mark - PipsPriceInputBox
//PIPS型入力ボック実装
@implementation PipsPriceInputBox
@synthesize isCurrentRangeTypeInput;

//初期化
-(void)setupContents {
 
    [super setupContents];
    self.isCurrentRangeTypeInput = NO; //default
}
// 価格を設定する
-(void)setValue:(NSString*)txt {
    
    NSLog(@"PipsPriceInputBox setValue  param : %@", txt);
    
    if ([StringUtil isEmptyIgnoreNull:txt]) {
        self.textFld.text = @"";
        return;
    }
    //textFld.text = [CommonUtil stringFixedPointCommaStyleByNumber:txt fractionDigits:_maxScale roundType:NSNumberFormatterRoundHalfUp allowSign:NO];
    NSString* tmpTxt = [NSString stringWithFormat:@"%0.01f", txt.doubleValue];
    NSString* tmpTxt2 = tmpTxt;
    if (tmpTxt.doubleValue > 0.0f) {
        tmpTxt2 = [NSString stringWithFormat:@"+%@", tmpTxt];
        
    }
    
    NSLog(@"PipsPriceInputBox setValue  result  : %@", tmpTxt2);
    self.textFld.text = tmpTxt2;
}

// コンマ付きの数量を取得する
-(NSString*)getFormattedValue {
    return self.textFld.text;
}

// コンマなし　且つ　記号（＋）なしの数量を取得する
-(NSString*)getNormalValue {
    NSString* tmpStr =  [super getNormalValue];
    
    NSString* resultStr = [tmpStr stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    return resultStr;
}

//最小値又は最大値チェック
-(NSString*) checkMinMaxValue:(NSString*) checkItem withIgnoreActiveStatus:(BOOL) bIgnoreActiveStatus
{
    if (self.isCurrentRangeTypeInput) {
        //現在がレンジタイプの入力の場合、既存のままにする。
        return [super checkMinMaxValue:checkItem withIgnoreActiveStatus:bIgnoreActiveStatus];
    }
    
    //@"EC0038" {0}は{1}〜{2}の範囲で変更してください。
    //NSString* errorMsgStr = [MessageMst messageForKey: @"EC0038" params: checkItem, minValStr, maxValStr, nil];
    
    NSString* errorMsgCd = @"EC0044";
    NSString* limitVal = self.minValStr;
    if (self.maxValue < 0.0f) {
        errorMsgCd = @"EC0045";
        limitVal = self.maxValStr;
    }
    NSString* errorMsgStr = [MessageMst messageForKey: errorMsgCd params: checkItem, limitVal,  nil];
    
    NSString* currentVal = [self getNormalValue];
    //YES扱い
    if ([StringUtil isEmptyIgnoreNull:currentVal]) {
        return @"";
    }
    
    if( [StringUtil isEmptyIgnoreNull:self.minValStr]||
       [StringUtil isEmptyIgnoreNull:self.maxValStr]) {
        return @"";
    }
    
    NSDecimalNumber* nCurrentVal = [NSDecimalNumber decimalNumberWithString:currentVal];
    NSDecimalNumber* nMinVal = [NSDecimalNumber decimalNumberWithString:self.minValStr];
    NSDecimalNumber* nMaxVal = [NSDecimalNumber decimalNumberWithString:self.maxValStr];
    NSLog(@"checkMinMaxValue nCurrentVal[%@] , nMinVal[%@]nMaxVal[%@]  ",nCurrentVal , nMinVal, nMaxVal);
    
    NSComparisonResult resultMin = [nCurrentVal compare:nMinVal];
    
    NSComparisonResult resultMax = [nCurrentVal compare:nMaxVal];
    
    if (resultMin == NSOrderedAscending  ||  resultMax == NSOrderedDescending ) {
        
        NSLog(@"nCurrentVal > nMaxVal || nCurrentVal < nMinVal ");
        
    } else {
        return @"";
    }
    
    
    return errorMsgStr;
    
}


/**
 * テキストが編集されたとき
 * @param textField イベントが発生したテキストフィールド
 * @param range 文字列が置き換わる範囲(入力された範囲)
 * @param string 置き換わる文字列(入力された文字列)
 * @retval YES 入力を許可する場合
 * @retval NO 許可しない場合
 */
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL bResult =[super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    if (self.isCurrentRangeTypeInput) {
        //現在がレンジタイプの入力の場合、既存のままにする。
        return bResult;
    }
    
    // すでに入力されているテキストを取得
    NSMutableString *text = [textField.text mutableCopy];
    
    // すでに入力されているテキストに今回編集されたテキストをマージ
    [text replaceCharactersInRange:range withString:string];
    
    //空白の場合
    if ([StringUtil isEmptyIgnoreNull:text]) {
        return bResult;
    }
    
    //複数の「.」が存在する場合、
    NSArray *subStringsPoint = [text componentsSeparatedByString:@"."];
    //複数の「+」が存在する場合、
    NSArray *subStringsPlus = [text componentsSeparatedByString:@"+"];
    //複数の「-」が存在する場合、
    NSArray *subStringsMinus = [text componentsSeparatedByString:@"-"];
    
    BOOL bKigoExist = NO;
    if (subStringsPlus.count >= 2 || subStringsMinus.count >= 2) {
        bKigoExist = YES;
    }
    NSInteger limitLength = 7;
    if (subStringsPoint.count == 1) {
        if (bKigoExist) {
            //整数部のみの場合(+,-記号あり)
            limitLength = 6;
        } else {
            //整数部のみの場合
            limitLength = 5;
        }
    }else {
        if (bKigoExist) {
            //(+,-記号あり)
            limitLength = 8;
        }
    }
    //桁数の制限 (整数：５桁＋小数部１桁）
    if (text.length > limitLength) {
        return NO;
    }
    
    return bResult;
}
#endif
@end
