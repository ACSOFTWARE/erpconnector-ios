//
//  ACUIRecord.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 01.07.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIForm.h"
#import "ERPCCommon.h"
#import "ACUICDocSummary.h"
#import "ACUIPart.h"
#import "ACUITableViewCell.h"

@implementation ACUILabel {
    UILabel *_label;
    BOOL _dataLabel;
}

- (id)initWithFrame:(CGRect)frame andForm:(ACUIForm *)form
{
    if ( frame.size.height == 0 ) {
     frame = [form getBaseFrame];
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.925 green:0.933 blue:0.941 alpha:1.000];
        _label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, frame.size.width-10, frame.size.height)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.dataLabel = NO;
        [self addSubview:_label];
    }
    return self;
}

-(NSString*)text {
    return _label.text;
}

-(void)setText:(NSString *)text {
    _label.text = NSLocalizedString(text == nil ? @"" : text, nil);
}

-(BOOL)dataLabel {
    return _dataLabel;
}

-(void)setDataLabel:(BOOL)dataLabel {
    
    if ( dataLabel ) {
        [_label setFont:[UIFont systemFontOfSize:10]];
        [_label setTextAlignment:NSTextAlignmentRight];
    } else {
        [_label setFont:[UIFont systemFontOfSize:13]];
        [_label setTextAlignment:NSTextAlignmentLeft];
    }
    _dataLabel = dataLabel;
}

@end

// ---------------------------------------------------------------
// ---------------------------------------------------------------
// ---------------------------------------------------------------

@implementation ACUIDataItem {
    ACUILabel *_label;
    UILabel *_data;
    ACUIForm *_form;
    UITextField *_textField;
    UITextView *_textView;
    UIStepper *_stepper;
    UIPickerView *_pickerView;
    NSArray *_vlist;
    NSNumber *_numVal;
    NSString *_numValSuffix;
    UIButton *_detailButton;
    UIActivityIndicatorView *_actInd;
    BOOL _readonly;
    
    int _dict_type;
    Contractor *_dict_contractor;
    
    id dt_target;
    SEL dt_action;
}

@synthesize hideIfEmpty;
@synthesize maxValue;
@synthesize minValue;
@synthesize selection;

- (id)initWithFrame:(CGRect)frame andForm:(ACUIForm*)form
{
    frame = [form getBaseFrame];
    frame.size.height = 29;
    self = [super initWithFrame:frame];
    if (self) {
        _dict_type = 0;
        _dict_contractor = nil;
        self.autoresizesSubviews = NO;
        maxValue = 1000000;
        minValue = 0;
        _readonly = YES;
        _form = form;
        _label = [[ACUILabel alloc] initWithFrame:CGRectMake(0, 0, 86, 29) andForm:form];
        _label.dataLabel = YES;
        
        _textField = nil;
        _textView = nil;
        _stepper = nil;
        _pickerView = nil;
        _actInd = nil;
        _detailButton = nil;
        [self addSubview:_label];
        
        _data = [self newLabel];
        
    }
    
    return self;
}

-(void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if ( _form ) {
        [_form updatePositions];
    }
}

-(UIColor*)textColor {
    return _data.textColor;
}

-(void)setTextColor:(UIColor *)textColor {
    _data.textColor = textColor;
}

-(BOOL)readonly {
    return _readonly;
}

-(void)setReadonly:(BOOL)readonly {
    if ( readonly != _readonly ) {
        _readonly = readonly;
        if ( readonly ) {
           [self endEditing:YES];
        }
    }
}

- (void)setListOfValues:(NSArray*)values {
    _vlist = [NSArray arrayWithArray:values];
}

- (void)setDictionaryOfType:(int)type forContractor:(Contractor*)contractor {
    
    _dict_type = type;
    _dict_contractor = contractor;

}

- (void)setDoubleValue:(double)val withSuffix:(NSString*)suffix {
    _numVal = [NSNumber numberWithDouble:val];
    _numValSuffix = suffix ? [NSString stringWithString:suffix] : nil;
    self.data = [NSString stringWithFormat:@"%@ %@", [_numVal moneyToString], suffix];
}

