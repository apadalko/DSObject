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






NSString *const kDSIdentifier = @"identifier";


@interface DSObject ()
{
    NSObject *lock;
    DSObjectsManager * _objectsManager;
    NSString * _storageName;
  
}

@property (nonnull,nonatomic,retain)NSMutableDictionary * _data;
@property (atomic)BOOL locked;


@end
@implementation DSObject

@synthesize _data=__data;
@dynamic identifier;

@synthesize  locked=_locked;

#pragma mark - ObjectId



#pragma mark - constructors


+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable )data{
    DSAssert(self != [DSObject class], @"Available only for subclasses");
    return [self objectWithType:nil andIdentifier:nil andData:data sync:YES];

}
+(instancetype)objectWithIdentifier:(NSString*)identifier{
    DSAssert(self != [DSObject class], @"Available only for subclasses");
    return [self objectWithType:nil andIdentifier:identifier andData:nil sync:YES];
}
+(instancetype)objectWithIdentifier:(NSString*)identifier andData:(NSDictionary*)data{
    DSAssert(self != [DSObject class], @"Available only for subclasses");
    return [self objectWithType:nil andIdentifier:identifier andData:data sync:YES];
}

+(_Nonnull instancetype)objectWithType:(NSString*)type{
    return [self objectWithType:type andIdentifier:nil andData:nil sync:NO];
}
+(instancetype)objectWithType:(NSString*)type andData:(NSDictionary*)data{
    return [self objectWithType:type andIdentifier:nil andData:data sync:YES];
}
+(instancetype)objectWithType:(NSString*)type andIdentifier:(NSString*)identifier{
    return [self objectWithType:type andIdentifier:identifier andData:nil sync:YES];
}
+(instancetype)objecWithType:(NSString*)type andIdentifier:(NSString*)identifier andData:(NSDictionary*)data{
    return [self objectWithType:type andIdentifier:identifier andData:data sync:YES];
}

#pragma mark private
+(instancetype)objectWithType:(NSString*)type andIdentifier:(NSString*)identifier andData:(NSDictionary*)data sync:(BOOL)sync{
    DSObject * obj = [[self alloc] init];
    if (type) {
        [obj setCustomStorageName:type];
    }
    for (NSString * key in data) {
        [obj setObject:[data valueForKey:key] forKey:key];
        
    }
    
    if (sync) {
        return [obj sync:YES];
    }else return obj;
}
- (instancetype)init {
    lock = [[NSObject alloc] init];
    return self;
}

#pragma mark - private methods



-(NSString*)identifierKey{
    return [[self class] identifierKey];
}

#pragma mark - public static

+(NSString*)identifierKey{
    return kDSIdentifier;
}

#pragma mark -

-(void)setKeyValues:(NSDictionary *)keyValues{
    for (NSString * key in keyValues) {
        [self setObject:[keyValues valueForKey:key] forKey:key];
    }
}



+(void)clearRam{
    [DSObjectsRamStorage clean];
}
-(BOOL)allowedToUseRamStorage{
    return self.identifier && (self.class != [DSObject class] || _storageName!=nil) ;
}
-(void)setCustomStorageName:(NSString*)storageName{
    _storageName=storageName;
}

-(NSString*)_ds_objectType{
    NSString * storageName = [self storageName];
    
    if (storageName==nil) {
        storageName=NSStringFromClass([self class]);
    }
    return storageName;
}
-(NSString*)storageName{
    return  _storageName;
}

-(NSString *)objectId{
    id a = [self _data][[self identifierKey]];
    return a;
}
-(void)setObjectId:(NSString *)objectId{
    [self _data][[self identifierKey]]=objectId;
}

-(void)copyToObject:(DSObject*)toObject override:(BOOL)override{
    
    [self setLocked:YES];
    if (override) {
        for (NSString * k in [self _data]) {
            toObject[k]=[self _data][k];
        }
    }else{
        //            for (NSString * k in [self _data]) {
        //                if (!obj[k]) {
        //                      obj[k]=[obj _data][k];
        //                }
        //
        //            }
    }
    
    [self setLocked:NO];
}

-(DSObject*)sync:(BOOL)override{
    
    if (![self allowedToUseRamStorage]) {
        return self;
    }
    
 
    
    DSObject * obj = [[DSObjectsRamStorage storageForClassName:[self _ds_objectType]] registerOrGetRecentObject:self fromStorageByIndetifier:[self identifier]];
    
    if ([obj isEqual:self]) {
        return obj;
    }
    else{
        [self copyToObject:obj override:override];
        return obj;
    }
}

#pragma mark - to remove
-(instancetype)localSync:(BOOL)fetched{
       // so here we need to check if local id is passing and should do double sync: 1 in main storage and then in some new refrence of local storage
    
    if (![self allowedToUseRamStorage]) {
        return self;
    }
  
    
    DSObject * obj = [[DSObjectsRamStorage storageForClassName:[self _ds_objectType]] registerOrGetRecentObject:self fromStorageByIndetifier:[self identifier]];
    
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
#pragma mark -




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

-(void)setValue:(id)value forKey:(NSString *)key{
    self[key]=key;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    self[key] = value;
}
- (void)setObject:(id)object forKey:(NSString *)key {
    [self _setObject:object forKey:key];
}


- (void)_setObject:(id)object forKey:(NSString *)key {

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
