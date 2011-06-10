//
//  NaAtom.h
//  memor
//
//  Created by Wang Dong on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NaAtomRawData.h"


@interface NaAtom : NSObject {
@private
    NaAtomRawData* rawData;
}

@property(readonly, nonatomic) NaAtomRawData* rawData;

-(id) initWithRawData: (NaAtomRawData*)data;
-(void) beforeWrite;
-(NaAtomRawData*) swapData: (NaAtomRawData*)data;
-(void) didFinishSwapping;

@end
