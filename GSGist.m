//
//  Gist.m
//  Gisties
//
//  Created by Michael Schrag on 2/13/09.
//  Copyright 2009 m Dimension Technology. All rights reserved.
//

#import "GSGist.h"
#import "NSDictionary+http.h"
#import "UKXattrMetadataStore.h"

@interface GSGist (private)
- (int)execute:(NSArray *)arguments error:(NSError **)error;
- (void)_loadFromGitHub:(NSError **)error;
@end

@implementation GSGist

@synthesize gistID = _gistID;
@synthesize name = _name;
@synthesize content = _content;
@synthesize private = _private;
@synthesize loaded = _loaded;
@synthesize temporary = _temporary;
@synthesize gistyFolder = _gistyFolder;
@synthesize saving = _saving;
@synthesize syncing = _syncing;
@synthesize frame = _frame;

@synthesize originalName = _originalName;

- (id)initWithAuthDelegate:(id<GSAuthDelegate>)delegate {
	if (self = [super init]) {
		_authDelegate = delegate;
		
		CFUUIDRef uuid = CFUUIDCreate(NULL);
		CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
		CFRelease(uuid);
		[self setTemporary:YES];

		[self setName:@"Untitled.txt"];
		[self setGistID:[(NSString *)uuidStr autorelease]];
	}
	return self;
}

- (id)initWithFolder:(NSString *)gistyFolder authDelegate:(id<GSAuthDelegate>)delegate {
	if (self = [super init]) {
		_authDelegate = delegate;
		
		NSString *gistID = [[gistyFolder lastPathComponent] stringByDeletingPathExtension];
		[self setGistID:gistID];
		[self setGistyFolder:gistyFolder];
	}
	return self;
}

- (id)initWithID:(NSString *)gistID authDelegate:(id<GSAuthDelegate>)delegate {
	if (self = [super init]) {
		_authDelegate = delegate;
		
		[self setGistID:gistID];
	}
	return self;
}

+ (NSString *)gistiesFolder {
	return [@"~/Library/Application Support/Gisties" stringByExpandingTildeInPath];
}

- (NSString *)gistyFolder {
	NSString *gistyFolder = _gistyFolder;
	if (!gistyFolder) {
		gistyFolder = [[[GSGist gistiesFolder] stringByAppendingPathComponent:_gistID] stringByAppendingPathExtension:@"gisty"];

	}
	return gistyFolder;
}

- (NSString *)gistyFile {
	return [self name] ? [[self gistyFolder] stringByAppendingPathComponent:[self name]] : [[self gistyFolder] stringByAppendingPathComponent:@"Untitled.txt"];
}

- (void)load:(NSError **)error {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:[self gistyFolder]] && ![self temporary]) {
		[self loadFromGitHub:error];
	}
	else {
		[self loadFromDisk:error];
	}
}

- (void)updateFolderAttributes:(NSError **)error {
	[UKXattrMetadataStore setString:[self private] ? @"YES" : @"NO" forKey:@"gist.private" atPath:[self gistyFolder] traverseLink:YES];
	[UKXattrMetadataStore setString:NSStringFromRect(_frame) forKey:@"gist.frame" atPath:[self gistyFolder] traverseLink:YES];
}
	
- (void)loadFromDisk:(NSError **)error {
	NSString *gistyFolder = [self gistyFolder];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *gistieFiles = [fileManager directoryContentsAtPath:gistyFolder];
	NSString *matchingGistyFile = nil;
	for (NSString *gistyFile in gistieFiles) {
		BOOL isDir = NO;
		if ([fileManager fileExistsAtPath:[gistyFolder stringByAppendingPathComponent:gistyFile] isDirectory:&isDir] && !isDir) {
			matchingGistyFile = gistyFile;
			break;
		}
	}
	
	if (matchingGistyFile) {
		[self setOriginalName:matchingGistyFile];
		[self setName:matchingGistyFile];
		NSString *content = [NSString stringWithContentsOfFile:[self gistyFile] encoding:NSUTF8StringEncoding error:error];
		if ([content isEqualToString:@"[empty]"]) {
			content = @"";
		}
		NSMutableAttributedString* attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
		[self setContent:attributedContent];
		[attributedContent release];
	}
	else {
		[self setOriginalName:nil];
		[self setName:nil];
		[self setContent:nil];
	}
	
	[self setLoaded:YES];
	[self setTemporary:![fileManager fileExistsAtPath:[gistyFolder stringByAppendingPathComponent:@".git"]]];

	[self setPrivate:[[UKXattrMetadataStore stringForKey:@"gist.private" atPath:[self gistyFolder] traverseLink:YES] isEqualToString:@"YES"]];
	[self setFrame:NSRectFromString([UKXattrMetadataStore stringForKey:@"gist.frame" atPath:[self gistyFolder] traverseLink:YES])];
}

