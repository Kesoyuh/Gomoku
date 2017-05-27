#import "GGMove.h"

@implementation GGMove

- (instancetype)initWithPlayer:(GGPlayerType)player point:(GGPoint)point {
    self = [super init];
    
    if (self) {
        _player = player;
        _point = point;
    }
    
    return self;
}

@end
