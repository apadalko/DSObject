//
//  SRKObject.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 identifier
 */

#ifndef DSAssert
#define DSAssert( condition, ... ) NSCAssert( (condition) , ##__VA_ARGS__)
#endif // DSAssert

extern NSString *const kDSIdentifier;


NS_REQUIRES_PROPERTY_DEFINITIONS

@interface DSObject : NSObject

+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

+(_Nonnull instancetype)objectWithType:(NSString*)type;
+(_Nonnull instancetype)objectWithType:(NSString*)type andData:(NSDictionary* _Nullable )data;
+(instancetype)objectWithType:(NSString*)type andIdentifier:(NSString*)identifier;
+(instancetype)objectWithType:(NSString*)type andIdentifier:(NSString*)identifier andData:(NSDictionary*)data;

+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable )data;
+(instancetype)objectWithIdentifier:(NSString*)identifier;
+(instancetype)objectWithIdentifier:(NSString*)identifier andData:(NSDictionary*)data;


-(void)setKeyValues:(NSDictionary * _Nullable)keyValues;


#pragma mark - set objs
- (nullable id)objectForKey:( NSString * _Nonnull)key;
- (void)setObject:(id _Nullable)object forKey:(NSString * _Nullable)key;
- (void)removeObjectForKey:(NSString * _Nonnull)key;

//TODO make able to use properties here
- (nullable id)objectForKeyedSubscript:(NSString * _Nonnull)key;
- (void)setObject:(id _Nullable)object forKeyedSubscript:(NSString * _Nullable)key;


#pragma mark - props
@property (nullable, nonatomic, strong) NSString * identifier;
//@property (nullable, nonatomic, strong,readonly) NSString * localId;





-(NSDictionary* _Nonnull)convertToDictionary;







////
+(void)clearRam;
@end
