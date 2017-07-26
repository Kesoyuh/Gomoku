#import "GGGreedyAI.h"

@interface GGMinimaxAI : GGGreedyAI

- (instancetype)initWithPlayer:(GGPlayerType)playerType;
- (void)setDepth:(int)depth;

@end
