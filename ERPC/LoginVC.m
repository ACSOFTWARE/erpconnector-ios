/*
 LoginVC.m
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

#import "LoginVC.h"
#import "SearchVC.h"
#import "BackgroundOperations.h"
#import "RemoteAction.h"
#import "ERPCCommon.h"
#import "AppDelegate.h"
#import "SideMenuVC.h"
#import "MFSideMenu.h"

@interface ACLoginVC ()

@end

@implementation ACLoginVC {
    ACSideMenuVC *sideMenuVC;
    NSTimer *delayTimer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndicator setAccessibilityViewIsModal:UIActivityIndicatorViewStyleWhite];
    sideMenuVC = nil;
    delayTimer = nil;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setActivityIndicator:nil];
    [self setEdLogin:nil];
    [self setEdPassword:nil];
    [self setLogoView:nil];
    [self setLoginPanel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIDeviceOrientationPortrait|UIDeviceOrientationPortraitUpsideDown;
}

- (void)onRemoteLoginResult:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    self.activityIndicator.hidden = YES;
    
    ACRemoteAction *RA = [notif.userInfo valueForKey:@"RA"];
    
    if ( RA
        && RA.result
        && RA.result.status
        && RA.result.status.success ) {
        
        Common.LastLogin = [NSDate date];
        
        [UIView transitionFromView:Common.window.rootViewController.view
                            toView:Common.navigationController.view
                          duration:0.65f
                           options: UIViewAnimationOptionTransitionFlipFromTop /*UIViewAnimationOptionTransitionCrossDissolve*/
         
         
                        completion:^(BOOL finished){
                            
                            self.edPassword.text = @"";
                            
                            Common.window.rootViewController = Common.navigationController;
                            [Common.window makeKeyAndVisible];
                            
                            if ( sideMenuVC == nil ) {
                                sideMenuVC = [[ACSideMenuVC alloc] init];
                                sideMenuVC.tableView.backgroundColor = [UIColor clearColor];
                                sideMenuVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                            };
                            
                            MenuOptions options = MenuButtonEnabled|BackButtonEnabled;
                            
                            [MFSideMenuManager configureWithNavigationController:Common.navigationController
                                                              sideMenuController:sideMenuVC
                                                                        menuSide:MenuLeftHandSide
                                                                         options:options];
                            
                            [sideMenuVC.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
                        }];
    }
        
}

- (IBAction)websiteTouch:(id)sender {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.acsoftware.pl/erpc.html"]]; 
}

- (void)moveToPosition:(float)y {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = self.logoView.frame;
        f.origin.y = y;
        self.logoView.frame = f;
        f = self.loginPanel.frame;
        f.origin.y = self.logoView.frame.origin.y + 60;
        self.loginPanel.frame = f;
    }];
}

- (void)moveToZeroPos:(id)sender {
    [self moveToPosition:90];
}

- (IBAction)startEditEvent:(id)sender {
    if ( delayTimer ) {
        [delayTimer invalidate];
        delayTimer = nil;
    }
    [self moveToPosition:[UIScreen mainScreen].bounds.size.height > 480 ? 40 : 2];
}

- (IBAction)endEditEvent:(id)sender {
    delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(moveToZeroPos:) userInfo:nil repeats:NO];
}

- (void)onConnectionError:(NSNotification *)notif {

    if ( Common.ServerAddress
        && ![Common.ServerAddress isEqualToString:@""] ) {
        
        [Common.OpQueue cancelAllOperations];
        self.activityIndicator.hidden =  YES;
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Brak połączenia z serwerem", nil)
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    };
}

- (void)onVersionError:(NSNotification *)notif {
   
    [Common.OpQueue cancelAllOperations];
    self.activityIndicator.hidden =  YES;
    
        
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Wersja serwera nie jest kompatybilna z tym oprogramowaniem! Skontaktuj się z administratorem serwera.", nil)
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];

}



- (IBAction)touchLoginBtn:(id)sender {
    
    if ( Common.ServerAddress == nil
        || [Common.ServerAddress isEqualToString:@""] ) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Wprowadź adres serwera. (Ustawienia)", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1;
        [alert show];

    } else {
    
        [Common.OpQueue cancelAllOperations];
        self.activityIndicator.hidden = NO;
    
        while(Common.OpQueue.operationCount > 0) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
        };
    
        if ( self.activityIndicator.hidden == NO ) {
          [ACRemoteOperation login:self.edLogin.text withPassword:self.edPassword.text];
        }
        
    };
     
}
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( alertView.tag == 1 ) {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs://"]];
    }
}
*/
@end
