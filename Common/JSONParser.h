/*
 * JSONParser.h
 *
 * Copyright (C) 2015 Edward Costello
 *
 */

#include <vector>
#include <map>
#include <string>
#import "Parameter.h"
vector<Parameter> parseParameters(string bundleID);
vector<pair<string, map<string, Float32>>> parsePresets(string bundleID);
map<string, string> parseConfiguration(string bundleID);
