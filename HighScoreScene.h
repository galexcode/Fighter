//
//  HighScoreScene.h
//  Fighter
//
//  Created by Mel Gray on 8/13/10.
//  Copyright 2010 Clever Collie, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "CCTableView.h"

@interface HighScoreScene : CCLayer <CCTableViewDataSource, CCTableViewDelegate>  {

	// Database variables
	NSString *databaseName;
	NSString *databasePath;
	
	// Array to store the animal objects
	NSMutableArray *scores;
	
}

+(id) scene;
-(id) init;

@end
