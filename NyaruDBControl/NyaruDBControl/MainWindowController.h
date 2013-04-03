//
//  MainWindowController.h
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/29.
//
//

#import <Cocoa/Cocoa.h>

@class NyaruDB;

@interface MainWindowController : NSWindowController <NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    // UI
    IBOutlet NSTextField *_path;
    IBOutlet NSTextField *_newCollection;
    IBOutlet NSTableView *_tableCollections;
    
    // database
    NyaruDB *_db;
    
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
