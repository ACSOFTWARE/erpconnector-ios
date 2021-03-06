/*
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
@class ArticleSHItem;
@class DataExport;
@class ACRemoteActionResultAsync;
@class ACRemoteActionResultDict;
@class IndividualPrice;
@class Limit;
@class ACRemoteActionResultLogin;

@interface ACDatabase : NSObject

- (BOOL)performFetch:(NSFetchedResultsController *)frc;

-(Contractor*) jsonToContractor:(NSDictionary *)dict;
-(NSString*) contractorTojsonString:(Contractor*)contractor autoShortcut:(BOOL)as;
-(Contractor*) newContractor;
-(void) updateContractor:(Contractor*)contractor;
-(void) removeContractor:(Contractor*)contractor;
-(Contractor*) fetchContractor:(Contractor*)contractor;
-(Contractor*) fetchContractorByShortcut:(NSString *)Shortcut;
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
-(Order*) jsonToOrder:(NSDictionary *)dict customerShortcut:(NSString **) cshortcut;
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
-(ArticleSHItem*) jsonToArticleSHItem:(NSDictionary *)dict;
-(void) updateArticle:(Article*)article qty:(NSNumber*)Qty warehouseid:(NSString *)WareHouseId warehousename:(NSString *)WareHouseName;
-(void) addArticleSHItem:(ArticleSHItem*)item article:(Article*)a;
-(Article*) fetchArticleByShortcut:(NSString *)Shortcut;
-(Article*) fetchArticle:(Article *)article;
-(NSFetchedResultsController *)fetchedArticlesWithText:(NSString *)txt;
-(void) addArticle:(Article*)article ToOrder:(Order*)order;
-(void) addArticleByShortcut:(NSString*)shortcut ToOrder:(Order*)order;
- (NSFetchedResultsController *)fetchedWarehousesForArticle:(Article *)article;
-(double) articleQtyByUserWarehouse:(Article *)article;
-(void) removeArticleSHItems:(Article*)article;
-(void) updateArticleSHdate:(Article*)article;
- (NSFetchedResultsController *)fetchedSalesHistoryForArticle:(Article *)article;

- (NSFetchedResultsController *)fetchedPaymentsForContractor:(Contractor *)c;
-(Payment*) jsonToPaymentItem:(NSDictionary *)dict;
-(void) insertPaymentItem:(Payment*)payment contractor:(Contractor*)c;
-(void) removeAllContractorPayments:(Contractor*)c;
-(NSDictionary *) paymentSummaryForContractor:(Contractor*)c;

-(void) updateRecentListWithObject:(id)obj;

-(Favorite*) fetchFavoriteItemForObject:(id)obj;
-(void) addToFavorites:(id)obj;
-(void) removeFavoriteItem:(id)obj;

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
