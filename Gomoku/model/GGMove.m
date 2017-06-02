#import "GGMove.h"

@implementation GGMove

- (instancetype)initWithPlayer:(GGPlayerType)playerType point:(GGPoint)point {
    self = [super init];
    
    if (self) {
        _playerType = playerType;
        _point = point;
    }
    
    return self;
}

@end
