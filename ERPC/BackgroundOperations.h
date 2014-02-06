/*
 ACRemoteOperation.h
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

#import <Foundation/Foundation.h>



@interface ACRemoteOperation : NSOperation

+(void)registerDevice;
+(void)login:(NSString*)Login withPassword:(NSString*)password;
+(void)customerSearch:(NSString*)text mtu:(int)MTU;
+(void)customerSearchOnlyByShortcut:(NSString*)shortcut;
+(void)invoicesForCustomerWithShortcut:(NSString*)shortcut mtu:(int)MTU fromDate:(NSDate*)date;
+(void)outstandingPaymentsForCustomerWithShortcut:(NSString*)shortcut;
+(void)getInvoiceDocumentWithShortcut:(NSString*)shortcut;

@end