- (void)setMoneyValue:(double)val {
    [self setDoubleValue:val withSuffix:@"zł"];
}

- (void)setDateTimeValue:(NSDate*)date {
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    self.data = [dateFormatter stringFromDate:date];
}

-(ACUIForm*)getForm {
    return _form;
}

-(UILabel*)newLabel {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(91, 0, self.frame.size.width - 91 , 29)];
    l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
   // l.autoresizingMask = UIViewAutoresizingNone
    [self addSubview:l];
    return l;
}


-(NSString*)caption {
    return _label.text;
}

-(void)setCaption:(NSString *)caption {
    _label.text = caption;
}

-(void)setEditing:(BOOL)editing {
    if ( [self editing] != editing ) {
        if ( editing ) {
            [self startEdit];
        } else {
            [self setEditing:NO];
        }
    }
}

-(BOOL)editing {
    return _pickerView || _textField || _textView;
}

-(float)getRaightMargin {
    float rmargin = 0.0;
    
    if ( self.actInidicator ) {
        rmargin = _actInd.frame.size.width+5;
    } else if ( _detailButton ) {
        rmargin = [_form getBaseFrame].size.width - _detailButton.frame.origin.x + 5;
    }
    
    return rmargin;
}

-(void)setData:(NSString *)data {
    _data.text = data;
    
    if ( _pickerView ) return;
    
    [_data setLineBreakMode:NSLineBreakByTruncatingTail];
    

    CGRect frame;
    frame = _data.frame;
    frame.size.width = self.frame.size.width - frame.origin.x - [self getRaightMargin];
    _data.frame = frame;
    
    if ( self.numberOfLines > 1 ) {
       [_data sizeToFit];
    }
    
    if ( _data.frame.size.height < 29 ) {
        frame = _data.frame;
        frame.size.height = 29;
        _data.frame = frame;
    }
    
    frame = self.frame;
    frame.size.height = _data.frame.size.height;
    self.frame = frame;
    
    if ( self.hideIfEmpty ) {
        [super setHidden:[data isEqualToString:@""]];
    }
    
    if ( !_data.hidden ) {
       [_form updatePositions];
    }
    
}

-(NSString*)data {
    return _data.text;
}

-(double)doubleValue {
    return _numVal ? [_numVal doubleValue] : 0.00;
}

-(UILabel*)dataLabel {
    return _data;
}

-(void)setNumberOfLines:(int)numberOfLines {
    _data.numberOfLines = numberOfLines;
    self.data = self.data;
}

-(int)numberOfLines {
    return _data.numberOfLines;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _vlist.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_vlist objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _data.text = [_vlist objectAtIndex:row];
    [_form onFieldChange:self];
}

-(void)setActInidicator:(BOOL)actInidicator {
    if ( actInidicator != [self actInidicator] ) {
        
        CGRect frame;
        
        if ( actInidicator ) {
            self.editing = NO;
            [self removeDetailButton];
            _actInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            _actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [self addSubview:_actInd];
            
            frame = _actInd.frame;
            frame.origin.x = [_form getBaseFrame].size.width -  frame.size.width;
            frame.origin.y = self.frame.size.height / 2 - frame.size.height / 2;
            _actInd.frame = frame;
            
            [_actInd startAnimating];

        } else {
            if ( _actInd ) {
                [_actInd removeFromSuperview];
                _actInd = nil;
            }
        }
        
        self.data = self.data;
    }
}

-(BOOL)actInidicator {
    return _actInd != nil;
}

- (void)addDetailButtonWithImageName:(NSString*)name addTarget:(id)target touchAction:(SEL)action  {
    
    [self removeDetailButton];
    
    if ( _detailButton == nil ) {
        
        self.actInidicator = NO;
        CGRect frame = [_form getBaseFrame];
        
        _detailButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - frame.size.height - 10, 0, frame.size.height, frame.size.height)];
        [self addSubview:_detailButton];
    }

    [_detailButton setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    if ( target != nil
        && action != nil ) {
       [_detailButton addTarget:target action:action forControlEvents:UIControlEventTouchDown]; 
    }
    
}

