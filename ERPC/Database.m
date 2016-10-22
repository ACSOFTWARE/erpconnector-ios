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

#import <CoreData/CoreData.h>
#import "Database.h"
#import "ERPCCommon.h"
#import "User.h"
#import "Server.h"
#import "Contractor.h"
#import "Invoice.h"
#import "InvoiceItem.h"
#import "Payment.h"
#import "Recent.h"
#import "Favorite.h"
#import "Order.h"
#import "OrderItem.h"
#import "DataExport.h"
#import "DataExportMsg.h"
#import "Article+CoreDataProperties.h"
#import "ArticleSHItem+CoreDataProperties.h"
#import "BackgroundOperations.h"
#import "RemoteAction.h"
#import "WareHouse.h"
#import "Dict.h"
#import "IndividualPrice.h"
#import "Limit.h"
#include <CommonCrypto/CommonHMAC.h>

@implementation ACDatabase {
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectContext *_managedObjectContext;

}

-(id)init {
    self = [super init];
    if ( self ) {
        _managedObjectContext = nil;
        _persistentStoreCoordinator = nil;
        _managedObjectModel = nil;
    }
    return self;
}


#pragma mark ModelInitialization

-(NSManagedObjectModel*)managedObjectModel {
    if ( _managedObjectModel == nil ) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

-(void)setManagedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    _managedObjectModel = managedObjectModel;
}

-(void)removeDocumentFile:(NSString*)file {
    
    NSURL *fURL = [[Common applicationDocumentsDirectory] URLByAppendingPathComponent:file];
    
    NSError *err;
    if ( [fURL checkResourceIsReachableAndReturnError:&err] == YES ) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:fURL error:&err];
    };
    
}

-(void)removeDB:(NSString*)file {
    
    [self removeDocumentFile:file];
    [self removeDocumentFile:[NSString stringWithFormat:@"%@-shm", file]];
    [self removeDocumentFile:[NSString stringWithFormat:@"%@-wal", file]];
};

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
    if ( _persistentStoreCoordinator == nil ) {
        
        
        [self removeDB:@"Model.sqlite"];

        
        NSURL *storeURL = [[Common applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model_v4.sqlite"];
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    }
    
    return _persistentStoreCoordinator;
}

- (void)setPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    _persistentStoreCoordinator = persistentStoreCoordinator;
}

-(NSManagedObjectContext*)managedObjectContext {
    if ( _managedObjectContext == nil ) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        [_managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    }
    
    return _managedObjectContext;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
}

- (BOOL)performFetch:(NSFetchedResultsController *)frc {
    
    if ( frc == nil ) return NO;
    
    NSError *error = nil;
    [frc performFetch:&error];
    if ( error ) {
        NSLog(@"%@", error.description);
        return NO;
    }
    
    return YES;
}

-(NSArray *) fetchByPredicate:(NSPredicate *)predicate entityName:(NSString*)en limit:(int)l {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = predicate;
    
    if ( l > 0 ) {
      [fetchRequest setFetchLimit:l];
    }
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:en inManagedObjectContext: self.managedObjectContext]];
    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error == nil && r.count > 0 ) {
        return r;
    }
    
    return nil;
};

-(id) fetchItemByPredicate:(NSPredicate *)predicate entityName:(NSString*)en {
    
    NSArray *r = [self fetchByPredicate:predicate entityName:en limit:1];
    if ( r != nil && r.count > 0 ) {
        return [r objectAtIndex:0];
    }
    
    return nil;
};

-(void) deleteAllByPredicate:(NSPredicate *)predicate entityName:(NSString*)en  {
    
    NSArray *r = [self fetchByPredicate:predicate entityName:en limit:0];
    
    if ( r != nil ) {
        for(int a=0;a<r.count;a++) {
            [self.managedObjectContext deleteObject:[r objectAtIndex:a]];
        }
    }
}


-(void) updateVisibilityStatusWithEntityName:(NSString*)en andPredicate:(NSPredicate*)predicate  {

    int time = 0;
    
    Server *server = [self getCurrentServer];
    
    if ( server ) {
        if ( Common.Connected ) {
            time = [server.online_validitytime intValue];
        } else {
            time = [server.offline_validitytime intValue];
        }
        
        time*=60;
        
        if ( time > 0 )
            time*=-1;
    }
    
    NSPredicate *pAND = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"visible == YES AND user == %@ AND uptodate < %@", [self getCurrentUser], [[NSDate date] dateByAddingTimeInterval:time]], predicate, nil]];

    NSArray *r = [self fetchByPredicate:pAND entityName:en limit:0];
    
    if ( r != nil ) {
        for(int a=0;a<r.count;a++) {
            id obj = [r objectAtIndex:a];
            [obj setValue:[NSNumber numberWithBool:NO] forKey:@"visible"];
        }
        
        [self save];
    }
    
    
};

-(void) updateVisibilityStatusWithEntityName:(NSString*)en {
    [self updateVisibilityStatusWithEntityName:en andPredicate:nil];
};

-(id) fetchItemByShortcut:(NSString *)Shortcut entityName:(NSString*)en {
    
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"shortcut = %@ AND shortcut <> %@ AND shortcut <> nil AND user = %@", Shortcut, @"", [self getCurrentUser]] entityName:en];
};

-(id) fetchObject:(id)obj entityName:(NSString*)en {
    
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"self = %@", obj] entityName:en];
};

-(NSDate*)minUnvisibleWithEntityName:(NSString*)en andContractor:(Contractor*)c {
    
    NSDate *result = nil;
    
    NSExpressionDescription *ed1 = [[NSExpressionDescription alloc] init];
    [ed1 setName:@"mdate"];
    [ed1 setExpression:[NSExpression expressionForFunction:@"min:" arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"uptodate"]]]];
    [ed1 setExpressionResultType:NSDoubleAttributeType];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:ed1, nil]];
    [request setResultType:NSDictionaryResultType];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"visible == NO AND user == %@ AND customer == %@", [self getCurrentUser], c]];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:en
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    if ( results
        && results.count > 0 ) {
        NSDictionary *resultsDictionary = [results objectAtIndex:0];
        
        result = [resultsDictionary objectForKey:@"mdate"];
        
        NSLog(@"ENTITY: %@, MinDate: %@", en, result);
    }
    
    
    return result;
    
}

#pragma mark Contractor

-(Contractor*) fetchContractorByShortcut:(NSString *)Shortcut {
    
    return [self fetchItemByShortcut:Shortcut entityName:@"Contractor"];
    
};

-(Contractor*) fetchContractor:(Contractor*)contractor {
    return [self fetchObject:contractor entityName:@"Contractor"];
}

- (NSFetchedResultsController *)fetchedContractorsWithText:(NSString *)txt {
    
   
    [self updateVisibilityStatusWithEntityName:@"Contractor" andPredicate:[NSPredicate predicateWithFormat:@"dataexport == nil"]];
    
    
    txt = [NSString stringWithFormat:@"*%@*", txt];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSPredicate *p0 = [NSPredicate predicateWithFormat:@"user == %@ AND visible == YES AND (dataexport == nil OR dataexport.status <> %@)", [self getCurrentUser], [NSNumber numberWithInt:QSTATUS_DONE]];
    
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"shortcut like[c] %@", txt];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"name like[c] %@", txt];
    NSPredicate *p3 = [NSPredicate predicateWithFormat:@"nip like[c] %@", txt];
    NSPredicate *p4 = [NSPredicate predicateWithFormat:@"regon like[c] %@", txt];
    //NSPredicate *p5 = [NSPredicate predicateWithFormat:@"region like[c] %@", txt];
    //NSPredicate *p6 = [NSPredicate predicateWithFormat:@"country like[c] %@", txt];
    //NSPredicate *p7 = [NSPredicate predicateWithFormat:@"postcode like[c] %@", txt];
    NSPredicate *p8 = [NSPredicate predicateWithFormat:@"city like[c] %@", txt];
    NSPredicate *p9 = [NSPredicate predicateWithFormat:@"street like[c] %@", txt];
    //NSPredicate *p10 = [NSPredicate predicateWithFormat:@"houseno like[c] %@", txt];
    NSPredicate *p11 = [NSPredicate predicateWithFormat:@"tel1 like[c] %@", txt];
    NSPredicate *p12 = [NSPredicate predicateWithFormat:@"tel2 like[c] %@", txt];
    NSPredicate *p13 = [NSPredicate predicateWithFormat:@"tel3 like[c] %@", txt];
    NSPredicate *p14 = [NSPredicate predicateWithFormat:@"email1 like[c] %@", txt];
    NSPredicate *p15 = [NSPredicate predicateWithFormat:@"email2 like[c] %@", txt];
    NSPredicate *p16 = [NSPredicate predicateWithFormat:@"email3 like[c] %@", txt];
    NSPredicate *p17 = [NSPredicate predicateWithFormat:@"www1 like[c] %@", txt];
    NSPredicate *p18 = [NSPredicate predicateWithFormat:@"www2 like[c] %@", txt];
    NSPredicate *p19 = [NSPredicate predicateWithFormat:@"www3 like[c] %@", txt];
    
    NSPredicate *pOR = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:p1, p2, p3, p4, p8, p9, p11, p12, p13, p14, p15, p16, p17, p18, p19, nil]];
                        
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:pOR, p0, nil]];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Contractor" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"name.firstChar" cacheName:nil];
}

