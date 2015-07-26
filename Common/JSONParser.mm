/*
 * JSONParser.mm
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#include <Foundation/Foundation.h>
#include "JSONParser.h"

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
                                   allKeys[@"NibName"],
                                   allKeys[@"csd"],
                                   nil];

    if (configurationArray.count != 3) {

        printf("Error, configuration json malformed\nExiting\n");
        exit(-1);
    }

    string viewBundleID = [configurationArray[0] cStringUsingEncoding:NSUTF8StringEncoding];
    string nibName = [configurationArray[1] cStringUsingEncoding:NSUTF8StringEncoding];
    string csdName = [configurationArray[2] cStringUsingEncoding:NSUTF8StringEncoding];
    configuration["ViewBundleID"] = viewBundleID;
    configuration["NibName"] = nibName;
    configuration["csd"] = csdName;
    return configuration;
}
