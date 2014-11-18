//
//  ACUIRecord.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 01.07.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ACUIRefreshPanel.h"
#import "ACUIPart.h"

@class ACUIForm;
@class ACUICDocSummary;
@class ACUITableViewCell;
@class Contractor;

@protocol ACUIFormDelegate<NSObject>
@optional
-(void)fieldChanged:(id)field;
@end

@protocol ACUITableViewDataSource<NSObject>
@required
-(NSFetchedResultsController*)frc;
@end

@protocol ACUITableViewDelegate<NSObject>
-(void)recordSelected:(id)record cellSelected:(ACUITableViewCell*)cell;
@optional
-(BOOL)recordIsSelected:(id)record;
-(void)detailSelected:(int)idx record:(id)record;
@end

@interface ACUILabel : UIView

@property (weak, nonatomic)NSString *text;
@property (nonatomic)BOOL dataLabel;
- (id)initWithFrame:(CGRect)frame andForm:(ACUIForm *)form;
@end

@interface ACUIDataItem : UIView <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate>
- (id)initWithFrame:(CGRect)frame andForm:(ACUIForm*)form;

- (void)setDateTimeValue:(NSDate*)date;
- (void)setDoubleValue:(double)val withSuffix:(NSString*)suffix;
- (void)setMoneyValue:(double)val;
- (void)setListOfValues:(NSArray*)values;
- (void)setDictionaryOfType:(int)type forContractor:(Contractor*)contractor;
- (void)addDetailButtonWithImageName:(NSString*)name addTarget:(id)target touchAction:(SEL)action;
- (void)addErrorButtonWithTarget:(id)target touchAction:(SEL)action;
- (void)addWarningButtonWithTarget:(id)target touchAction:(SEL)action;
- (void)removeDetailButton;
- (void)setDataTouchTarget:(id)target action:(SEL)action;

@property (nonatomic)double doubleValue;
@property (nonatomic)BOOL editing;
@property (nonatomic)BOOL actInidicator;
@property (nonatomic)double minValue;
@property (nonatomic)double maxValue;
@property (nonatomic)BOOL readonly;
@property (weak, nonatomic)NSString *caption;
@property (weak, nonatomic)NSString *data;
@property (weak, nonatomic)NSString *selection;
@property (weak, nonatomic)UIColor *textColor;
@property (nonatomic)BOOL hideIfEmpty;
@property (nonatomic)int numberOfLines;
@end

@interface ACUIMultiDataItem : ACUIDataItem
- (id)initWithFrame:(CGRect)frame andForm:(ACUIForm*)form;
-(void)setData:(NSString*)data Level:(int)level;
-(NSString*)getDataWithLevel:(int)level;
@property (nonatomic, readonly)int count;
@end

@interface ACUITableView: ACUIPart <UITableViewDataSource, UITableViewDelegate>

- (id)initWithFrame:(CGRect)frame headerNibName:(NSString*)hnib cellNibName:(NSString*)cnib form:(ACUIForm*)f;
- (void)reloadData;
- (void)reloadDataWithResize:(BOOL)resize;
- (void)maxHeight;
@property (nonatomic) BOOL selectMode;
@property (nonatomic, assign)   id <ACUITableViewDataSource> dataSource;
@property (nonatomic, assign)   id <ACUITableViewDelegate> delegate;
@property (nonatomic) int rowHeight;
@end


@interface ACUIForm : UIView

-(void)updatePositions;
-(void)CreateRefreshPanel;
-(void)RemoveRefreshPanel;
-(void)CreateTitleFrame:(NSString *)Title;
-(ACUIDataItem *)CreateDataItem:(NSString*)Caption;
-(void)RemoveTitleFrame;
-(ACUIMultiDataItem *)CreateMultiDataItem:(NSString*)Caption;
-(void)AddUIPart:(ACUIPart*)uipart;
-(void)RemoveUIPart:(ACUIPart*)uipart;
-(ACUICDocSummary*)CreateCDocSummary;
-(ACUITableView *)CreateTableViewWithMargin:(float)margin headerNibName:(NSString*)hnib cellNibName:(NSString*)cnib;
-(void)onFocusIn:(id)sender;
-(void)onFieldChange:(id)sender;
-(void)onKeyboardVisible;
-(void)onKeyboardHide;

-(CGRect)getBaseFrame;

@property (readonly, nonatomic)ACUIRefreshPanel *refreshPanel;
@property (weak, nonatomic)NSString *Title;
@property (nonatomic)float LRMargin;
@property (readonly, nonatomic)float scroolFrameHeight;
@property (nonatomic, assign)  id <ACUIFormDelegate> delegate;

@end
