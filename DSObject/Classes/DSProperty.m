//
//  DSProperty.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/14/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import "DSProperty.h"
#import <objc/message.h>

/// some constanst to finds out type of object
NSString *const DSPropertyTypeInt = @"i";
NSString *const DSPropertyTypeShort = @"s";
NSString *const DSPropertyTypeFloat = @"f";
NSString *const DSPropertyTypeDouble = @"d";
NSString *const DSPropertyTypeLong = @"l";
NSString *const DSPropertyTypeLongLong = @"q";
NSString *const DSPropertyTypeChar = @"c";
NSString *const DSPropertyTypeBOOL1 = @"c";
NSString *const DSPropertyTypeBOOL2 = @"b";
NSString *const DSPropertyTypePointer = @"*";

NSString *const DSPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const DSPropertyTypeMethod = @"^{objc_method=}";
NSString *const DSPropertyTypeBlock = @"@?";
NSString *const DSPropertyTypeClass = @"#";
NSString *const DSPropertyTypeSEL = @":";
NSString *const DSPropertyTypeId = @"@";




static inline NSString *ds_safeStringWithPropertyAttributeValue(objc_property_t property, const char *attribute) {
    char *value = property_copyAttributeValue(property, attribute);
    if (!value)
        return nil;
        return (__bridge_transfer NSString *)CFStringCreateWithCStringNoCopy(NULL,
                                                                         value,
                                                                         kCFStringEncodingUTF8,
                                                                         kCFAllocatorMalloc);
}

static inline NSString *ds_stringByCapitalizingFirstCharacter(NSString *string) {
    return [NSString stringWithFormat:@"%C%@",
            (unichar)toupper([string characterAtIndex:0]),
            [string substringFromIndex:1]];
}



@implementation DSProperty
static NSArray  * _numberTypes;

+(NSArray*)numberTypes {
 
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       _numberTypes =  @[DSPropertyTypeInt, DSPropertyTypeShort, DSPropertyTypeBOOL1, DSPropertyTypeBOOL2, DSPropertyTypeFloat, DSPropertyTypeDouble, DSPropertyTypeLong, DSPropertyTypeLongLong, DSPropertyTypeChar];
    });
    return _numberTypes;
};

+ (instancetype)propertyWithSourceClass:(Class)sourceClass andName:(NSString *)propertyName;
{
    return [[self alloc] initWithSourceClass:sourceClass name:propertyName];
}


- (instancetype)initWithSourceClass:(Class)sourceClass name:(NSString *)propertyName {
    self = [super init];
    if (!self) return nil;
    
    _sourceClass = sourceClass;
    _propertyName = [propertyName copy];
//    _associationType = associationType;
    
    objc_property_t objcProperty = class_getProperty(sourceClass, _propertyName.UTF8String);
    
    _typeEncoding = ds_safeStringWithPropertyAttributeValue(objcProperty, "T");
    _objectType = [_typeEncoding hasPrefix:@"@"];
    
    NSString *propertyGetter = ds_safeStringWithPropertyAttributeValue(objcProperty, "G") ?: _propertyName;
    _getterSelector = NSSelectorFromString(propertyGetter);
    
    BOOL readonly = ds_safeStringWithPropertyAttributeValue(objcProperty, "R") != nil;
    NSString *propertySetter = ds_safeStringWithPropertyAttributeValue(objcProperty, "S");
    if (propertySetter == nil && !readonly) {
        propertySetter = [NSString stringWithFormat:@"set%@:", ds_stringByCapitalizingFirstCharacter(_propertyName)];
    }
    
    _setterSelector = NSSelectorFromString(propertySetter);
    

    BOOL isCopy = ds_safeStringWithPropertyAttributeValue(objcProperty, "C") != nil;
    BOOL isWeak = ds_safeStringWithPropertyAttributeValue(objcProperty, "W") != nil;
    BOOL isRetain = ds_safeStringWithPropertyAttributeValue(objcProperty, "&") != nil;
    
    if (isWeak) {
        _propertyForceType = DSPropertyForceTypeWeak;
    } else if (isCopy) {
        _propertyForceType = DSPropertyForceTypeCopy;
    } else if (isRetain) {
        _propertyForceType = DSPropertyForceTypeStrong;
    } else {
        _propertyForceType = DSPropertyForceTypeAssign;
    }
    
    NSString *attrs = @(property_getAttributes(objcProperty));
    NSUInteger dotLoc = [attrs rangeOfString:@","].location;
    NSString *code = nil;
    NSUInteger loc = 1;
    if (dotLoc == NSNotFound) {
        code = [attrs substringFromIndex:loc];
    } else {
        code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
    }
    _code = code;
 
    
    if ([_code isEqualToString:DSPropertyTypeId]) {
        _objectType = YES;
    } else if (code.length == 0) {
        //blabla 
    } else if (code.length > 3 && [code hasPrefix:@"@\""]) {
        _propertyClassName = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _propertyClass = NSClassFromString(_propertyClassName);
        //TODO FOUNDATION CHECK??
        
        _numberType = [_propertyClass isSubclassOfClass:[NSNumber class]];
        
    } else if ([code isEqualToString:DSPropertyTypeSEL] ||
               [code isEqualToString:DSPropertyTypeIvar] ||
               [code isEqualToString:DSPropertyTypeMethod]) {
        
// THIS THIS NOT A PROP
//
    }

    NSString *lowerCode = _code.lowercaseString;
 
    if ([[DSProperty numberTypes] containsObject:lowerCode]) {
        _numberType = YES;
        
        if ([lowerCode isEqualToString:DSPropertyTypeBOOL1]
            || [lowerCode isEqualToString:DSPropertyTypeBOOL2]) {
            _boolType = YES;
        }
    }

    
    
    
    return self;
}


@end
