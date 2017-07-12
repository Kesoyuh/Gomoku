#import "GGBoard.h"

@interface GGGreedyAI : GGBoard

- (instancetype)initWithPlayer:(GGPlayerType)playerType;
- (int)getScoreWithPoint:(GGPoint)point;

@end
