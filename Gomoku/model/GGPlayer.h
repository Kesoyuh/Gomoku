#import <Foundation/Foundation.h>
#import "GGBoard.h"

@interface GGPlayer : NSObject

- (instancetype)initWithPlayer:(GGPlayerType)player;
- (void)update:(GGMove *)move;
- (GGMove *)getMove;

@end
