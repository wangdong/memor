//
//  NaAtomRawData.m
//  memor
//
//  Created by Wang Dong on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NaAtomRawData.h"
#import "NaAtomStore.h"


@implementation NaAtomRawData
@synthesize tip;

-(id) init {
    self = [super init];
    tip = [NaAtomStore sharedStore].tip;
    return self;
}

-(NaAtomRawData*) copy {
    assert(false);
    return [self retain];
}


@end
