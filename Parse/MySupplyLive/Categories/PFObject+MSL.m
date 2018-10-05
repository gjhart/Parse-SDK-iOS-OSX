//
//  PFObject+MSL.m
//  Parse
//
//  Created by Greg Hart on 1/23/18.
//  Copyright © 2018 Parse Inc. All rights reserved.
//

#import "PFObject+MSL.h"
#import "PFObjectPrivate.h"
#import "PFCommandResult.h"

@implementation PFObject (MSL)

#pragma mark - Public

+ (NSDictionary<NSString *, NSArray<PFObject *> *> *)objectsForServerResponse:(NSDictionary *)result
                                                               responseString:(NSString *)responseString
                                                                     response:(NSHTTPURLResponse *)response
{
    PFCommandResult *commandResult = [PFCommandResult commandResultWithResult:result
                                                                 resultString:responseString
                                                                 httpResponse:response];
    return [PFObject _mappedObjectsForCommandResult:commandResult];
}

#pragma mark - Private

+ (NSDictionary<NSString *, NSArray<PFObject *> *> *)_mappedObjectsForCommandResult:(PFCommandResult *)commandResult
{
    NSArray<PFCommandResult *> *commandResults = [PFObject _commandResultsForCommandResult:commandResult];
    return [PFObject _mappedObjectsForCommandResults:commandResults];
}

+ (NSDictionary<NSString *, NSArray<PFObject *> *> *)_mappedObjectsForCommandResults:(NSArray<PFCommandResult *> *)commandResults
{
    NSMutableDictionary<NSString *, NSArray<PFObject *> *> *mappedObjects = [NSMutableDictionary dictionary];
    
    for (PFCommandResult *commandResult in commandResults) {
        NSMutableArray *foundObjects = [NSMutableArray arrayWithCapacity:[PFObject _totalNumberOfObjectsForCommandResults:@[commandResult]]];
        NSString *resultClassName = commandResult.result[@"meta"][@"className"];
        NSArray *resultObjects    = commandResult.result[@"results"];
        
        if (resultObjects != nil) {
            if (!resultClassName) {
                return nil;
            }
            
            for (NSDictionary *resultObject in resultObjects) {
                PFObject *object = [PFObject _objectFromDictionary:resultObject
                                                  defaultClassName:resultClassName
                                                      selectedKeys:nil];
                [foundObjects addObject:object];
            }
        }
        
        [mappedObjects setObject:foundObjects forKey:resultClassName];
    }
    
    return mappedObjects;
}

+ (NSArray<PFObject *> *)_objectsForCommandResult:(PFCommandResult *)commandResult
{
    NSArray<PFCommandResult *> *commandResults = [PFObject _commandResultsForCommandResult:commandResult];
    return [PFObject _objectsForCommandResults:commandResults];
}

+ (NSArray<PFObject *> *)_objectsForCommandResults:(NSArray<PFCommandResult *> *)commandResults
{
    NSMutableArray *foundObjects = [NSMutableArray arrayWithCapacity:[PFObject _totalNumberOfObjectsForCommandResults:commandResults]];
    
    for (PFCommandResult *commandResult in commandResults) {
        NSString *resultClassName = commandResult.result[@"meta"][@"className"];
        NSArray *resultObjects    = commandResult.result[@"results"];
        
        if (resultObjects != nil) {
            if (!resultClassName) {
                return nil;
            }
            
            for (NSDictionary *resultObject in resultObjects) {
                PFObject *object = [PFObject _objectFromDictionary:resultObject
                                                  defaultClassName:resultClassName
                                                      selectedKeys:nil];
                [foundObjects addObject:object];
            }
        }
    }
    
    return foundObjects;
}

+ (NSUInteger)_totalNumberOfObjectsForCommandResults:(NSArray<PFCommandResult *> *)commandResults
{
    NSUInteger total = 0;
    
    for (PFCommandResult *commandResult in commandResults) {
        total += ((NSArray *)commandResult.result[@"results"]).count;
    }
    
    return total;
}

+ (NSArray<PFCommandResult *> *)_commandResultsForCommandResult:(PFCommandResult *)commandResult
{
    NSString *resultClassName = commandResult.result[@"meta"][@"className"];
    
    if ([resultClassName isEqualToString:@"Response"]) {
        return [PFObject _commandResultsForData:commandResult.result[@"results"]
                                 responseString:commandResult.resultString
                                       response:commandResult.httpResponse];
    }
    
    return @[commandResult];
}

+ (NSArray<PFCommandResult *> *)_commandResultsForData:(NSArray<NSDictionary *> *)results
                                        responseString:(NSString *)responseString
                                              response:(NSHTTPURLResponse *)response
{
    NSMutableArray<PFCommandResult *> *commandResults = [NSMutableArray array];
    
    for (NSDictionary *result in results) {
        if ([result isKindOfClass:NSDictionary.class]) {
            [commandResults addObject:[PFCommandResult commandResultWithResult:result
                                                                  resultString:responseString
                                                                  httpResponse:response]];
        }
    }
    
    return commandResults;
}

@end
