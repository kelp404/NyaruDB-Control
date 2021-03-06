//
//  MainWindowController.m
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/29.
//
//

#import "MainWindowController.h"
#import "NyaruControlAppDelegate.h"
#import "QuerySplitView.h"
#import "ViewUtility.h"
#import <NyaruDB/NyaruDB.h>
#import <NyaruDB/NyaruQueryCell.h>
#import <CoffeeCocoa/CoffeeCocoa.h>


@interface MainWindowController ()

@end



@implementation MainWindowController


+ (NSString *)nibName
{
    return @"MainWindow";
}


#pragma mark - Window Events
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // setup menus
    NyaruControlAppDelegate *app = (NyaruControlAppDelegate *)[[NSApplication sharedApplication] delegate];
    [[app.menuCollection.itemArray objectAtIndex:0] setAction:@selector(focusNewCollection:)];
    [[app.menuCollection.itemArray objectAtIndex:1] setAction:@selector(removeCollection:)];
    [[app.menuQuery.itemArray objectAtIndex:0] setAction:@selector(evalQuery:)];        // run
    [[app.menuQuery.itemArray objectAtIndex:2] setAction:@selector(newQuery:)];         // new query
    [[app.menuQuery.itemArray objectAtIndex:3] setAction:@selector(closeQuery:)];       // close query
    [[app.menuQuery.itemArray objectAtIndex:5] setAction:@selector(nextQuery:)];        // next query
    [[app.menuQuery.itemArray objectAtIndex:6] setAction:@selector(previousQuery:)];    // previous query
    
    // setup tab
    _tabIncrement = 0;
    [self addQuery];
    
    // load QueryPrefix -> QueryPrefix.coffee
    NSString *path = [[NSBundle mainBundle] pathForResource:@"QueryPrefix" ofType:@"coffee"];
    _queryPrefix = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    // show open panel
    [self clickOpenPath:nil];
}

#pragma mark - Window delegates
- (void)windowWillClose:(NSNotification *)notification
{
    [(NyaruControlAppDelegate *)[[NSApplication sharedApplication] delegate] removeWindowFromPool:self];
}

#pragma mark - Actions
- (IBAction)pressEnterLoadDatabase:(NSTextField *)sender
{
    if (sender.stringValue.length > 0) {
        [self setupDatabase:_path.stringValue];
    }
}
- (IBAction)addCollection:(id)sender
{
    if (_newCollection.stringValue.length > 0) {
        [_db collection:_newCollection.stringValue];
        [_newCollection setStringValue:@""];
        
        [self loadCollections];
    }
}

#pragma mark Buttons
- (IBAction)clickOpenPath:(NSMenuItem *)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    
    if (sender.tag == 1) {      // ~/
        [panel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    }
    else if (sender.tag == 2) { // /tmp
        [panel setDirectoryURL:[NSURL fileURLWithPath:@"/tmp"]];
    }
    else {      // iPhone Simulator
        NSURL *applicationSupport = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].lastObject;
        [panel setDirectoryURL:[applicationSupport URLByAppendingPathComponent:@"iPhone Simulator"]];
    }
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            [_path setStringValue:panel.URL.path];
            [self setupDatabase:_path.stringValue];
        }
        else if (_path.stringValue.length <= 0) {
            [_path setStringValue:@"/tmp/NyaruDB"];
            [self setupDatabase:_path.stringValue];
        }
    }];
}

