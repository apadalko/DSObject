//
//  DSObject_Private.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/14/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//


#import "DSObject.h"
@interface DSObject ()

+(instancetype)objectWithType:(NSString*)type andIdentifier:(NSString*)identifier andData:(NSDictionary*)data sync:(BOOL)sync;

#pragma mark -

+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable)data storageName:(NSString* _Nullable)storageName;
+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable)data sync:(BOOL)sync storageName:(NSString* _Nullable)storageName;
+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable)data sync:(BOOL)sync;
-(void)setCustomStorageName:(NSString * _Nonnull)storageName;


////
-(void)setLocked:(BOOL)locked;
-(instancetype)sync:(BOOL)override;
-(BOOL)allowedToUseRamStorage;
-(NSString*)_ds_objectType;
-(NSString*)storageName;


-(void)copyToObject:(DSObject*)toObject override:(BOOL)override;
@end
