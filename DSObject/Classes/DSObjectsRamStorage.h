//
//  SRKRamStorage.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSObject.h"
@interface DSObjectsRamStorage : NSObject
+(instancetype)storageForClassName:(NSString* )className;
-(id)registerOrGetRecentObject:(id)object fromStorageByIndetifier:(NSString*)indetifier;
+(void)clean;
@end
