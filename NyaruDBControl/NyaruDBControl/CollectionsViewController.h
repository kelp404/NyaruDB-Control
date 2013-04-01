//
//  CollectionsViewController.h
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/30.
//
//

#import <Cocoa/Cocoa.h>
@class NyaruDB;


@interface CollectionsViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSTableView *_tableView;
    NSArray *_collections;
}

+ (NSString *)nibName;

@property (strong, nonatomic) NyaruDB *db;

@end
