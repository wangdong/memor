//
//  NaAtomStore.h
//  memor
//
//  Created by Wang Dong on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_MAX_UNDO_STEPS 20


@class NaAtomRawData;

@interface NaAtomStore : NSObject {
@private
    id snapshotStack;
    uint32_t tip;
}

@property(nonatomic, readonly) uint32_t tip;


-(void) reset;

-(int) maxSteps;
-(void) setMaxSteps: (uint32_t)maxSteps;

-(void) snapshot;

-(bool) canUndo;
-(void) undo;

-(bool) canRedo;
-(void) redo;


-(NaAtomRawData*) needCopy: atom rawData: (NaAtomRawData*)data;

+(NaAtomStore*) sharedStore;

@end
