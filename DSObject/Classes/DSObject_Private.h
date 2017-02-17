//
//  DSObject_Private.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/14/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//


#import "DSObject.h"
@interface DSObject ()


+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable)data storageName:(NSString* _Nullable)storageName;
+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable)data sync:(BOOL)sync storageName:(NSString* _Nullable)storageName;
+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable)data sync:(BOOL)sync;
-(DSObject * _Nonnull)localSync:(BOOL)fetched;
-(void)setCustomStorageName:(NSString * _Nonnull)storageName;
-(void)setCustomIdentifierKey:(NSString* _Nonnull)identifierKey;
@end
