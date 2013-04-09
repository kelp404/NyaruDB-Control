//
//  MainWindowController.h
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/29.
//
//

#import <Cocoa/Cocoa.h>

@class QuerySplitView;
@class NyaruDB;
@class CoffeeCocoa;

@interface MainWindowController : NSWindowController <NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    // UI
    IBOutlet NSTextField *_path;
    IBOutlet NSTextField *_newCollection;
    IBOutlet NSTableView *_tableCollections;
    IBOutlet NSTabView *_tabQuery;
    // in tab
    NSUInteger _tabIncrement;
    IBOutlet QuerySplitView *_splitQuery;
    
    // database
    NyaruDB *_db;
    
    // CoffeeCocoa
    CoffeeCocoa *_coffee;
    NSString *_queryPrefix;
    
    // collections for table view
    NSArray *_collections;
}


+ (NSString *)nibName;

#pragma mark - Actions
- (IBAction)pressEnterLoadDatabase:(NSTextField *)sender;
- (IBAction)addCollection:(id)sender;

#pragma mark Buttons
- (IBAction)clickOpenPath:(id)sender;


@end