- (void)addErrorButtonWithTarget:(id)target touchAction:(SEL)action {
    [self addDetailButtonWithImageName:@"error.png" addTarget:target touchAction:action];
}

- (void)addWarningButtonWithTarget:(id)target touchAction:(SEL)action {
    [self addDetailButtonWithImageName:@"warning.png" addTarget:target touchAction:action];
}

- (void)removeDetailButton {
    if ( _detailButton ) {
        [_detailButton removeFromSuperview];
        _detailButton = nil;
    }
}

- (void)setDataTouchTarget:(id)target action:(SEL)action {
    dt_target = target;
    dt_action = action;
}

- (void)startEdit {
    
    if ( self.readonly ) return;
    
    _data.hidden = YES;
    self.actInidicator = NO;
    [self removeDetailButton];
    
    CGRect frame;
    
    if ( _numVal
        && _stepper == nil ) {
        _stepper = [[UIStepper alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _stepper.minimumValue = minValue;
        _stepper.maximumValue = maxValue;
        _stepper.value = _numVal.doubleValue;
        [_stepper addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        _stepper.tintColor = [UIColor grayColor];
        frame = _stepper.frame;
        frame.origin.x = self.frame.size.width - frame.size.width;
        _stepper.frame = frame;
        
        [self addSubview:_stepper];
        
    }
    
    frame = [_form getBaseFrame];
    frame.origin.x = _data.frame.origin.x;
    frame.size.width-=frame.origin.x;
    
    if ( _dict_type ) {
        _vlist = [Common.DB valuesOfDictionaryOfTpe:_dict_type forContractor:_dict_contractor];
    }
    
    if ( _vlist != nil ) {
        
        if ( _pickerView == nil ) {
            frame.origin.y = 0;
            _pickerView = [[UIPickerView alloc] initWithFrame:frame];
            _pickerView.showsSelectionIndicator = YES;
            _pickerView.dataSource = self;
            _pickerView.delegate = self;
            [_pickerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerTapped:)]];
            
            frame = self.frame;
            frame.size.height = _pickerView.frame.size.height;
            self.frame = frame;
            frame = _label.frame;
            frame.size.height = self.frame.size.height;
            _label.frame = frame;
            
            [self addSubview:_pickerView];
            [_form updatePositions];
            
            NSString *_sel = self.selection ? self.selection : self.data;
            
            for(int a=0;a<_vlist.count;a++)
                if ( [[_vlist objectAtIndex:a] isEqualToString:_sel] ) {
                    [_pickerView selectRow:a inComponent:0 animated:NO];
                    break;
                }
            
            
        };
        
    } else if ( self.numberOfLines > 1 ) {
        
        if ( !_textView ) {
            _textView = [[UITextView alloc] initWithFrame:frame];
            _textView .layer.borderWidth = 0.25f;
            _textView .layer.borderColor = [[UIColor grayColor] CGColor];
            _textView.layer.cornerRadius = 5;
            _textView.clipsToBounds = YES;
            _textView.text = self.data;
            _textView.delegate = self;
            
            frame.size.height*=4;
            _textView.frame = frame;
            [self addSubview:_textView];
            
            frame = self.frame;
            frame.size.height = _textView.frame.size.height;
            self.frame = frame;
            
            [_form updatePositions];
        }
        
    } else  {
        
        if ( _textField == nil ) {
            
            if ( _stepper ) {
                frame.size.width-=_stepper.frame.size.width+5;
            }
            _textField = [[UITextField alloc] initWithFrame:frame];
            _textField.text = _numVal ? [_numVal moneyToString] :_data.text;
            _textField.borderStyle = UITextBorderStyleRoundedRect;
            _textField.delegate = self;
            
            if ( _stepper ) {
                _textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            }
            
            _textField.returnKeyType = UIReturnKeyDone;
            [self addSubview:_textField];
        }
    }

}

-(void)pickerTapped:(NSObject*)sender {
   [_form onFocusIn:nil];
}


-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [super touchesBegan:touches withEvent:event];
    
    [_form onFocusIn:self];
    [self startEdit];
    
    if ( !self.editing
        && dt_action
        && dt_target ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [dt_target performSelector:dt_action withObject:self];
#pragma clang diagnostic pop
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *newString = @"";
    
    if ( string.length ) {
         newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if ( _numVal ) {
            NSString *expression = [NSString stringWithFormat:@"^([0-9]+)?(\\%@([0-9]{1,2})?)?$", [[NSLocale currentLocale] objectForKey: NSLocaleDecimalSeparator]];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:nil];
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                                options:0
                                                                  range:NSMakeRange(0, [newString length])];
            if (numberOfMatches == 0)
                return NO;
            
            if ( _stepper ) {
                _stepper.value = [newString doubleValueWithLocalization];
            }
        }
    }

    if ( _numVal ) {
        [self setDoubleValue:[newString doubleValueWithLocalization] withSuffix:_numValSuffix];
    } else {
        self.data = newString;
    }
    
    [_form onFieldChange:self];

    return YES;
}

