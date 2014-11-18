//
//  Database.h
//  ERPC
//
//  Created by Przemysław Zygmunt on 12.10.2012.
//  Copyright (c) 2012 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;
@class Contractor;
@class Invoice;
@class InvoiceItem;
@class Payment;
@class Favorite;
@class Order;
@class OrderItem;
@class Article;
@class DataExport;
@class ACRemoteActionResultAsync;
@class ACRemoteActionResultDict;
@class IndividualPrice;
@class Limit;
@class ACRemoteActionResultLogin;

@interface ACDatabase : NSObject

- (BOOL)performFetch:(NSFetchedResultsController *)frc;

-(Contractor*) jsonToContractor:(NSDictionary *)dict;
-(void) updateContractor:(Contractor*)contractor;
-(Contractor*) fetchContractorByShortcut:(NSString *)Shortcut;
-(Contractor*) fetchContractor:(Contractor*)contractor;
-(NSFetchedResultsController *)fetchedContractorsWithText:(NSString *)txt;

-(NSFetchedResultsController *)fetchedInvoicesForContractor:(Contractor *)c;
-(NSFetchedResultsController *)fetchedItemsOfInvoice:(Invoice *)invoice;
-(Invoice*) fetchInvoiceByShortcut:(NSString *)Shortcut;
-(Invoice*) fetchInvoice:(Invoice *)invoice;
-(InvoiceItem*) fetchInvoiceItem:(InvoiceItem *)ii;
-(Invoice*) jsonToInvoice:(NSDictionary *)dict;
-(InvoiceItem*) jsonToInvoiceItem:(NSDictionary *)dict;
-(void) updateInvoice:(Invoice*)invoice customer:(Contractor*)c;
-(void) insertInvoiceItem:(InvoiceItem*)ii order:(Invoice*)i;
-(void) removeAllInvoiceItems:(Invoice*)i;
-(NSDate*)minUnvisibleInvoiceDateWithContractor:(Contractor *)c;

-(NSFetchedResultsController *)fetchedOrdersForContractor:(Contractor *)c;
-(NSFetchedResultsController *)fetchedItemsOfOrder:(Order *)order;
-(Order*) fetchOrderByShortcut:(NSString *)Shortcut;
-(Order*) jsonToOrder:(NSDictionary *)dict;
-(void) updateOrder:(Order*)order customer:(Contractor*)c;
-(OrderItem*) jsonToOrderItem:(NSDictionary *)dict;
-(void) insertOrderItem:(OrderItem*)oi order:(Order*)o;
-(void) removeAllOrderItems:(Order*)o;
-(Order*) newOrderForCustomer:(Contractor*)c;
-(Order*) fetchOrder:(Order *)order;
-(OrderItem*) fetchOrderItem:(OrderItem *)oi;
-(void)updateOrderSummary:(Order*)order;
-(NSString*) orderTojsonString:(Order*)order;
-(void) removeOrder:(Order*)order;
-(void) removeOrderItem:(OrderItem*)item;
-(NSArray*)orderItemsWithoutIndividualPrices:(Order*)order;
-(BOOL)eOrdersForContractor:(Contractor *)c;
-(NSDate*)minUnvisibleOrderDateWithContractor:(Contractor *)c;

-(Article*) jsonToArticle:(NSDictionary *)dict qty:(NSNumber**)Qty warehouseid:(NSString **)WareHouseId warehousename:(NSString **)WareHouseName;
-(void) updateArticle:(Article*)article qty:(NSNumber*)Qty warehouseid:(NSString *)WareHouseId warehousename:(NSString *)WareHouseName;
-(Article*) fetchArticleByShortcut:(NSString *)Shortcut;
-(Article*) fetchArticle:(Article *)article;
-(NSFetchedResultsController *)fetchedArticlesWithText:(NSString *)txt;
-(void) addArticle:(Article*)article ToOrder:(Order*)order;
-(void) addArticleByShortcut:(NSString*)shortcut ToOrder:(Order*)order;
- (NSFetchedResultsController *)fetchedWarehousesForArticle:(Article *)article;
-(double) articleQtyByUserWarehouse:(Article *)article;

- (NSFetchedResultsController *)fetchedPaymentsForContractor:(Contractor *)c;
-(Payment*) jsonToPaymentItem:(NSDictionary *)dict;
-(void) insertPaymentItem:(Payment*)payment contractor:(Contractor*)c;
-(void) removeAllContractorPayments:(Contractor*)c;
-(NSDictionary *) paymentSummaryForContractor:(Contractor*)c;

-(void) updateRecentListWithObject:(id)obj;

-(Favorite*) fetchFavoriteItemForObject:(id)obj;
-(void) addToFavorites:(id)obj;
-(void) removeFavoriteItem:(id)obj;

-(Invoice*) jsonToInvoice:(NSDictionary *)dict;
-(void) updateInvoice:(Invoice*)invoice customer:(Contractor*)c;
-(NSFetchedResultsController *)fetchedHistory;
-(NSFetchedResultsController *)fetchedFavorites;

-(DataExport*) getDataToExport;
-(DataExport*) fetchDataExport:(DataExport*)de;
-(NSFetchedResultsController *)fetchedDataExportResultMessages:(DataExport*)de;
-(void) updateDataExport:(DataExport*)de withStatus:(int)status;
-(void) updateDataExport:(DataExport*)de withResult:(ACRemoteActionResultAsync*)result;
-(void) updateDataExport:(DataExport*)de withErrorMessage:(NSString*)msg;
-(void) removeDataExport:(DataExport*)de;
-(void) removeDataExportMessages:(DataExport*)de;

- (NSFetchedResultsController *)fetchedDataExportQueue;

-(void)onLogin:(ACRemoteActionResultLogin*)login_result;
-(User*)getCurrentUser;
-(void)clearUserPassword;
-(BOOL)localPasswordPass;
-(void)updateServerData;
-(NSDate*)offlineValitityDate;

-(void)updateDictionaryOfType:(int)type forContractor:(NSString*)contractor withData:(ACRemoteActionResultDict*)dict;
-(NSFetchedResultsController *)fetchedDictionaryOfType:(int)type  forContractor:(Contractor *)c;
-(NSArray*)valuesOfDictionaryOfTpe:(int)type forContractor:(Contractor*)c;

-(void)updateIndividualPriceForContractor:(Contractor*)contractor withPrice:(NSNumber*)pricenet article:(Article*)article currency:(NSString*)currency;
-(void)updateIndividualPriceForContractor:(NSString*)contractor withPrice:(NSNumber*)pricenet articleShortcut:(NSString*)article currency:(NSString*)currency;

-(IndividualPrice *)individualPriceForContractor:(Contractor*)contractor article:(Article*)article currency:(NSString*)currency;
-(IndividualPrice *)individualPriceForContractor:(NSString*)contractor articleShortcut:(NSString*)article currency:(NSString*)currency;

-(Limit*) jsonToLimitItem:(NSDictionary *)dict;
-(void) insertLimitItem:(Limit*)payment contractor:(Contractor*)c;
-(void) removeAllContractorLimits:(Contractor*)c;
-(Limit*) contractor1stLimit:(Contractor*)contractor;
-(NSFetchedResultsController *)fetchedLimitsForContractor:(Contractor *)c;

-(BOOL) save;

@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end
