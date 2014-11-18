//
//  ACUIRefreshPanel.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 01.07.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIRefreshPanel.h"

#define MARGIN 10

@implementation ACUIRefreshPanel {
    UILabel *_lInfo;
    UIButton *_btnRefresh;
    UIActivityIndicatorView *_actInd;
    id _targetObj;
    SEL _targetAction;
}


- (id)initWithFrame:(CGRect)frame
{
    CGRect b = [[UIScreen mainScreen] bounds];
    frame.size.width = b.size.width;
    frame.size.height = 33;
    
    self = [super initWithFrame:frame];
    if (self) {
        _targetObj = nil;
        _targetAction = nil;
        
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_bg1.png"]];
        bg.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:bg];
        
        
        _lInfo = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, (frame.size.height - 20) / 2, 240, 20)];

        _lInfo.textColor = [UIColor whiteColor];
        _lInfo.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
        [_lInfo setShadowColor:[UIColor colorWithRed:0.643 green:0.361 blue:0.090 alpha:1.000]];
        _lInfo.shadowOffset = CGSizeMake(0, -1);
        [self addSubview:_lInfo];
        
        _btnRefresh = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 28 - MARGIN, (frame.size.height - 28) / 2, 28, 28)];
        [_btnRefresh setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
        [_btnRefresh addTarget:self action:@selector(refreshButtonTouched:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_btnRefresh];
        
        
        
        _actInd = [[UIActivityIndicatorView alloc] init];
        [_actInd setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        _actInd.frame = CGRectMake(_btnRefresh.frame.origin.x + ((_btnRefresh.frame.size.width-_actInd.frame.size.width)/2), _btnRefresh.frame.origin.y + ((_btnRefresh.frame.size.height-_actInd.frame.size.height)/2), _actInd.frame.size.width, _actInd.frame.size.height);
        
        [self addSubview:_actInd];
        
        self.refreshBtnHidden = NO;
        self.date = nil;
        
        
        
    }
    return self;
}

- (NSDate *)date {
    return nil;
}

- (void)setDate:(NSDate *)date {
    if ( date == nil ) {
      _lInfo.text = @"";
    } else {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        _lInfo.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Dane z dnia", nil), [dateFormatter stringFromDate:date]];
    }
}

- (BOOL)refreshBtnHidden {
    return _btnRefresh.hidden;
}

- (void)setRefreshBtnHidden:(BOOL)refreshBtnHidden {
    if ( refreshBtnHidden ) {
        _btnRefresh.hidden = YES;
        _actInd.hidden = NO;
        [_actInd startAnimating];
    } else {
        _btnRefresh.hidden = NO;
        _actInd.hidden = YES;
        [_actInd stopAnimating];
    }
}

-(void) btnRefreshAddTarget:(id)obj action:(SEL)Action {
    if ( obj != nil && Action != nil ) {
        _targetObj = obj;
        _targetAction = Action;
    } else {
        _targetAction = nil;
        _targetObj = nil;
    }
}

-(void)refreshButtonTouched:(id)sender {
    self.refreshBtnHidden = YES;
    
    if ( _targetObj != nil && _targetAction != nil ) {
        [_targetObj performSelectorOnMainThread:_targetAction withObject:self waitUntilDone:NO];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