-(Contractor*) jsonToContractor:(NSDictionary *)dict {
    
    if ( !dict
        || ![dict isKindOfClass:[NSDictionary class]] )
        return nil;
    
    NSString *khid = [dict stringValueForKey:@"Id"];
    
    if ( khid.length < 1) return nil;
    
    Contractor*c = [[Contractor alloc] initWithEntity:[NSEntityDescription entityForName:@"Contractor" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    c.shortcut = khid;
    c.name = [dict stringValueForKey:@"Name"];
    if ( c.name.length == 0 ) {
        c.name = c.shortcut;
    }
    
    c.section = [[c.name stringByReplacingOccurrencesOfString:@"\"" withString:@""] uppercaseString];

    if ( c.section.length > 1 ) {
      c.section = [c.section substringToIndex:1];
    }
    
    c.nip = [dict stringValueForKey:@"VATid"];
    c.regon = [dict stringValueForKey:@"Regon"];
    c.region = [dict stringValueForKey:@"Region"];
    c.country = [dict stringValueForKey:@"Country"];
    c.postcode = [dict stringValueForKey:@"PostCode"];
    c.city = [dict stringValueForKey:@"City"];
    c.street = [dict stringValueForKey:@"Street"];
    c.houseno = [dict stringValueForKey:@"StNo"];
    c.tel1 = [dict stringValueForKey:@"Phone1"];
    c.tel2 = [dict stringValueForKey:@"Phone2"];
    c.tel3 = [dict stringValueForKey:@"Phone3"];
    c.email1 = [dict stringValueForKey:@"Email1"];
    c.email2 = [dict stringValueForKey:@"Email2"];
    c.email3 = [dict stringValueForKey:@"Email3"];
    c.www1 = [dict stringValueForKey:@"WWW1"];
    c.www2 = [dict stringValueForKey:@"WWW2"];
    c.www3 = [dict stringValueForKey:@"WWW3"];
    c.limit = [dict numberValueForKey:@"Limit"];
    c.trnlocked = [NSNumber numberWithBool:([dict boolValueForKey:@"TrnLocked"] || [[dict stringValueForKey:@"TrnLocked"] isEqualToString:@"1"] || [[dict stringValueForKey:@"TrnLocked"] isEqualToString:@"Yes"])];
    c.invoices_last_resp_date = nil;
    c.payments_last_resp_date = nil;
    c.orders_last_resp_date = nil;
    
    return c;
}

-(NSString*) notNullString:(NSString*)str {
    return str == nil ? @"" : str;
}

-(NSString*) contractorTojsonString:(Contractor*)contractor autoShortcut:(BOOL)as {
    if ( contractor == nil ) return nil;
    
    NSArray *keys = nil;
    NSArray *values = nil;
    

    keys = [NSArray arrayWithObjects:@"Shortcut",
            @"Name",
            @"NIP",
            @"REGON",
            @"Country",
            @"Region",
            @"PostCode",
            @"City",
            @"Street",
            @"HouseNumber",
            @"Phone1",
            @"Phone2",
            @"Phone3",
            @"WWW1",
            @"WWW2",
            @"WWW3",
            @"Email1",
            @"Email2",
            @"Email3",
            nil];
    
    NSString *Shortcut = contractor.shortcut;
    if ( as == YES ) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyMMddHHmmss"];
        
        Shortcut = [formatter stringFromDate:[NSDate date]];
    }
    
    values = [NSArray arrayWithObjects:
              [self notNullString:Shortcut],
              [self notNullString:contractor.name],
              [self notNullString:contractor.nip],
              [self notNullString:contractor.regon],
              [self notNullString:contractor.country],
              [self notNullString:contractor.region],
              [self notNullString:contractor.postcode],
              [self notNullString:contractor.city],
              [self notNullString:contractor.street],
              [self notNullString:contractor.houseno],
              [self notNullString:contractor.tel1],
              [self notNullString:contractor.tel2],
              [self notNullString:contractor.tel3],
              [self notNullString:contractor.www1],
              [self notNullString:contractor.www2],
              [self notNullString:contractor.www3],
              [self notNullString:contractor.email1],
              [self notNullString:contractor.email2],
              [self notNullString:contractor.email3],
              nil];
    
    NSDictionary *c_dict = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    keys = [NSArray arrayWithObjects:@"CData", nil];
    values = [NSArray arrayWithObjects:c_dict, nil];
    
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:[[NSDictionary alloc] initWithObjects:values forKeys:keys]  options:0 error:&err];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(void) updateContractor:(Contractor*)contractor {
    if ( !contractor ) return;
    Contractor*c = [self fetchContractorByShortcut:contractor.shortcut];
    if (c) {
        c.name = contractor.name;
        c.section = contractor.section;
        c.nip = contractor.nip;
        c.regon = contractor.regon;
        c.region = contractor.region;
        c.country = contractor.country;
        c.postcode = contractor.postcode;
        c.city = contractor.city;
        c.street = contractor.street;
        c.houseno = contractor.houseno;
        c.tel1 = contractor.tel1;
        c.tel2 = contractor.tel2;
        c.tel3 = contractor.tel3;
        c.email1 = contractor.email1;
        c.email2 = contractor.email2;
        c.email3 = contractor.email3;
        c.www1 = contractor.www1;
        c.www2 = contractor.www2;
        c.www3 = contractor.www3;
        c.trnlocked = contractor.trnlocked;
        c.limit = contractor.limit;
    } else {
        c = contractor;
        [self.managedObjectContext insertObject:c];
        c.user = [self getCurrentUser];
    }
    
    c.uptodate = [NSDate date];
    c.visible = [NSNumber numberWithBool:YES];
    [self save];
}

-(Contractor*) newContractor {
    
    
    Contractor *c = [[Contractor alloc] initWithEntity:[NSEntityDescription entityForName:@"Contractor" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    
    DataExport *de = [[DataExport alloc] initWithEntity:[NSEntityDescription entityForName:@"DataExport" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    
    [self.managedObjectContext insertObject:de];
    [self.managedObjectContext insertObject:c];
    
    de.user = [self getCurrentUser];
    de.contractor = c;
    de.added = [NSDate date];
    de.status = [NSNumber numberWithInt:QSTATUS_EDITING];
    de.uptodate = nil;
    
    NSArray *arr = [self valuesOfDictionaryOfTpe:DICTTYPE_CONTRACTOR_COUNTRY forContractor:c];
    if ( arr && arr.count ) {
        c.country = [arr objectAtIndex:0];
    } else {
        arr = [self valuesOfDictionaryOfTpe:DICTTYPE_CONTRACTOR_COUNTRY forContractor:nil];
        if ( arr && arr.count ) {
            c.country = [arr objectAtIndex:0];
        } else {
            c.country = @"Polska";
        }
    }
    
    c.shortcut = @"";
    c.name = @"";
    c.user = de.user;
    c.dataexport = de;
    c.visible = [NSNumber numberWithBool:YES];
    
    return [self save] ? c : nil;
};

-(void) removeContractor:(Contractor*)contractor {
    
    if ( contractor != nil ) {
        [self removeFavoriteItem:contractor];
        [self removeRecentItem:contractor];
        
        DataExport *de = contractor.dataexport;
        
        [self.managedObjectContext deleteObject:contractor];
        [self save];
        
        [self updateDataExport:de withStatus:QSTATUS_DELETED];
    }
    
}

#pragma mark Invoices

- (NSFetchedResultsController *)fetchedInvoicesForContractor:(Contractor *)c {
    
    [self updateVisibilityStatusWithEntityName:@"Invoice" andPredicate:[NSPredicate predicateWithFormat:@"dataexport == nil"]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"customer = %@ AND user = %@ AND visible == YES", c, [self getCurrentUser]];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Invoice" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateofissue" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}


-(NSFetchedResultsController *)fetchedItemsOfInvoice:(Invoice *)invoice {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"invoice = %@", invoice];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"InvoiceItem" inManagedObjectContext: self.managedObjectContext]];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(Invoice*) fetchInvoiceByShortcut:(NSString *)Shortcut {

    return [self fetchItemByShortcut:Shortcut entityName:@"Invoice"];
};

-(Invoice*) jsonToInvoice:(NSDictionary *)dict {
    
    if ( !dict
        || ![dict isKindOfClass:[NSDictionary class]] )
        return nil;

    
    NSString *fvid = [dict valueForKey:@"Id"];
    
    if ( fvid == nil
        || fvid.length < 1) return nil;
    
    Invoice *i = [[Invoice alloc] initWithEntity:[NSEntityDescription entityForName:@"Invoice" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    i.shortcut = [fvid trim];
    
    i.number = [dict stringValueForKey:@"Number"];
    i.dateofissue = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"DateOfIssue"]];
    i.totalnet = [dict numberValueForKey:@"TotalNet"];
    i.totalgross = [dict numberValueForKey:@"TotalGross"];
    i.remaining = [dict numberValueForKey:@"Remaining"];
    i.paid = [dict numberValueForKey:@"Paid"];
    i.paymentmethod = [dict stringValueForKey:@"PaymentMethod"];
    i.termdate = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"PaymentDeadline"]];
    
    
    return i;
}

-(InvoiceItem*) jsonToInvoiceItem:(NSDictionary *)dict {
    
    if ( !dict
        || ![dict isKindOfClass:[NSDictionary class]] )
        return nil;
    
    InvoiceItem *ii = [[InvoiceItem alloc] initWithEntity:[NSEntityDescription entityForName:@"InvoiceItem" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    
    ii.shortcut = [dict stringValueForKey:@"Code"];
    ii.name = [dict stringValueForKey:@"Name"];
    ii.qty = [dict numberValueForKey:@"Qty"];
    ii.unit = [dict stringValueForKey:@"Unit"];
    ii.price = [dict numberValueForKey:@"Price"];
    ii.discount = [dict numberValueForKey:@"Discount"];
    ii.discountpercent = [dict numberValueForKey:@"DiscountPercent"];
    ii.pricenet = [dict numberValueForKey:@"PriceNet"];
    ii.totalnet = [dict numberValueForKey:@"TotalNet"];
    ii.vatrate = [dict stringValueForKey:@"VATrate"];
    ii.vatvalue = [dict numberValueForKey:@"VATvalue"];
    ii.totalgross = [NSNumber numberWithDouble:ii.totalnet.doubleValue + ii.vatvalue.doubleValue];
    
    return ii;
}

-(void) updateInvoice:(Invoice*)invoice customer:(Contractor*)c {
    if ( !invoice ) return;
    Invoice *i = [self fetchInvoiceByShortcut:invoice.shortcut];
    if (i) {
        
        i.number = invoice.number;
        i.dateofissue = invoice.dateofissue;
        i.totalnet = invoice.totalnet;
        i.totalgross = invoice.totalgross;
        i.remaining = invoice.remaining;
        i.paid = invoice.paid;
        i.termdate = invoice.termdate;
        i.paymentmethod = invoice.paymentmethod;

    } else {
        i = invoice;
        [self.managedObjectContext insertObject:i];
        i.user = [self getCurrentUser];
    }
    
    i.uptodate = [NSDate date];
    i.visible = [NSNumber numberWithBool:YES];
    
    if ( c ) {
        i.customer = c;
    }
    
    [self save];
}

-(void) insertInvoiceItem:(InvoiceItem*)ii order:(Invoice*)i {
    
    [self.managedObjectContext insertObject:ii];
    
    ii.invoice = i;
    
    [self save];
}

-(void) removeAllInvoiceItems:(Invoice*)i {
    
    [self deleteAllByPredicate:[NSPredicate predicateWithFormat:@"invoice = %@", i] entityName:@"InvoiceItem"];
    
}

-(Invoice*) fetchInvoice:(Invoice *)invoice {
    
    return [self fetchObject:invoice entityName:@"Invoice"];
};

-(InvoiceItem*) fetchInvoiceItem:(InvoiceItem *)ii {
    
    return [self fetchObject:ii entityName:@"InvoiceItem"];
};

-(NSDate*)minUnvisibleInvoiceDateWithContractor:(Contractor *)c {
    return [self minUnvisibleWithEntityName:@"Invoice" andContractor:c];
}

#pragma mark Orders

- (NSFetchedResultsController *)fetchedOrdersForContractor:(Contractor *)c {
    
    [self updateVisibilityStatusWithEntityName:@"Order" andPredicate:[NSPredicate predicateWithFormat:@"dataexport == nil"]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    /*
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"status == %i", QSTATUS_WAITING];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"status == %i", QSTATUS_SENT];
    NSPredicate *p3 = [NSPredicate predicateWithFormat:@"status == %i", QSTATUS_ASYNCREQUEST_CONFIRMED];

    [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:p1, p2, p3, nil]]
    */
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user == %@ AND customer == %@ AND (dataexport == nil OR dataexport.status <> %@) AND visible == YES", [self getCurrentUser], c, [NSNumber numberWithInt:QSTATUS_DONE]];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Order" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *col1SD = [[NSSortDescriptor alloc] initWithKey:@"dataexport" ascending:NO];
    NSSortDescriptor *col2SD = [[NSSortDescriptor alloc] initWithKey:@"dateofissue" ascending:NO];
    NSSortDescriptor *col3SD = [[NSSortDescriptor alloc] initWithKey:@"shortcut" ascending:NO];

    NSArray *sortDescriptors = [NSArray arrayWithObjects:col1SD, col2SD, col3SD, nil];
    
  //  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shortcut" ascending:NO ];
  //  NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(NSFetchedResultsController *)fetchedItemsOfOrder:(Order *)order {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"order = %@", order];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"OrderItem" inManagedObjectContext: self.managedObjectContext]];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(Order*) fetchOrderByShortcut:(NSString *)Shortcut{
    
    
     return [self fetchItemByShortcut:Shortcut entityName:@"Order"];
};

-(Order*) fetchOrder:(Order *)order {
    
    return [self fetchObject:order entityName:@"Order"];
};

-(OrderItem*) fetchOrderItem:(OrderItem *)oi {
    
    return [self fetchObject:oi entityName:@"OrderItem"];
};


-(Order*) jsonToOrder:(NSDictionary *)dict customerShortcut:(NSString **) cshortcut{
    
    if ( !dict
        || ![dict isKindOfClass:[NSDictionary class]] )
        return nil;
    
    
    NSString *oid = [dict valueForKey:@"Id"];
    
    if ( oid == nil
        || oid.length < 1) return nil;
    
    Order *o = [[Order alloc] initWithEntity:[NSEntityDescription entityForName:@"Order" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    

    o.shortcut = [oid trim];
    
    o.number = [dict stringValueForKey:@"Number"];
    o.dateofissue = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"DateOfIssue"]];
    o.totalnet = [dict numberValueForKey:@"TotalNet"];
    o.totalgross = [dict numberValueForKey:@"TotalGross"];
    o.paymentmethod = [dict stringValueForKey:@"PaymentMethod"];
    o.dateofcomplete = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"DateOfComplete"]];
    o.termofcontract = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"TermOfContract"]];
    o.state = [dict stringValueForKey:@"State"];
    o.desc = [dict stringValueForKey:@"Description"];
    o.valuerealized = [dict numberValueForKey:@"ValueRealized"];
    
    if ( [dict objectForKey:@"ContractorID"] != nil ) {
        *cshortcut =[dict stringValueForKey:@"ContractorID"];
    }
    
    return o;
}