- (void)_loadFromGitHub:(NSError **)error {
	NSString *gistiesFolder = [GSGist gistiesFolder];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:gistiesFolder]) {
		[fileManager createDirectoryAtPath:gistiesFolder withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	NSString *gistyFolder = [self gistyFolder];
	if ([fileManager fileExistsAtPath:gistyFolder]) {
		[self execute:[NSArray arrayWithObjects:@"fetch", @"-u", @"origin", nil] error:error];
		[self execute:[NSArray arrayWithObjects:@"merge", @"origin/master", nil] error:error];
	}
	else {
		[self execute:[NSArray arrayWithObjects:@"clone", [NSString stringWithFormat:@"git@gist.github.com:%@.git", _gistID], gistyFolder, nil] error:error];
		[self updateFolderAttributes:error];
	}
}

- (void)loadFromGitHub:(NSError **)error {
	[self _loadFromGitHub:error];
	[self loadFromDisk:error];
}

- (void)saveToDisk:(NSError **)error {
	@synchronized(self) {
		if (_syncing) {
			NSLog(@"you tried to save while syncing .. queuing for later");
			_saveDuringSync = YES;
			return;
		}
		if (_saving) {
			NSLog(@"you were already saving ... ignoring");
			return;
		}
		[self setSaving:YES];
	}
	
	NSString *gistyFolder = [self gistyFolder];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:gistyFolder]) {
		[fileManager createDirectoryAtPath:gistyFolder withIntermediateDirectories:YES attributes:nil error:error];
	}
	
	[self updateFolderAttributes:error];
	
	NSString *gistyFile = [self gistyFile];
	[[[self content] string] writeToFile:gistyFile atomically:YES encoding:NSUTF8StringEncoding error:error];
	
	if (_originalName != nil && ![_originalName isEqualToString:_name]) {
		NSString *originalPath = [gistyFolder stringByAppendingPathComponent:_originalName];
		[fileManager removeItemAtPath:originalPath error:error];
		if (![self temporary]) {
			[self execute:[NSArray arrayWithObjects:@"rm", originalPath, nil] error:error];
		}
	}

//	if (![self temporary]) {
//		[self execute:[NSArray arrayWithObjects:@"add", gistyFile, nil] error:error];
//		[self execute:[NSArray arrayWithObjects:@"commit", @"-m", @"Saved", nil] error:error];
//	}

	@synchronized(self) {
		[self setSaving:NO];
		if (_syncDuringSave) {
			NSLog(@"you tried to sync while saving previously ... starting again");
			[self saveToGitHub:error];
			_syncDuringSave = NO;
		}
	}
}

- (void)saveToGitHub:(NSError **)error {
	@synchronized(self) {
		if (_saving) {
			NSLog(@"tried to sync while saving ... queuing");
			_syncDuringSave = YES;
			return;
		}
		if (_syncing) {
			NSLog(@"you're already syncing, ignoring request");
			return;
		}
		[self setSyncing:YES];
	}
	
	if ([self temporary]) {
		NSMutableDictionary *data = [NSMutableDictionary dictionary];
		NSString *name = _name;
		if (!name) {
			name = @"Untitled.txt";
		}
		NSString *ext = [_name pathExtension];
		if (ext && [ext length] > 0) {
			[data setObject:[@"." stringByAppendingString:ext] forKey:@"file_ext[gistfile1]"];
		}
		[data setObject:_name forKey:@"file_name[gistfile1]"];
		NSString *content = [_content string];
		if (!content || [content length] == 0) {
			content = @"[empty]";
		}
		[data setObject:content forKey:@"file_contents[gistfile1]"];
		if (_private) {
			[data setObject:@"on" forKey:@"private"];
		}

		NSString *userName = [_authDelegate userName];
		if (userName) {
			[data setObject:userName forKey:@"login"];
			NSString *token = [_authDelegate token];
			if (token) {
				[data setObject:token forKey:@"token"];
			}
		}
		
		NSMutableURLRequest *post = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://gist.github.com/gists"]];
		[post setHTTPMethod:@"POST"];
		NSData *gistData = [[data formEncoded] dataUsingEncoding:NSASCIIStringEncoding];
		[post setHTTPBody:gistData];
		[post setValue:[NSString stringWithFormat:@"%d", [gistData length]] forHTTPHeaderField:@"Content-Length"];  
		[post setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
		
		NSHTTPURLResponse *response;
		[NSURLConnection sendSynchronousRequest:post returningResponse:&response error:error];
		NSString *newGistID = [[[response URL] path] lastPathComponent];
		
		[self deleteFromDisk:error];

		[self setGistID:newGistID];
		[self setGistyFolder:nil];
		[self setTemporary:NO];
		[self _loadFromGitHub:error];
	}
	else {
		[self execute:[NSArray arrayWithObjects:@"add", [self gistyFile], nil] error:error];
		[self execute:[NSArray arrayWithObjects:@"commit", @"-m", @"Gisty Update", nil] error:error];
		[self execute:[NSArray arrayWithObjects:@"push", nil] error:error];
	}
	
	@synchronized(self) {
		[self setSyncing:NO];
		if (_saveDuringSync) {
			NSLog(@"you tried to save while syncing .. starting that again");
			[self saveToDisk:error];
			_saveDuringSync = NO;
		}
	}
}

- (int)execute:(NSArray *)arguments error:(NSError **)error {
	NSTask *task = [[NSTask alloc] init];
	[task setCurrentDirectoryPath:[self gistyFolder]];
	[task setLaunchPath:[_authDelegate gitPath]];
	[task setArguments:arguments];
	[task launch];
	[task waitUntilExit];
	int exitCode = [task terminationStatus];
	[task release];
	
	NSLog(@"Gist.execute: %@, exitCode = %d", [arguments objectAtIndex:0], exitCode);
	
	return exitCode;
}

- (void)deleteFromDisk:(NSError **)error {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *gistyFolder = [self gistyFolder];
	if ([fileManager fileExistsAtPath:gistyFolder]) {
		[fileManager removeItemAtPath:[self gistyFile] error:error];
		[fileManager removeItemAtPath:gistyFolder error:error];
	}
}

- (void)deleteFromGitHub:(NSError **)error {
	[self deleteFromDisk:error];
	
	if (![self temporary]) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://gist.github.com/delete/%@?login=%@&token=%@", [self gistID], [_authDelegate userName], [_authDelegate token]]];
		[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:error];
	}
}

- (void)dealloc {
	[_gistID release];
	[_name release];
	[_content release];
	[_gistyFolder release];
	[super dealloc];
}

@end
