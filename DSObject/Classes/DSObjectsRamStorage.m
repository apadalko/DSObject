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
@property (nonatomic,retain)NSString * name;
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
            storage.name=className;
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
-(id)registerOrGetRecentObject:(id)object fromStorageByIndetifier:(NSString*)indetifier{
    if (!indetifier) {
        return object;
    }
    @synchronized (self.mapTable) {
        
        id key = indetifier;
        
        if ([key isKindOfClass:[NSNumber class]]) {
            key = [key stringValue];
        }
        
        DSObject * oldObj = [self.mapTable objectForKey:key];
        
        if (!oldObj) {
            [self.mapTable setObject:object forKey:[object identifier]];
            return object;
        }else{
            
            
            /// why i did this statement for subclasses ?? it shouldn't work basiclly...each class - own fck storage
            /// mb in future updates ill add some kind of wrapper with forwarded invocations , that if someone already referenced
            /// object will also get updated data
            /// for now this one is ok
            return oldObj;
            
//            if ([oldObj class]==[object class]||[[oldObj class] isSubclassOfClass:[object class]]) {
//                return oldObj;
//            }else if ([[object class] isSubclassOfClass:[oldObj class]]){
//                
//                [self.mapTable setObject:object forKey:key];
//                
//                return object;
//            }else {
//                return object;
//            }
            
            
        }
    }
    
}
-(NSMapTable *)mapTable{
    if (!_mapTable) {
        _mapTable=[NSMapTable  mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return _mapTable;
}
@end