- (IBAction)valueChanged:(UIStepper *)sender {
    
    _textField.text = [[NSNumber numberWithDouble:sender.value] moneyToString];
    [self setDoubleValue:sender.value withSuffix:_numValSuffix];
    [_form onFieldChange:self];
    
}

- (void)textViewDidChange:(UITextView *)textView {
    self.data = textView.text;
    [_form onFieldChange:self];
}

-(BOOL)endEditing:(BOOL)force {
    
    if ( _pickerView ) {
        [_pickerView removeFromSuperview];

        self.data = _data.text;
        _pickerView = nil;
        CGRect frame = self.frame;
        frame.size.height = [_form getBaseFrame].size.height;
        self.frame = frame;
        frame = _label.frame;
        frame.size.height = self.frame.size.height;
        _label.frame = frame;
        [_form updatePositions];
    }
    
    if ( _textView ) {
        
        [_textView removeFromSuperview];
        _textView = nil;
        CGRect frame = self.frame;
        frame.size.height = [_form getBaseFrame].size.height;
        self.frame = frame;
        _data.hidden = NO;
        self.data = self.data;
    }
    
    if ( _textField != nil ) {
        [_textField removeFromSuperview];
        _textField = nil;
    }
    
    if ( _stepper ) {
        [_stepper removeFromSuperview];
        _stepper = nil;
    }
    
    if ( _data.hidden ) {
       _data.hidden = NO; 
    }
    

    
    return [super endEditing:force];
}


@end

// ---------------------------------------------------------------
// ---------------------------------------------------------------
// ---------------------------------------------------------------

@implementation ACUIMultiDataItem {
    
    NSMutableArray *arr;
    NSMutableArray *larr;
}

- (id)initWithFrame:(CGRect)frame andForm:(ACUIForm*)form
{
    self = [super initWithFrame:frame andForm:form];
    if (self) {
        arr = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
        larr = [NSMutableArray arrayWithObjects:[super dataLabel], nil];
    }
    return self;
}

-(void)setData:(NSString *)data {
    [self setData:data Level:0];
}

-(NSString*)data {
    return [self getDataWithLevel:0];
}

-(int)getLevel:(int)level {
    if ( level < 0 ) {
        level = 0;
    } else if ( level > 3 ) {
        level = 3;
    }
    
    return level;
}

-(int)count {
    int result = 0;
    
    for(int a=0;a<arr.count;a++) {
        NSString *d = [arr objectAtIndex:a];
        if ( d.length > 0 ) result++;
    }
    return result;
}


