//
//  DSObject_Private.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/14/17.
//  Copyright © 2017 Alex Padalko. All rights reserved.
//


#import "DSObject.h"
@interface DSObject ()

+(_Nonnull instancetype)objectWithData:(NSDictionary* _Nullable)data sync:(BOOL)sync;
-(nonnull DSObject*)localSync:(BOOL)fetched;

@end
