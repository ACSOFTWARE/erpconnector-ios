/*
 InfoVC.h
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

@interface ACInfoVC : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scroolView;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UILabel *lSectionUser;
@property (weak, nonatomic) IBOutlet UILabel *lLoginCaption;
@property (weak, nonatomic) IBOutlet UILabel *lLoginName;
@property (weak, nonatomic) IBOutlet UILabel *lSectionSys;
@property (weak, nonatomic) IBOutlet UILabel *lSysNameCaption;
@property (weak, nonatomic) IBOutlet UILabel *lSysName;
@property (weak, nonatomic) IBOutlet UILabel *lMfrCaption;
@property (weak, nonatomic) IBOutlet UILabel *lMfrName;
@property (weak, nonatomic) IBOutlet UILabel *lSectionServer;
@property (weak, nonatomic) IBOutlet UILabel *lServerVerCaption;
@property (weak, nonatomic) IBOutlet UILabel *lServerVer;
@property (weak, nonatomic) IBOutlet UILabel *lDrvMfrCaption;
@property (weak, nonatomic) IBOutlet UILabel *lDrvMfrName;
@property (weak, nonatomic) IBOutlet UILabel *lDrvVerCaption;
@property (weak, nonatomic) IBOutlet UILabel *lDrvVer;
@property (weak, nonatomic) IBOutlet UILabel *lSectionApp;
@property (weak, nonatomic) IBOutlet UILabel *lAppVerCaption;
@property (weak, nonatomic) IBOutlet UILabel *lAppVer;
@property (weak, nonatomic) IBOutlet UILabel *lSectionHelp;
@property (weak, nonatomic) IBOutlet UILabel *lIdent;
- (IBAction)helpTouch:(id)sender;
@end
