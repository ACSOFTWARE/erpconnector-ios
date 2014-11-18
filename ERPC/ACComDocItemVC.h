//
//  ACComDocItemVC.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 14.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIDataVC.h"

@class OrderItem;
@interface ACComDocItemVC : ACUIDataVC <ACUIFormDataSource, ACUIFormDelegate>
+(void)calculateOrderItem:(OrderItem*)oi priceNet:(double)net discount:(double)discount qty:(double)qty vatRate:(double)vat;
+(void)calculateOrderItem:(OrderItem*)oi;
@end
