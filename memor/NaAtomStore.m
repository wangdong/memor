//
//  NaAtomStore.m
//  memor
//
//  Created by Wang Dong on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NaAtomStore.h"
#import "NaAtom.h"
#import "NaAtomRawData.h"


@interface NaAtomImage : NSObject {
@private
    NaAtom* atom;
    NaAtomRawData* data;
}
@property(nonatomic, retain) NaAtom* atom;
@property(nonatomic, retain) NaAtomRawData* data;

@end


@implementation NaAtomImage
@synthesize atom;
@synthesize data;

-(void) dealloc {
    [atom release];
    [data release];
    [super dealloc];
}

-(id) init {
    self = [super init];
    atom = nil;
    data = nil;
    return self;
}

@end


@interface NaAtomSnapshot : NSObject {
@private
    NSMutableArray* atomImages;
}

-(void) appendAtom: (NaAtom*)atom rawData: (NaAtomRawData*)data;
-(void) swapData;
-(void) clear;

@end

@implementation NaAtomSnapshot

-(void) dealloc {
    [atomImages release];
    [super dealloc];
}

-(id) init {
    self = [super init];
    atomImages = [[NSMutableArray alloc] init];
    return self;
}

-(void) appendAtom: (NaAtom*)atom rawData: (NaAtomRawData*)data {
    NaAtomImage* image = [[NaAtomImage alloc] init];
    [image setAtom:atom];
    [image setData:data];
    [atomImages addObject:image];
    [image release];
}

-(void) swapData {
    for (id i in atomImages) {
        NaAtomImage* image = (NaAtomImage*)i;
        NaAtomRawData* data = [[image atom] swapData: [image data]];
        [image setData:data];
        [data release];
    }
}

-(void) clear {
    [atomImages removeAllObjects];
}

@end


@interface AtomSnapshotStack : NSObject {
@private
    NSMutableArray* snapshots;
    int32_t top;
    uint32_t capability;
}

@property (readonly, nonatomic) uint32_t capability;

-(void) setCapability: (uint32_t)cap;
-(void) forward;
-(void) backward;
-(uint32_t) snapshotsAhead;
-(void) cleanupAhead;
-(bool) isEmpty;
-(NaAtomSnapshot*) top;
-(void) reset;
-(void) reCapability;

@end

@implementation AtomSnapshotStack
@synthesize capability;


-(void) dealloc {
    [snapshots release];
    [super dealloc];
}

-(id) init {
    self = [super init];
    
    snapshots = [[NSMutableArray alloc] init];
    top = -1;
    capability = DEFAULT_MAX_UNDO_STEPS;
    
    return self;
}

-(void) setCapability: (uint32_t)cap {
    capability = cap;
    [self reCapability];
}

-(void) forward {
    if ([self snapshotsAhead] == 0) {
        NaAtomSnapshot* snapshot = [[NaAtomSnapshot alloc] init];
        [snapshots addObject:snapshot];
        [snapshot release];
    }
    ++top;
    
    [self reCapability];
}

-(void) backward {
    if (top > -1)
        --top;
}

-(uint32_t) snapshotsAhead {
    return [snapshots count] - (top + 1);
}


-(void) cleanupAhead {
    uint32_t size = [snapshots count];
    for (uint32_t i = top + 1; i < size; ++i)
        [snapshots removeLastObject];
}

-(bool) isEmpty {
    return top == -1;
}

-(NaAtomSnapshot*) top {
    return [snapshots objectAtIndex: top];
}

-(void) reset {
    for (id i in snapshots) {
        NaAtomSnapshot* snapshot = (NaAtomSnapshot*)i;
        [snapshot clear];
    }
    [snapshots removeAllObjects];
    
    top = -1;
    capability = DEFAULT_MAX_UNDO_STEPS;
}

-(void) reCapability {
    if (top >= capability) {
        int count = top - capability + 1;
        
        for (int i = 0; i < count; ++i) {
            NaAtomSnapshot* snapshot = [snapshots objectAtIndex: 0];
            [snapshot clear];
            [snapshots removeObjectAtIndex: 0];
            --top;
        }
    }    
}

@end



@implementation NaAtomStore
@synthesize tip;

-(void) dealloc {
    [snapshotStack release];
    [super dealloc];
}

-(id) init {
    self = [super init];
    tip = 0;
    snapshotStack = [[AtomSnapshotStack alloc] init];
    return self;
}


-(void) reset {
    tip = 0;
    [snapshotStack reset];
}

-(int) maxSteps {
    return [(AtomSnapshotStack*)snapshotStack capability];
}

-(void) setMaxSteps: (uint32_t)maxSteps {
    [snapshotStack setCapability: maxSteps];
}

-(void) commit {
    if ([self canRedo])
        [snapshotStack cleanupAhead];
    [snapshotStack forward];
    ++tip;
}

-(bool) canUndo {
    return ![snapshotStack isEmpty];
}

-(void) undo {
    if ([self canUndo]) {
        NaAtomSnapshot* snapshot = [snapshotStack top];
        [snapshot swapData];
        [snapshotStack backward];
        --tip;
    }
}

-(bool) canRedo {
    return [snapshotStack snapshotsAhead] > 0;
}

-(void) redo {
    if ([self canRedo]) {
        ++tip;
        [snapshotStack forward];
        [[snapshotStack top] swapData];
    }
}

-(NaAtomRawData*) needCopy: atom rawData: (NaAtomRawData*)data {
    if ([data tip] < tip) {
        [[snapshotStack top] appendAtom:atom rawData:data];
        data = [data deepCopy];
    }
    return data;
}


+(NaAtomStore*) sharedStore {
    static NaAtomStore* inst = nil;
    if (inst == nil)
        inst = [[NaAtomStore alloc] init];
    return inst;
}


@end
