//
//  ACArticleSalesHistory.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 26.01.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIDataVC.h"
@class Article;
@interface ACArticleSalesHistoryVC : ACUIDataVC <ACUIFormDataSource, ACUITableViewDataSource>
-(Article*)article;
- (void)onRemoteDataDone:(NSNotification *)notif;
@end