-(void) updateOrder:(Order*)order customer:(Contractor*)c {
    if ( !order ) return;
    Order *o = [self fetchOrderByShortcut:order.shortcut];
    if (o) {
        
        o.number = order.number;
        o.dateofissue = order.dateofissue;
        o.totalnet = order.totalnet;
        o.totalgross = order.totalgross;
        o.paymentmethod = order.paymentmethod;
        o.dateofcomplete = order.dateofcomplete;
        o.termofcontract = order.termofcontract;
        o.state = order.state;
        o.desc = order.desc;
        o.valuerealized = order.valuerealized;
        
    } else {
        o = order;
        [self.managedObjectContext insertObject:o];
        o.user = [self getCurrentUser];
        
    }
    
    o.uptodate = [NSDate date];
    o.visible = [NSNumber numberWithBool:YES];
    
    if ( c ) {
     o.customer = c;
    }
    
    
    [self save];
}

-(OrderItem*) jsonToOrderItem:(NSDictionary *)dict {
    
    if ( !dict
        || ![dict isKindOfClass:[NSDictionary class]] )
        return nil;

    OrderItem *oi = [[OrderItem alloc] initWithEntity:[NSEntityDescription entityForName:@"OrderItem" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    
    oi.shortcut = [dict stringValueForKey:@"Code"];
    oi.name = [dict stringValueForKey:@"Name"];
    oi.qty = [dict numberValueForKey:@"Qty"];
    oi.unit = [dict stringValueForKey:@"Unit"];
    oi.price = [dict numberValueForKey:@"Price"];
    oi.discount = [dict numberValueForKey:@"Discount"];
    oi.discountpercent = [dict numberValueForKey:@"DiscountPercent"];
    oi.pricenet = [dict numberValueForKey:@"PriceNet"];
    oi.totalnet = [dict numberValueForKey:@"TotalNet"];
    oi.vatrate = [dict stringValueForKey:@"VATrate"];
    oi.vatvalue = [dict numberValueForKey:@"VATvalue"];
    oi.totalgross = [NSNumber numberWithDouble:oi.totalnet.doubleValue + oi.vatvalue.doubleValue];
    
    return oi;
}


-(NSString*) orderTojsonString:(Order*)order {
    if ( order == nil ) return nil;

    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSArray *keys = nil;
    NSArray *values = nil;
    
    NSArray *oi = [self fetchByPredicate:[NSPredicate predicateWithFormat:@"order == %@", order] entityName:@"OrderItem" limit:0];
    
    if ( oi && oi.count > 0 ) {

        keys = [NSArray arrayWithObjects:@"Shortcut", @"Name", @"Description", @"WareHouse", @"Price", @"Discount", @"Qty", @"TotalPriceNet", nil];
  
        for(int a=0;a<oi.count;a++) {
            OrderItem *i = [oi objectAtIndex:a];
            if ( i ) {
                values = [NSArray arrayWithObjects:i.shortcut ? i.shortcut : @"", i.name ? i.name : @"", @"", @"", i.price == nil ? [NSNumber numberWithDouble:0.00] : i.price, i.discountpercent == nil ? [NSNumber numberWithDouble:0.00] : i.discountpercent, i.qty == nil ? [NSNumber numberWithDouble:1.00] : i.qty, i.totalnet == nil ? [NSNumber numberWithDouble:0.00] : i.totalnet, nil ];
                [items addObject:[[NSDictionary alloc] initWithObjects:values forKeys:keys]];
            }
            
        }
    }
    
    oi = nil;
    
    keys = [NSArray arrayWithObjects:@"ContractorShortcut", @"ContractorName", @"PaymentMethod", @"Discount", @"TotalPriceNet", @"Description", @"State", @"Items", nil];
    values = [NSArray arrayWithObjects:order.customer.shortcut ? order.customer.shortcut : @"", order.customer.name ? order.customer.name : @"", order.paymentmethod ? order.paymentmethod : @"", [NSNumber numberWithDouble:0.00], order.totalnet == nil ? [NSNumber numberWithDouble:0.00] : order.totalnet, order.desc ? order.desc : @"", order.state ? order.state : @"", items, nil];
    
    NSDictionary *order_dict = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    keys = [NSArray arrayWithObjects:@"OData", nil];
    values = [NSArray arrayWithObjects:order_dict, nil];

    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:[[NSDictionary alloc] initWithObjects:values forKeys:keys]  options:0 error:&err];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}



-(void) insertOrderItem:(OrderItem*)oi order:(Order*)o {

    [self.managedObjectContext insertObject:oi];

    oi.order = o;
    
    [self save];
}

-(void) removeAllOrderItems:(Order*)o {
    
    [self deleteAllByPredicate:[NSPredicate predicateWithFormat:@"order = %@", o] entityName:@"OrderItem"];

}

-(Order*) newOrderForCustomer:(Contractor*)c {
    
    if ( c == nil ) return nil;

    
    Order *o = [[Order alloc] initWithEntity:[NSEntityDescription entityForName:@"Order" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    
    DataExport *de = [[DataExport alloc] initWithEntity:[NSEntityDescription entityForName:@"DataExport" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];

    [self.managedObjectContext insertObject:de];
    [self.managedObjectContext insertObject:o];
    
    de.user = [self getCurrentUser];
    de.order = o;
    de.added = [NSDate date];
    de.status = [NSNumber numberWithInt:QSTATUS_EDITING];
    de.uptodate = nil;
    
    o.shortcut = @"";
    
    o.number = @"";
    o.dateofissue = [NSDate date];
    o.totalnet = [NSNumber numberWithDouble:00.00];
    o.totalgross = [NSNumber numberWithDouble:00.00];
    
    NSArray *arr = [self valuesOfDictionaryOfTpe:DICTTYPE_CONTRACTOR_PAYMENTMETHODS forContractor:c];
    if ( arr && arr.count ) {
        o.paymentmethod = [arr objectAtIndex:0];
    } else {
        arr = [self valuesOfDictionaryOfTpe:DICTTYPE_CONTRACTOR_PAYMENTMETHODS forContractor:nil];
        if ( arr && arr.count ) {
            o.paymentmethod = [arr objectAtIndex:0];
        } else {
            o.paymentmethod = @"Gotówka";
        }
    }
    
    o.dateofcomplete = nil;
    o.termofcontract = nil;
    o.state = @"";
    
    arr = [self valuesOfDictionaryOfTpe:DICTTYPE_NEWORDER_STATE forContractor:nil];
    if ( arr && arr.count ) {
        o.state = [arr objectAtIndex:0];
    }
    
    o.desc = @"";
    o.valuerealized = [NSNumber numberWithDouble:00.00];
    o.customer = c;
    o.user = de.user;
    o.dataexport = de;
    o.visible = [NSNumber numberWithBool:YES];
    
    
    return [self save] ? o : nil;
};

-(void)updateOrderSummary:(Order*)order {
    
    
    NSExpressionDescription *ed1 = [[NSExpressionDescription alloc] init];
    [ed1 setName:@"net"];
    [ed1 setExpression:[NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"totalnet"]]]];
    [ed1 setExpressionResultType:NSDoubleAttributeType];
    
    NSExpressionDescription *ed2 = [[NSExpressionDescription alloc] init];
    [ed2 setName:@"gross"];
    [ed2 setExpression:[NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"totalgross"]]]];
    [ed2 setExpressionResultType:NSDoubleAttributeType];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:ed1, ed2, nil]];
    [request setResultType:NSDictionaryResultType];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"order = %@", order]];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OrderItem"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    if ( results
        && results.count > 0 ) {
        NSDictionary *resultsDictionary = [results objectAtIndex:0];
        
        
        order = [self fetchOrder:order];
        order.totalnet = [resultsDictionary objectForKey:@"net"];
        order.totalgross = [resultsDictionary objectForKey:@"gross"];
        
        [self save];
    }
    
}

