//
//  ACUIDataVC.m
//  ERPC
//
//  Created by Przemysław Zygmunt on 11.08.2014.
//  Copyright (c) 2014 AC SOFTWARE SP. Z O.O. All rights reserved.
//

#import "ACUIDataVC.h"
#import "MFSideMenu.h"
#import "ERPCCommon.h"
#import "DataExport.h"

@interface ACUIDataVC ()

@end

@implementation ACUIDataVC {
    ACUIForm *_form;
    id _record;
    id _loadAfterLoaded;
    UIButton *favBtn;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionError:) name:kConnectionErrorNotification object:nil];
        
        _loadAfterLoaded = nil;
        
        _form = [[ACUIForm alloc] initWithFrame:self.view.frame];
        
        self.view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_form];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConnectionErrorNotification object:nil];
}

- (void)onConnectionError:(NSNotification *)notif {
    
    if ( _form.refreshPanel ) {
        _form.refreshPanel.refreshBtnHidden = NO;
    }
    
};


-(ACUIForm*)form {
    return _form;
}

-(id)record {
    return _record;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    if ( Common.navigationController.viewControllers.count > 1 ) {
        [self setupSideMenuBarButtonItem];
    }
    
    [super viewWillAppear:animated];
    
    if ( _loadAfterLoaded ) {
        [self showRecord:_loadAfterLoaded];
        _loadAfterLoaded = nil;
    } else if ( _record ) {
        [self showRecord:_record];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_form onFocusIn:nil];
}

-(BOOL)refreshPanelVisible {
    return _form.refreshPanel != nil;
}

-(void)setRefreshPanelVisible:(BOOL)refreshPanelVisible {
    if ( refreshPanelVisible ) {
        [self.form CreateRefreshPanel];
        [self.form.refreshPanel btnRefreshAddTarget:self action:@selector(refreshTouch:)];
    } else {
        [[self form] RemoveRefreshPanel];
    }
}

-(void)showRecord:(id)record andRefresh:(BOOL)refresh {
    
    if ( _record != nil ) {
        
        id _new = [self newRecord];
        
        if ( _new ) {
            _record = _new;
        }
        
        [_form onFocusIn:nil];
        
        if ( _form.refreshPanel ) {
            _form.refreshPanel.date = nil;
        }
        
        if ([self respondsToSelector:@selector(fetchData)]) {
            _record = [(ACUIDataVC <ACUIFormDataSource> *)self fetchData];
        }
        
        if ( _record ) {
            
            if ([self respondsToSelector:@selector(onDataView)]) {
                [(ACUIDataVC <ACUIFormDataSource> *)self onDataView];
            }
            
            if ( _form.refreshPanel
                 && [self respondsToSelector:@selector(getDate)]) {
                _form.refreshPanel.date = [(ACUIDataVC <ACUIFormDataSource> *)self getDate];
            }
            
            [Common.DB updateRecentListWithObject:_record];
            
            
            if ( refresh == YES ) {
                [self refreshTouch:nil];
            }
        }
    }
    

}

-(void)showRecord:(id)record {
    
    _record = record;
    
    if ( self.isViewLoaded == NO ) {
        _loadAfterLoaded = record;
    } else {
        [self showRecord:_record andRefresh:YES];
    }
}

- (BOOL) canRefresh {
    return YES;
}

- (void)_fetchRemoteDataWithRefreshTouch:(BOOL)rtouch {
    
    if ([self respondsToSelector:@selector(fetchRemoteDataWithRefreshTouch:)]) {
        [(ACUIDataVC <ACUIFormDataSource> *)self  fetchRemoteDataWithRefreshTouch:rtouch];
    }
}

- (void)_fetchRemoteDataByShortcut:(NSString*)shortcut RefreshTouch:(BOOL)rtouch {
    
    if ([self respondsToSelector:@selector(fetchRemoteDataByShortcut:RefreshTouch:)]) {
        [(ACUIDataVC <ACUIFormDataSource> *)self  fetchRemoteDataByShortcut:shortcut RefreshTouch:rtouch];
    }
}