-(void)setData:(NSString*)data Level:(int)level {

    level = [self getLevel:level];
    [arr replaceObjectAtIndex:level withObject:data];
    
    int c = self.count;
    int a;
    UILabel *l;
    
    if ( larr.count != c ) {
        
        if ( c > 1
            && larr.count > c ) {
            for(a=0;a<(larr.count-c);a++) {
                l = [larr objectAtIndex:a];
                [l removeFromSuperview];
                [larr removeObjectAtIndex:a];
                a--;
            }
        }
        
        if ( c > larr.count ) {
            [larr addObject:[self newLabel]];
        }
    }
    
    c=0;
    
    for(a=0;a<arr.count;a++) {
        NSString *d = [arr objectAtIndex:a];
        if ( d.length > 0 ) {
            l = [larr objectAtIndex:c];
            l.text = d;
            c++;
        };
    }
    
    int y = 0;
    CGRect frame;

    float rmargin = [self getRaightMargin];
    
    for(a=0;a<larr.count;a++) {
        l = [larr objectAtIndex:a];
        if ( l ) {
            frame = l.frame;
            frame.size.width = a>0 ? self.frame.size.width - frame.origin.x : (self.frame.size.width - frame.origin.x - rmargin);
            frame.origin.y = y;
            y += frame.size.height+3;
            l.frame = frame;
        }
    }
    
    frame = self.frame;
    frame.size.height = y;
    self.frame = frame;
    
    if ( self.hideIfEmpty ) {
        [super setHidden:self.count == 0];
    }
    
    [[self getForm] updatePositions];
}

-(NSString*)getDataWithLevel:(int)level {
    
    level = [self getLevel:level];
    return [arr objectAtIndex:level];
}

@end

// ---------------------------------------------------------------
// ---------------------------------------------------------------
// ---------------------------------------------------------------

@implementation ACUITableView {
    UITableView *_tv;
    NSString *_cnib;
    ACUIForm *_form;
}

@synthesize dataSource;
@synthesize delegate;
@synthesize selectMode;

- (id)initWithFrame:(CGRect)frame headerNibName:(NSString*)hnib cellNibName:(NSString*)cnib form:(ACUIForm*)f {
    
    frame = [f getBaseFrame];
    
    self = [super initWithFrame:frame];
    if (self) {
        
        float y = 0;
        _cnib = cnib;
        _form = f;

        if ( hnib ) {
            
            frame = self.frame;
            frame.origin.x = 0;

            UIView *header = [ACUIPart viewByNamedNib:hnib owner:self frame:frame];
            if ( header ) {
                frame = self.frame;
                frame.size.height = header.frame.size.height;
                self.frame = frame;
                [self addSubview:header];
                
                y = header.frame.size.height;
            }
        }
        
        frame = self.frame;
        frame.origin.x = 0;
        frame.origin.y = y;
        
        _tv = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tv.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tv.dataSource = self;
        _tv.delegate = self;
        [self addSubview:_tv];
        
        frame = self.frame;
        frame.size.height = y+_tv.frame.size.height;
        self.frame = frame;
        
    }
    return self;
}

- (void)reloadDataWithResize:(BOOL)resize {
    [_tv reloadData];
   
    if ( resize ) {
        CGRect frame = _tv.frame;
        frame.size.height = [self.frc.fetchedObjects count] * _tv.rowHeight + 10;
        _tv.frame = frame;
        
        frame = self.frame;
        frame.size.height = _tv.frame.origin.y + _tv.frame.size.height;
        self.frame = frame;
        
        [_form updatePositions];
    }

}

- (void)reloadData {
    [self reloadDataWithResize:YES];
}

- (void)maxHeight {
    CGRect frame = self.frame;
    frame.size.height = _form.scroolFrameHeight - frame.origin.y;
    self.frame = frame;
    frame = _tv.frame;
    frame.size.height = self.frame.size.height;
    _tv.frame = frame;
}

-(int)rowHeight {
    return _tv.rowHeight;
}

-(void)setRowHeight:(int)rowHeight {
    _tv.rowHeight = rowHeight;
}

#pragma mark Table Support

