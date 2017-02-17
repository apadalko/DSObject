//
//  SRKRamStorage.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "DSObjectsRamStorage.h"
@interface DSObjectsRamStorage ()
@property (nonatomic,retain)NSMapTable  * mapTable;
@end
@implementation DSObjectsRamStorage
static NSMutableDictionary * storageData;
+(instancetype)storageForClassName:(NSString* )className{
    @synchronized (storageData) {
        if (!storageData) {
            storageData=[[NSMutableDictionary alloc] init];
        }
        
        DSObjectsRamStorage * storage = [storageData valueForKey:className];
        if (!storage) {
            storage=[[DSObjectsRamStorage alloc] init];
            [storageData setValue:storage forKey:className];
        }
        
        return storage;
    }
    
    
    
}

+(void)clean{
    
    @synchronized (storageData) {
        
        storageData=nil;
    }
}
-(DSObject*)registerOrGetRecentObjectFromStorage:(DSObject*)object fetched:(BOOL)fetched{
    if (![object objectId]) {
        return object;
    }
    @synchronized (self.mapTable) {
        
        id key = [object objectId];
        
        if ([key isKindOfClass:[NSNumber class]]) {
            key = [key stringValue];
        }
        
        DSObject * oldObj = [self.mapTable objectForKey:key];
        
        if (!oldObj) {
            [self.mapTable setObject:object forKey:[object objectId]];
            [object willAddToStorage:fetched];
            return object;
        }else{
            
            if ([oldObj class]==[object class]||[[oldObj class] isSubclassOfClass:[object class]]) {
                return oldObj;
            }else if ([[object class] isSubclassOfClass:[oldObj class]]){
                
                [self.mapTable setObject:object forKey:key];
                
                return object;
            }else {
                return object;
            }
            
            
        }
    }
    
}
-(NSMapTable *)mapTable{
    if (!_mapTable) {
        _mapTable=[NSMapTable  mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _mapTable;
}
@end
