//
//  NaAtom.m
//  memor
//
//  Created by Wang Dong on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NaAtom.h"
#import "NaAtomStore.h"


@implementation NaAtom
@synthesize rawData;


-(void) dealloc {
    [rawData release];
    [super dealloc];
}

-(id) initWithRawData: (NaAtomRawData*)data {
    self = [super init];
    rawData = data;
    [rawData retain];
    return self;
}



-(void) beforeWrite {
    rawData = [[NaAtomStore sharedStore] needCopy:self rawData:rawData];
}

-(NaAtomRawData*) swapData: (NaAtomRawData*)data {
    NaAtomRawData* tmp = rawData;
    rawData = data;
    [rawData retain];
    return tmp;
}

-(void) didFinishSwapping {
   
}


@end