- (NSFetchedResultsController*)frc {
    return self.dataSource && self.dataSource.frc ? self.dataSource.frc : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.frc ? [[self.frc sections] count] : 0;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if ( self.frc ) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ACUITableViewCell *cell = (ACUITableViewCell *)[tableView dequeueReusableCellWithIdentifier:_cnib];
    if (cell == nil) {
        
        UIView *c = [ACUIPart viewByNamedNib:_cnib owner:self];
        if ( [c isKindOfClass:[ACUITableViewCell class]] ) {
            cell = (ACUITableViewCell*)c;
        }
    }
    
    if ( cell != nil ) {
        cell.selectMode = selectMode;
        cell.record = [self.frc objectAtIndexPath:indexPath];
        cell.delegate = self.delegate;
        
        if ( selectMode
             && self.delegate != nil ) {
           cell.record_selected = [self.delegate recordIsSelected:cell.record];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( self.delegate != nil ) {
        
        ACUITableViewCell *cell = (ACUITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self.delegate recordSelected:[self.frc objectAtIndexPath:indexPath] cellSelected:cell];

    }
    
}

@end

// ---------------------------------------------------------------
// ---------------------------------------------------------------
// ---------------------------------------------------------------

@implementation ACUIForm {
    UIScrollView *_sv;
    NSMutableArray *_components;
    ACUILabel *_titleLabel;
    float _LRMargin;
}

@synthesize refreshPanel = _refreshPanel;
@synthesize LRMargin = _LRMargin;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _LRMargin = 8;
        _refreshPanel = nil;
        _titleLabel = nil;
        _sv = [[UIScrollView alloc] init];
        [self addSubview:_sv];
        _components = [[NSMutableArray alloc] init];
        
        
    }
    return self;
}

-(CGRect)getBaseFrame {
    
    CGRect frame;
    frame.origin.y = 0;
    frame.origin.x = _LRMargin;
    frame.size.width = [[UIScreen mainScreen] bounds].size.width - _LRMargin*2;
    frame.size.height = 29;

    return frame;
}


-(float)scroolFrameHeight {
    return _sv.frame.size.height;
}

-(void)updatePositions {
    
    CGRect frame;
    float y = 0;
    
    CGRect b = [[UIScreen mainScreen] bounds];
    
    if ( _refreshPanel
         && !_refreshPanel.hidden ) {
        frame = _refreshPanel.frame;
        frame.origin.y = y;
        _refreshPanel.frame = frame;
        y = frame.origin.y+frame.size.height;
    }
    
    _sv.frame = CGRectMake(0, y, b.size.width, b.size.height-y- Common.navigationController.toolbar.frame.size.height-Common.navigationController.navigationBar.frame.origin.y);
  
    UIView *c;
 
    y=0;
    
    for(int a=0;a<_components.count;a++) {
        c = [_components objectAtIndex:a];
        if ( c.hidden == NO ) {
            frame = c.frame;
            frame.origin.y = y+ ([c isKindOfClass:[ACUIPart class]] ? [(ACUIPart*)c topMargin] : 5);
            c.frame = frame;
            y = c.frame.origin.y+c.frame.size.height;
        }
    }
    
    
    _sv.contentSize = CGSizeMake(b.size.width, y+10);
}

-(void)onFocusIn:(id)sender {
    
    UIView *c;
    
    for(int a=0;a<_components.count;a++) {
        c = [_components objectAtIndex:a];
        if ( c != sender ) {
            [c endEditing:YES];
        }
    }
    
}

-(void)AddComponent:(UIView*)component setTop:(BOOL)top {
    if ( [_components indexOfObject:component] == NSNotFound ) {
        if ( top ) {
            [_components insertObject:component atIndex:0];
        } else {
            [_components addObject:component];
        }
        
        [_sv addSubview:component];
        [self updatePositions];
    }
}

-(void)AddComponent:(UIView*)component {
    [self AddComponent:component setTop:NO];
}

