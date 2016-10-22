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
#import "BackgroundOperations.h"
#import "RemoteAction.h"
#import "ERPCCommon.h"
#import "AppDelegate.h"
#import "KeychainItemWrapper.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface ACLoginVC ()

@end

@implementation ACLoginVC {

    NSTimer *delayTimer1;
    NSTimer *delayTimer2;
    BOOL credentialsEdited;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndicator setAccessibilityViewIsModal:UIActivityIndicatorViewStyleWhite];
    delayTimer1 = nil;
    delayTimer2 = nil;
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *l = [[NSUserDefaults standardUserDefaults] stringForKey:@"login_preference"];
    if ( l ) {
        [self.edLogin setText:l];
    }
    
    
    if ( [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil] ) {
        _btnTIDAuth.hidden = NO;
    } else {
        _btnTIDAuth.hidden = YES;
    }
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if ( self.btnTIDAuth.hidden == NO ) {
        
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"ERPC" accessGroup:nil];
        
        NSString *password = [keychainItem objectForKey:kSecValueData];
        NSString *username = [keychainItem objectForKey:kSecAttrAccount];
        
        if ( password != nil && password.length > 0
            && username != nil && username.length > 0 ) {
            
            [self touchTIDAuthBtn:self];
        }
    }

    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (NSUInteger)supportedInterfaceOrientations {
    return  UIDeviceOrientationPortrait|UIDeviceOrientationPortraitUpsideDown;
}

- (void)onRemoteLoginResult:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    self.activityIndicator.hidden = YES;
    
    ACRemoteAction *RA = [notif.userInfo valueForKey:@"RA"];
    
    if ( RA
        && RA.result
        && RA.result.status
        && RA.result.status.success ) {
        
        [Common onLogin:RA.login_result];

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


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( textField == self.edLogin ) {
        [self.edPassword becomeFirstResponder];
    } else {
        [self touchLoginBtn:nil];
    }
    return NO;
}

- (IBAction)startEditEvent:(id)sender {
    if ( delayTimer1 ) {
        [delayTimer1 invalidate];
        delayTimer1 = nil;
    }
    [self moveToPosition:[UIScreen mainScreen].bounds.size.height > 480 ? 40 : 2];
}

- (IBAction)endEditEvent:(id)sender {
    delayTimer1 = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(moveToZeroPos:) userInfo:nil repeats:NO];
    
    credentialsEdited = YES;
}

- (void)onConnectionError:(NSNotification *)notif {

    [NSTimer scheduledTimerWithTimeInterval:delayTimer2 ? 3 : 0 target:self selector:@selector(delayedConnectionErrorMsg:) userInfo:nil repeats:NO];
}

- (void)delayedConnectionErrorMsg:(id)sender {
    
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
    
    credentialsEdited = NO;
    
    if ( Common.ServerAddress == nil
        || [Common.ServerAddress isEqualToString:@""] ) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Wprowadź adres serwera. (Ustawienia)", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1;
        [alert show];

    } else {
        
        [[NSUserDefaults standardUserDefaults] setValue:self.edLogin.text forKey:@"login_preference"];
        
        Common.Connected = NO;
        Common.Login = self.edLogin.text;
        Common.Password = self.edPassword.text;
        
        [Common BeforeLogin];
        self.activityIndicator.hidden = NO;
    
        while(Common.OpQueue.operationCount > 0) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
        };
    
        if ( self.activityIndicator.hidden == NO ) {
          [ACRemoteOperation login:Common.Login withPassword:Common.Password];
          delayTimer2 = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(localAuth:) userInfo:nil repeats:NO];
        
        }
        
    };
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 1 ) {
        
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"ERPC" accessGroup:nil];
        
        [keychainItem setObject:self.edPassword.text forKey:kSecValueData];
        [keychainItem setObject:self.edLogin.text forKey:kSecAttrAccount];
        
    }

}

- (void)touchIDAuthSuccess {
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"ERPC" accessGroup:nil];
    
    NSString *password = [keychainItem objectForKey:kSecValueData];
    NSString *username = [keychainItem objectForKey:kSecAttrAccount];
    
    
    [self.edLogin setText:username == nil ? @"" : username];
    [self.edPassword setText:password == nil ? @"" : password];
    
    
    if ( self.edLogin.text.length > 0
        && self.edPassword.text.length > 0 ) {
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
        
       [self touchLoginBtn:self];
    }
    
}

- (IBAction)touchTIDAuthBtn:(id)sender {
    
    
    if ( credentialsEdited ) {
        
        credentialsEdited = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Touch ID" message:NSLocalizedString(@"Czy chcesz zapisać te poświadczenia dla autentykacji poprzez TouchID ?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Nie", nil) otherButtonTitles:@"Tak", nil];
        [alert show];
        
    } else {
        
        LAContext *context = [[LAContext alloc] init];
        NSError *error = nil;
        NSString *reason = NSLocalizedString(@"Autentykacja użytkownika", nil);
        
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                    localizedReason:reason
                              reply:^(BOOL success, NSError *error) {
                                  if (success) {
                                      
                                      NSLog(@"Auth was OK");
                                      [self performSelectorOnMainThread:@selector(touchIDAuthSuccess) withObject:nil waitUntilDone:NO];

                                  }
                                  else {
                                      NSLog(@"Error received: %@", error);
                                  }
                              }];
        }
        
    }

    
}

-(void)localAuth:(id)sender {
    
    if ( self.activityIndicator.hidden == NO
        && [Common loginVC_Active]
        && [Common.DB localPasswordPass] ) {
        self.activityIndicator.hidden = YES;
        [Common onLogin:nil];
    }
    
    delayTimer2 = nil;
};


@end
