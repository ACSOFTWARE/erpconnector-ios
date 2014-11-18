/*
 Copyright (C) 2012-2014 AC SOFTWARE SP. Z O.O.
 (p.zygmunt@acsoftware.pl)
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 3
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

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
