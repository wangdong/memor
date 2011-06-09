//
//  NaAtomRawData.h
//  memor
//
//  Created by Wang Dong on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NaAtomRawData : NSObject {
@private
    uint32_t tip;
}

@property(nonatomic, readonly) uint32_t tip;

-(NaAtomRawData*) copyData;

@end