#pragma mark - Menu
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL menuAction = [menuItem action];
    
	if (menuAction == @selector(closeQuery:)) {
        return _tabQuery.tabViewItems.count > 1;
	}
    
 	return YES;
}
#pragma mark collection
- (void)focusNewCollection:(id)sender
{
    [_newCollection becomeFirstResponder];
}
- (void)removeCollection:(id)sender
{
    NyaruCollection *co = [_collections objectAtIndex:_tableCollections.selectedRow];
    [_db removeCollection:co.name];
    [self loadCollections];
}
#pragma mark query
- (void)evalQuery:(id)sender
{
    QuerySplitView *queryView = (QuerySplitView *)_tabQuery.selectedTabViewItem.view;
    NSMutableString *queryScript = [NSMutableString stringWithString:_queryPrefix];
    [queryScript appendString:queryView.textQuery.string];
    
    // eval query
    [queryView.coffee evalCoffeeScript:@"clear()"];
    [queryView.coffee evalCoffeeScript:queryScript];
    [self loadCollections];
}
- (void)newQuery:(id)sender
{
    [self addQuery];
    [_tabQuery selectLastTabViewItem:sender];
    
    NSTextView *textQuery = [_tabQuery.selectedTabViewItem.view textQuery];
    if (_tableCollections.selectedRow >= 0) {
        NyaruCollection *co = [_collections objectAtIndex:_tableCollections.selectedRow];
        [textQuery setString:[NSString stringWithFormat:@"co = db.collection '%@'\n"
                              "print co.all().fetch()", co.name]];
    }
}
- (void)closeQuery:(id)sender
{
    if (_tabQuery.tabViewItems.count > 1) {
        [_tabQuery removeTabViewItem:_tabQuery.selectedTabViewItem];
    }
}
- (void)nextQuery:(id)sender
{
    [_tabQuery selectNextTabViewItem:sender];
}
- (void)previousQuery:(id)sender
{
    [_tabQuery selectPreviousTabViewItem:sender];
}


#pragma mark - NSTableViewDelegate (Collections table view)
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [(NyaruCollection *)[_collections objectAtIndex:row] name];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _collections.count;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTextView *textQuery = [_tabQuery.selectedTabViewItem.view textQuery];
    if (textQuery.string.length <= 0) {
        NyaruCollection *co = [_collections objectAtIndex:_tableCollections.selectedRow];
        [textQuery setString:[NSString stringWithFormat:@"co = db.collection '%@'\n"
                              "print co.all().fetch()", co.name]];
    }
}


#pragma mark - Helper
- (void)addQuery
{
    // copy _splitQuery
    NSData *archivedView = [NSKeyedArchiver archivedDataWithRootObject:_splitQuery];
    QuerySplitView *split = [NSKeyedUnarchiver unarchiveObjectWithData:archivedView];
    
    // setup textQuery
    split.textQuery = [ViewUtility searchViewIn:split kindOf:[NSTextView class] deep:4];
    [split.textQuery setFont:[NSFont fontWithName:@"Monaco" size:14.0]];
    // Smart Quotes disabled, http://stackoverflow.com/questions/19801601/nstextview-with-smart-quotes-disabled-still-replaces-quotes
    [split.textQuery setAutomaticQuoteSubstitutionEnabled:NO];
    split.textQuery.enabledTextCheckingTypes = 0;
    
    // setup CoffeeCocoa
    split.coffee = [self setupCoffeeCocoa];
    [[split.subviews objectAtIndex:1] removeFromSuperview];
    [split addSubview:split.coffee.webView];
    [split.coffee.webView setFrameSize:NSMakeSize(split.frame.size.width, split.frame.size.height - 180)];
    
    NSTabViewItem *tab = [NSTabViewItem new];
    tab.view = split;
    [tab setLabel:[NSString stringWithFormat:@"Query #%lx", ++_tabIncrement]];
    [_tabQuery addTabViewItem:tab];
}


