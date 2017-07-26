#import "GGGreedyAI.h"
#import "GGMinimaxAI.h"

typedef NS_ENUM(NSInteger, GGDifficulty) {
    GGDifficultyEasy,
    GGDifficultyMedium,
    GGDifficultyHard
};

@interface GGPlayer : NSObject

- (instancetype)initWithPlayer:(GGPlayerType)player;
- (void)update:(GGMove *)move;
- (GGMove *)getMove;

@end
