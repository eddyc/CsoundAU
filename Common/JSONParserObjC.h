//
//  JSONParserObjC.h
//  CsoundAU
//
//  Created by Edward Costello on 24/07/2015.
//
//

#import <Foundation/Foundation.h>

NSMutableArray *parseParameters(NSBundle *bundle);
NSArray *getJSONFromFile(NSBundle *bundle, NSString *resourceString);
NSMutableDictionary *parseConfiguration(NSString *bundleID);
NSDictionary *synchroniseArchivedObjects(NSBundle *bundle);
