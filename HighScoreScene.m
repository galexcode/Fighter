//
//  HighScoreScene.m
//  Fighter
//
//  Created by Mel Gray on 8/13/10.
//  Copyright 2010 Clever Collie, LLC. All rights reserved.
//

#import "HighScoreScene.h"
#import "MenuScene.h"
#import "sqlite3.h"


@implementation HighScoreScene


+(id) scene{
	CCScene *scene = [CCScene node];
	HighScoreScene *layer = [HighScoreScene node];
	[scene addChild:layer];
	return scene;
}

-(id) init{
	
	if ((self=[super init])) {
		
		// Add some labels and background
		CCSprite* background = [CCSprite spriteWithFile:@"SpaceBackground.gif"];
		background.anchorPoint = CGPointMake(0, 0);
		[self addChild:background];
		
		CCSprite *blackBar = [CCSprite spriteWithFile:@"BlackBar.gif"];
		blackBar.position = ccp(240, 260);
		blackBar.opacity = 175;
		[self addChild:blackBar];

		CCSprite *hsLogo = [CCSprite spriteWithFile:@"HighScoresLogo.gif"];
		hsLogo.position = ccp(240, 260);
		[self addChild:hsLogo];

		CCMenuItem *backButton = [CCMenuItemImage itemFromNormalImage:@"BackButton.gif" selectedImage:@"BackButton.gif" target:self selector:@selector(goBackToMainMenu:)];
		CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
		[menu alignItemsVertically];
		menu.position = ccp(20, 20);
		
		[self addChild:menu];
		
		// Setup some globals
		databaseName = @"HighScores.sql";
		
		// Get the path to the documents directory and append the databaseName
		NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDir = [documentPaths objectAtIndex:0];
		databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
		
		// Execute the "checkAndCreateDatabase" function
		[self checkAndCreateDatabase];
		
		// Query the database for all high scores
		[self readScoresFromDatabase];
		
		/*
		CCScrollView *view = [CCScrollView scrollViewWithViewSize:CGSizeMake(200, 200)];
		CCSprite *baby = [CCSprite spriteWithFile:@"SpaceBaby.gif"];
		
		baby.position = ccp(0.0f, 0.0f);
		view.position   = ccp(50.0f, 50.0f);
		view.contentOffset = ccp(0.0f, 0.0f); // setting internal content container (CCLayer) position.
		view.contentSize = baby.contentSize;
		[view addChild:baby];
		[self addChild:view];
		
		
		NSEnumerator *enumerator = [scores objectEnumerator];
		id element;
				
		while(element = [enumerator nextObject]){
		  NSLog(@"%@", element);
		}*/
	}
	return self;
}


-(void) checkAndCreateDatabase{
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
	
	// If the database already exists then return without doing anything
	if(success) return;
	
	// If not then proceed to copy the database from the application to the users filesystem
	
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
	[fileManager release];
}

-(void) readScoresFromDatabase {
	// Setup the database object
	sqlite3 *database;
	
	// Init the animals Array
	scores = [[NSMutableArray alloc] init];
	
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
		const char *sqlStatement = "select * from scores limit 10";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				
				// Read the data from the result row
				NSString *player = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
				NSString *numberOfBabies = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];

				[scores addObject:[[NSString alloc] initWithFormat:@"%s - %d babies", player, numberOfBabies]];				
			}
		} else {
			NSLog(@"Error getting scores: %s", sqlite3_errmsg(database));
		}

		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
	
}


// FIXME: Ultra nasty
+(void)saveScore:(int)score forPlayer:(NSString *)player{
	NSLog(@"In savescore");
	
	sqlite3 *database;
	
	// Setup some globals
	NSString *databaseName = @"HighScores.sql";
	
	NSLog(@"About to save");
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString *databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		
		NSLog(@"DB Opened");
		
		// Setup the SQL Statement and compile it for faster access
		const char *sqlStatement = nil;
		sqlStatement = [[NSString stringWithFormat:@"INSERT INTO scores(player, score) VALUES ('%s',%d)", [player UTF8String], score] UTF8String];
		NSLog(@"sql: %s", sqlStatement);
		
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			CCLOG(@"Saved new score to local sqlite3 database");
		} else {
			NSLog(@"Database error was: %s", sqlite3_errmsg(database));
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	sqlite3_close(database);
};

-(void)goBackToMainMenu:(id)sender {
	[[CCDirector sharedDirector] replaceScene:[CCSlideInLTransition transitionWithDuration:0.5 scene:[MenuScene scene]]];
}


@end
