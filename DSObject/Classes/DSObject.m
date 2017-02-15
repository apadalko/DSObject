//
//  DSObject.m
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <objc/message.h>
#import <objc/objc-sync.h>
#import <objc/runtime.h>

#import "DSObject.h"

#import "DSObjectsManager.h"
#import "DSObjectsRamStorage.h"

@interface DSObject ()
{
    NSObject *lock;
    DSObjectsManager * _objectsManager;
    NSString * _storageClassName;
}

@property (nonnull,nonatomic,retain)NSMutableDictionary * _data;
@property (atomic)BOOL locked;


@end
@implementation DSObject
@synthesize _data=__data;
@dynamic className;
@dynamic objectId;
//@synthesize objectId=_objectId;
@synthesize  locked=_locked;
-(void)setKeyValues:(NSDictionary *)keyValues{
    for (NSString * key in keyValues) {
        [self setObject:[keyValues valueForKey:key] forKey:key];
    }
}

+(void)clearRam{
    [DSObjectsRamStorage clean];
}

-(void)willAddToStorage:(BOOL)fetched{
    
}
-(NSString*)storageClassName{
    if (!_storageClassName) {
        _storageClassName=NSStringFromClass([self class]);
    }
    return _storageClassName;
}

-(NSString *)objectId{
    return [self _data][@"objectId"];
}
-(void)setObjectId:(NSString *)objectId{
    [self _data][@"objectId"]=objectId;
}

-(DSObject*)localSync:(BOOL)fetched{
    DSObject * obj = [[DSObjectsRamStorage storageForClassName:[self storageClassName]] registerOrGetRecentObjectFromStorage:self fetched:fetched];
    
    if ([obj isEqual:self]) {
        return obj;
    }
    else{
        
        [obj setLocked:YES];
        if (fetched) {
            for (NSString * k in [self _data]) {
                obj[k]=[self _data][k];
            }
        }else{
            //            for (NSString * k in [self _data]) {
            //                if (!obj[k]) {
            //                      obj[k]=[obj _data][k];
            //                }
            //
            //            }
        }
        
        [obj setLocked:NO];
        return obj;
    }
    
}
+(instancetype)objectWithData:(NSDictionary*)data{
    
    DSObject * obj = [[self alloc] init];
    
    for (NSString * key in data) {
        [obj setObject:[data valueForKey:key] forKey:key];
        
    }
    
    return [obj localSync:NO];
    
}
+(instancetype)objectWithData:(NSDictionary*)data sync:(BOOL)sync{
    
    DSObject * obj = [[self alloc] init];
    
    for (NSString * key in data) {
        [obj setObject:[data valueForKey:key] forKey:key];
        
    }
    if (sync) {
        return [obj localSync:NO];
    }else return obj;
    
    
}

- (instancetype)init {
    lock = [[NSObject alloc] init];
    return self;
}


#pragma mark - Key/Value Accessors
-(void)removeObjectForKey:(NSString *)key{
    if (self.locked) {
        
        @synchronized (lock) {
            [self._data removeObjectForKey:key];
        }
    }else{
        [self._data removeObjectForKey:key];
    }
}
#pragma mark SETTERS
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    self[key] = value;
}
- (void)setObject:(id)object forKey:(NSString *)key {
    [self _setObject:object forKey:key onlyIfDifferent:NO];
}


- (void)_setObject:(id)object forKey:(NSString *)key onlyIfDifferent:(BOOL)onlyIfDifferent {
    if (onlyIfDifferent) {
        id currentObject = self[key];
        if (currentObject == object ||
            [currentObject isEqual:object]) {
            return;
        }
    }
    
    id val = [self _processValue:object forKey:key];
    
    if (self.locked) {
        @synchronized (lock) {
            
            
            
            
            self._data[key]=val;
        }
    }else{
        self._data[key]=val;
    }
    
    
}

#pragma mark GETTERS
- (void)setObject:(id)object forKeyedSubscript:(NSString *)key {
    [self setObject:object forKey:key];
}
- (id)objectForKey:(NSString *)key {
    
    if (self.locked) {
        @synchronized (lock) {
            id result = self._data[key];
            return result;
        }
    }else{
        id result = self._data[key];
        return result;
        
    }
    
}
-(id)objectForKeyedSubscript:(NSString *)key{
    return [self objectForKey:key];
}
- (id)valueForUndefinedKey:(NSString *)key {
    return self[key];
}










