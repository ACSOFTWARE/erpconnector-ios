//
//  ACUITableSearch.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 14.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUITableSearchPanel.h"
@implementation ACUITableSearchPanel {
    UIView *_aiView;
    UIActivityIndicatorView *_ai;
    UIImageView *_searchimg;
    int _minLen;
}

@synthesize delegate;


- (id)initWithNamedNib:(NSString *)nib form:(ACUIForm*)_form {
    self = [super initWithNamedNib:nib form:_form];
    if ( self ) {
        _aiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
        
        _ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_aiView addSubview:_ai];
        _aiView.hidden = YES;
        _ai.frame = CGRectMake(3, 0, 20, 20);
        
        _searchimg = [[ UIImageView  alloc ] initWithImage: [UIImage  imageNamed : @"search_black.png" ]];
        
        [self.searchField setLeftViewMode: UITextFieldViewModeAlways];
        
        self.searchField.layer.cornerRadius = 8;
        //self.searchField.borderStyle = UITextBorderStyleRoundedRect;//To change borders to rounded
        self.searchField.layer.borderWidth = 1.0f; //To hide the square corners
        self.searchField.layer.borderColor = [[UIColor grayColor] CGColor];
        
        self.minLen = 3;
        self.activityIndicatorVisible = NO;
    }
    
    return self;
}

-(NSString*)text {
    return self.searchField.text;
}

-(int)minLen {
    return _minLen;
}

-(BOOL)requiredLen {
    return self.searchField.text.length >= self.minLen;
}

-(void)setMinLen:(int)minLen {
    _minLen = minLen;
    self.searchField.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Min %i znaki", nil),  _minLen];
}

-(void)setActivityIndicatorVisible:(BOOL)activityIndicatorVisible {
    
    if ( activityIndicatorVisible ) {
        _aiView.hidden = NO;
        [self.searchField setLeftView:_aiView];
        [_ai startAnimating];
    } else {
        _aiView.hidden = YES;
        [_ai stopAnimating];
        [self.searchField setLeftView:_searchimg];
    }
}

-(BOOL)activityIndicatorVisible {
    return !_aiView.hidden;
}

- (IBAction)searchEditingChanged:(id)sender {
    
    self.activityIndicatorVisible = self.requiredLen;
    
    if ( self.delegate ) {
        [(NSObject <ACUITableSearchPanelDelegate> *)self.delegate searchFieldChanged:self withText:self.searchField.text];
    }
}



- (IBAction)startEditing:(id)sender {
    
    if ( self.delegate
        && [self.delegate respondsToSelector:@selector(searchFieldStartEditing:)] ) {
        [(NSObject <ACUITableSearchPanelDelegate> *)self.delegate searchFieldStartEditing:self];
    }

    
}
@end