-(void) removeOrder:(Order*)order {
    
    if ( order != nil ) {
        [self removeFavoriteItem:order];
        [self removeRecentItem:order];
        [self removeAllOrderItems:order];
        
        DataExport *de = order.dataexport;
        
        [self.managedObjectContext deleteObject:order];
        [self save];
        
        [self updateDataExport:de withStatus:QSTATUS_DELETED];
    }

}

-(void) removeOrderItem:(OrderItem*)item {
    if ( item ) {
        Order *order = item.order;
        [self.managedObjectContext deleteObject:item];
        [self save];
        
        [self updateOrderSummary:order];
    }
}

-(NSArray*)orderItemsWithoutIndividualPrices:(Order*)order {
    return  [self fetchByPredicate:[NSPredicate predicateWithFormat:@"order = %@ AND (individualprice = nil OR individualprice = %@)", order, [NSNumber numberWithBool:NO]] entityName:@"OrderItem" limit:0];
}

-(BOOL)eOrdersForContractor:(Contractor *)c {
    
    return [self fetchByPredicate:[NSPredicate predicateWithFormat:@"user == %@ AND customer == %@ AND dataexport != nil  AND dataexport.status == %i", [self getCurrentUser], c, QSTATUS_EDITING] entityName:@"Order" limit:1] != nil;
}

