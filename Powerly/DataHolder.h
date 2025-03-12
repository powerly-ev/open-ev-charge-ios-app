#import <Foundation/Foundation.h>

@interface DataHolder : NSObject

+ (DataHolder *)sharedInstance;

@property (assign) int level;
@property (assign) int score;

-(void) saveData;
-(void) loadData;

@end