//
//  CollectionsViewController.m
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/30.
//
//

#import "CollectionsViewController.h"
#import <NyaruDB/NyaruDB.h>


@interface CollectionsViewController ()

@end



@implementation CollectionsViewController

@synthesize db = _db;

+ (NSString *)nibName
{
    return @"CollectionsView";
}


#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


#pragma mark - Proprities
- (NyaruDB *)db { return _db; }
- (void)setDb:(NyaruDB *)db
{
    _db = db;
    [self loadCollections];
}


#pragma mark - Private methods
- (void)loadCollections
{
    _collections = [_db.collections sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(NyaruCollection *)obj1 name] compare:[(NyaruCollection *)obj2 name]];
    }];
    
    [_tableView reloadData];
}


#pragma mark - NSTableViewDelegate
// /Users/Kelp/Library/Application Support/iPhone Simulator/6.1/Applications/4A71BBDC-D94D-4E45-9754-B32A9C87AAD9/Documents/NyaruDB
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [(NyaruCollection *)[_collections objectAtIndex:row] name];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _collections.count;
}



@end
