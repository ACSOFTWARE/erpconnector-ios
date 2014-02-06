/*
 InvoicePreviewVC.m
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

#import "InvoicePreviewVC.h"
#import "ERPCCommon.h"
#import "BackgroundOperations.h"
#import "Invoice.h"
#import "MFSideMenu.h"

@interface ACInvoicePreviewVC ()

@end

@implementation ACInvoicePreviewVC {
    NSString *_currentShortcut;
    QLPreviewController* _preview;
}

@synthesize btnFav = _btnFav;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        _currentShortcut = nil;
        _preview = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSideMenuBarButtonItem];
    _btnFav = [self addFavButtonWithSelector:@selector(favTouch:)];
    
    _preview = [[QLPreviewController alloc] init];
    _preview.dataSource = self;
    [self addChildViewController:_preview];

    _preview.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:_preview.view];
    [_preview didMoveToParentViewController:self];
    [self.view bringSubviewToFront:self.bView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIDeviceOrientationPortrait|UIDeviceOrientationPortraitUpsideDown;
}

-(NSString*)invoiceFilePath {
    return [NSTemporaryDirectory() stringByAppendingString:@"invoice.pdf"];
}

-(NSURL*)invoiceURL {
    if ( _currentShortcut ) {
        NSString *pdf_file = [self invoiceFilePath];
        if ( [[NSFileManager defaultManager] fileExistsAtPath:pdf_file] ) {
            return [NSURL fileURLWithPath:pdf_file];
        }
    }
    
    return nil;
}

-(BOOL)invoiceWriteToFile:(Invoice*)i {
    
    _currentShortcut = [NSString stringWithString:_currentShortcut];
    NSString *pdf_file = [self invoiceFilePath];
    [[NSFileManager defaultManager] removeItemAtPath:pdf_file error: NULL];
    
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

-(void)showCustomNavBar:(id)sender {
    Common.navigationController.navigationBar.hidden = YES;
    self.view.hidden = NO;
    CGRect f = self.view.frame;
    f.origin.y = 0;
    self.view.frame = f;
}

-(void)showDocument:(NSString*)shortcut remoteEnabled:(BOOL)re {
    

    
    _currentShortcut = [NSString stringWithString:shortcut];
    CGRect f = self.bView.frame;
    
    if ( ![self invoiceWriteToFile:[Common.DB fetchInvoiceByShortcut:shortcut]] ) {
        if ( re ) {
            
            self.progressView.progress = 0;
            self.progressView.hidden = NO;
            f.origin.x = 0;
            f.size.width = self.view.frame.size.width;
            
            [Common.OpQueue cancelAllOperations];
            [ACRemoteOperation getInvoiceDocumentWithShortcut:shortcut];
            
        } else {
            [self documentErrorWithMessage:@"Brak dokumentu!"];
        }

    } else {
        
       // [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showCustomNavBar:) userInfo:nil repeats:NO];

        
        self.progressView.progress = 0;
        self.progressView.hidden = YES;
        
        self.btnFav.selected = [Common.DB fetchFavoriteItemForContractor:nil orInvoice:[Common.DB fetchInvoiceByShortcut:shortcut]] != nil;
        
        f.size.width = 180;
        f.origin.x = self.view.frame.size.width - f.size.width;
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(62, -1, 195, 46)];
        UIButton *B = [UIButton buttonWithType:UIButtonTypeCustom];
        B.frame = CGRectMake(3, 5, 95, 35);
        [B setTitle:NSLocalizedString(@"Wyślij", nil) forState:UIControlStateNormal];
        [B setBackgroundImage:[UIImage  imageNamed : @"send_bg1.png" ] forState:UIControlStateNormal];
        [B addTarget:self action:@selector(emailTouch:) forControlEvents:UIControlEventTouchDown];
        [v addSubview:B];
        
        B = [UIButton buttonWithType:UIButtonTypeCustom];
        B.frame = CGRectMake(96, 5, 95, 35);
        [B setTitle:NSLocalizedString(@"Drukuj", nil) forState:UIControlStateNormal];
        [B setBackgroundImage:[UIImage  imageNamed : @"print_bg1.png" ] forState:UIControlStateNormal];
        [B addTarget:self action:@selector(printTouch:) forControlEvents:UIControlEventTouchDown];
        [v addSubview:B];
        
        self.navigationController.navigationBar.topItem.titleView = v;
        
    }
    
    self.bView.frame = f;
    [_preview reloadData];

}

- (IBAction)favTouch:(id)sender {

    if ( [self invoiceURL] != nil ) {
        BOOL FAV = self.btnFav.selected;
        
        Invoice *i = [Common.DB fetchInvoiceByShortcut:_currentShortcut];
        if ( i ) {
            if ( FAV ) {
                [Common.DB removeFavoriteItem:nil orInvoice:i];
                FAV = NO;
            } else {
                [Common.DB addToFavorites:nil orInvoice:i];
                FAV = YES;
            }
        }
        
        self.btnFav.selected = FAV;
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)printTouch:(id)sender {
    if ( [self invoiceURL] != nil ) {
        NSString *path = [self invoiceFilePath];
        NSData *dataFromPath = [NSData dataWithContentsOfFile:path];
        
        UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
        
        if(printController && [UIPrintInteractionController canPrintData:dataFromPath]) {
            
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = [path lastPathComponent];
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            printController.printInfo = printInfo;
            printController.showsPageRange = YES;
            printController.printingItem = dataFromPath;
            
            void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
                if (!completed && error) {
                    NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
                }
            };
            
            [printController presentAnimated:YES completionHandler:completionHandler];
            
        }
    }
}

- (IBAction)emailTouch:(id)sender {
    
    if ( [self invoiceURL] != nil ) {
        NSData *file = [[NSData alloc] initWithContentsOfFile:[self invoiceFilePath]];
        
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
            mailController.mailComposeDelegate = self;
            [mailController addAttachmentData:file mimeType:@"application/pdf" fileName:@"Faktura.pdf"];
            
            [self presentModalViewController:mailController animated:YES];
        }
    }

}

-(void)onDocumentPart:(NSString*)shortcut position:(float)pos size:(float)s
{
    if ( _currentShortcut
        && [shortcut isEqualToString:_currentShortcut] ) {
        self.progressView.progress = pos/s;
    }
}

-(void)onGetDocumentDone:(NSString*)shortcut {
    if ( _currentShortcut
        && [shortcut isEqualToString:_currentShortcut] ) {
        [self showDocument:_currentShortcut remoteEnabled:NO];
    }
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 1;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{

}

- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    NSURL *url = [self invoiceURL];
    if ( url
        && _currentShortcut ) {
        [Common.DB updateRecentListWithContractor:nil orInvoice:[Common.DB fetchInvoiceByShortcut:_currentShortcut]];
        return url;
    }

    return nil;
}

-(BOOL)documentVisible {
    return _preview && _preview.currentPreviewItem && [self invoiceURL];
}

- (void)viewDidUnload {
    [self setBView:nil];
    [self setProgressView:nil];
    [self setBtnFav:nil];
    [super viewDidUnload];
}
- (IBAction)backTouch:(id)sender {
    [Common.navigationController popViewControllerAnimated:YES];
}
@end
