/*
 AppDelegate.m
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

#import "AppDelegate.h"
#import "LoginVC.h"
#import "ERPCCommon.h"
#import "BackgroundOperations.h"

@implementation ACAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    
    NSString *UDID = [[NSUserDefaults standardUserDefaults] stringForKey:@"udid_preference"];
    if ( UDID == nil || [UDID isEqualToString:@""] ) {
        
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        CFRelease(newUniqueId);
        
        [[NSUserDefaults standardUserDefaults] setValue:uuidString forKey:@"udid_preference"];
    }
    
    Common = [[ACERPCCommon alloc] init];
    [Common defaultsChanged:nil];


    [ACRemoteOperation registerDevice];
    
    Common.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    Common.window.backgroundColor =  [UIColor colorWithHue:0.500 saturation:0.036 brightness:0.110 alpha:1.000];

    Common.window.rootViewController = Common.LoginVC;
    
    [Common.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    Common.LoginVC.activityIndicator.hidden = YES;
    [Common.OpQueue cancelAllOperations];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [Common CheckTimeout];
    
    if ( [Common loginVC_Active] ) {
        [ACRemoteOperation registerDevice];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [Common.OpQueue cancelAllOperations];
}

@end
