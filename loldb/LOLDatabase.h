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

//TODO: Thread-safety
- (NSData *)dataForKey:(NSString *)key;
- (void)setData:(NSData *)data forKey:(NSString *)key;

@end

@interface LOLDatabase : NSObject

- (id)initWithPath:(NSString *)inPathe;

- (void)accessWithBlock:(void (^)(id <LOLDatabaseAccessor>))block;

@end
