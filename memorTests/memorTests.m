//
//  memorTests.m
//  memorTests
//
//  Created by Wang Dong on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "memorTests.h"
#import "NaAtomStore.h"
#import "NaAtomRawData.h"
#import "NaAtom.h"


@interface MyAtomData : NaAtomRawData {
@private
    NSString* msg;
}

@property(copy, nonatomic) NSString* msg;


@end

@implementation MyAtomData
@synthesize msg;

-(NaAtomRawData*) deepCopy {

    MyAtomData* data = [[MyAtomData alloc] init];
    data.msg = self.msg;
    return data;
}

@end


@interface MyAtom : NaAtom {
}

-(NSString*) msg;
-(void) putMsg: (NSString*) msg;

@end

@implementation MyAtom

-(id) init {
    MyAtomData* data = [[MyAtomData alloc] init];
    self = [super initWithRawData: data];
    [data release];
    return self;
}

-(NSString*) msg {
    return ((MyAtomData*)(self.rawData)).msg;
}

-(void) putMsg: (NSString*)msg {
    [self beforeWrite];
    ((MyAtomData*)(self.rawData)).msg = msg;
}

@end


@implementation memorTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testNormal
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NaAtomStore* store = [NaAtomStore sharedStore];
    MyAtom* atom = [[[MyAtom alloc] init] autorelease];
    
    [atom putMsg: @"Hello, World!"];
    
    [store commit];
    [atom putMsg: @"Hello, Atom!"];
    [atom putMsg: @"Hello, AtomStore!"];
    [store commit];
    [atom putMsg: @"Hello, AtomImage!"];
    
    STAssertEquals(@"Hello, AtomImage!", [atom msg], @"");
    [store undo];
    STAssertEquals(@"Hello, AtomStore!", [atom msg], @"");
    [store undo];
    STAssertEquals(@"Hello, World!", [atom msg], @"");

    
    [pool drain];
}

@end
