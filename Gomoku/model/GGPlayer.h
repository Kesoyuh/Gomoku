#import "GGGreedyAI.h"
#import "GGMinimaxAI.h"

typedef NS_ENUM(NSInteger, GGDifficulty) {
    GGDifficultyEasy,
    GGDifficultyMedium,
    GGDifficultyHard
};

@interface GGPlayer : NSObject

- (instancetype)initWithPlayer:(GGPlayerType)playerType difficulty:(GGDifficulty)difficulty;
- (void)update:(GGMove *)move;
- (GGMove *)getMove;

@end
