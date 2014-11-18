//
//  ACUIRefreshPanel.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 01.07.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ACUIRefreshPanel : UIView

@property (weak, nonatomic) NSDate *date;
@property (nonatomic) BOOL refreshBtnHidden;
-(void) btnRefreshAddTarget:(id)obj action:(SEL)Action;
@end
