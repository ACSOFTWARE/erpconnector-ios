//
//  ACUIArticleTableViewCell.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 15.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACArticleWHTableViewCell.h"
#import "WareHouse.h"
#import "Article.h"

@implementation ACArticleWHTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setRecord:(id)record {
    [super setRecord:record];
    
    WareHouse *wh= (WareHouse*)record;
    
    if ( wh )  {
        self.lName.text = wh.name;
        self.lQty.text = [NSString stringWithFormat:@"%@ %@", wh.qty, wh.article.unit];
    } else {
        self.lName.text = @"";
        self.lQty.text = @"";

    }
}

@end
