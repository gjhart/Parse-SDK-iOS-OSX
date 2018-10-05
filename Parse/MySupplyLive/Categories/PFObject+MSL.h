//
//  PFObject+MSL.h
//  Parse
//
//  Created by Greg Hart on 1/23/18.
//  Copyright © 2018 Parse Inc. All rights reserved.
//

#import <Parse/PFObject.h>

@interface PFObject (MSL)

+ (NSDictionary<NSString *, NSArray<PFObject *> *> *)objectsForServerResponse:(NSDictionary *)result
                                                               responseString:(NSString *)responseString
                                                                     response:(NSHTTPURLResponse *)response;

@end
