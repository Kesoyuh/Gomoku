#import "GGPlayer.h"

@interface GGPlayer ()
{
    GGBoard *_board;
    GGPlayerType _player;
}

@end

@implementation GGPlayer

- (instancetype)initWithPlayer:(GGPlayerType)player {
    self = [super init];
    
    if (self) {
        _player = player;
        _board = [[GGBoard alloc] init];
    }
    
    return self;
}

- (void)update:(GGMove *)move {
    [_board makeMove:move];
}

@end
