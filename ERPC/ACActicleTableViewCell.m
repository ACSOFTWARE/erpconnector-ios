//
//  ACActicleTableViewCell.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 14.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACActicleTableViewCell.h"
#import "Article.h"
#import "ERPCCommon.h"

@implementation ACActicleTableViewCell

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
    
    Article *article = (Article*)record;
    
    if ( article )  {
        
        self.lName.text = [article.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.lShortcut.text = [article.shortcut stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        NSString *unit = article.unit.length == 0 ? @"" : [NSString stringWithFormat:@"/%@", article.unit];
        
        self.lTotalQty.text = [NSString stringWithFormat:@"%.2f%@ / %.2f%@",[Common.DB articleQtyByUserWarehouse:article], article.unit, [article.qty doubleValue], article.unit];
        
        self.lNet.text =  [NSString stringWithFormat:@"%.2f %@%@", [article.unitlistpricenet doubleValue], article.unitpurchasecurr, unit];
        
        self.lGross.text = [NSString stringWithFormat:@"%.2f %@%@", [article.unitlistpricegross doubleValue], article.unitpurchasecurr, unit];
        
        /*
        if ( [self isSeleceted:article.shortcut] == NSNotFound  ) {
            article.accessoryType = UITableViewCellAccessoryNone;
        } else {
            srticle.accessoryType = UITableViewCellAccessoryCheckmark;
        }
         */
        
    } else {
        self.lName.text = @"";
        self.lShortcut.text = @"";
        self.lTotalQty.text = @"";
        self.lNet.text = @"";
        self.lGross.text = @"";
        self.accessoryType = UITableViewCellAccessoryNone;
    }

}

-(void)setSelectMode:(BOOL)selectMode {
    [super setSelectMode:selectMode];
    self.vDetail.hidden = selectMode;
}

@end