-(void)RemoveComponent:(UIView*)component {
    if ( [_components indexOfObject:component] != NSNotFound ) {
        [_components removeObject:component];
        [component removeFromSuperview];
        [self updatePositions];
    }
}

-(void)CreateRefreshPanel {
    if ( _refreshPanel == nil ) {
        
        _refreshPanel = [[ACUIRefreshPanel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self addSubview:_refreshPanel];
        [self updatePositions];
    }
}

-(void)RemoveRefreshPanel {
    if ( _refreshPanel ) {
        [_refreshPanel removeFromSuperview];
        
        _refreshPanel = nil;
        [self updatePositions];
    }
}

-(void)CreateTitleFrame:(NSString *)Title {
    if ( _titleLabel == nil ) {
        _titleLabel = [[ACUILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0) andForm:self];
        _titleLabel.text = Title;
        [self AddComponent:_titleLabel setTop:YES];
    }
}

-(void)RemoveTitleFrame {
    
}

-(void)setTitle:(NSString *)Title {
    if ( _titleLabel ) {
        _titleLabel.text = Title;
    } else {
        [self CreateTitleFrame:Title];
    }
}

-(NSString*)Title {
    return _titleLabel ? _titleLabel.text : nil;
}

-(ACUIDataItem *)CreateDataItem:(NSString*)Caption {
    ACUIDataItem *di = [[ACUIDataItem alloc] initWithFrame:CGRectMake(0, 0, 0, 0) andForm:self];
    di.caption = Caption;
    [self AddComponent:di];
    
    return di;
}

-(ACUIMultiDataItem *)CreateMultiDataItem:(NSString*)Caption {
    
    ACUIMultiDataItem *di = [[ACUIMultiDataItem alloc] initWithFrame:CGRectMake(0, 0, 0, 0) andForm:self];
    di.caption = Caption;
    [self AddComponent:di];
    
    return di;
}

-(void)AddUIPart:(ACUIPart*)uipart {
    CGRect frame = uipart.frame;
    frame.size.width = self.frame.size.width;
    frame.origin.x = 0;
    uipart.frame = frame;
    [self AddComponent:uipart];
}

-(void)RemoveUIPart:(ACUIPart*)uipart {
    [self RemoveComponent:uipart];
}


-(ACUICDocSummary*)CreateCDocSummary {
    ACUICDocSummary *cds = [[ACUICDocSummary alloc] initWithNamedNib:@"ACUICDocSummary" form:self ];
    
    [self AddUIPart:cds];
    return cds;
}

-(ACUITableView *)CreateTableViewWithMargin:(float)margin headerNibName:(NSString*)hnib cellNibName:(NSString*)cnib {

    ACUITableView *tv = [[ACUITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) headerNibName:hnib cellNibName:cnib form:self];
    tv.topMargin = margin;
    [self AddComponent:tv setTop:NO];
    
    return tv;
}

-(void)onFieldChange:(id)sender {
    if ([delegate respondsToSelector:@selector(fieldChanged:)]) {
        [(UIView <ACUIFormDelegate> *)delegate fieldChanged:sender];
    }
}

-(ACUIDataItem *)editedComponent {
    ACUIDataItem *i;
    
    for(int a=0;a<_components.count;a++) {
        i = [_components objectAtIndex:a];
        if ( [i isKindOfClass:[ACUIDataItem class]]
              && i.editing == YES ) {
            return i;
        }
    }
    
    return nil;
}

-(void)onKeyboardVisible {
    
    ACUIDataItem *i = [self editedComponent];
    if ( i ) {
        float ktop = _sv.frame.size.height - Common.keyboardSize.height;
        float ctop = i.frame.origin.y + i.frame.size.height - _sv.contentOffset.y;
        
        if ( ktop < ctop ) {
            CGPoint co = _sv.contentOffset;
            co.y+=(ctop - ktop)+5;
            [_sv setContentOffset:co animated:YES];
        }

    }
    
}

-(void)onKeyboardHide {
    [self updatePositions];
}

@end
