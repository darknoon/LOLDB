//
//  loldbTests.m
//  loldbTests
//
//  Created by Andrew Pouliot on 12/12/11.
//  Copyright (c) 2011 Darknoon. All rights reserved.
//

#import "loldbTests.h"

#import "LOLDatabase.h"

@implementation loldbTests {
	LOLDatabase *db;
}

- (void)setUp
{
    [super setUp];
	
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"_123_loldb_temp.lol.sqlite"];
	//Delete any existing database
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
	
    db = [[LOLDatabase alloc] initWithPath:path];
	db.serializer = ^(id object){
		return [NSJSONSerialization dataWithJSONObject:object options:0 error:NULL];
	};
	db.deserializer = ^(NSData *data) {
		return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
	};
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
	
	NSLog(@"Starting database operations");
	NSLog(@"Reading");
	
	NSString *cacheName = @"somestuff.lol";

	__block NSDictionary *buttons = nil;
	[db accessCollection:@"shit" withBlock:^(id<LOLDatabaseAccessor>accessor) {
		//Do a bunch of unnecessary work for timing purposes
		NSDictionary *blahTemp = nil;
		for (int i=0; i<10000; i++) {
			@autoreleasepool {
				blahTemp = [accessor dictionaryForKey:[[NSString alloc] initWithFormat:@"fuckbuttons-%d", i]];
			}
		}
		buttons = [accessor dictionaryForKey:@"fuckbuttons"];
	}];
	
	NSLog(@"Writing");
	
	[db accessCollection:@"shit" withBlock:^(id<LOLDatabaseAccessor> accessor) {
		NSDictionary *whatItShouldBe = [[NSDictionary alloc] initWithObjectsAndKeys:@"ladida", @"whatever", [NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()], @"somenumber", nil];
		//An insert test
		for (int i=0; i<10000; i++) {
			@autoreleasepool {
				[accessor setDictionary:whatItShouldBe forKey:[[NSString alloc] initWithFormat:@"fuckbuttons-%d", i]];
				
			}
		}
		
		[accessor setDictionary:whatItShouldBe forKey:@"fuckbuttons"];
	}];
	
	NSLog(@"Current buttons: %@", buttons);
}

- (void)testDeleteInMultipleTransactions;
{
	NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:@"testData", @"subKey", nil];
	
	NSString *collectionName = @"deleteTest";
	NSString *keyName = @"keyName";
	
	
	//With transactions
	
	//Add something
	[db accessCollection:collectionName withBlock:^(id<LOLDatabaseAccessor>accessor) {
		
		[accessor setDictionary:item forKey:keyName];
	}];
	
	[db accessCollection:collectionName withBlock:^(id<LOLDatabaseAccessor>accessor) {
		
		NSDictionary *read = [accessor dictionaryForKey:keyName];
		
		STAssertEqualObjects([read objectForKey:@"subKey"], [item objectForKey:@"subKey"], @"Didn't save properly");
	}];
	
	
	[db accessCollection:collectionName withBlock:^(id<LOLDatabaseAccessor>accessor) {
		
		[accessor removeDictionaryForKey:keyName];
		
	}];
	
	[db accessCollection:collectionName withBlock:^(id<LOLDatabaseAccessor>accessor) {
		
		NSDictionary *read = [accessor dictionaryForKey:keyName];
		
		STAssertNil(read, @"Didn't delete!");
	}];
}

- (void)testDeleteInSingleTransaction;
{
	
	NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:@"testData", @"subKey", nil];
	
	NSString *collectionName = @"deleteTest";
	NSString *keyName = @"keyName";
	
	
	//With transactions
	
	//Add something
	[db accessCollection:collectionName withBlock:^(id<LOLDatabaseAccessor>accessor) {
		
		[accessor setDictionary:item forKey:keyName];

		NSDictionary *read = [accessor dictionaryForKey:keyName];
		
		STAssertEqualObjects([read objectForKey:@"subKey"], [item objectForKey:@"subKey"], @"Didn't save properly");

		
		[accessor removeDictionaryForKey:keyName];
		
		
		read = [accessor dictionaryForKey:keyName];
		
		STAssertNil(read, @"Didn't delete!");
	}];

}

@end
