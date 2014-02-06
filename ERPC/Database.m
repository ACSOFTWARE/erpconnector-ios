//
//  Database.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 12.10.2012.
//  Copyright (c) 2012 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Database.h"
#import "ERPCCommon.h"
#import "Contractor.h"
#import "Invoice.h"
#import "Payment.h"
#import "Recent.h"
#import "Favorite.h"

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

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
    if ( _persistentStoreCoordinator == nil ) {
        
        NSURL *storeURL = [[Common applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
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

#pragma mark Contractor

-(Contractor*) fetchContractorByShortcut:(NSString *)Shortcut {
    Contractor *result = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"shortcut == %@", Shortcut];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Contractor" inManagedObjectContext: self.managedObjectContext]];
    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error == nil && r.count > 0 ) {
        result = [r objectAtIndex:0];
    }
    
    return result;
};

- (NSFetchedResultsController *)fetchedContractorsWithText:(NSString *)txt {
    
    txt = [NSString stringWithFormat:@"*%@*", txt];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
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
    
    fetchRequest.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:p1, p2, p3, p4, p8, p9, p11, p12, p13, p14, p15, p16, p17, p18, p19, nil]];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Contractor" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"name.firstChar" cacheName:nil];
}

-(Contractor*) jsonToContractor:(NSDictionary *)dict {
    
    if ( !dict
        || ![dict isKindOfClass:[NSDictionary class]] )
        return nil;
    
    NSString *khid = [dict stringValueForKey:@"KHID"];
    
    if ( khid.length < 1) return nil;
    
    Contractor*c = [[Contractor alloc] initWithEntity:[NSEntityDescription entityForName:@"Contractor" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    c.shortcut = [khid trim];
    c.name = [dict stringValueForKey:@"KHNAZWA"];
    if ( c.name.length == 0 ) {
        c.name = c.shortcut;
    }
    c.nip = [dict stringValueForKey:@"KHNIP"];
    c.regon = [dict stringValueForKey:@"KHREGON"];
    c.region = [dict stringValueForKey:@"KHREGION"];
    c.country = [dict stringValueForKey:@"KHKRAJ"];
    c.postcode = [dict stringValueForKey:@"KHKODPOCZT"];
    c.city = [dict stringValueForKey:@"KHMIASTO"];
    c.street = [dict stringValueForKey:@"KHULICA"];
    c.houseno = [dict stringValueForKey:@"KHNUMER"];
    c.tel1 = [dict stringValueForKey:@"KHTEL1"];
    c.tel2 = [dict stringValueForKey:@"KHTEL2"];
    c.tel3 = [dict stringValueForKey:@"KHTEL3"];
    c.email1 = [dict stringValueForKey:@"KHEMAIL1"];
    c.email2 = [dict stringValueForKey:@"KHEMAIL2"];
    c.email3 = [dict stringValueForKey:@"KHEMAIL3"];
    c.www1 = [dict stringValueForKey:@"KHWWW1"];
    c.www2 = [dict stringValueForKey:@"KHWWW2"];
    c.www3 = [dict stringValueForKey:@"KHWWW3"];
    c.invoices_last_resp_date = nil;
    c.payments_last_resp_date = nil;
    
    
    return c;
}

-(void) updateContractor:(Contractor*)contractor {
    if ( !contractor ) return;
    Contractor*c = [self fetchContractorByShortcut:contractor.shortcut];
    if (c) {
        c.name = contractor.name;
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
    } else {
        c = contractor;
       [self.managedObjectContext insertObject:c];
    }
    
    c.updated = [NSDate date];
    NSError *error = nil;
    [self.managedObjectContext save:&error];
}

#pragma mark Invoices

- (NSFetchedResultsController *)fetchedInvoicesForContractor:(Contractor *)c {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"customer = %@", c];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Invoice" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateofissue" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(Invoice*) fetchInvoiceByShortcut:(NSString *)Shortcut {
    Invoice *result = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"shortcut == %@", Shortcut];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Invoice" inManagedObjectContext: self.managedObjectContext]];
    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error == nil && r.count > 0 ) {
        result = [r objectAtIndex:0];
    }
    
    return result;
};

-(Invoice*) jsonToInvoice:(NSDictionary *)dict {
    
    if ( !dict
        || ![dict isKindOfClass:[NSDictionary class]] )
        return nil;
    
    NSString *fvid = [dict valueForKey:@"FVID"];
    
    if ( fvid == nil
        || fvid.length < 1) return nil;
    
    Invoice *i = [[Invoice alloc] initWithEntity:[NSEntityDescription entityForName:@"Invoice" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:nil];
    i.shortcut = [fvid trim];
    
    i.number = [dict stringValueForKey:@"FVNUMER"];
    i.dateofissue = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"FVDATAWYST"]];
    i.totalnet = [dict numberValueForKey:@"FVNETTO"];
    i.totalgross = [dict numberValueForKey:@"FVBRUTTO"];
    i.remaining = [dict numberValueForKey:@"FVPOZOSTALO"];
    i.paid = [dict numberValueForKey:@"FVROZLICZONO"];
    i.paymentform = [dict stringValueForKey:@"FVFORMAP"];
    i.termdate = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"FVTERMINP"]];
    
    
    return i;
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
        i.paymentform = invoice.paymentform;

    } else {
        i = invoice;
        [self.managedObjectContext insertObject:i];
    }
    
    i.updated = [NSDate date];
    i.customer = c;
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
}