-(NSDate*)minUnvisibleOrderDateWithContractor:(Contractor *)c {
    return [self minUnvisibleWithEntityName:@"Order" andContractor:c];
}

#pragma mark DataExport

-(DataExport*) fetchDE:(DataExport *)de {
    
    return [self fetchObject:de entityName:@"DataExport"];
};


-(DataExport*) getDataToExport {
    
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"user = %@ AND (order <> nil OR invoice <> nil OR contractor <> nil ) AND (status == %i OR status == %i OR status == %i OR status == %i)", [self getCurrentUser], QSTATUS_WAITING, QSTATUS_USERCONFIRMATION_WAITING, QSTATUS_SENT, QSTATUS_ASYNCREQUEST_CONFIRMED] entityName:@"DataExport"];
}

-(DataExport*) fetchDataExport:(DataExport*)de {
    return [self fetchObject:de entityName:@"DataExport"];
}

-(void) updateDataExport:(DataExport*)de withStatus:(int)status {
    if ( de ) {
        de.uptodate = [NSDate date];
        de.status = [NSNumber numberWithInt:status];
        [self save];
    }
}

-(void) removeDataExportMessages:(DataExport*)de {
    if ( de != nil ) {
       [self deleteAllByPredicate:[NSPredicate predicateWithFormat:@"dataexport == %@", de] entityName:@"DataExportMsg"];
    }
}

-(void) updateDataExport:(DataExport*)de withResult:(ACRemoteActionResultAsync*)result {
    if ( de == nil ) return;
    

    if ( result.status.success ) {
        if ( result.newobject_result ) {
            
            if ( result.newobject_result.status.success == NO ) {
                
                if ( result.newobject_result.status.code == RESULTCODE_CONFIRMATION_NEEDED
                     && result.newobject_result.confirmrefid ) {
                    de.confirmrefid = result.newobject_result.confirmrefid;
                }
            
                if ( result.newobject_result.vresult
                    && result.newobject_result.vresult.count > 0 ) {
                    
                    BOOL err = NO;
                    BOOL msg = NO;
                    [self removeDataExportMessages:de];
                    
                    for(int a=0;a<result.newobject_result.vresult.count;a++) {
                        ACRemoteActionVerificationResultItem *i = [result.newobject_result.vresult objectAtIndex:a];
                        if ( i ) {
                            [self addMessage:i.msg asError:i.err forDataExport:de withSave:NO];
                            msg = YES;
                            if ( i.err ) {
                                err = YES;
                            }
                        }
                        
                    }
                    
                    if ( msg ) {
                        de.status = [NSNumber numberWithInt:err ? QSTATUS_ERROR : QSTATUS_WARNING];
                        de.uptodate = [NSDate date];
                        [self save];
                    } else {
                        [self updateDataExport:de withErrorMessage:nil];
                    }

                    
                } else {
                    [self updateDataExport:de withErrorMessage:[ACRemoteAction messageByResultCode:result.newobject_result.status.code]];
                }
                
            }
            else {
                
                de.status = [NSNumber numberWithInt:QSTATUS_DONE];
                de.uptodate = [NSDate date];
                de.shortcut = result.newobject_result.shortcut;
                de.number = result.newobject_result.number;
                
                            
                [self save];
            }
            
            
        }
    } else if ( result ) {
        [self updateDataExport:de withErrorMessage:[ACRemoteAction messageByResultCode:result.status.code]];
    }
}

-(void) updateDataExport:(DataExport*)de withErrorMessage:(NSString*)msg {
    if ( de == nil ) return;
    
    de.status = [NSNumber numberWithInt:QSTATUS_ERROR];
    de.uptodate = [NSDate date];
    [self removeDataExportMessages:de];
    [self addMessage:msg asError:YES forDataExport:de withSave:YES];
}

-(void) addMessage:(NSString*)msg asError:(BOOL)err forDataExport:(DataExport*)de withSave:(BOOL)s {
    if ( de == nil ) return;
    if ( msg == nil ) msg = NSLocalizedString(@"Nieokreślony błąd", nil);
    
    DataExportMsg *m = [[DataExportMsg alloc] initWithEntity:[NSEntityDescription entityForName:@"DataExportMsg" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    
    if ( m ) {
        m.message = msg;
        m.error = [NSNumber numberWithBool:err];
        [self.managedObjectContext insertObject:m];
        m.dataexport = de;
        
        if ( s ) {
         [self save];
        }
    }
    

}

-(void)removeDataExport:(DataExport*)de {
    if ( de ) {
        [self removeDataExportMessages:de];
        [self.managedObjectContext deleteObject:de];
    }
}


- (NSFetchedResultsController *)fetchedDataExportQueue {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user = %@ AND status <> %@ AND status <> %@ AND status <> %@ AND (order <> nil OR invoice <> nil OR contractor <> nil )", [self getCurrentUser], [NSNumber numberWithInt:QSTATUS_DONE], [NSNumber numberWithInt:QSTATUS_DELETED], [NSNumber numberWithInt:QSTATUS_EDITING]];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"DataExport" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO ];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(NSFetchedResultsController *)fetchedDataExportResultMessages:(DataExport*)de {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"dataexport = %@", de];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"DataExportMsg" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"error" ascending:NO ];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark Articles

-(Article*) jsonToArticle:(NSDictionary *)dict qty:(NSNumber**)Qty warehouseid:(NSString **)WareHouseId warehousename:(NSString **)WareHouseName {
    
    if ( !dict
        || ![dict isKindOfClass:[NSDictionary class]] )
        return nil;
    
    
    NSString *shortcut = [dict valueForKey:@"Code"];
    
    if ( shortcut == nil
        || shortcut.length < 1) return nil;
    
    Article *a = [[Article alloc] initWithEntity:[NSEntityDescription entityForName:@"Article" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    
    
    a.codeex = [dict stringValueForKey:@"CodeEx"];
    a.desc = [dict stringValueForKey:@"Description"];
    a.group = [dict stringValueForKey:@"Group"];
    a.name = [dict stringValueForKey:@"Name"];
    a.pkwiu = [dict stringValueForKey:@"PKWIU"];
    a.shortcut = [shortcut trim];
    a.unit = [dict stringValueForKey:@"Unit"];
    a.unitpurchasecurr = [dict stringValueForKey:@"UnitPurchaseCurr"];
    a.unitpurchaseprice = [dict numberValueForKey:@"UnitPurchasePrice"];
    a.unitretailcurr = [dict stringValueForKey:@"UnitRetailCurr"];
    a.unitretailprice = [dict numberValueForKey:@"UnitRetailPrice"];
    a.unitspecialcurr = [dict stringValueForKey:@"UnitSpecialCurr"];
    a.unitspecialprice = [dict numberValueForKey:@"UnitSpecialPrice"];
    a.unitwholesalecurr = [dict stringValueForKey:@"UnitPurchaseCurr"];
    a.unitwholesaleprice = [dict numberValueForKey:@"UnitPurchasePrice"];
    a.vatrate = [dict stringValueForKey:@"VATrate"];
    a.vatpercent = [NSNumber numberWithDouble:[a.vatrate doubleValue]];
    
    if ( [a.vatpercent  doubleValue] < 0 ) {
        a.vatpercent = [NSNumber numberWithDouble:0.00];
    }
    
    NSNumber *price = a.unitretailprice;
    NSString *curr = a.unitretailcurr;
    
    if ( [price doubleValue] <= 0 ) {
        price = a.unitwholesaleprice;
        curr = a.unitwholesalecurr;
    }
    
    if ( [price doubleValue] <= 0 ) {
        price = a.unitspecialprice;
        curr = a.unitspecialcurr;
    }
    
    a.unitlistpricenet = price;
    a.unitlistpricecurr = curr;
    a.unitlistpricegross = [NSNumber numberWithDouble:[a.unitlistpricenet doubleValue]+ ( [a.unitlistpricenet doubleValue] * [a.vatpercent doubleValue] / 100.00 )];
    
    if ( Qty ) {
        *Qty = [dict numberValueForKey:@"Qty"];
    }
    
    if ( WareHouseId ) {
       *WareHouseId = [dict stringValueForKey:@"WareHouseID"];
    }
    
    if ( WareHouseName ) {
       *WareHouseName = [dict stringValueForKey:@"WareHouseName"];
    }
    

    return a;
}

-(ArticleSHItem*) jsonToArticleSHItem:(NSDictionary *)dict {
    
    if ( !dict
        || ![dict isKindOfClass:[NSDictionary class]] )
        return nil;
    
    
    ArticleSHItem *i = [[ArticleSHItem alloc] initWithEntity:[NSEntityDescription entityForName:@"ArticleSHItem" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    
    i.cshortcut = [dict stringValueForKey:@"ContractorID"];
    i.cname = [dict stringValueForKey:@"ContractorName"];
    i.dateofsale = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"DateOfSale"]];
    i.invoice = [dict stringValueForKey:@"Invoice"];
    i.whdoc = [dict stringValueForKey:@"WhDoc"];
    i.pricenet = [dict numberValueForKey:@"PriceNet"];
    i.qty = [dict numberValueForKey:@"Qty"];
    i.unit = [dict stringValueForKey:@"Unit"];
    i.totalnet = [dict numberValueForKey:@"TotalNet"];
    i.totalgross = [dict numberValueForKey:@"TotalGross"];

    return i;

}

-(NSNumber*) articleTotalQty:(Article*)article WareHouseId:(NSString*)whid {
 
    NSNumber *result = [NSNumber numberWithDouble:0.00];
    
    NSExpression *ex = [NSExpression expressionForFunction:@"sum:"
                                                 arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"qty"]]];
    
    NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
    [ed setName:@"result"];
    [ed setExpression:ex];
    [ed setExpressionResultType:NSDoubleAttributeType];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPropertiesToFetch:[NSArray arrayWithObject:ed]];
    [request setResultType:NSDictionaryResultType];
    
    User *user = [self getCurrentUser];
    
    
    if ( whid != nil ) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"user = %@ AND article == %@ AND whid == %@", user, article, whid]];
    } else {
        [request setPredicate:[NSPredicate predicateWithFormat:@"user = %@ AND article == %@", user, article]];
    }
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WareHouse"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    if ( results
        && results.count > 0 ) {
        NSDictionary *resultsDictionary = [results objectAtIndex:0];
        result = [resultsDictionary objectForKey:@"result"];
    }
    
    return result;
    
}