#pragma mark - process value
-(id)_processValue:(id)val forKey:(NSString*)key{
    
    //    [[self objectController] ]
    
    DSProperty* prop = [[self objectsManager] propertyForKey:key];
    if (prop) {
        
        id value = val;
        
        Class propertyClass = prop.propertyClass;
        
        
        if (propertyClass == [NSString class]) {
            if ([value isKindOfClass:[NSNumber class]]) {
                // NSNumber -> NSString
                value = [value description];
            } else if ([value isKindOfClass:[NSURL class]]) {
                // NSURL -> NSString
                value = [value absoluteString];
            }
        } else if ([value isKindOfClass:[NSString class]]) { //NSString
            if (propertyClass == [NSURL class]) {
                // NSString -> NSURL
                value = [value urlFromString:val];
            } else if (prop.isNumberType) {
                NSString *oldValue = value;
                
                // NSString -> NSNumber
                if (propertyClass == [NSDecimalNumber class]) {
                    value = [NSDecimalNumber decimalNumberWithString:oldValue];
                } else {
                    value = [[DSObject numberFormatter] numberFromString:oldValue];
                }
                
                // BOOL
                if (prop.isBoolType) {
                   
                    NSString *lower = [oldValue lowercaseString];
                    if ([lower isEqualToString:@"yes"] || [lower isEqualToString:@"true"]) {
                        value = @YES;
                    } else if ([lower isEqualToString:@"no"] || [lower isEqualToString:@"false"]) {
                        value = @NO;
                    }
                }
            }
        } else if ([value isKindOfClass:[NSDictionary class]]&&[propertyClass isSubclassOfClass:[DSObject class]]){
            return [propertyClass objectWithData:value];
        }else  if (propertyClass==[NSDate class]) {
            
            if ([value isKindOfClass:[NSNumber class]]) {
                
                value = [NSDate dateWithTimeIntervalSince1970:[value integerValue]];
            } else if ([value isKindOfClass:[NSURL class]]) {
                // NSURL -> NSString
                value = nil;
            }
        }
        
        
        // duh...
        if (propertyClass && ![value isKindOfClass:propertyClass]) {
            value = nil;
        }
        
        
        return value;
        
        
    }else
        return val;
}

#pragma mark - val helpers temp
- (NSURL *)urlFromString:(NSString*)string
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return [NSURL URLWithString:output];
}


#pragma mark - Convert To Dictionary
-(NSDictionary *)convertToDictionary{
    
    NSMutableDictionary * newDictionary = [[NSMutableDictionary alloc] init];
    NSDictionary *currentDataCopy = [[self _data] copy];
    for (NSString * k in currentDataCopy) {
        
        id val  = [ self _data][k];
        [newDictionary setValue:[self processValue:val] forKey:k];
    }
    return newDictionary;
}
-(id)processValue:(id)val{
    if ([val isKindOfClass:[DSObject class]]) {
        return [val convertToDictionary];
    }else if ([val isKindOfClass:[NSDictionary class]]){
        return val;
    }else if ([val isKindOfClass:[NSArray class]]){
        NSMutableArray * newArr = [[NSMutableArray alloc] init];
        
        for (id v in val) {
            [newArr addObject:[self processValue:v]];
        }
        return newArr;
    }else return val;
}

#pragma mark - methods creation

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    
    if (self == [DSObject class]) {
        return NO;
    }
    
    NSMethodSignature *signature = [[DSObjectsManager  objectManagerForClass:[self class]] forwardingMethodSignatureForSelector:sel];
    if (!signature) {
        return NO;
    }
    
    // Convert the method signature *back* into a objc type string (sidenote, why isn't this a built in?).
    NSMutableString *typeString = [NSMutableString stringWithFormat:@"%s", signature.methodReturnType];
    for (NSUInteger argumentIndex = 0; argumentIndex < signature.numberOfArguments; argumentIndex++) {
        [typeString appendFormat:@"%s", [signature getArgumentTypeAtIndex:argumentIndex]];
    }
    
    // TODO: (richardross) Support stret return here (will need to introspect the method signature to do so).
    class_addMethod(self, sel, _objc_msgForward, typeString.UTF8String);
    
    return YES;
}


- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (![[self objectsManager] forwardObjectInvocation:anInvocation withObject:self]) {
        [self doesNotRecognizeSelector:anInvocation.selector];
    }
}

#pragma mark - lazy init
-(DSObjectsManager*)objectsManager{
    if (!_objectsManager) {
        _objectsManager=[DSObjectsManager objectManagerForClass:[self class]];
    }
    
    return _objectsManager;
}

static NSNumberFormatter *_numberFormatter;
+(NSNumberFormatter*)numberFormatter{
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
    }
    return _numberFormatter;
}
#pragma mark data
-(NSMutableDictionary *)_data{
    if (!__data) {
        __data=[[NSMutableDictionary alloc] init];
    }
    return __data;
}


@end
