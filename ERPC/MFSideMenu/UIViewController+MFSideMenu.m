//
//  UIViewController+MFSideMenu.m
//
//  Created by Michael Frederick on 3/18/12.
//

#import "UIViewController+MFSideMenu.h"
#import "MFSideMenuManager.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@class ACSideMenuVC;

@interface UIViewController (MFSideMenuPrivate)

- (void) toggleSideMenu:(BOOL)hidden animationDuration:(NSTimeInterval)duration;
@end

@implementation UIViewController (MFSideMenu) 

static char menuStateKey;
static char velocityKey;


- (NSUInteger)supportedInterfaceOrientations {
    return UIDeviceOrientationPortrait|UIDeviceOrientationPortraitUpsideDown;
}

- (void) toggleSideMenuPressed:(id)sender {
    if(self.navigationController.menuState == MFSideMenuStateVisible) {
        [self.navigationController setMenuState:MFSideMenuStateHidden];
    } else {
        [self.navigationController setMenuState:MFSideMenuStateVisible];
    }
}

- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIBarButtonItem *)menuBarButtonItem {

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 45, 35);
    [btn setImage:[UIImage  imageNamed : @"btn_menu.png" ] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(toggleSideMenuPressed:) forControlEvents:UIControlEventTouchDown];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];

}

- (UIBarButtonItem *)backBarButtonItem {

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 45, 35);
    [btn setBackgroundImage:[UIImage  imageNamed : @"btn_bg3.png" ] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchDown];
    //[btn setTitle:@"Wstecz" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:10];

    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void) setupSideMenuBarButtonItem {
    
    if([MFSideMenuManager sharedManager].menuSide == MenuRightHandSide
       && [MFSideMenuManager menuButtonEnabled]) {
        self.navigationItem.rightBarButtonItem = [self menuBarButtonItem];
        return;
    }
    
    if(self.navigationController.menuState == MFSideMenuStateVisible ||
       [[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        if([MFSideMenuManager menuButtonEnabled]) {
            self.navigationItem.leftBarButtonItem = [self menuBarButtonItem];
        }
    } else {
        if([MFSideMenuManager sharedManager].menuSide == MenuLeftHandSide) {
            if([MFSideMenuManager backButtonEnabled]) {
                self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
            }
        }
    }
}

-(UIButton*) addRightBarButtonWithSelector:(SEL)s imageName:(NSString *)iname activeImageName:(NSString*)aimage {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 45, 35);
    [btn setImage:[UIImage  imageNamed : iname ] forState:UIControlStateNormal];
    
    if ( aimage ) {
        [btn setImage:[UIImage  imageNamed : aimage ] forState:UIControlStateSelected];
    }
    
    [btn addTarget:self action:s forControlEvents:UIControlEventTouchDown];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return btn;
}

-(UIButton*) addFavButtonWithSelector:(SEL)s {
    
    return [self addRightBarButtonWithSelector:s imageName:@"btn_fav.png" activeImageName:@"btn_fav_active.png"];
}

-(UIButton*) addAddButtonWithSelector:(SEL)s {
    
    return [self addRightBarButtonWithSelector:s imageName:@"btn_add.png" activeImageName:nil];
}

-(void)removeRightButton {
    self.navigationItem.rightBarButtonItem = nil;
}

-(UIButton*) addDoneButtonWithSelector:(SEL)s {
    
    return [self addRightBarButtonWithSelector:s imageName:@"btn_done.png" activeImageName:nil];
}

- (void)setMenuState:(MFSideMenuState)menuState {
    [self setMenuState:menuState animationDuration:kMenuAnimationDuration];
}

- (void)setMenuState:(MFSideMenuState)menuState animationDuration:(NSTimeInterval)duration {
    if(![self isKindOfClass:[UINavigationController class]]) {
        [self.navigationController setMenuState:menuState animationDuration:duration];
        return;
    }
    
    MFSideMenuState currentState = self.menuState;
    
    objc_setAssociatedObject(self, &menuStateKey, [NSNumber numberWithInt:menuState], OBJC_ASSOCIATION_RETAIN);
    
    switch (currentState) {
        case MFSideMenuStateHidden:
            if (menuState == MFSideMenuStateVisible) {
                [self toggleSideMenu:NO animationDuration:duration];
            }
            break;
        case MFSideMenuStateVisible:
            if (menuState == MFSideMenuStateHidden) {
                [self toggleSideMenu:YES animationDuration:duration];
            }
            break;
        default:
            break;
    }
}

- (MFSideMenuState)menuState {
    if(![self isKindOfClass:[UINavigationController class]]) {
        return self.navigationController.menuState;
    }
    
    return (MFSideMenuState)[objc_getAssociatedObject(self, &menuStateKey) intValue];
}

- (void)setVelocity:(CGFloat)velocity {
    objc_setAssociatedObject(self, &velocityKey, [NSNumber numberWithFloat:velocity], OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)velocity {
    return (CGFloat)[objc_getAssociatedObject(self, &velocityKey) floatValue];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    if ([animationID isEqualToString:@"toggleSideMenu"]) {
        if([self isKindOfClass:[UINavigationController class]]) {
            UINavigationController *controller = (UINavigationController *)self;
            [controller.visibleViewController setupSideMenuBarButtonItem];
            
            // disable user interaction on the current view controller is the menu is visible
            controller.visibleViewController.view.userInteractionEnabled = (self.menuState == MFSideMenuStateHidden);
        }
    }
}

@end


@implementation UIViewController (MFSideMenuPrivate)

- (CGFloat) xAdjustedForInterfaceOrientation:(CGPoint)point {
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return ABS(point.x);
    } else {
        return ABS(point.y);
    }
}

- (void) toggleSideMenu:(BOOL)hidden animationDuration:(NSTimeInterval)duration {
    if(![self isKindOfClass:[UINavigationController class]]) return;
    
    CGFloat x = [self xAdjustedForInterfaceOrientation:self.view.frame.origin];
    CGFloat navigationControllerXPosition = [MFSideMenuManager menuVisibleNavigationControllerXPosition];
    CGFloat animationPositionDelta = (hidden) ? x : (navigationControllerXPosition  - x);
    
    if(ABS(self.velocity) > 1.0) {
        // try to continue the animation at the speed the user was swiping
        duration = animationPositionDelta / ABS(self.velocity);
    } else {
        // no swipe was used, user tapped the bar button item
        CGFloat animationDurationPerPixel = kMenuAnimationDuration / navigationControllerXPosition;
        duration = animationDurationPerPixel * animationPositionDelta;
    }
    
    if(duration > kMenuAnimationMaxDuration) duration = kMenuAnimationMaxDuration;
    
    [UIView beginAnimations:@"toggleSideMenu" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationDuration:duration];
    
    CGRect frame = self.view.frame;
    frame.origin = CGPointZero;
    if (!hidden) {
        switch (self.interfaceOrientation) 
        {
            case UIInterfaceOrientationPortraitUpsideDown:
                frame.origin.x = -1*navigationControllerXPosition;
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                frame.origin.y = -1*navigationControllerXPosition;
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                frame.origin.y = navigationControllerXPosition;
                break;
                
            default:
                frame.origin.x = navigationControllerXPosition;
                break;
        } 
    }
    self.view.frame = frame;
        
    [UIView commitAnimations];
}

@end 