- (void)_fetchRemoteDetailDataWithRefreshTouch:(BOOL)rtouch {
    
    if ([self respondsToSelector:@selector(fetchRemoteDetailDataWithRefreshTouch:)]) {
        [(ACUIDataVC <ACUIFormDataSource> *)self  fetchRemoteDetailDataWithRefreshTouch:rtouch];
    }
}

- (id)_fetchRecordByShortcut:(NSString*)shortcut {
    
    if ([self respondsToSelector:@selector(fetchRecordByShortcut:)]) {
        return [(ACUIDataVC <ACUIFormDataSource> *)self  fetchRecordByShortcut:shortcut];
    };
    
    return nil;
}

- (IBAction)refreshTouch:(id)sender {
    
    if ( [self canRefresh] ) {
        
        self.form.refreshPanel.refreshBtnHidden = YES;
        [Common.OpQueue cancelAllOperations];
  
        [self _fetchRemoteDetailDataWithRefreshTouch:sender != nil];
        [self _fetchRemoteDataWithRefreshTouch:sender != nil];
    }
    
}

-(DataExport*)_dataexport {
    if ([self respondsToSelector:@selector(dataexport)]) {
        return [(ACUIDataVC <ACUIFormDataSource> *)self dataexport];
    }
    
    return nil;
}

- (void)onRecordDetailData:(NSNotification *)notif {
    
    if ( self.form.refreshPanel ) {
        self.form.refreshPanel.refreshBtnHidden = NO;
    }
    
    if ( _record ) {
        [self showRecord:_record andRefresh:NO];
    }
    
};

- (id)newRecord {
    
    id result = nil;
    
    if ( _record ) {
        DataExport *de = [self _dataexport];
        if ( de
            && de.shortcut
            && de.shortcut.length > 0 ) {
            
            id r = [self _fetchRecordByShortcut:de.shortcut];
            
            if ( r && r != _record ) {
                result = r;
                [self _fetchRemoteDetailDataWithRefreshTouch:NO];
            }
        }
    }
    
    return result;
}

- (void)onRecordData:(NSNotification *)notif {
    
    if ( _record ) {
        [self showRecord:_record andRefresh:NO];
    }

}

- (void)onRecordAddDone:(NSNotification *)notif {
    
    BOOL show = YES;
    
    NSDictionary *dict = notif.userInfo;
    if ( dict && dict.count > 0 ) {
        NSString *shortcut = [dict valueForKey:@"Shortcut"];
        if ( shortcut && shortcut.length > 0 ) {
            [self _fetchRemoteDataByShortcut:shortcut RefreshTouch:NO];
            show = NO;
        };
    }
    
    if ( show ) {
        [self onRecordData:nil];
    }
    
}

- (BOOL)recordIsFavorite {
    return [Common.DB fetchFavoriteItemForObject:_record] != nil;
}

- (void)showFavBtn {
    favBtn = [self addFavButtonWithSelector:@selector(favTouch:)];
    favBtn.selected = [self recordIsFavorite];
}

- (void)removeRightNavBtn {
    [self removeRightButton];
    favBtn = nil;
}

- (void)favTouch:(id)sender {
    if ( favBtn ) {
        if ( [self recordIsFavorite] ) {
            [Common.DB removeFavoriteItem:_record];
            favBtn.selected = NO;
        } else {
            [Common.DB addToFavorites:_record];
            favBtn.selected = YES;
        }
    }

}

-(void)onKeyboardShow:(NSNotification *)notif {
    
    if ( _form ) {
        [_form onKeyboardVisible];
    }
    
}

-(void)onKeyboardHide:(NSNotification *)notif {
    
    if ( _form ) {
        [_form onKeyboardHide];
    }
}


@end