-(void) addArticleSHItem:(ArticleSHItem*)item article:(Article*)a {
    
    if ( !item ) return;
    
    [self.managedObjectContext insertObject:item];
    
    item.user = [self getCurrentUser];
    item.article = a;
    
    [self save];
}


-(void) updateArticle:(Article*)article qty:(NSNumber*)Qty warehouseid:(NSString *)WareHouseId warehousename:(NSString *)WareHouseName {
    
    if ( !article ) return;
    Article *a = [self fetchArticleByShortcut:article.shortcut];
    if (a) {
        
        a.desc = article.desc;
        a.group = article.group;
        a.name = article.name;
        a.pkwiu = article.pkwiu;
        a.shortcut = article.shortcut;
        a.unit = article.unit;
        a.unitlistpricecurr = article.unitlistpricecurr;
        a.unitlistpricegross = article.unitlistpricegross;
        a.unitlistpricenet = article.unitlistpricenet;
        a.unitpurchasecurr = article.unitpurchasecurr;
        a.unitpurchaseprice = article.unitpurchaseprice;
        a.unitretailcurr = article.unitretailcurr;
        a.unitretailprice = article.unitretailprice;
        a.unitspecialcurr = article.unitspecialcurr;
        a.unitspecialprice = article.unitspecialprice;
        a.unitwholesalecurr = article.unitwholesalecurr;
        a.unitwholesaleprice = article.unitwholesaleprice;
        a.vatrate = article.vatrate;
        a.vatpercent = article.vatpercent;
        
    } else {
        a = article;
        [self.managedObjectContext insertObject:a];
        a.user = [self getCurrentUser];
    }
    
    [self deleteAllByPredicate:[NSPredicate predicateWithFormat:@"article = %@ AND uptodate < %@ AND user = %@", a, [[NSDate date] dateByAddingTimeInterval:-600], [self getCurrentUser]] entityName:@"WareHouse"];
    
    WareHouse *wh = [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"whid = %@ AND name = %@ AND article = %@ AND user = %@", WareHouseId, WareHouseName, a, [self getCurrentUser]] entityName:@"WareHouse"];
    
    User *user = [self getCurrentUser];
    
    if ( wh == nil ) {
        wh = [[WareHouse alloc] initWithEntity:[NSEntityDescription entityForName:@"WareHouse" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
        [self.managedObjectContext insertObject:wh];
        wh.whid = WareHouseId;
        wh.name = WareHouseName;
        wh.user = user;
    }
    
    wh.article = a;
    wh.qty = Qty;
    wh.uptodate = [NSDate date];
    
    a.qty = [self articleTotalQty:a WareHouseId:nil];
    a.uptodate = [NSDate date];
    a.visible = [NSNumber numberWithBool:YES];

    [self save];
}

-(Article*) fetchArticleByShortcut:(NSString *)Shortcut {

    return [self fetchItemByShortcut:Shortcut entityName:@"Article"];
}

-(Article*) fetchArticle:(Article *)article {
    return [self fetchObject:article entityName:@"Article"];
}

-(NSFetchedResultsController *)fetchedArticlesWithText:(NSString *)txt {
    
    [self updateVisibilityStatusWithEntityName:@"Article"];
    
    txt = [NSString stringWithFormat:@"*%@*", txt];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user == %@ AND (shortcut LIKE[c] %@ OR name LIKE[c] %@) AND visible == YES", [self getCurrentUser], txt, txt];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Article" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"name.firstChar" cacheName:nil];
}

-(void) addArticle:(Article*)article ToOrder:(Order*)order {
  
    if ( !article || !order ) return;
    
    OrderItem *oi = [[OrderItem alloc] initWithEntity:[NSEntityDescription entityForName:@"OrderItem" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    
    oi.shortcut = article.shortcut;
    oi.name = article.name;
    oi.qty = [NSNumber numberWithDouble:1.00];
    oi.unit = article.unit;
    oi.price = article.unitlistpricenet;
    oi.discount = [NSNumber numberWithDouble:0.00];
    oi.discountpercent = [NSNumber numberWithDouble:0.00];
    oi.pricenet = article.unitlistpricenet;
    oi.totalnet = article.unitlistpricenet;
    oi.vatrate = article.vatrate;
    oi.vatvalue = [NSNumber numberWithDouble:[article.unitlistpricegross doubleValue] - [article.unitlistpricenet doubleValue]];
    oi.totalgross = article.unitlistpricegross;

    [self.managedObjectContext insertObject:oi];
    
    oi.order = order;
    
    if ( article.unitlistpricecurr != nil
         && ![article.unitlistpricecurr isEqualToString:@""]
         && ( order.currency == nil
             || [order.currency isEqualToString:@""] ) ) {
             order.currency = [NSString stringWithString:article.unitlistpricecurr];
         }

    [self save];
    [self updateOrderSummary:order];
}

-(void) addArticleByShortcut:(NSString*)shortcut ToOrder:(Order*)order {
    [self addArticle:[self fetchArticleByShortcut:shortcut] ToOrder:order];
}

- (NSFetchedResultsController *)fetchedWarehousesForArticle:(Article *)article {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"article = %@ AND user = %@", article, [self getCurrentUser]];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"WareHouse" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"qty" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (NSFetchedResultsController *)fetchedSalesHistoryForArticle:(Article *)article {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"article = %@ AND user = %@", article, [self getCurrentUser]];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ArticleSHItem" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateofsale" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(double) articleQtyByUserWarehouse:(Article *)article {
    
     WareHouse *W = [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"article = %@ AND user = %@ AND user.warehouse != nil AND user.warehouse != %@ AND whid == user.warehouse", article, [self getCurrentUser], @""] entityName:@"WareHouse"];
    
    return W == nil ? 0 : [W.qty doubleValue];
}

-(void) removeArticleSHItems:(Article*)article {
    
    [self deleteAllByPredicate:[NSPredicate predicateWithFormat:@"article = %@ AND user = %@", article, [self getCurrentUser]] entityName:@"ArticleSHItem"];
    
}

-(void) updateArticleSHdate:(Article*)article {
    
    article.sh_uptodate = [NSDate date];
    [self save];
}

#pragma mark Payments

- (NSFetchedResultsController *)fetchedPaymentsForContractor:(Contractor *)c {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"contractor = %@ AND user = %@", c, [self getCurrentUser]];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Payment" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateofissue" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(Payment*) jsonToPaymentItem:(NSDictionary *)dict {
    
    if ( !dict
        || ![dict isKindOfClass:[NSDictionary class]] )
        return nil;
    

    Payment *p = [[Payment alloc] initWithEntity:[NSEntityDescription entityForName:@"Payment" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    
    p.number = [dict stringValueForKey:@"DocNum"];
    p.dateofissue = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"DateOfIssue"]];
    p.dateofsale = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"DateOfSale"]];
    p.paymentform = [dict stringValueForKey:@"PaymentMethod"];
    p.termdate = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"PaymentDeadline"]];
    p.remaining = [dict numberValueForKey:@"Remaining"];
    p.totalnet = [dict numberValueForKey:@"TotalNet"];
    p.totalgross = [dict numberValueForKey:@"TotalGross"];
        
    return p;
}