#pragma mark Payments

- (NSFetchedResultsController *)fetchedPaymentsForContractor:(Contractor *)c {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"contractor = %@", c];
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
    
    p.number = [dict stringValueForKey:@"PLNUMER"];
    p.dateofissue = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"PLDATAWYST"]];
    p.dateofsale = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"PLDATAS"]];
    p.paymentform = [dict stringValueForKey:@"PLFORMAP"];
    p.termdate = [NSDate dateWithTimeIntervalSince1970:[dict intValueForKey:@"PLTERMINP"]];
    p.remaining = [dict numberValueForKey:@"PLPOZOSTALO"];
    p.totalnet = [dict numberValueForKey:@"PLWNETTO"];
    p.totalgross = [dict numberValueForKey:@"PLWBRUTTO"];
        
    return p;
}

-(void) insertPaymentItem:(Payment*)payment contractor:(Contractor*)c {
    
    [self.managedObjectContext insertObject:payment];
    payment.contractor = c;
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
}

-(void) removeAllContractorPayments:(Contractor*)c {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"contractor == %@", c];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Payment" inManagedObjectContext: self.managedObjectContext]];
    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error == nil && r.count > 0 ) {
        for(int a=0;a<r.count;a++) {
            [self.managedObjectContext deleteObject:[r objectAtIndex:a]];
        }
    }
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
    
    NSNumber *totalgross = [self paymentSummaryForContractor:c field:@"totalgross" predicte:[NSPredicate predicateWithFormat:@"contractor == %@", c]];

    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"contractor == %@", c];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"termdate >= %@", [NSDate date]];

    NSNumber *before = [self paymentSummaryForContractor:c field:@"remaining" predicte:[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:p1, p2, nil]]];
    
    p2 = [NSPredicate predicateWithFormat:@"termdate < %@", [NSDate date]];
    NSNumber *after= [self paymentSummaryForContractor:c field:@"remaining" predicte:[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:p1, p2, nil]]];
    
    NSArray *keys = [NSArray arrayWithObjects:@"total", @"before", @"after", nil];
    NSArray *values = [NSArray arrayWithObjects:totalgross, before, after, nil];
    
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
}

#pragma mark Recent and Fav Common

-(id) fetchRFItem:(NSString*)entName forContractor:(Contractor*)c orInvoice:(Invoice*)i {
    if ( !c && !i ) return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    if ( c ) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"contractor == %@", c];
    } else {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"invoice == %@", i];
    }
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:entName inManagedObjectContext: self.managedObjectContext]];
    NSError *error = nil;
    NSArray *r = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( error == nil && r.count > 0 ) {
        return [r objectAtIndex:0];
    }
    
    return nil;
}

#pragma mark Recent

-(Recent*) fetchRecentItemForContractor:(Contractor*)c orInvoice:(Invoice*)i {
    return [self fetchRFItem:@"Recent" forContractor:c orInvoice:i];
};

-(void) updateRecentListWithContractor:(Contractor*)c orInvoice:(Invoice*)i {
    Recent *r = [self fetchRecentItemForContractor:c orInvoice:i];
    if ( r == nil ) {
        r = [[Recent alloc] initWithEntity:[NSEntityDescription entityForName:@"Recent" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        r.contractor = c;
        r.invoice = i;
    }
    
    r.last_access = [NSDate date];

    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
}

#pragma mark Favorites

-(Favorite*) fetchFavoriteItemForContractor:(Contractor*)c orInvoice:(Invoice*)i {

    return [self fetchRFItem:@"Favorite" forContractor:c orInvoice:i];

}

-(void) addToFavorites:(Contractor*)c orInvoice:(Invoice*)i {
    
    Favorite *f = [self fetchFavoriteItemForContractor:c orInvoice:i];
    if ( f == nil ) {
        f = [[Favorite alloc] initWithEntity:[NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        f.order = 0;
        f.contractor = c;
        f.invoice = i;
        
        NSError *error = nil;
        [self.managedObjectContext save:&error];
    }
    
}

-(void) removeFavoriteItem:(Contractor*)c orInvoice:(Invoice*)i {
    Favorite *f = [self fetchFavoriteItemForContractor:c orInvoice:i];
    if ( f ) {
        [self.managedObjectContext deleteObject:f];
    }
}

#pragma mark History

-(NSFetchedResultsController *)fetchedHistory {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Recent" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"last_access" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark Favorites

-(NSFetchedResultsController *)fetchedFavorites {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Favorite" inManagedObjectContext: self.managedObjectContext]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark Others



@end
