//
//  ACComDocPreview.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 27.10.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <QuickLook/QuickLook.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ACComDocPreviewVC : QLPreviewController <QLPreviewControllerDataSource, MFMailComposeViewControllerDelegate>

-(void)onGetDocumentDone:(NSString*)shortcut;
-(void)showDocument:(id)record remoteEnabled:(BOOL)re;
@end