-(void) insertPaymentItem:(Payment*)payment contractor:(Contractor*)c {
    
    [self.managedObjectContext insertObject:payment];
    payment.contractor = c;
    payment.user = [self getCurrentUser];
    
    [self save];
}

-(void) removeAllContractorPayments:(Contractor*)c {
    
    [self deleteAllByPredicate:[NSPredicate predicateWithFormat:@"user = %@ AND contractor == %@", [self getCurrentUser], c] entityName:@"Payment"];
    
}

- (NSNumber*) paymentSummaryForContractor:(Contractor*)c field:(NSString *)f predicte:(NSPredicate*)p {
    
    NSNumber *result = [NSNumber numberWithDouble:0.00];
    
    NSExpression *ex = [NSExpression expressionForFunction:@"sum:"
                                                 arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:f]]];
    
    NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
    [ed setName:@"result"];
    [ed setExpression:ex];
    [ed setExpressionResultType:NSDoubleAttributeType];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPropertiesToFetch:[NSArray arrayWithObject:ed]];
    [request setResultType:NSDictionaryResultType];
    
    [request setPredicate:p];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Payment"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    if ( results
        && results.count > 0 ) {
        NSDictionary *resultsDictionary = [results objectAtIndex:0];
        result = [resultsDictionary objectForKey:@"result"];
    }
    
    return result;
}

-(NSDictionary *) paymentSummaryForContractor:(Contractor*)c {
    
    NSNumber *totalgross = [self paymentSummaryForContractor:c field:@"totalgross" predicte:[NSPredicate predicateWithFormat:@"user = %@ AND contractor = %@", [self getCurrentUser], c]];


    NSNumber *before = [self paymentSummaryForContractor:c field:@"remaining" predicte:[NSPredicate predicateWithFormat:@"contractor == %@ AND termdate >= %@ AND user = %@", c, [NSDate date], [self getCurrentUser]]];
    
    NSNumber *after= [self paymentSummaryForContractor:c field:@"remaining" predicte:[NSPredicate predicateWithFormat:@"contractor == %@ AND termdate < %@ AND user = %@", c, [NSDate date], [self getCurrentUser]]];
    
    NSArray *keys = [NSArray arrayWithObjects:@"total", @"before", @"after", nil];
    NSArray *values = [NSArray arrayWithObjects:totalgross, before, after, nil];
    
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
}

#pragma mark Recent and Fav Common

-(id) fetchRFItem:(NSString*)entName forObject:(id)obj {
    if ( obj == nil ) return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *p1;
    
    if ( [obj isKindOfClass:[Contractor class]] ) {
        p1 = [NSPredicate predicateWithFormat:@"contractor = %@", obj];
    } else if ( [obj isKindOfClass:[Invoice class]] ) {
        p1 = [NSPredicate predicateWithFormat:@"invoice = %@", obj];
    } else if ( [obj isKindOfClass:[Order class]] ) {
        p1 = [NSPredicate predicateWithFormat:@"order = %@", obj];
    } else {
        return nil;
    }
    
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"user = %@", [self getCurrentUser]];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:p1, p2, nil]];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:entName inManagedObjectContext: self.managedObjectContext]];
    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error == nil && r.count > 0 ) {
        return [r objectAtIndex:0];
    }
    
    return nil;
}

#pragma mark Recent

-(Recent*) fetchRecentItemForObject:(id)obj {
    return [self fetchRFItem:@"Recent" forObject:obj];
};

