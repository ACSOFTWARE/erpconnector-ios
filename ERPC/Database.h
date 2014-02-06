//
//  Database.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 12.10.2012.
//  Copyright (c) 2012 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Contractor;
@class Invoice;
@class Payment;
@class Favorite;
@interface ACDatabase : NSObject

- (BOOL)performFetch:(NSFetchedResultsController *)frc;

-(Contractor*) jsonToContractor:(NSDictionary *)dict;
-(void) updateContractor:(Contractor*)contractor;
-(Contractor*) fetchContractorByShortcut:(NSString *)Shortcut;
-(NSFetchedResultsController *)fetchedContractorsWithText:(NSString *)txt;

-(NSFetchedResultsController *)fetchedInvoicesForContractor:(Contractor *)c;
-(Invoice*) fetchInvoiceByShortcut:(NSString *)Shortcut;
-(Invoice*) jsonToInvoice:(NSDictionary *)dict;
-(void) updateInvoice:(Invoice*)invoice customer:(Contractor*)c;

- (NSFetchedResultsController *)fetchedPaymentsForContractor:(Contractor *)c;
-(Payment*) jsonToPaymentItem:(NSDictionary *)dict;
-(void) insertPaymentItem:(Payment*)payment contractor:(Contractor*)c;
-(void) removeAllContractorPayments:(Contractor*)c;
-(NSDictionary *) paymentSummaryForContractor:(Contractor*)c;

-(void) updateRecentListWithContractor:(Contractor*)c orInvoice:(Invoice*)i;

-(Favorite*) fetchFavoriteItemForContractor:(Contractor*)c orInvoice:(Invoice*)i;
-(void) addToFavorites:(Contractor*)c orInvoice:(Invoice*)i;
-(void) removeFavoriteItem:(Contractor*)c orInvoice:(Invoice*)i;


-(NSFetchedResultsController *)fetchedHistory;
-(NSFetchedResultsController *)fetchedFavorites;

@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end
