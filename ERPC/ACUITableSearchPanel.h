//
//  ACUITableSearch.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 14.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//
#import "ACUIPart.h"

@class ACUITableSearchPanel;
@protocol ACUITableSearchPanelDelegate<NSObject>

@required
-(void)searchFieldChanged:(ACUITableSearchPanel*)search_panel withText:(NSString*)text;
@optional
-(void)searchFieldStartEditing:(ACUITableSearchPanel*)search_panel;
@end

@interface ACUITableSearchPanel : ACUIPart
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic) int minLen;
@property (nonatomic) BOOL activityIndicatorVisible;
@property (nonatomic, readonly) BOOL requiredLen;
@property (readonly, weak, nonatomic) NSString *text;
@property (nonatomic, assign)   id <ACUITableSearchPanelDelegate> delegate;
- (IBAction)startEditing:(id)sender;
@end