-(void) updateRecentListWithObject:(id)obj {
    
    if ( !obj
         || ( ![obj isKindOfClass:[Contractor class]]
              && ![obj isKindOfClass:[Invoice class]]
              && ![obj isKindOfClass:[Order class]]  ) ) {
        return;
    }
    
    Recent *r = [self fetchRecentItemForObject:obj];
    if ( r == nil ) {
        
        r = [[Recent alloc] initWithEntity:[NSEntityDescription entityForName:@"Recent" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        r.user = [self getCurrentUser];
        
    }
    
    if ( [obj isKindOfClass:[Contractor class]] ) {
        r.contractor = obj;
    } else if ( [obj isKindOfClass:[Invoice class]] ) {
        r.invoice = obj;
    } else if ( [obj isKindOfClass:[Order class]] ) {
        r.order = obj;
    } else {
        return;
    }
    
    r.last_access = [NSDate date];
    [self save];
}

#pragma mark Favorites

-(Favorite*) fetchFavoriteItemForObject:(id)obj {

    return [self fetchRFItem:@"Favorite" forObject:obj];

}

-(void) addToFavorites:(id)obj {
    
    Favorite *f = [self fetchFavoriteItemForObject:obj];
    if ( f == nil ) {
        f = [[Favorite alloc] initWithEntity:[NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        if ( [obj isKindOfClass:[Contractor class]] ) {
            f.contractor = obj;
        } else if ( [obj isKindOfClass:[Invoice class]] ) {
            f.invoice = obj;
        } else if ( [obj isKindOfClass:[Order class]] ) {
            f.order = obj;
        } else {
            return;
        }
        
        f.user = [self getCurrentUser];
        [self save];
    }
    
}

-(NSFetchedResultsController *)fetchedFavorites {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Favorite" inManagedObjectContext: self.managedObjectContext]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user = %@ AND ((contractor != nil AND contractor.visible == YES) OR (invoice != nil AND invoice.visible == YES) OR (order != nil AND order.visible == YES)) ", [self getCurrentUser]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}


-(void) removeFavoriteItem:(id)obj {
    Favorite *f = [self fetchFavoriteItemForObject:obj];
    if ( f ) {
        [self.managedObjectContext deleteObject:f];
    }
}
#pragma mark History

-(NSFetchedResultsController *)fetchedHistory {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user = %@ AND ( (order <> nil AND order.visible = YES AND (order.dataexport = nil OR order.dataexport.status <> %i)) OR (invoice <> nil AND invoice.visible = YES AND (invoice.dataexport = nil OR invoice.dataexport.status <> %i)) OR (contractor <> nil AND contractor.visible = YES AND (contractor.dataexport = nil OR contractor.dataexport.status <> %i))  )", [self getCurrentUser], QSTATUS_DONE];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Recent" inManagedObjectContext: self.managedObjectContext]];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"last_access" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(void) removeRecentItem:(id)obj {
    Recent *r = [self fetchRecentItemForObject:obj];
    if ( r ) {
        [self.managedObjectContext deleteObject:r];
    }
}



#pragma mark Auth

-(Server*)getCurrentServer {
    
    NSString *serverinstanceid = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverinstanceid_preference"];
    
    Server *server = [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"instanceid = %@", serverinstanceid] entityName:@"Server"];
    
    if ( server == nil ) {
        
        server = [[Server alloc] initWithEntity:[NSEntityDescription entityForName:@"Server" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        [self.managedObjectContext insertObject:server];
        server.instanceid = serverinstanceid;
    }
    


    return server;
}

-(void)updateServerData {
    
    Server *server = [self getCurrentServer];
    
    if ( server
         && Common.HelloData != nil ) {
        
        server.drv_mfr =  Common.HelloData.drv_mfr;
        server.drv_ver = Common.HelloData.drv_ver;
        server.erp_mfr = Common.HelloData.erp_mfr;
        server.erp_name = Common.HelloData.erp_name;
        server.svr_vmajor = [NSNumber numberWithInt:Common.HelloData.ver_major];
        server.svr_vminor = [NSNumber numberWithInt:Common.HelloData.ver_minor];
        server.online_validitytime = [NSNumber numberWithInt:Common.HelloData.online_validitytime];
        server.offline_validitytime = [NSNumber numberWithInt:Common.HelloData.offline_valitidytime];
        server.cap = [NSNumber numberWithLongLong:Common.HelloData.cap];
        
        [self save];
    }
    
}

-(User*)getCurrentUser {
    Server *server = [self getCurrentServer];
    User *user = [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"login = %@ AND server = %@", [Common.Login lowercaseString], server] entityName:@"User"];
    
    if ( user == nil ) {
        
        user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        user.login = [Common.Login lowercaseString];
        user.server = server;
        [self.managedObjectContext insertObject:user];
        [self save];
    }
    
    return user;
}

-(void)clearUserPassword {
    User *user = [self getCurrentUser];
    user.password = @"";
    [self save];
}

-(void)onLogin:(ACRemoteActionResultLogin*)login_result {
    
    User *user = [self getCurrentUser];
    user.password = [Common.Password HMACWithSecret:@"{}"];
    user.lastaccess = [NSDate date];
    
    if ( login_result
        && login_result.userdetails ) {
        user.name = login_result.userdetails.name;
        user.warehouse = login_result.userdetails.default_warehouse;
    }
    
    [self save];
    
    Server *server = [self getCurrentServer];
    
    if ( Common.HelloData == nil ) {
        Common.HelloData = [[ACRemoteActionResultHello alloc] init];
    }
    
    Common.HelloData.drv_mfr = server.drv_mfr;
    Common.HelloData.drv_ver = server.drv_ver;
    Common.HelloData.erp_mfr = server.erp_mfr;
    Common.HelloData.erp_name = server.erp_name;
    Common.HelloData.ver_major = [server.svr_vmajor intValue];
    Common.HelloData.ver_minor = [server.svr_vminor intValue];
    Common.HelloData.cap = [server.cap longLongValue];
    
    [ACRemoteOperation dictinaryOfType:DICTTYPE_CONTRACTOR_PAYMENTMETHODS forContractor:@""];
    [ACRemoteOperation dictinaryOfType:DICTTYPE_NEWORDER_STATE forContractor:@""];
    
    [ACRemoteOperation dictinaryOfType:DICTTYPE_CONTRACTOR_COUNTRY forContractor:@""];
    [ACRemoteOperation dictinaryOfType:DICTTYPE_CONTRACTOR_REGION forContractor:@""];
    
}


-(BOOL)localPasswordPass {
    User *user = [self getCurrentUser];
    return user.password.length > 0 && [user.password isEqualToString:[Common.Password HMACWithSecret:@"{}"]];
}

#pragma mark Limits

-(Limit*) jsonToLimitItem:(NSDictionary *)dict {
    
    if ( !dict
        || ![dict isKindOfClass:[NSDictionary class]] )
        return nil;
    
    
    Limit *l = [[Limit alloc] initWithEntity:[NSEntityDescription entityForName:@"Limit" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    
    
    l.currency = [dict stringValueForKey:@"Currency"];
    l.limit = [dict numberValueForKey:@"Limit"];
    l.overdue = [dict numberValueForKey:@"Overdue"];
    l.overdueallowed = [dict numberValueForKey:@"OverdueAllowed"];
    l.remain = [dict numberValueForKey:@"Remain"];
    l.unlimited = [dict numberValueForKey:@"Unlimited"];
    l.used = [dict numberValueForKey:@"Used"];
    
    return l;
}

-(Limit*) contractor1stLimit:(Contractor*)contractor {
    
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"user == %@ AND contractor == %@", [self getCurrentUser], contractor] entityName:@"Limit"];
    
}


-(void) insertLimitItem:(Limit*)limit contractor:(Contractor*)c {
    
    [self.managedObjectContext insertObject:limit];
    limit.contractor = c;
    limit.user = [self getCurrentUser];
    
    [self save];
}

-(void) removeAllContractorLimits:(Contractor*)c {
    [self deleteAllByPredicate:[NSPredicate predicateWithFormat:@"user = %@ AND contractor == %@", [self getCurrentUser], c] entityName:@"Limit"];
}

-(NSFetchedResultsController *)fetchedLimitsForContractor:(Contractor *)c {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user = %@ AND contractor = %@", [self getCurrentUser], c];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Limit" inManagedObjectContext: self.managedObjectContext]];
    

    NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"currency" ascending:NO], nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark Others

-(void)updateDictionaryOfType:(int)type forContractor:(NSString*)contractor withData:(ACRemoteActionResultDict*)dict {
    
    User *user = [self getCurrentUser];
    [self deleteAllByPredicate:[NSPredicate predicateWithFormat:@"type = %i AND user = %@", type, user] entityName:@"Dict"];
    
    Contractor *c = nil;
    if ( contractor && contractor.length > 0 ) {
        c = [self fetchContractorByShortcut:contractor];
    }
    
    Dict *item;
    
    for(int a=0;a<dict.items.count;a++) {
         item = [[Dict alloc] initWithEntity:[NSEntityDescription entityForName:@"Dict" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        [self.managedObjectContext insertObject:item];
        
        ACRemoteDictionaryItem *d = [dict ItemAtIndex:a];

        item.type = [NSNumber numberWithInt:type];
        item.value = d.name;
        item.shortcut = d.shortcut;
        item.priority = [NSNumber numberWithInt:d.pri];
        item.user = user;
        item.contractor = c;
    }
    
    [self save];
    
}

- (NSFetchedResultsController *)fetchedDictionaryOfType:(int)type  forContractor:(Contractor *)c {

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user = %@ AND contractor = %@ AND type = %i", [self getCurrentUser], c, type];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Dict" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES ];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(NSArray*)valuesOfDictionaryOfTpe:(int)type forContractor:(Contractor*)c {
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSFetchedResultsController *f = [self fetchedDictionaryOfType:type forContractor:c];
    
    NSError *error = nil;
    [f performFetch:&error];
    if ( error ) {
        NSLog(@"%@", error.description);
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[f sections] objectAtIndex:0];
        if ( [sectionInfo numberOfObjects] > 0 ) {
            
            for(int a=0;a<[sectionInfo numberOfObjects];a++) {
                Dict *dict = [f objectAtIndexPath:[NSIndexPath indexPathForRow:a inSection:0]];
                if ( dict ) {
                    [arr addObject:[NSString stringWithString:dict.value]];
                }
            }
        }
    }
    
    return arr;
}

-(IndividualPrice *)individualPriceForContractor:(Contractor*)contractor article:(Article*)article currency:(NSString*)currency {
    if ( contractor == nil || article == nil ) return nil;
    
    
    return [self fetchItemByPredicate:[NSPredicate predicateWithFormat:@"user = %@ AND contractor = %@ AND article = %@ AND currency = %@", [self getCurrentUser], contractor, article, currency] entityName:@"IndividualPrice"];
};

-(IndividualPrice *)individualPriceForContractor:(NSString*)contractor articleShortcut:(NSString*)article currency:(NSString*)currency {
    
    Contractor *c = [self fetchContractorByShortcut:contractor];
    if ( c ) {
        Article *a = [self fetchArticleByShortcut:article];
        if ( a ) {
            return [self individualPriceForContractor:c article:a currency:currency];
        }
    }
    
    return nil;
}

-(void)updateIndividualPriceForContractor:(Contractor*)contractor withPrice:(NSNumber*)pricenet article:(Article*)article currency:(NSString*)currency {
    
    if ( contractor == nil || pricenet == nil || article == nil ) return;
    
    IndividualPrice *price = [self individualPriceForContractor:contractor article:article currency:currency];
    
    if ( price == nil ) {
        
        price = [[IndividualPrice alloc] initWithEntity:[NSEntityDescription entityForName:@"IndividualPrice" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        [self.managedObjectContext insertObject:price];
        price.contractor = contractor;
        price.article = article;
        price.user = [self getCurrentUser];
        price.currency = currency;
    }
    
    price.pricenet = pricenet;
    [self save];
}

-(void)updateIndividualPriceForContractor:(NSString*)contractor withPrice:(NSNumber*)pricenet articleShortcut:(NSString*)article currency:(NSString*)currency {
    

    Contractor *c = [self fetchContractorByShortcut:contractor];
    if ( c ) {
        Article *a = [self fetchArticleByShortcut:article];
        if ( a ) {
            [self updateIndividualPriceForContractor:c withPrice:pricenet article:a currency:currency];
        }
    }
    
}


-(BOOL) save {
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    
    if ( error ) {
        NSLog(@"DBSaveError(%i): %@", [NSThread isMainThread], error);
    }
    
    return error == nil;
}




@end
