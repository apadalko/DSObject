//
//  SRKObject.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_REQUIRES_PROPERTY_DEFINITIONS
@interface DSObject : NSObject

+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable )data;

-(void)setKeyValues:(NSDictionary * _Nullable)keyValues;


#pragma mark - set objs
- (nullable id)objectForKey:( NSString * _Nonnull)key;
- (void)setObject:(id _Nullable)object forKey:(NSString * _Nullable)key;
- (void)removeObjectForKey:(NSString * _Nonnull)key;
- (nullable id)objectForKeyedSubscript:(NSString * _Nonnull)key;
- (void)setObject:(id _Nullable)object forKeyedSubscript:(NSString * _Nullable)key;


#pragma mark - props
@property (nonatomic,retain , nonnull) NSString * className;
@property (nullable, nonatomic, strong) NSString * objectId;






-(void)willAddToStorage:(BOOL)fetched;
-(NSDictionary* _Nonnull)convertToDictionary;





-(NSString * _Nonnull)storageClassName;

////
+(void)clearRam;
@end
