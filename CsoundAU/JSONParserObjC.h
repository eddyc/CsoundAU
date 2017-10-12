/*
 * JSONParserObjC.h
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#import <Foundation/Foundation.h>

NSMutableArray *parseParameters(NSBundle *bundle);
NSArray *getJSONFromFile(NSBundle *bundle, NSString *resourceString);
NSMutableDictionary *parseConfiguration(NSString *bundleID);
NSDictionary *synchroniseArchivedObjects(NSBundle *bundle);
