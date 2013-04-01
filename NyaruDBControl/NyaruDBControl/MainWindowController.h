//
//  MainWindowController.h
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/29.
//
//

#import <Cocoa/Cocoa.h>

@class NyaruDB;
@class CollectionsViewController;
@class CollectionViewController;

@interface MainWindowController : NSWindowController <NSWindowDelegate> {
    IBOutlet NSTextField *_path;
    IBOutlet NSSplitView *_split;
    CollectionsViewController *_collections;
    CollectionViewController *_collection;
    NyaruDB *_db;
}


+ (NSString *)nibName;

#pragma mark - Actions
- (IBAction)pressEnter:(NSTextField *)sender;

#pragma mark Buttons
- (IBAction)clickOpenPath:(id)sender;


@end
