//
//  DSProperty.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/14/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//


#import <objc/runtime.h>
#import <Foundation/Foundation.h>


/**
 type of property attributes types
 */
typedef NS_ENUM(uint8_t,  DSPropertyForceType) {
    DSPropertyForceTypeDefault,
    DSPropertyForceTypeAssign,
    DSPropertyForceTypeStrong,
    DSPropertyForceTypeWeak,
    DSPropertyForceTypeCopy,
    DSPropertyForceTypeMutableCopy,
};

@interface DSProperty : NSObject
+ (instancetype)propertyWithSourceClass:(Class)sourceClass andName:(NSString *)propertyName;

//usualy we need to use only this four below
@property (nonatomic, readonly) Class propertyClass;
@property (nonatomic, copy, readonly) NSString *propertyClassName;

@property (nonatomic, copy, readonly) NSString *propertyName;
@property (nonatomic, readonly) DSPropertyForceType propertyForceType;

//we will save this properties - just in case
@property (nonatomic, copy, readonly) NSString *code; // could be used as property class classname
@property (nonatomic, copy, readonly) NSString *typeEncoding;
@property (nonatomic, assign, readonly) Ivar ivar;

//source class and related to source class selectors
@property (nonatomic, assign, readonly) Class sourceClass;
@property (nonatomic, assign, readonly) SEL getterSelector;
@property (nonatomic, assign, readonly) SEL setterSelector;




@property (nonatomic, assign, readonly, getter=isObjectType) BOOL objectType;
@property (nonatomic, assign, readonly, getter=isNumberType) BOOL numberType;
@property (nonatomic, assign, readonly, getter=isBoolType) BOOL boolType;
@property (nonatomic, assign, readonly, getter=isFromFoundation) BOOL fromFoundation;

@end
