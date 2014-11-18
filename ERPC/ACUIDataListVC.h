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
