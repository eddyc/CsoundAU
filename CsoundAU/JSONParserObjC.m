/*
 * JSONParserObjC.m
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#include "JSONParserObjC.h"


NSMutableArray *parseParameters(NSBundle *bundle)
{
    NSArray *allKeys = getJSONFromFile(bundle, @"Parameters");
    
    NSMutableArray *parameters = [[NSMutableArray alloc] init];
    for (size_t i = 0; i < allKeys.count; i++) {
        
        NSDictionary *parameterJSON = [allKeys objectAtIndex:i];
        NSArray *parameterArray = [[NSArray alloc]
                                   initWithObjects:
                                   parameterJSON[@"name"]?:@"empty",
                                   parameterJSON[@"minValue"]?:@"empty",
                                   parameterJSON[@"maxValue"]?:@"empty",
                                   parameterJSON[@"defaultValue"]?:@"empty",
                                   parameterJSON[@"unit"]?:@0,
                                   parameterJSON[@"flag"]?:@0,
                                   parameterJSON[@"strings"]?:@false,
                                   nil];
        for (size_t j = 0; j < 4 /* iterate to 'defaultValue' */; ++j) {
            
            if ([[parameterArray objectAtIndex:j]  isEqual: @"empty"]) {
                
                printf("Required fields not given for parameter, exiting\n");
                exit(-1);
            }
        }
        
        NSString *name = parameterArray[0];
        NSNumber *minValue = parameterArray[1];
        NSNumber *maxValue = parameterArray[2];
        NSNumber *defaultValue = parameterArray[3];
        NSNumber *unit = parameterArray[4];
        NSNumber *flag = parameterArray[5];
        
        if ([[parameterArray objectAtIndex:6] isNotEqualTo:@false]) {
            
            NSArray *stringArray = [parameterArray objectAtIndex:6];
            
            [parameters addObject:@{@"name":name,
                                    @"minValue":minValue,
                                    @"maxValue":maxValue,
                                    @"defaultValue":defaultValue,
                                    @"unit":unit,
                                    @"flag":flag,
                                    @"strings":stringArray}];
        }
        else {
            
            [parameters addObject:@{@"name":name,
                                    @"minValue":minValue,
                                    @"maxValue":maxValue,
                                    @"defaultValue":defaultValue,
                                    @"unit":unit,
                                    @"flag":flag}];
        }
    }
    
    return parameters;
}


NSArray *getJSONFromFile(NSBundle *bundle, NSString *resourceString)
{
    
    NSString *path  = [bundle pathForResource:resourceString
                                       ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:path
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSArray *allKeys = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return allKeys;
}

NSMutableDictionary *parseConfiguration(NSString *bundleID)
{
    NSDictionary *allKeys = (NSDictionary *)getJSONFromFile([NSBundle bundleWithIdentifier:bundleID], @"Configuration");
    NSMutableDictionary *configuration = [[NSMutableDictionary alloc] init];
    NSArray *configurationArray = [[NSArray alloc]
                                   initWithObjects:
                                   allKeys[@"ViewBundleID"],
                                   allKeys[@"ViewType"],
                                   allKeys[@"ViewFileName"],
                                   allKeys[@"csd"],
                                   nil];
    
    if (configurationArray.count < 4) {
        
        printf("Error, configuration json malformed\nExiting\n");
        exit(-1);
    }
    
    configuration[@"ViewBundleID"] = configurationArray[0];
    configuration[@"ViewType"] = configurationArray[1];
    configuration[@"ViewFileName"] = configurationArray[2];
    configuration[@"csd"] = configurationArray[3];
    
    
    if (allKeys[@"ViewWidth"] != nil) {
        
        configuration[@"ViewWidth"] = allKeys[@"ViewWidth"];
    }
    
    if (allKeys[@"ViewHeight"] != nil) {
        
        configuration[@"ViewHeight"] = allKeys[@"ViewHeight"];
    }
    
    return configuration;
}

NSDate *getFileLastModifiedDate(NSString *path)
{
    NSDate *fileLastModifiedDate = nil;
    
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    
    if (attrs && !error) {
        
        fileLastModifiedDate = [attrs fileModificationDate];
        return fileLastModifiedDate;
    }
    else {
        
        return nil;
    }
}

NSDictionary *synchroniseArchivedObjects(NSBundle *bundle)
{
    NSMutableArray *parameters;
    NSMutableDictionary *configuration;
    
    NSString *fileModificationDatesPath = [bundle pathForResource:@"FileModificationDates" ofType:@"dat"];
    NSString *configurationArchivePath = [NSString stringWithFormat:@"%@%@", bundle.resourcePath, @"/Configuration.dat"];
    NSString *parametersArchivePath = [NSString stringWithFormat:@"%@%@", bundle.resourcePath, @"/Parameters.dat"];
    
    if (fileModificationDatesPath == nil) {
        
        parameters = parseParameters(bundle);
        configuration = parseConfiguration([bundle bundleIdentifier]);
        [NSKeyedArchiver archiveRootObject:parameters toFile:parametersArchivePath];
        [NSKeyedArchiver archiveRootObject:configuration toFile:configurationArchivePath];
        NSDictionary *fileModificationDates = @{@"Parameters":[NSDate date], @"Configuration":[NSDate date]};
        fileModificationDatesPath = [NSString stringWithFormat:@"%@%@", bundle.resourcePath, @"/FileModificationDates.dat"];
        [NSKeyedArchiver archiveRootObject:fileModificationDates toFile:fileModificationDatesPath];
    }
    else {
        
        NSDictionary *fileModificationDates = [NSKeyedUnarchiver unarchiveObjectWithFile:fileModificationDatesPath];
        NSDate *configurationModifiedDate = getFileLastModifiedDate([bundle pathForResource:@"Configuration" ofType:@"json"]);
        NSDate *parametersModifiedDate = getFileLastModifiedDate([bundle pathForResource:@"Parameters" ofType:@"json"]);
       
        if ([configurationModifiedDate compare:fileModificationDates[@"Configuration"]] == NSOrderedDescending) {
            
            configuration = parseConfiguration([bundle bundleIdentifier]);
            [NSKeyedArchiver archiveRootObject:configuration toFile:configurationArchivePath];
            configurationModifiedDate = [NSDate date];
            NSDictionary *fileModificationDates = @{@"Parameters":parametersModifiedDate, @"Configuration":configurationModifiedDate};
            fileModificationDatesPath = [NSString stringWithFormat:@"%@%@", bundle.resourcePath, @"/FileModificationDates.dat"];
            [NSKeyedArchiver archiveRootObject:fileModificationDates toFile:fileModificationDatesPath];
        }
        else {
            
            configuration = [NSKeyedUnarchiver unarchiveObjectWithFile:configurationArchivePath];
        }
        
        if ([parametersModifiedDate compare:fileModificationDates[@"Parameters"]] == NSOrderedDescending) {
            
            parameters = parseParameters(bundle);
            [NSKeyedArchiver archiveRootObject:parameters toFile:parametersArchivePath];
            parametersModifiedDate = [NSDate date];
            NSDictionary *fileModificationDates = @{@"Parameters":parametersModifiedDate, @"Configuration":configurationModifiedDate};
            fileModificationDatesPath = [NSString stringWithFormat:@"%@%@", bundle.resourcePath, @"/FileModificationDates.dat"];
            [NSKeyedArchiver archiveRootObject:fileModificationDates toFile:fileModificationDatesPath];
        }
        else {
            
            parameters = [NSKeyedUnarchiver unarchiveObjectWithFile:parametersArchivePath];
        }
    }
    
    return @{@"Parameters":parameters, @"Configuration":configuration};
}