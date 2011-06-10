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

-(NaAtomRawData*) copyData {

    MyAtomData* data = [[MyAtomData alloc] init];
    data.msg = self.msg;
    return data;
}

@end


@interface MyAtom : NaAtom {
@private
    int notifyCount;
}

@property(nonatomic, readonly) int notifyCount;

-(NSString*) msg;
-(void) putMsg: (NSString*) msg;

@end

@implementation MyAtom
@synthesize notifyCount;


-(id) init {
    notifyCount = 0;
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

-(void) didFinishSwapping {
    ++notifyCount;
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
    [[NaAtomStore sharedStore] reset];
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
    
    
    //
    // undo/redoÂà∞Â∞ΩÂ§¥ÂêéÁöÑË°å‰∏∫
    //
    STAssertFalse([store canUndo], @"");
    [store undo];
    [store undo];
    [store undo];
    STAssertEquals(@"Hello, World!", [atom msg], @"");
    
    [store redo];
    STAssertEquals(@"Hello, AtomStore!", [atom msg], @"");
    [store redo];
    STAssertEquals(@"Hello, AtomImage!", [atom msg], @"");
    
    STAssertFalse([store canRedo], @"");
    [store redo];
    [store redo];
    [store redo];
    STAssertEquals(@"Hello, AtomImage!", [atom msg], @"");
    
    //
    // redoÂêéÂèàÊèê‰∫§‰ºö‰∏¢ÂºÉÊéâÂâçÈù¢ÁöÑÂÜÖÂÆπ‰ªéËÄåÊó†Ê≥ïÂÜçredoÂõûÂéª
    //
    [store undo];
    STAssertEquals(@"Hello, AtomStore!", [atom msg], @"");
    [atom putMsg:@"Hello, RedoRedo!"];
    [store commit];
    
    STAssertFalse([store canRedo], @"");
    STAssertEquals(@"Hello, RedoRedo!", [atom msg], @"");

    
    [pool drain];
}


-(void) testMaxSteps {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NaAtomStore* store = [NaAtomStore sharedStore];
    STAssertEquals(DEFAULT_MAX_UNDO_STEPS, [store maxSteps], @"");
    
    MyAtom* atom =  [[[MyAtom alloc] init] autorelease];
    
    [atom putMsg:@"Hello, World!"];
    [store commit];
    
    for (int i = 0; i < 20; ++i) {
        [atom putMsg:@"Hello, CAP!"];
        [store commit];
    }
    
    for (int i = 0; i < 20; ++i)
        [store undo];
    STAssertFalse([store canUndo], @"");
    STAssertEquals(@"Hello, CAP!", [atom msg], @"");
    
    [store setMaxSteps: 3];
    [store redo];
    [store redo];
    [store redo];
    [store redo];
    STAssertTrue([store canRedo], @"");

    [store undo];
    [store undo];
    [store undo];
    STAssertFalse([store canUndo], @"");
    
    [store setMaxSteps:50];
    for (int i = 0; i < 50; ++i) {
        [atom putMsg: @"Hello, CAP!"];
        [store commit];
    }
    for (int i = 0; i < 50; ++i)
        [store undo];
    STAssertFalse([store canUndo], @"");
    
    [pool drain];
}


-(void) testReset {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NaAtomStore* store = [NaAtomStore sharedStore];

    MyAtom* atom = [[MyAtom alloc] init];
    [atom putMsg:@"ABC"];
    [store commit];
    [atom putMsg:@"DEF"];
    [store commit];
    [atom putMsg:@"HIG"];
    [store commit];
    
    [store undo];
    STAssertTrue([store canRedo], @"");
    STAssertTrue([store canUndo], @"");

    [store reset];
    
    STAssertFalse([store canRedo], @"");
    STAssertFalse([store canUndo], @"");
    STAssertEquals(DEFAULT_MAX_UNDO_STEPS, [store maxSteps], @"");
    
    [pool drain];
}

-(void) testNotify {
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    NaAtomStore* store = [NaAtomStore sharedStore];
    
    MyAtom* atom = [[MyAtom alloc] init];
    
    [atom putMsg:@"ABC"];
    [store commit];
    
    [store undo];
    [store redo];
    
    STAssertEquals(0, atom.notifyCount, @"");
    
    
    [atom putMsg: @"ABC"];
    [store commit];
    [atom putMsg: @"DEF"];
    
    [store undo];
    [store redo];
    
    STAssertEquals(2, atom.notifyCount, @"");
    
    [pool drain];
}


@end
