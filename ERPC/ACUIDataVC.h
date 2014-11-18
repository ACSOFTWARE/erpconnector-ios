//
//  ACUIDataVC.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 11.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACUIForm.h"
@class DataExport;
@protocol ACUIFormDataSource<NSObject>

@optional
-(id)fetchRecordByShortcut:(NSString*)shortcut;
-(id)fetchData;
-(void)fetchRemoteDataWithRefreshTouch:(BOOL)rtouch;
-(void)fetchRemoteDataByShortcut:(NSString*)shortcut RefreshTouch:(BOOL)rtouch;
-(void)fetchRemoteDetailDataWithRefreshTouch:(BOOL)rtouch;
-(void)onDataView;
-(NSDate*)getDate;
-(DataExport*)dataexport;
@end

@interface ACUIDataVC : UIViewController

-(void)showRecord:(id)record;

- (void)onConnectionError:(NSNotification *)notif;
-(void)onRecordData:(NSNotification *)notif;
-(void)onRecordDetailData:(NSNotification *)notif;
-(void)onRecordAddDone:(NSNotification *)notif;
-(void)onKeyboardShow:(NSNotification *)notif;
-(void)onKeyboardHide:(NSNotification *)notif;
- (void)showFavBtn;
- (void)removeRightNavBtn;

@property (readonly) ACUIForm *form;
@property (nonatomic) BOOL refreshPanelVisible;
@property (nonatomic) BOOL connectionError;
@property (readonly)id record;
@end
