//
//  ACArticleVC.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 14.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIDataVC.h"
@class Article;
@interface ACArticleVC : ACUIDataVC <ACUIFormDataSource, ACUITableViewDataSource>
-(Article*)article;
@end
