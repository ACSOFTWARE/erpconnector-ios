//
//  ACArticleVC.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 14.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACArticleVC.h"
#import "Article.h"
#import "BackgroundOperations.h"
#import "ERPCCommon.h"

@implementation ACArticleVC {
    
    ACUIDataItem *di_shortcut;
    ACUIDataItem *di_name;
    ACUIDataItem *di_group;
    ACUIDataItem *di_pkwiu;
    ACUIDataItem *di_vatrate;
    ACUIDataItem *di_qty;
    ACUIDataItem *di_wprice;
    ACUIDataItem *di_rprice;
    ACUIDataItem *di_sprice;
    ACUIDataItem *di_desc;
    ACUITableView *itv;
    NSFetchedResultsController *_frc;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
        _frc = nil;
        self.refreshPanelVisible = YES;
        self.form.Title = @"Arykuł";
        di_shortcut = [self.form CreateDataItem:@"symbol"];
        di_name = [self.form CreateDataItem:@"nazwa"];
        di_group = [self.form CreateDataItem:@"grupa"];
        di_group.hideIfEmpty = YES;
        di_pkwiu = [self.form CreateDataItem:@"pkwiu"];
        di_pkwiu.hideIfEmpty = YES;
        di_vatrate = [self.form CreateDataItem:@"stawka vat"];
        di_qty = [self.form CreateDataItem:@"łączny stan"];
        di_wprice = [self.form CreateDataItem:@"cena detaliczna"];
        di_wprice.hideIfEmpty = YES;
        di_rprice = [self.form CreateDataItem:@"cena hurtowa"];
        di_rprice.hideIfEmpty = YES;
        di_sprice = [self.form CreateDataItem:@"cena specjalna"];
        di_sprice.hideIfEmpty = YES;
        di_desc = [self.form CreateDataItem:@"opis"];
        di_desc.hideIfEmpty = YES;
        
        di_desc.numberOfLines = 5;
        itv = [self.form CreateTableViewWithMargin:20 headerNibName:@"ACUIArticleTableHeader1" cellNibName:@"ACArticleWHTableViewCell"];
        itv.dataSource = self;
        itv.rowHeight = 18;
    }
    return self;
}

-(void)fetchRemoteDataByShortcut:(NSString*)shortcut RefreshTouch:(BOOL)rtouch {
    
    if ( self.article ) {
        [ACRemoteOperation articleSearch:shortcut mtu:3];
    }
}

-(void)fetchRemoteDataWithRefreshTouch:(BOOL)rtouch {
    [self fetchRemoteDataByShortcut:self.article.shortcut RefreshTouch:rtouch];
}

-(id)fetchRecordByShortcut:(NSString*)shortcut {
    return [Common.DB fetchArticleByShortcut:self.article.shortcut];
}

-(id)fetchData {
    _frc = nil;
    
    Article *article = [Common.DB fetchArticle:self.article];
    if ( article ) {
        _frc = [Common.DB fetchedWarehousesForArticle:self.article];
        [Common.DB performFetch:_frc];
        [itv reloadData];
 
    }
    
    return article;
}

-(NSFetchedResultsController*)frc {
    return _frc;
}

-(void)onDataView {
    
    Article *article = self.record;
    
    if ( article )  {
        
        di_shortcut.data = article.shortcut;
        di_name.data = article.name;
        di_group.data = article.group;
        di_pkwiu.data = article.pkwiu;
        [di_vatrate setDoubleValue:[self.article.vatrate doubleValue] withSuffix:@"%"];
        di_qty.data = [NSString stringWithFormat:@"%.2f %@ / %.2f %@", [Common.DB articleQtyByUserWarehouse:article], article.unit, [article.qty doubleValue], article.unit];
        di_wprice.data = @"";
        di_rprice.data = @"";
        di_sprice.data = @"";
        di_desc.data = article.desc;
        
    } else {
        di_shortcut.data = @"";
        di_name.data = @"";
        di_group.data = @"";
        di_pkwiu.data = @"";
        di_vatrate.data = @"";
        di_qty.data = @"";
        di_wprice.data = @"";
        di_rprice.data = @"";
        di_sprice.data = @"";
        di_desc.data = @"";
    }
}

-(Article*)article {
    return (Article*)self.record;
}

-(NSDate*)getDate {
    return self.article.uptodate;
}

@end
