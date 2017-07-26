#import "GGBoard.h"

@interface GGGreedyAI : GGBoard

- (instancetype)initWithPlayer:(GGPlayerType)playerType;
- (GGPoint)getBestPoint;
- (int)getScoreWithPoint:(GGPoint)point;

@end
