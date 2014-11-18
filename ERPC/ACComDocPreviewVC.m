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

#import "ACComDocPreviewVC.h"
#import "Invoice.h"
#import "ERPCCommon.h"
#import "BackgroundOperations.h"
#import "MFSideMenu/MFSideMenu.h"

@interface ACComDocPreviewVC () {
    UIView *title_view;
    id _record;
}

@end

@implementation ACComDocPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSideMenuBarButtonItem];
    title_view = [[UIView alloc] initWithFrame:CGRectMake(62, -1, 195, 46)];
    self.dataSource = self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.titleView = title_view;
}

-(NSString*)docFilePath {
    return [NSTemporaryDirectory() stringByAppendingString:@"doc.pdf"];
}

-(NSURL*)docURL {

        NSString *pdf_file = [self docFilePath];
        if ( [[NSFileManager defaultManager] fileExistsAtPath:pdf_file] ) {
            return [NSURL fileURLWithPath:pdf_file];
        }
    
    return nil;
}

-(Invoice*)invoice {
   return [_record isKindOfClass:[Invoice class]] ? (Invoice*)_record : nil;
}

-(BOOL)docWriteToFile {
    
    NSString *pdf_file = [self docFilePath];
    [[NSFileManager defaultManager] removeItemAtPath:pdf_file error: NULL];

    Invoice *i = self.invoice;

    if ( i
        && i.doc
        && [i.doc length] > 0 ) {
        [i.doc writeToFile:pdf_file atomically:NO];
        return YES;
    }
    return NO;
}


-(void)documentError:(NSTimer*)timer {
    if (  Common.navigationController.visibleViewController == self ) {
        if ( [timer.userInfo isKindOfClass:[NSString class]] ) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:timer.userInfo
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [timer invalidate];
        }
        
        
        [Common.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)documentErrorWithMessage:(NSString *)msg {
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(documentError:) userInfo:msg repeats:NO];
}

-(void)showDocument:(id)record remoteEnabled:(BOOL)re {
    
    _record = record;
    
    if ( ![self docWriteToFile] ) {
        if ( re ) {
            [Common.OpQueue cancelAllOperations];
            if ( [record isKindOfClass:[Invoice class]] ) {
               [ACRemoteOperation getInvoiceDocumentWithShortcut:((Invoice*)record).shortcut];
            } else {
                
            }
            
            
        } else {
            [self documentErrorWithMessage:@"Brak dokumentu!"];
        }
    }
    
    [self reloadData];
    
    
}


-(void)onGetDocumentDone:(NSString*)shortcut {
    
    if ( self.invoice && [self.invoice.shortcut isEqualToString:shortcut] ) {
      [self showDocument:_record remoteEnabled:NO];
    }
}


- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [self docURL];
}

@end
