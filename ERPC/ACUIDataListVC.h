//
//  ACUISearchVC.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 14.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIDataVC.h"
#import "ACUITableSearchPanel.h"

@protocol ACUIDataListItemsSource <NSObject>

@required
-(NSFetchedResultsController*)list_frc;
@optional
-(void)doRemoteSearchWithText:(NSString*)text;
-(void)doOpenRecord:(id)record;
-(void)onRecordChoice:(id)record;
-(void)onItemSelected:(BOOL)selected item:(id)record;
@end

@interface ACUIDataListVC : ACUIDataVC <ACUIFormDataSource, ACUITableViewDelegate, ACUITableViewDataSource, ACUITableSearchPanelDelegate>
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil topPanel:(BOOL)topp;
-(void)initTableWithNamedNib:(NSString*)cellnib;
-(void)initTableWithNamedNib:(NSString*)cellnib andHeaderNib:(NSString*)headernib;
-(void)onRemoteSearchDone:(NSNotification *)notif;
-(void)setBackgroundImageWithName:(NSString*)name;
-(void)loadList;

-(void)onDetailDataItem:(NSNotification *)notif;
-(void)onDetailDataLoadDone:(NSNotification *)notif;

@property (weak, readonly, nonatomic)NSString *searchText;
@property (nonatomic)int minLen;
@property (readonly, nonatomic)BOOL requiredLen;
@property (nonatomic)BOOL selectionMode;
@property (nonatomic)int rowHeight;

@end
