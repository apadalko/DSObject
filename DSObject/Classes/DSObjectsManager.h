//
//  SRKObjectManager.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/11/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSProperty.h"
@class DSObject;
@interface DSObjectsManager : NSObject
+(DSObjectsManager*)objectManagerForClass:(Class)clazz;



-(DSObject*)registerOrGetRecentObjectFromStorage:(DSObject*)object fetched:(BOOL)fetched;


- (DSProperty*)propertyForKey:(NSString*)key;
- (NSMethodSignature *)forwardingMethodSignatureForSelector:(SEL)cmd ;
- (BOOL)forwardObjectInvocation:(NSInvocation *)invocation withObject:(DSObject*)object;

@end

