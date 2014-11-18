/*
 Copyright (C) 2012-2014 AC SOFTWARE SP. Z O.O.
 (p.zygmunt@acsoftware.pl)
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 3
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

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
