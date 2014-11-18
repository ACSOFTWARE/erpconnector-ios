//
//  ACUIArticleListVC.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 14.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACArticleListVC.h"
#import "ACUIDataListVC.h"
#import "ERPCCommon.h"
#import "BackgroundOperations.h"
#import "Order.h"

@implementation ACArticleListVC {
    
}

@synthesize ComDoc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setBackgroundImageWithName:@"articles_bg1.png"];
        [self initTableWithNamedNib:@"ACActicleTableViewCell"];
        self.rowHeight = 49;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSFetchedResultsController*)list_frc {
    
    return [Common.DB fetchedArticlesWithText:[NSString stringWithFormat:@"*%@*", self.searchText]];
}

-(void)doRemoteSearchWithText:(NSString*)text {
    
    if ( self.requiredLen ) {
        [ACRemoteOperation articleSearch:self.searchText mtu:3];
    }
    
}

-(void)doOpenRecord:(id)record {
    if ( record ) {
        [Common showArticle:record];
    }
}

-(void)onRecordChoice:(id)record {
    if ( [ComDoc isKindOfClass:[Order class]] ) {
        [Common.DB addArticle:record ToOrder:ComDoc];
    }
    
}



@end
