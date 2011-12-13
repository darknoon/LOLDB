//
//  LOLDatabase.m
//  loldb
//
//  Created by Andrew Pouliot on 12/12/11.
//  Copyright (c) 2011 Darknoon. All rights reserved.
//

#import "LOLDatabase.h"

#import "sqlite3.h"

@interface _LOLDatabaseAccessor : NSObject <LOLDatabaseAccessor>
- (id)initWithDatabase:(LOLDatabase *)db collection:(NSString *)collection;
- (void)done;
@end

@implementation LOLDatabase {
@public
	sqlite3 *db;
}

- (id)initWithPath:(NSString *)inPath;
{
	self = [super init];
	if (!self) return nil;
	
	int status = sqlite3_open([inPath UTF8String], &db);
	
	if (status != SQLITE_OK) {
		NSLog(@"Couldn't open database: %@", inPath);
		return nil;
	}
	
	NSString *sql = @"PRAGMA legacy_file_format = 0;";
	if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, NULL) != SQLITE_OK) {
		sqlite3_close(db);
		NSLog(@"shit table failed to be created");
		return nil;
	}

	return self;
}

- (void)dealloc {
    sqlite3_close(db);
}

- (void)accessWithBlock:(void (^)(id <LOLDatabaseAccessor>))block;
{
	_LOLDatabaseAccessor *a = [[_LOLDatabaseAccessor alloc] initWithDatabase:self collection:@"shit"];
	block(a);
	[a done];
}

@end


@implementation _LOLDatabaseAccessor {
	NSString *_collection;
	LOLDatabase *_d;
	sqlite3_stmt *getByKeyStatement;
	sqlite3_stmt *setByKeyStatement;
}

- (id)initWithDatabase:(LOLDatabase *)db collection:(NSString *)collection;
{
    self = [super init];
    if (!self) return nil;
	
	_d = db;
	
	NSString *q = nil;
	int status = SQLITE_OK;
	
	q = @"BEGIN TRANSACTION;";
	if (sqlite3_exec(_d->db, [q UTF8String], NULL, NULL, NULL) != SQLITE_OK) {
		NSLog(@"Couldn't begin a transaction!");
	}
	
	q = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('key' CHAR PRIMARY KEY  NOT NULL  UNIQUE, 'data' BLOB);", collection];
	if (sqlite3_exec(_d->db, [q UTF8String], NULL, NULL, NULL) != SQLITE_OK) {
		sqlite3_close(_d->db);
		NSLog(@"shit table failed to be created");
		return nil;
	}
	
	q = [[NSString alloc] initWithFormat:@"SELECT data FROM %@ WHERE key = ? ;", collection];
	status = sqlite3_prepare_v2(_d->db, [q UTF8String], q.length+1, &getByKeyStatement, NULL);
	if (status != SQLITE_OK) {
		NSLog(@"Error with get query! %s", sqlite3_errmsg(_d->db));
		return nil;
	}
    
	q = [[NSString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ ('key', 'data') VALUES (?, ?);", collection];
	status = sqlite3_prepare_v2(_d->db, [q UTF8String], q.length+1, &setByKeyStatement, NULL);
	if (status != SQLITE_OK) {
		NSLog(@"Error with set query! %s", sqlite3_errmsg(_d->db));
		return nil;
	}
	
    return self;
}

- (void)done;
{
	sqlite3_finalize(getByKeyStatement);
	sqlite3_finalize(setByKeyStatement);

	NSString *q = @"COMMIT TRANSACTION;";
	if (sqlite3_exec(_d->db, [q UTF8String], NULL, NULL, NULL) != SQLITE_OK) {
		NSLog(@"Couldn't end a transaction!");
	}
}

- (void)dealloc {
	
}

- (NSData *)dataForKey:(NSString *)key;
{
	sqlite3_bind_text(getByKeyStatement, 1, [key UTF8String], -1, SQLITE_TRANSIENT);

	NSData *fullData = nil;
	int status = sqlite3_step(getByKeyStatement);
	if (status == SQLITE_ROW) {
		const void *data = sqlite3_column_blob(getByKeyStatement, 0);
		size_t size = sqlite3_column_bytes(getByKeyStatement, 0);
		fullData = [[NSData alloc] initWithBytes:data length:size];
	} else if (status == SQLITE_ERROR) {
		NSLog(@"error getting by key: %s", sqlite3_errmsg(_d->db));
	}
	sqlite3_reset(getByKeyStatement);
	
	return fullData;
}

- (void)setData:(NSData *)data forKey:(NSString *)key;
{
	sqlite3_bind_text(setByKeyStatement, 1, [key UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_blob(setByKeyStatement, 2, data.bytes, data.length, SQLITE_TRANSIENT);
	
	int status = sqlite3_step(setByKeyStatement);
	if (status != SQLITE_DONE) {
		NSLog(@"error setting by key %d: %s", status, sqlite3_errmsg(_d->db));
	}
	sqlite3_reset(setByKeyStatement);
}


@end


