//
//  ACArticleSalesHistory.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 26.01.2016.
//  Copyright © 2016 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACArticleSalesHistoryVC.h"
#import "Article+CoreDataProperties.h"
#import "BackgroundOperations.h"
#import "ERPCCommon.h"

@interface ACArticleSalesHistoryVC ()

@end

@implementation ACArticleSalesHistoryVC {
    
    ACUIDataItem *di_shortcut;
    ACUIDataItem *di_name;
    ACUITableView *itv;
    NSFetchedResultsController *_frc;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _frc = nil;
        self.refreshPanelVisible = YES;
        self.form.Title = @"Artykuł - Historia Sprzedaży";
        di_shortcut = [self.form CreateDataItem:@"symbol"];
        di_name = [self.form CreateDataItem:@"nazwa"];
       
        itv = [self.form CreateTableViewWithMargin:20 headerNibName:@"ACUIArtSalesHistoryTableHeader" cellNibName:@"ACArtSalesHistoryTableViewCell"];
        itv.dataSource = self;
        itv.rowHeight = 35;
       // [itv maxHeight];
    }
    return self;
}

-(void)fetchRemoteDataByShortcut:(NSString*)shortcut RefreshTouch:(BOOL)rtouch {
    
    if ( self.article ) {
        [ACRemoteOperation articleSalesHistory:self.article.shortcut mtu:3];
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
        _frc = [Common.DB fetchedSalesHistoryForArticle:self.article];
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
        
    } else {
        di_shortcut.data = @"";
        di_name.data = @"";
    }
}

-(Article*)article {
    return (Article*)self.record;
}

-(NSDate*)getDate {
    return self.article.sh_uptodate;
}


- (void)onRemoteDataDone:(NSNotification *)notif {
    
    [Common.DB updateArticleSHdate:self.article];
    
    [self onRecordDetailData:notif];
}
@end
