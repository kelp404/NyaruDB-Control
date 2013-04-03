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
#import "MGSFragaria.h"


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
    
//    co = db.collectionForName('afe')
//    print co.all().fetch()
//    co.where(index='name', equal='kelp').fetch()
    
    // setup text view
    MGSFragaria *fragaria = [MGSFragaria new];
    [fragaria setObject:@"CoffeeScript" forKey:MGSFOSyntaxDefinitionName];
    [fragaria embedInView:_textQuery];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsAutocompleteSuggestAutomatically];
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsIndentNewLinesAutomatically];
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsIndentWithSpaces];
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:MGSFragariaPrefsShowLineNumberGutter];
    [defaults setObject:[NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Monaco" size:13]] forKey:MGSFragariaPrefsTextFont];
    
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
        [self setupDatabase];
    }
}
- (void)focusNewCollection:(id)sender
{
    [_newCollection becomeFirstResponder];
}
- (IBAction)addCollection:(id)sender
{
    if (_newCollection.stringValue.length > 0) {
        [_db collectionForName:_newCollection.stringValue];
        [_newCollection setStringValue:@""];
        
        [self loadCollections];
    }
}
- (void)removeCollection:(id)sender
{
    NyaruCollection *co = [_collections objectAtIndex:_tableCollections.selectedRow];
    [_db removeCollection:co.name];
    [self loadCollections];
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
            [self setupDatabase];
        }
        else if (_path.stringValue.length <= 0) {
            [_path setStringValue:@"/tmp/NyaruDB"];
            [self setupDatabase];
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


#pragma mark - Setup
- (void)setupDatabase
{
    if (_db) {
        [_db close];
    }
    
    self.window.title = [NSString stringWithFormat:@"NyaruDB Control - %@", _path.stringValue];
    @try {
        _db = [[NyaruDB alloc] initWithPath:_path.stringValue];
    }
    @catch (__unused NSException *exception) {
        NSAlert *alert = [NSAlert new];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:@"NyaruDB Control"];
        [alert setInformativeText:@"Data loading failed!"];
        [alert runModal];
        return;
    }
    
    [self loadCollections];
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


@end
