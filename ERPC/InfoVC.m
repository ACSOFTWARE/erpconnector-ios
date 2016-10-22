/*
 InfoVC.m
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

#import "InfoVC.h"
#import "ERPCCommon.h"
#import "LoginVC.h"
#import "RemoteAction.h"

@interface ACInfoVC ()

@end

@implementation ACInfoVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.scroolView.contentSize = self.view2.frame.size;
    
    if ( Common.HelloData ) {
        self.lSysName.text = Common.HelloData.erp_name;
        self.lMfrName.text = Common.HelloData.erp_mfr;
        self.lServerVer.text = [NSString stringWithFormat:@"%i.%i", Common.HelloData.ver_major, Common.HelloData.ver_minor];
        self.lDrvMfrName.text = Common.HelloData.drv_mfr;
        self.lDrvVer.text = Common.HelloData.drv_ver;
        self.lAppVer.text = @"2.3";
        self.lIdent.text = Common.UDID;
    }
    self.lLoginName.text = [NSString stringWithString:Common.LoginVC.edLogin.text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIDeviceOrientationPortrait|UIDeviceOrientationPortraitUpsideDown;
}

- (void)viewDidUnload {
    [self setScroolView:nil];
    [self setView2:nil];
    [self setLLoginCaption:nil];
    [self setLSysName:nil];
    [self setLLoginName:nil];
    [self setLSectionUser:nil];
    [self setLLoginCaption:nil];
    [self setLLoginName:nil];
    [self setLSectionSys:nil];
    [self setLSysNameCaption:nil];
    [self setLSysName:nil];
    [self setLMfrCaption:nil];
    [self setLMfrName:nil];
    [self setLSectionServer:nil];
    [self setLServerVerCaption:nil];
    [self setLServerVer:nil];
    [self setLDrvMfrCaption:nil];
    [self setLDrvMfrName:nil];
    [self setLDrvVerCaption:nil];
    [self setLDrvVer:nil];
    [self setLSectionApp:nil];
    [self setLAppVerCaption:nil];
    [self setLAppVer:nil];
    [self setLSectionHelp:nil];
    [self setLIdent:nil];
    [super viewDidUnload];
}
- (IBAction)helpTouch:(id)sender {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:pomoc@acsoftware.pl"]]; 
}
@end
