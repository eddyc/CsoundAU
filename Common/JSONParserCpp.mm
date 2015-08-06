/*
 * JSONParser.mm
 *
 * Copyright (C) 2015 Edward Costello
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#include <Foundation/Foundation.h>
#include "JSONParserCpp.h"

NSArray *getJSONFromFile(string bundleID, string resourceName)
{
    NSString *bundleIDString = [NSString stringWithUTF8String:bundleID.c_str()];
    NSString *resourceString = [NSString stringWithUTF8String:resourceName.c_str()];
    NSBundle *bundle = [NSBundle bundleWithIdentifier:bundleIDString];
    
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


NSArray *getJSONFromFile(NSString *bundleID, NSString *resourceName)
{
    return getJSONFromFile([bundleID cStringUsingEncoding:NSUTF8StringEncoding],
                           [resourceName cStringUsingEncoding:NSUTF8StringEncoding]);
}


vector<Parameter> parseParameters(string bundleID)
{
    NSArray *allKeys = getJSONFromFile(bundleID, "Parameters");
    
    vector<Parameter> parameters;
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
        
        const char *name = [parameterArray[0] cStringUsingEncoding:NSUTF8StringEncoding];
        Float32 minValue = [parameterArray[1] floatValue];
        Float32 maxValue = [parameterArray[2] floatValue];
        Float32 defaultValue = [parameterArray[3] floatValue];
        UInt32 unit = (UInt32)[parameterArray[4] integerValue];
        UInt32 flag = (UInt32)[parameterArray[5] integerValue];
        
        if ([[parameterArray objectAtIndex:6] isNotEqualTo:@false]) {
            
            vector<string> strings;
            NSArray *stringArray = [parameterArray objectAtIndex:6];
            
            for (size_t j = 0; j < stringArray.count; ++j) {
                
                strings.push_back([[stringArray objectAtIndex:j] cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
            parameters.push_back({name, minValue, maxValue, defaultValue, unit, flag, strings});
        }
        else {
            
            parameters.push_back({name, minValue, maxValue, defaultValue, unit, flag});
        }
    }
    
    return parameters;
}

vector<pair<string, map<string, Float32>>> parsePresets(string bundleID)
{
    NSArray *allKeys = getJSONFromFile(bundleID, "Presets");
    
    vector<pair<string, map<string, Float32>>> presets;
    
    for (size_t i = 0; i < allKeys.count; i++) {
        
        NSDictionary *presetJSON = allKeys[i];
        string name = [presetJSON[@"name"] cStringUsingEncoding:NSUTF8StringEncoding]?:to_string(i);
        map<string, Float32> preset;
        
        NSDictionary *presetParameters = presetJSON[@"preset"];
        NSArray *presetKeys = presetParameters.allKeys;
        
        for (size_t j = 0; j < presetKeys.count; ++j) {
            
            Float32 value = [presetParameters[presetKeys[j]] floatValue];
            string key = [presetKeys[j] cStringUsingEncoding:NSUTF8StringEncoding];
            preset[key] = value;
        }
        
        presets.push_back({name, preset});
    }
    
    return presets;
}

map<string, string> parseConfiguration(string bundleID)
{
    NSDictionary *allKeys = (NSDictionary *)getJSONFromFile(bundleID, "Configuration");
    map<string, string> configuration;
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
    
    string viewBundleID = [configurationArray[0] cStringUsingEncoding:NSUTF8StringEncoding];
    string viewType = [configurationArray[1] cStringUsingEncoding:NSUTF8StringEncoding];
    string viewFileName = [configurationArray[2] cStringUsingEncoding:NSUTF8StringEncoding];
    string csdName = [configurationArray[3] cStringUsingEncoding:NSUTF8StringEncoding];
    configuration["ViewBundleID"] = viewBundleID;
    configuration["ViewType"] = viewType;
    configuration["ViewFileName"] = viewFileName;
    configuration["csd"] = csdName;
    
    if (allKeys[@"ViewWidth"] != nil) {
        
        configuration["ViewWidth"] = [allKeys[@"ViewWidth"] cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (allKeys[@"ViewHeight"] != nil) {
        
        configuration["ViewHeight"] = [allKeys[@"ViewHeight"] cStringUsingEncoding:NSUTF8StringEncoding];
    }
    return configuration;
}


