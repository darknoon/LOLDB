//
//  LOLDatabase.h
//  loldb
//
//  Created by Andrew Pouliot on 12/12/11.
//  Copyright (c) 2011 Darknoon. All rights reserved.
//

/*
 * Design goals:
 * 1. Getting or storing an item out is < O(n) and as close to O(1) as possible
 * 2. Never keep an unbounded set in memory!
 * 3. Allow seamless access from multiple threads via dispatch api
 */

#import <Foundation/Foundation.h>

@protocol LOLDatabaseAccessor <NSObject>

//Uses JSON to serialize and deserialize from the database
- (NSDictionary *)dictionaryForKey:(NSString *)key;
- (void)setDictionary:(NSDictionary *)dict forKey:(NSString *)key;

@end

@interface LOLDatabase : NSObject

- (id)initWithPath:(NSString *)path;

- (void)accessCollection:(NSString *)collection withBlock:(void (^)(id <LOLDatabaseAccessor>accessor))block;

@end
