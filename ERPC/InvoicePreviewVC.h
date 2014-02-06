/*
 InvoicePreviewVC.h
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

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class Invoice;
@interface ACInvoicePreviewVC : UIViewController <QLPreviewControllerDataSource, MFMailComposeViewControllerDelegate>

-(void)showDocument:(NSString*)shortcut remoteEnabled:(BOOL)re;
-(void)onDocumentPart:(NSString*)shortcut position:(float)pos size:(float)s;
-(void)onGetDocumentDone:(NSString*)shortcut;
-(void)documentErrorWithMessage:(NSString *)msg;
-(BOOL)documentVisible;

- (IBAction)favTouch:(id)sender;
- (IBAction)printTouch:(id)sender;
- (IBAction)emailTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *bView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property UIButton *btnFav;
@end