////  TableViewScene.m//  CCTable////  Created by Sangwoo Im on 6/4/10.//  Copyright 2010 Sangwoo Im. All rights reserved.//#import "TableViewScene.h"#import "MyCell.h"#import "CCTableViewCell.h"#import "CCMultiColumnTableView.h"@implementation TableViewScene+(id)scene {    CCScene *scene;    scene = [CCScene node];    [scene addChild:[TableViewScene node]];    return scene;}-(id)init {    if ((self = [super init])) {        NSAutoreleasePool *pool;        CGSize            winSize, cSize;                pool    = [NSAutoreleasePool new];        cSize   = [MyCell cellSize];        winSize = [[CCDirector sharedDirector] winSize];         hTable  = [[CCTableView tableViewWithDataSource:self size:CGSizeMake(winSize.width, cSize.height)] retain];        vTable  = [[CCTableView tableViewWithDataSource:self size:CGSizeMake(cSize.width, winSize.height-cSize.height)] retain];        mhTable = [[CCMultiColumnTableView tableViewWithDataSource:self size:CGSizeMake(cSize.width * 3, cSize.height * 3)] retain];        mvTable = [[CCMultiColumnTableView tableViewWithDataSource:self size:CGSizeMake(cSize.width * 3, cSize.height * 3)] retain];                hTable.direction = mhTable.direction = CCScrollViewDirectionHorizontal;        vTable.direction = mvTable.direction = CCScrollViewDirectionVertical;                [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"cell.plist"];                hTable.position  = ccp(0.0, 0.0);        vTable.position  = ccp(0.0, cSize.height);        mhTable.position = ccp(cSize.width, cSize.height);        mvTable.position = ccp(cSize.width + mhTable.viewSize.width, cSize.height);        hTable.tDelegate = vTable.tDelegate = mhTable.tDelegate = mvTable.tDelegate = self;                [self addChild:hTable];        [self addChild:vTable];        [self addChild:mvTable];        [self addChild:mhTable];                [hTable reloadData];        [vTable reloadData];        [mvTable reloadData];        [mhTable reloadData];        [pool drain];    }    return self;}#pragma mark -#pragma mark TableView Delegate-(void)table:(CCTableView *)table cellTouched:(CCTableViewCell *)cell {    //CCLOG(@"cell touched at index: %i", cell.idx);}#pragma mark -#pragma mark TableView DataSource-(Class)cellClassForTable:(CCTableView *)table {    return [MyCell class];}-(CCTableViewCell *)table:(CCTableView *)table cellAtIndex:(NSUInteger)idx {    CCTableViewCell *cell;    NSString        *spriteName;    CCSprite        *sprite;        cell       = [table dequeueCell];    spriteName = [NSString stringWithFormat:@"cell%i.png", idx%10];    sprite     = [CCSprite spriteWithSpriteFrameName:spriteName];    if (!cell) {        cell = [[MyCell new] autorelease];    }    cell.node = sprite;         return cell;}-(NSUInteger)numberOfCellsInTableView:(CCTableView *)table {    return 20;}-(void) dealloc {    [hTable release];    [vTable release];    [mhTable release];    [mvTable release];    [super dealloc];    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];}@end