#pragma mark - NyaruDB
- (void)setupDatabase:(NSString *)path
{
    if (_db) {
        [_db close];
    }
    
    self.window.title = [NSString stringWithFormat:@"NyaruDB Control - %@", path];
    @try {
        _db = [[NyaruDB alloc] initWithPath:path];
        [self loadCollections];
    }
    @catch (__unused NSException *exception) {
        NSAlert *alert = [NSAlert new];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:@"NyaruDB Control"];
        [alert setInformativeText:@"Data loading failed!"];
        [alert runModal];
        return;
    }
}
- (void)loadCollections
{
    // sort collections
    _collections = [_db.collections sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(NyaruCollection *)obj1 name] compare:[(NyaruCollection *)obj2 name]];
    }];
    [_tableCollections reloadData];
    if (_collections.count > 0 && _tableCollections.selectedRow == NSUIntegerMax) {
        [_tableCollections selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
}


#pragma mark - CoffeeCocoa
- (CoffeeCocoa *)setupCoffeeCocoa
{
    CoffeeCocoa *coffee = [CoffeeCocoa new];
    
    [coffee.cocoa setPrint:^(id msg) {
        NSLog(@"cocoa.print %@", msg);
    }];
    [coffee.cocoa setError:^(id msg) {
        NSLog(@"cocoa.error %@", msg);
    }];
    
    // load CoffeeScript -> NyaruDB.coffee
    NSString *path = [[NSBundle mainBundle] pathForResource:@"NyaruDB" ofType:@"coffee"];
    NSString *nyaruScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [coffee evalCoffeeScript:nyaruScript];
    
    // load CoffeeScript -> NyaruDB-Control.coffee
    path = [[NSBundle mainBundle] pathForResource:@"NyaruDB-Control" ofType:@"coffee"];
    NSString *nyaruControlScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [coffee evalCoffeeScript:nyaruControlScript];
    
    // load bootstrap -> bootstrap.min.css
    path = [[NSBundle mainBundle] pathForResource:@"bootstrap" ofType:@"coffee"];
    NSString *bootstrapScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [coffee evalCoffeeScript:bootstrapScript];
    
    // extend methods
    [self mappingAllIndexes:coffee];
    [self mappingCreateIndexes:coffee];
    [self mappingRemoveIndexes:coffee];
    [self mappingPut:coffee];
    [self mappingCount:coffee];
    [self mappingFetch:coffee];
    [self mappingRemove:coffee];
    [self mappingRemoveAll:coffee];
    
    return coffee;
}

#pragma mark [NyaruCollection allIndexes]
/**
 JavaScript: nyaru.collection.allIndexes({collectionName})
 Objective-C: [NyaruCollection allIndexes]
 */
- (void)mappingAllIndexes:(CoffeeCocoa *)coffee
{
    [coffee extendFunction:@"allIndexes" inObject:@"window.nyaru.collection" handler:^id(id object) {
        NyaruCollection *co = [_db collection:[object objectForKey:@"collectionName"]];
        return [co allIndexes];
    }];
}

#pragma mark [NyaruCollection createIndex]
/**
 JavaScript: nyaru.collection.createIndex({collectionName, indexName})
 Objective-C: [NyaruCollection createIndex]
 */
- (void)mappingCreateIndexes:(CoffeeCocoa *)coffee
{
    [coffee extendFunction:@"createIndex" inObject:@"window.nyaru.collection" handler:^id(id object) {
        NyaruCollection *co = [_db collection:[object objectForKey:@"collectionName"]];
        [co createIndex:[object objectForKey:@"indexName"]];
        return @1;
    }];
}

#pragma mark [NyaruCollection removeIndex]
/**
 JavaScript: nyaru.collection.removeIndex({collectionName, indexName})
 Objective-C: [NyaruCollection removeIndex]
 */
- (void)mappingRemoveIndexes:(CoffeeCocoa *)coffee
{
    [coffee extendFunction:@"removeIndex" inObject:@"window.nyaru.collection" handler:^id(id object) {
        NyaruCollection *co = [_db collection:[object objectForKey:@"collectionName"]];
        [co removeIndex:[object objectForKey:@"indexName"]];
        return @1;
    }];
}

#pragma mark [NyaruCollection put]
/**
 JavaScript: nyaru.collection.put({collectionName, document={}})
 Objective-C: [NyaruCollection put]
 */
- (void)mappingPut:(CoffeeCocoa *)coffee
{
    [coffee extendFunction:@"put" inObject:@"window.nyaru.collection" handler:^id(id object) {
        NyaruCollection *co = [_db collection:[object objectForKey:@"collectionName"]];
        return [co put:[object objectForKey:@"document"]];
    }];
}

#pragma mark [NyaruCollection count]
/**
 JavaScript: nyaru.collection.count({collectionName, queries=[]})
 Objective-C: [NyaruCollection count]
 */
- (void)mappingCount:(CoffeeCocoa *)coffee
{
    [coffee extendFunction:@"count" inObject:@"window.nyaru.collection" handler:^id(id object) {
        NyaruCollection *co = [_db collection:[object objectForKey:@"collectionName"]];
        NSMutableArray *queries = [NSMutableArray new];
        for (NSDictionary *item in [object objectForKey:@"queries"]) {
            NyaruQueryCell *queryCell = [NyaruQueryCell new];
            queryCell.schemaName = [item objectForKey:@"schemaName"];
            queryCell.operation = [[item objectForKey:@"operation"] unsignedIntegerValue];
            queryCell.value = [item objectForKey:@"value"];
            [queries addObject:queryCell];
        }
        NSNumber *count = [NSNumber numberWithUnsignedInteger:[co countByQuery:queries]];
        return count;
    }];
}

#pragma mark [NyaruCollection fetch]
/**
 JavaScript: nyaru.collection.fetch({collectionName, queries=[], skip=0, limit=0})
 Objective-C: [NyaruCollection fetch]
 */
- (void)mappingFetch:(CoffeeCocoa *)coffee
{
    [coffee extendFunction:@"fetch" inObject:@"window.nyaru.collection" handler:^id(id object) {
        NyaruCollection *co = [_db collection:[object objectForKey:@"collectionName"]];
        NSMutableArray *queries = [NSMutableArray new];
        for (NSDictionary *item in [object objectForKey:@"queries"]) {
            NyaruQueryCell *queryCell = [NyaruQueryCell new];
            queryCell.schemaName = [item objectForKey:@"schemaName"];
            queryCell.operation = [[item objectForKey:@"operation"] unsignedIntegerValue];
            queryCell.value = [item objectForKey:@"value"];
            [queries addObject:queryCell];
        }
        NSArray *documents = [co fetchByQuery:queries
                                         skip:[[object objectForKey:@"skip"] unsignedIntegerValue]
                                        limit:[[object objectForKey:@"limit"] unsignedIntegerValue]];
        return documents;
    }];
}

#pragma mark [NyaruCollection remove]
/**
 JavaScript: nyaru.collection.remove({collectionName, queries=[]})
 Objective-C: [NyaruCollection remove]
 */
- (void)mappingRemove:(CoffeeCocoa *)coffee
{
    [coffee extendFunction:@"remove" inObject:@"window.nyaru.collection" handler:^id(id object) {
        NyaruCollection *co = [_db collection:[object objectForKey:@"collectionName"]];
        NSMutableArray *queries = [NSMutableArray new];
        for (NSDictionary *item in [object objectForKey:@"queries"]) {
            NyaruQueryCell *queryCell = [NyaruQueryCell new];
            queryCell.schemaName = [item objectForKey:@"schemaName"];
            queryCell.operation = [[item objectForKey:@"operation"] unsignedIntegerValue];
            queryCell.value = [item objectForKey:@"value"];
            [queries addObject:queryCell];
        }
        [co removeByQuery:queries];
        return @1;
    }];
}

#pragma mark [NyaruCollection removeAll]
/**
 JavaScript: nyaru.collection.removeAll({collectionName})
 Objective-C: [NyaruCollection removeAll]
 */
- (void)mappingRemoveAll:(CoffeeCocoa *)coffee
{
    [coffee extendFunction:@"removeAll" inObject:@"window.nyaru.collection" handler:^id(id object) {
        NyaruCollection *co = [_db collection:[object objectForKey:@"collectionName"]];
        [co removeAll];
        return @1;
    }];
}


@end
