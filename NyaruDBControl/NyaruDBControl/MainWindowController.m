//
//  MainWindowController.m
//  NyaruDBControl
//
//  Created by Kelp on 2013/03/29.
//
//

#import "MainWindowController.h"
#import "NyaruControlAppDelegate.h"
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
    [[app.menuQuery.itemArray objectAtIndex:0] setAction:@selector(evalQuery:)];
    
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
        [_db collectionForName:_newCollection.stringValue];
        [_newCollection setStringValue:@""];
        
        [self loadCollections];
    }
}
#pragma mark Menu
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
- (void)evalQuery:(id)sender
{
    // load QueryPrefix -> QueryPrefix.coffee
    NSString *path = [[NSBundle mainBundle] pathForResource:@"QueryPrefix" ofType:@"coffee"];
    NSMutableString *queryScript = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    [queryScript appendString:[_fragaria string]];
    
    // eval query
    [_coffee evalCoffeeScript:queryScript];
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


#pragma mark - NSTableViewDelegate
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
//    if (_fragaria.string.length <= 0) {
//        NyaruCollection *co = [_collections objectAtIndex:_tableCollections.selectedRow];
//        [_fragaria setString:[NSString stringWithFormat:@"co = db.collectionForName '%@'\n"
//                              "print co.all().fetch()", co.name]];
//    }
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
    
    [self setupCoffeeCocoa];
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
- (void)setupCoffeeCocoa
{
    _coffee = [CoffeeCocoa new];
    
    [_coffee.cocoa setPrint:^(id msg) {
        NSLog(@"cocoa.print %@", msg);
    }];
    
    // load CoffeeScript -> NyaruDB.coffee
    NSString *path = [[NSBundle mainBundle] pathForResource:@"NyaruDB" ofType:@"coffee"];
    NSString *nyaruScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [_coffee evalCoffeeScript:nyaruScript];
    
    // extend methods
    [self mappingInsert];
    [self mappingFetch];
    
    
    // JavaScript: print()
    // Objective-C: show result
    [_coffee extendFunction:@"print" inObject:@"window" handler:^id(id object) {
        NSLog(@"print %@", object);
        return nil;
    }];
}

#pragma mark [NyaruCollection insert]
/**
 JavaScript: nyaru.collection.insert({collectionName, document={}})
 Objective-C: [NyaruCollection insert]
 */
- (void)mappingInsert
{
    [_coffee extendFunction:@"insert" inObject:@"window.nyaru.collection" handler:^id(id object) {
        NyaruCollection *co = [_db collectionForName:[object objectForKey:@"collectionName"]];
        return [co insert:[object objectForKey:@"document"]];
    }];
}

#pragma mark [NyaruCollection fetch]
/**
 JavaScript: nyaru.collection.fetch({collectionName, queries=[], skip=0, limit=0})
 Objective-C: [NyaruCollection fetch]
 */
- (void)mappingFetch
{
    [_coffee extendFunction:@"fetch" inObject:@"window.nyaru.collection" handler:^id(id object) {
        NyaruCollection *co = [_db collectionForName:[object objectForKey:@"collectionName"]];
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


@end
